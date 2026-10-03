import 'package:map_rate/features/currency/currency_info.dart';

/// 為替リストの1行分。
class ExchangeRow {
  const ExchangeRow({
    required this.countryCode,
    required this.currency,
    required this.amount,
    required this.history,
    required this.isPinned,
    required this.hasRate,
    this.isBaseInput = false,
  });

  final String countryCode;
  final CurrencyInfo currency;

  /// いまの換算金額（ベース金額とレートから計算）。
  final double amount;

  /// スパークライン用の履歴（USD建てレート）。空ならグラフなし。
  final List<double> history;

  final bool isPinned;

  /// Frankfurter にその通貨が無く、換算できないとき false。
  final bool hasRate;

  /// ユーザーが手入力した基準金額の行なら true。
  final bool isBaseInput;

  String get flagEmoji => flagEmojiFromCountryCode(countryCode) ?? '🌐';
}

/// 画面下の為替リスト全体の状態。
class ExchangeListState {
  const ExchangeListState({
    this.rows = const [],
    this.visibleCountryCodes = const {},
    this.order = const [],
    this.pinned = const [],
    this.baseCountryCode = 'JP',
    this.baseAmount = 100,
    this.ratesPerUsd = const {'USD': 1.0},
    this.historyPerUsd = const {},
    this.rateDate,
    this.fetchedAt,
    this.sourceName = 'Frankfurter',
    this.isLoading = false,
    this.errorKey,
    this.mapCenterLat,
    this.mapCenterLng,
    this.focusCountryCode,
  });

  final List<ExchangeRow> rows;
  final Set<String> visibleCountryCodes;
  final List<String> order;
  final List<String> pinned;
  final String baseCountryCode;
  final double baseAmount;
  final Map<String, double> ratesPerUsd;
  final Map<String, List<double>> historyPerUsd;
  final String? rateDate;
  final DateTime? fetchedAt;
  final String sourceName;
  final bool isLoading;

  /// l10n のキー名。null ならエラーなし。
  final String? errorKey;

  /// 十字（照準）の緯度経度。距離ソートの基準。
  final double? mapCenterLat;
  final double? mapCenterLng;

  /// 十字の下にある国。リスト先頭に出す。
  final String? focusCountryCode;

  ExchangeListState copyWith({
    List<ExchangeRow>? rows,
    Set<String>? visibleCountryCodes,
    List<String>? order,
    List<String>? pinned,
    String? baseCountryCode,
    double? baseAmount,
    Map<String, double>? ratesPerUsd,
    Map<String, List<double>>? historyPerUsd,
    String? rateDate,
    DateTime? fetchedAt,
    String? sourceName,
    bool? isLoading,
    String? errorKey,
    bool clearError = false,
    bool clearRateDate = false,
    bool clearFetchedAt = false,
    double? mapCenterLat,
    double? mapCenterLng,
    bool clearMapCenter = false,
    String? focusCountryCode,
    bool clearFocusCountry = false,
  }) {
    return ExchangeListState(
      rows: rows ?? this.rows,
      visibleCountryCodes: visibleCountryCodes ?? this.visibleCountryCodes,
      order: order ?? this.order,
      pinned: pinned ?? this.pinned,
      baseCountryCode: baseCountryCode ?? this.baseCountryCode,
      baseAmount: baseAmount ?? this.baseAmount,
      ratesPerUsd: ratesPerUsd ?? this.ratesPerUsd,
      historyPerUsd: historyPerUsd ?? this.historyPerUsd,
      rateDate: clearRateDate ? null : (rateDate ?? this.rateDate),
      fetchedAt: clearFetchedAt ? null : (fetchedAt ?? this.fetchedAt),
      sourceName: sourceName ?? this.sourceName,
      isLoading: isLoading ?? this.isLoading,
      errorKey: clearError ? null : (errorKey ?? this.errorKey),
      mapCenterLat:
          clearMapCenter ? null : (mapCenterLat ?? this.mapCenterLat),
      mapCenterLng:
          clearMapCenter ? null : (mapCenterLng ?? this.mapCenterLng),
      focusCountryCode: clearFocusCountry
          ? null
          : (focusCountryCode ?? this.focusCountryCode),
    );
  }
}

