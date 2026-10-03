import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:map_rate/features/currency/country_geo.dart';
import 'package:map_rate/features/currency/currency_info.dart';
import 'package:map_rate/features/currency/exchange_list_models.dart';
import 'package:map_rate/features/currency/exchange_prefs.dart';
import 'package:map_rate/features/currency/exchange_rate_api.dart';
import 'package:map_rate/features/map/map_place_provider.dart';

final exchangeRateApiProvider = Provider<ExchangeRateApi>(
  (ref) => ExchangeRateApi(),
);

final exchangePrefsProvider = Provider<ExchangePrefs>(
  (ref) => ExchangePrefs(),
);

final exchangeListProvider =
    NotifierProvider<ExchangeListNotifier, ExchangeListState>(
  ExchangeListNotifier.new,
);

class ExchangeListNotifier extends Notifier<ExchangeListState> {
  late final ExchangeRateApi _api;
  late final ExchangePrefs _prefs;

  var _requestId = 0;
  Timer? _boundsDebounce;
  Timer? _baseSaveTimer;
  LatLngBounds? _lastBounds;
  CancelToken? _ratesCancel;
  Set<String> _lastFetchedCurrencies = {};

  @override
  ExchangeListState build() {
    _api = ref.watch(exchangeRateApiProvider);
    _prefs = ref.watch(exchangePrefsProvider);
    ref.onDispose(() {
      _boundsDebounce?.cancel();
      _baseSaveTimer?.cancel();
      _ratesCancel?.cancel();
      _requestId++;
    });
    // 保存済みの順番・固定・金額を読み、可能ならキャッシュレートも戻す
    Future.microtask(_loadPrefs);
    return const ExchangeListState(isLoading: true);
  }

  Future<void> _loadPrefs() async {
    final order = await _prefs.loadOrder();
    final pinned = await _prefs.loadPinned();
    final baseCountry = await _prefs.loadBaseCountry() ?? 'JP';
    final baseAmount = await _prefs.loadBaseAmount();
    final cached = await _prefs.loadSnapshot();
    if (!ref.mounted) return;

    var next = state.copyWith(
      order: order,
      pinned: pinned,
      baseCountryCode: baseCountry,
      baseAmount: baseAmount,
      isLoading: cached == null,
      clearError: true,
    );
    if (cached != null) {
      next = next.copyWith(
        ratesPerUsd: cached.ratesPerUsd,
        historyPerUsd: cached.historyPerUsd,
        rateDate: cached.rateDate,
        fetchedAt: cached.fetchedAt,
        sourceName: cached.sourceName,
        isLoading: false,
      );
    }
    state = _rebuildRows(next);

    // 地図の中心国が分かっていれば、可視化に含める
    final place = ref.read(mapPlaceProvider);
    if (_lastBounds != null) {
      await setVisibleBounds(_lastBounds!, centerCountryCode: place.countryCode);
    } else if (place.countryCode != null) {
      await setVisibleCountries({place.countryCode!});
    } else {
      await refreshRates();
    }
  }

  /// 地図の表示範囲が変わったときに呼ぶ（デバウンス付き）。
  void onMapBoundsChanged(
    LatLngBounds bounds, {
    String? centerCountryCode,
    double? focusLat,
    double? focusLng,
  }) {
    _lastBounds = bounds;
    _boundsDebounce?.cancel();
    _boundsDebounce = Timer(const Duration(milliseconds: 500), () {
      unawaited(
        setVisibleBounds(
          bounds,
          centerCountryCode: centerCountryCode,
          focusLat: focusLat,
          focusLng: focusLng,
        ),
      );
    });
  }

  /// 十字下の国が分かったときに呼ぶ（固定の次へ）。
  void setFocusCountry(String? countryCode) {
    final code = normalizeCountryCode(countryCode);
    if (code == state.focusCountryCode) return;
    if (code != null && currencyForCountryCode(code) == null) return;
    final visible = {...state.visibleCountryCodes};
    if (code != null) visible.add(code);
    state = _rebuildRows(
      state.copyWith(
        visibleCountryCodes: visible,
        focusCountryCode: code,
        clearFocusCountry: code == null,
      ),
    );
  }

  Future<void> setVisibleBounds(
    LatLngBounds bounds, {
    String? centerCountryCode,
    double? focusLat,
    double? focusLng,
  }) async {
    // 照準の緯度経度を優先。無いときだけ表示範囲の幾何中心を使う
    final centerLat = focusLat ?? (bounds.north + bounds.south) / 2;
    final centerLng = focusLng ?? (bounds.east + bounds.west) / 2;
    final codes = visibleCountryCodes(
      view: bounds,
      extraCountryCodes: [
        ?centerCountryCode,
      ],
    );
    await setVisibleCountries(
      codes,
      mapCenterLat: centerLat,
      mapCenterLng: centerLng,
      focusCountryCode: centerCountryCode,
    );
  }

