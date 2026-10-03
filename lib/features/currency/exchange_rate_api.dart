import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 1 USD あたりの為替と、履歴・更新情報。
class ExchangeRateSnapshot {
  const ExchangeRateSnapshot({
    required this.ratesPerUsd,
    required this.historyPerUsd,
    required this.rateDate,
    required this.fetchedAt,
    required this.sourceName,
    this.isOfflineSeed = false,
  });

  /// 通貨コード → 1 USD で買えるその通貨の量。USD 自身は 1.0。
  final Map<String, double> ratesPerUsd;

  /// 通貨コード → 直近の日次レート（古い→新しい）。スパークライン用。
  final Map<String, List<double>> historyPerUsd;

  /// API が示したレートの基準日（YYYY-MM-DD）。
  final String rateDate;

  /// 端末が取得を終えた時刻。
  final DateTime fetchedAt;

  /// 画面の出典説明で出す短い名前。
  final String sourceName;

  /// アプリ同梱の仮レートを使っているとき true。
  final bool isOfflineSeed;
}

/// 複数の無料ソースから中値レートを取る（届くものを使う）。
class ExchangeRateApi {
  ExchangeRateApi({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
                // 一部のフィルタは独自 User-Agent を弾くので、Accept だけにする
                headers: const {'Accept': 'application/json'},
                followRedirects: true,
                validateStatus: (code) => code != null && code >= 200 && code < 400,
              ),
            );

  final Dio _dio;

  /// Frankfurter 履歴用。最新取得では使わない（対応通貨が少ないため）。
  static const frankfurterQuotes = <String>{
    'AUD', 'BRL', 'CAD', 'CHF', 'CNY', 'CZK', 'DKK', 'EUR', 'GBP', 'HKD',
    'HUF', 'IDR', 'ILS', 'INR', 'ISK', 'JPY', 'KRW', 'MXN', 'MYR', 'NOK',
    'NZD', 'PHP', 'PLN', 'RON', 'SEK', 'SGD', 'THB', 'TRY', 'USD', 'ZAR',
  };

  /// [currencyCodes] は ISO 4217。
  Future<ExchangeRateSnapshot> fetchForCurrencies(
    Iterable<String> currencyCodes, {
    CancelToken? cancelToken,
  }) async {
    final wanted = <String>{};
    for (final raw in currencyCodes) {
      final code = raw.trim().toUpperCase();
      if (RegExp(r'^[A-Z]{3}$').hasMatch(code)) {
        wanted.add(code);
      }
    }
    wanted.add('USD');

    final ratesPerUsd = <String, double>{'USD': 1.0};
    final historyPerUsd = <String, List<double>>{'USD': const [1.0]};
    var rateDate = _todayUtc();
    var sourceName = 'ExchangeRate-API';
    var isOfflineSeed = false;

    Object? lastError;
    final sources = <Future<({String date, Map<String, double> rates, String name})> Function()>[
      () => _fetchOpenErLatest(cancelToken),
      () => _fetchCurrencyApiCdn(cancelToken),
      () => _fetchFrankfurterLatest(
            wanted.where((c) => c != 'USD' && frankfurterQuotes.contains(c)).toSet(),
            cancelToken,
          ),
    ];

    var gotLatest = false;
    for (final source in sources) {
      try {
        final latest = await source();
        var nonUsdHit = 0;
        for (final code in wanted) {
          if (code == 'USD') continue;
          final value = latest.rates[code];
          if (value != null) {
            ratesPerUsd[code] = value;
            nonUsdHit++;
          }
        }
        // USD しか取れない応答は成功扱いにしない（シードへ進める）
        if (nonUsdHit > 0 ||
            latest.rates.keys.where((k) => k != 'USD').length > 1) {
          ratesPerUsd.addAll(latest.rates);
          ratesPerUsd['USD'] = 1.0;
          rateDate = latest.date;
          sourceName = latest.name;
          gotLatest = true;
          break;
        }
      } catch (error) {
        lastError = error;
        if (error is DioException && CancelToken.isCancel(error)) {
          rethrow;
        }
        debugPrint('MapRate rate source failed: $error');
      }
    }

    if (!gotLatest) {
      // VPN / 広告ブロックで全APIが届かないときでも、金額欄を空にしない
      try {
        final seed = await _loadSeedRates();
        ratesPerUsd
          ..clear()
          ..addAll(seed.rates);
        ratesPerUsd['USD'] = 1.0;
        rateDate = seed.date;
        sourceName = seed.name;
        isOfflineSeed = true;
        gotLatest = true;
      } catch (error) {
        debugPrint('MapRate seed rates failed: $error');
        throw lastError ?? error;
      }
    }

    final historyQuotes = wanted
        .where((c) => c != 'USD' && frankfurterQuotes.contains(c))
        .toSet();
    if (!isOfflineSeed && historyQuotes.isNotEmpty) {
      try {
        final history = await _fetchFrankfurterHistory(
          historyQuotes,
          rateDate,
          cancelToken,
        );
        historyPerUsd.addAll(history);
      } catch (error) {
        if (error is DioException && CancelToken.isCancel(error)) {
          rethrow;
        }
        // 履歴だけ失敗しても金額表示は続ける
      }
    }

    for (final entry in ratesPerUsd.entries) {
      // List<double> を明示しないと List<dynamic> になり、unmodifiable で落ちる
      historyPerUsd.putIfAbsent(entry.key, () => <double>[entry.value]);
    }

    // 型を明示して、Map.unmodifiable のキャスト失敗を防ぐ
    final safeHistory = <String, List<double>>{
      for (final entry in historyPerUsd.entries)
        entry.key: List<double>.from(entry.value),
    };

    return ExchangeRateSnapshot(
      ratesPerUsd: Map<String, double>.unmodifiable(
        Map<String, double>.from(ratesPerUsd),
      ),
      historyPerUsd: Map<String, List<double>>.unmodifiable(
        {
          for (final entry in safeHistory.entries)
            entry.key: List<double>.unmodifiable(entry.value),
        },
      ),
      rateDate: rateDate,
      fetchedAt: DateTime.now().toUtc(),
      sourceName: sourceName,
      isOfflineSeed: isOfflineSeed,
    );
  }