/// [fromAmount] を [fromCurrency] から [toCurrency] へ、USD 経由で換算する。
double? convertViaUsd({
  required double fromAmount,
  required String fromCurrency,
  required String toCurrency,
  required Map<String, double> ratesPerUsd,
}) {
  if (!fromAmount.isFinite || fromAmount < 0) return null;
  final from = fromCurrency.trim().toUpperCase();
  final to = toCurrency.trim().toUpperCase();
  if (!RegExp(r'^[A-Z]{3}$').hasMatch(from)) return null;
  if (!RegExp(r'^[A-Z]{3}$').hasMatch(to)) return null;

  final fromRate = ratesPerUsd[from];
  final toRate = ratesPerUsd[to];
  if (fromRate == null || toRate == null) return null;
  if (!fromRate.isFinite || !toRate.isFinite || fromRate <= 0 || toRate <= 0) {
    return null;
  }
  // from → USD → to
  return fromAmount / fromRate * toRate;
}

/// 表示対象の国コードを並べる。
///
/// 1. 固定国（[pinned] の順）
/// 2. 十字下の国（[focusCountryCode]。固定と重複は除く）
/// 3. それ以外は十字位置に近い順（[distanceScores] が小さいほど上）
/// 4. 距離が同じ／無いときは [order]、最後に国コード
List<String> buildDisplayOrder({
  required Set<String> eligible,
  required List<String> pinned,
  required List<String> order,
  Map<String, double>? distanceScores,
  String? focusCountryCode,
}) {
  final result = <String>[];
  final seen = <String>{};

  for (final code in pinned) {
    if (!eligible.contains(code) || seen.contains(code)) continue;
    seen.add(code);
    result.add(code);
  }

  final focus = normalizeCountryCode(focusCountryCode);
  if (focus != null && eligible.contains(focus) && !seen.contains(focus)) {
    seen.add(focus);
    result.add(focus);
  }

  final rest = eligible.where((c) => !seen.contains(c)).toList();
  final orderIndex = <String, int>{
    for (var i = 0; i < order.length; i++) order[i]: i,
  };
  rest.sort((a, b) {
    final da = distanceScores?[a] ?? double.infinity;
    final db = distanceScores?[b] ?? double.infinity;
    final byDistance = da.compareTo(db);
    if (byDistance != 0) return byDistance;
    final oa = orderIndex[a] ?? 1 << 20;
    final ob = orderIndex[b] ?? 1 << 20;
    final byOrder = oa.compareTo(ob);
    if (byOrder != 0) return byOrder;
    return a.compareTo(b);
  });
  result.addAll(rest);
  return result;
}

/// 並び替え後の [order] を、固定国を除いて作る。
///
/// [newIndex] は Flutter の onReorderItem が渡す「取り出したあとの挿入位置」。
List<String> orderAfterReorder({
  required List<String> displayCodes,
  required int oldIndex,
  required int newIndex,
  required Set<String> pinnedSet,
}) {
  if (oldIndex < 0 ||
      oldIndex >= displayCodes.length ||
      newIndex < 0 ||
      newIndex >= displayCodes.length) {
    return displayCodes.where((c) => !pinnedSet.contains(c)).toList();
  }

  final next = List<String>.from(displayCodes);
  final item = next.removeAt(oldIndex);
  next.insert(newIndex, item);
  return next.where((c) => !pinnedSet.contains(c)).toList();
}

/// 固定同士の並びも変えたあとの pinned リスト。
///
/// [newIndex] は Flutter の onReorderItem が渡す「取り出したあとの挿入位置」。
List<String> pinnedAfterReorder({
  required List<String> displayCodes,
  required int oldIndex,
  required int newIndex,
  required List<String> pinned,
}) {
  final pinnedSet = pinned.toSet();
  if (oldIndex < 0 ||
      oldIndex >= displayCodes.length ||
      newIndex < 0 ||
      newIndex >= displayCodes.length) {
    return List<String>.from(pinned);
  }
  final nextDisplay = List<String>.from(displayCodes);
  final moving = nextDisplay.removeAt(oldIndex);
  nextDisplay.insert(newIndex, moving);
  return nextDisplay.where(pinnedSet.contains).toList();
}