  Future<void> setVisibleCountries(
    Set<String> codes, {
    double? mapCenterLat,
    double? mapCenterLng,
    String? focusCountryCode,
  }) async {
    final normalized = <String>{};
    for (final raw in codes) {
      final code = normalizeCountryCode(raw);
      if (code != null && currencyForCountryCode(code) != null) {
        normalized.add(code);
      }
    }
    final focus = normalizeCountryCode(focusCountryCode);
    if (focus != null && currencyForCountryCode(focus) != null) {
      normalized.add(focus);
    }
    // 固定国は地図外でも残す
    final eligible = {...normalized, ...state.pinned};
    final next = _rebuildRows(
      state.copyWith(
        visibleCountryCodes: normalized,
        mapCenterLat: mapCenterLat ?? state.mapCenterLat,
        mapCenterLng: mapCenterLng ?? state.mapCenterLng,
        focusCountryCode: focus ?? state.focusCountryCode,
      ),
      eligibleOverride: eligible,
    );
    state = next;

    final currencies = <String>{};
    for (final code in eligible) {
      final currency = currencyForCountryCode(code);
      if (currency != null) currencies.add(currency.code);
    }
    currencies.add('USD');

    // 同じ通貨セットで、すでにレートがあるなら取り直さない（地図操作の連打対策）
    final sameSet = currencies.length == _lastFetchedCurrencies.length &&
        currencies.every(_lastFetchedCurrencies.contains);
    if (sameSet && state.ratesPerUsd.length > 1 && state.errorKey == null) {
      return;
    }
    await refreshRates();
  }