  /// アプリ同梱の JSON から仮レートを読む。
  Future<({String date, Map<String, double> rates, String name})>
      _loadSeedRates() async {
    final raw = await rootBundle.loadString('assets/rates_seed.json');
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw StateError('invalid seed rates json');
    }
    final date = _dateFromOpenEr(decoded['time_last_update_utc']?.toString()) ??
        _todayUtc();
    final rates = _parseFlatRates(decoded['rates']);
    rates['USD'] = 1.0;
    if (rates.length <= 1) {
      throw StateError('empty seed rates');
    }
    return (date: date, rates: rates, name: 'offline seed');
  }

  Future<({String date, Map<String, double> rates, String name})>
      _fetchOpenErLatest(CancelToken? cancelToken) async {
    final response = await _dio.get<dynamic>(
      'https://open.er-api.com/v6/latest/USD',
      cancelToken: cancelToken,
    );
    final data = response.data;
    if (data is! Map) {
      throw StateError('unexpected open.er-api payload');
    }
    if (data['result']?.toString() != 'success') {
      throw StateError('open.er-api result=${data['result']}');
    }
    final date = _dateFromOpenEr(data['time_last_update_utc']?.toString()) ??
        _todayUtc();
    final rates = _parseFlatRates(data['rates']);
    if (rates.isEmpty) throw StateError('empty open.er-api rates');
    return (date: date, rates: rates, name: 'ExchangeRate-API');
  }

  /// CDN 経由の日次レート（フィルタに弾かれにくい）。
  Future<({String date, Map<String, double> rates, String name})>
      _fetchCurrencyApiCdn(CancelToken? cancelToken) async {
    final urls = [
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.min.json',
      'https://latest.currency-api.pages.dev/v1/currencies/usd.min.json',
    ];
    Object? lastError;
    for (final url in urls) {
      try {
        final response = await _dio.get<dynamic>(url, cancelToken: cancelToken);
        final data = response.data;
        if (data is! Map) continue;
        final date = data['date']?.toString() ?? _todayUtc();
        final usd = data['usd'];
        if (usd is! Map) continue;
        final rates = <String, double>{'USD': 1.0};
        for (final entry in usd.entries) {
          final code = entry.key.toString().toUpperCase();
          final value = entry.value;
          if (!RegExp(r'^[A-Z]{3}$').hasMatch(code)) continue;
          if (value is! num || !value.isFinite || value <= 0) continue;
          rates[code] = value.toDouble();
        }
        if (rates.length <= 1) continue;
        final safeDate =
            RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date) ? date : _todayUtc();
        return (
          date: safeDate,
          rates: rates,
          name: 'currency-api',
        );
      } catch (error) {
        lastError = error;
        if (error is DioException && CancelToken.isCancel(error)) {
          rethrow;
        }
      }
    }
    throw lastError ?? StateError('currency-api CDN failed');
  }

  Future<({String date, Map<String, double> rates, String name})>
      _fetchFrankfurterLatest(
    Set<String> quotes,
    CancelToken? cancelToken,
  ) async {
    if (quotes.isEmpty) {
      return (
        date: _todayUtc(),
        rates: const {'USD': 1.0},
        name: 'Frankfurter',
      );
    }
    final response = await _dio.get<dynamic>(
      'https://api.frankfurter.dev/v1/latest',
      queryParameters: {
        'from': 'USD',
        'to': quotes.join(','),
      },
      cancelToken: cancelToken,
    );
    final data = response.data;
    if (data is! Map) {
      throw StateError('unexpected frankfurter latest payload');
    }
    final date = data['date']?.toString() ?? _todayUtc();
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
      throw StateError('invalid frankfurter date');
    }
    final rates = _parseFlatRates(data['rates']);
    rates['USD'] = 1.0;
    if (rates.length <= 1) {
      throw StateError('empty frankfurter rates');
    }
    return (date: date, rates: rates, name: 'Frankfurter');
  }

  Future<Map<String, List<double>>> _fetchFrankfurterHistory(
    Set<String> quotes,
    String toDate,
    CancelToken? cancelToken,
  ) async {
    final from = _daysAgoUtc(30);
    final response = await _dio.get<dynamic>(
      'https://api.frankfurter.dev/v1/$from..$toDate',
      queryParameters: {
        'from': 'USD',
        'to': quotes.join(','),
      },
      cancelToken: cancelToken,
    );
    final data = response.data;
    if (data is! Map) return {};
    final ratesRoot = data['rates'];
    if (ratesRoot is! Map) return {};

    final byCode = <String, List<({String date, double rate})>>{};
    for (final dayEntry in ratesRoot.entries) {
      final date = dayEntry.key.toString();
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) continue;
      final dayRates = dayEntry.value;
      if (dayRates is! Map) continue;
      for (final rateEntry in dayRates.entries) {
        final code = rateEntry.key.toString().toUpperCase();
        final value = rateEntry.value;
        if (!RegExp(r'^[A-Z]{3}$').hasMatch(code)) continue;
        if (value is! num || !value.isFinite || value <= 0) continue;
        byCode
            .putIfAbsent(code, () => <({String date, double rate})>[])
            .add((date: date, rate: value.toDouble()));
      }
    }

    final out = <String, List<double>>{};
    for (final entry in byCode.entries) {
      final sorted = entry.value.toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      out[entry.key] = [for (final item in sorted) item.rate];
    }
    return out;
  }

  Map<String, double> _parseFlatRates(Object? ratesRaw) {
    final rates = <String, double>{};
    if (ratesRaw is! Map) return rates;
    for (final entry in ratesRaw.entries) {
      final code = entry.key.toString().toUpperCase();
      final value = entry.value;
      if (!RegExp(r'^[A-Z]{3}$').hasMatch(code)) continue;
      if (value is! num || !value.isFinite || value <= 0) continue;
      rates[code] = value.toDouble();
    }
    return rates;
  }

  String? _dateFromOpenEr(String? utcText) {
    if (utcText == null || utcText.isEmpty) return null;
    final parsed = DateTime.tryParse(utcText);
    if (parsed != null) return _formatDate(parsed.toUtc());
    return null;
  }

  String _todayUtc() => _formatDate(DateTime.now().toUtc());

  String _daysAgoUtc(int days) =>
      _formatDate(DateTime.now().toUtc().subtract(Duration(days: days)));

  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}