  Future<void> refreshRates() async {
    final eligible = _eligibleCountries(state);
    if (eligible.isEmpty) {
      state = state.copyWith(
        rows: const [],
        isLoading: false,
        clearError: true,
      );
      return;
    }

    final currencies = <String>{};
    for (final code in eligible) {
      final currency = currencyForCountryCode(code);
      if (currency != null) currencies.add(currency.code);
    }
    currencies.add('USD');

    final requestId = ++_requestId;
    // 進行中の通信はキャンセルせず、古い結果だけ捨てる（途中切断で失敗扱いになるのを防ぐ）
    final cancelToken = CancelToken();
    _ratesCancel = cancelToken;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final snapshot = await _api.fetchForCurrencies(
        currencies,
        cancelToken: cancelToken,
      );
      if (!ref.mounted || requestId != _requestId) return;

      _lastFetchedCurrencies = Set<String>.from(currencies);

      // 既存レートにマージ（取得できなかった通貨は古い値を残す）
      final mergedRates = Map<String, double>.from(state.ratesPerUsd)
        ..addAll(snapshot.ratesPerUsd);
      final mergedHistory = Map<String, List<double>>.from(state.historyPerUsd)
        ..addAll(snapshot.historyPerUsd);

      // 先に画面へ反映する（保存失敗で金額が出ない事故を防ぐ）
      state = _rebuildRows(
        state.copyWith(
          ratesPerUsd: mergedRates,
          historyPerUsd: mergedHistory,
          rateDate: snapshot.rateDate,
          fetchedAt: snapshot.fetchedAt,
          sourceName: snapshot.sourceName,
          isLoading: false,
          errorKey: snapshot.isOfflineSeed ? 'ratesLoadFailed' : null,
          clearError: !snapshot.isOfflineSeed,
        ),
      );

      try {
        await _prefs.saveSnapshot(snapshot);
      } catch (_) {
        // 表示は維持する。次回オンライン時にまた保存を試みる
      }
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return;
      if (!ref.mounted || requestId != _requestId) return;
      // 失敗しても直前のレートは残して表示を続ける
      state = _rebuildRows(
        state.copyWith(
          isLoading: false,
          errorKey: state.ratesPerUsd.length > 1 ? null : 'ratesLoadFailed',
        ),
      );
    } catch (_) {
      if (!ref.mounted || requestId != _requestId) return;
      state = _rebuildRows(
        state.copyWith(
          isLoading: false,
          errorKey: state.ratesPerUsd.length > 1 ? null : 'ratesLoadFailed',
        ),
      );
    }
  }

  Future<void> togglePinned(String countryCode) async {
    final code = normalizeCountryCode(countryCode);
    if (code == null) return;
    final pinned = List<String>.from(state.pinned);
    if (pinned.contains(code)) {
      pinned.remove(code);
    } else {
      pinned.add(code);
    }
    await _prefs.savePinned(pinned);
    if (!ref.mounted) return;
    state = _rebuildRows(state.copyWith(pinned: pinned));
    // 地図外の固定国はレート未取得のことがあるので、足りなければ取りに行く
    final currency = currencyForCountryCode(code);
    if (currency != null && !state.ratesPerUsd.containsKey(currency.code)) {
      await refreshRates();
    }
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;
    final display = state.rows.map((r) => r.countryCode).toList();
    if (oldIndex < 0 ||
        oldIndex >= display.length ||
        newIndex < 0 ||
        newIndex >= display.length) {
      return;
    }

    final pinnedSet = state.pinned.toSet();
    final newPinned = pinnedAfterReorder(
      displayCodes: display,
      oldIndex: oldIndex,
      newIndex: newIndex,
      pinned: state.pinned,
    );
    final newOrder = orderAfterReorder(
      displayCodes: display,
      oldIndex: oldIndex,
      newIndex: newIndex,
      pinnedSet: pinnedSet,
    );

    await _prefs.savePinned(newPinned);
    await _prefs.saveOrder(newOrder);
    if (!ref.mounted) return;
    state = _rebuildRows(
      state.copyWith(pinned: newPinned, order: newOrder),
    );
  }

  /// ある国の金額を入力したとき、それを基準に他国（固定含む）を換算し直す。
  Future<void> setAmountForCountry({
    required String countryCode,
    required double amount,
  }) async {
    final code = normalizeCountryCode(countryCode);
    if (code == null) return;
    if (!amount.isFinite || amount < 0 || amount > 1e12) return;

    // 保存より先に画面を更新する（入力のたびに固定国もすぐ換算される）
    state = _rebuildRows(
      state.copyWith(baseCountryCode: code, baseAmount: amount),
    );

    // 連打・キー入力では保存をまとめる
    _baseSaveTimer?.cancel();
    _baseSaveTimer = Timer(const Duration(milliseconds: 350), () async {
      try {
        await _prefs.saveBaseCountry(code);
        await _prefs.saveBaseAmount(amount);
      } catch (_) {
        // 表示は維持。次回入力時にまた保存を試みる
      }
    });
  }

  Set<String> _eligibleCountries(ExchangeListState s) {
    return {...s.visibleCountryCodes, ...s.pinned};
  }

  ExchangeListState _rebuildRows(
    ExchangeListState s, {
    Set<String>? eligibleOverride,
  }) {
    final eligible = eligibleOverride ?? _eligibleCountries(s);
    Map<String, double>? distanceScores;
    final lat = s.mapCenterLat;
    final lng = s.mapCenterLng;
    if (lat != null && lng != null) {
      distanceScores = <String, double>{};
      for (final code in eligible) {
        final score = distanceScoreForCountry(
          countryCode: code,
          centerLat: lat,
          centerLng: lng,
        );
        if (score != null) distanceScores[code] = score;
      }
    }
    final displayCodes = buildDisplayOrder(
      eligible: eligible,
      pinned: s.pinned,
      order: s.order,
      distanceScores: distanceScores,
      focusCountryCode: s.focusCountryCode,
    );
    final pinnedSet = s.pinned.toSet();
    final baseCurrency = currencyForCountryCode(s.baseCountryCode)?.code;

    final rows = <ExchangeRow>[];
    for (final countryCode in displayCodes) {
      final currency = currencyForCountryCode(countryCode);
      if (currency == null) continue;
      final hasRate = s.ratesPerUsd.containsKey(currency.code);
      double amount = 0;
      if (hasRate && baseCurrency != null) {
        amount = convertViaUsd(
              fromAmount: s.baseAmount,
              fromCurrency: baseCurrency,
              toCurrency: currency.code,
              ratesPerUsd: s.ratesPerUsd,
            ) ??
            0;
      } else if (hasRate && currency.code == 'USD') {
        amount = s.baseAmount;
      }
      rows.add(
        ExchangeRow(
          countryCode: countryCode,
          currency: currency,
          amount: amount,
          history: s.historyPerUsd[currency.code] ?? const [],
          isPinned: pinnedSet.contains(countryCode),
          hasRate: hasRate,
          // 手入力した基準の国をハイライトする
          isBaseInput: countryCode == s.baseCountryCode,
        ),
      );
    }

    return s.copyWith(rows: rows);
  }
}
