import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_rate/features/currency/exchange_rate_api.dart';

class _FailingAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return Future.error(
      DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: 'blocked for test',
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('全API失敗時は同梱シードで JPY/CNY/RUB が出る', () async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: 100),
        receiveTimeout: const Duration(milliseconds: 100),
      ),
    )..httpClientAdapter = _FailingAdapter();

    final api = ExchangeRateApi(dio: dio);
    final snapshot = await api.fetchForCurrencies(const ['JPY', 'CNY', 'RUB']);

    expect(snapshot.isOfflineSeed, isTrue);
    expect(snapshot.sourceName, 'offline seed');
    expect(snapshot.ratesPerUsd['JPY'], greaterThan(1));
    expect(snapshot.ratesPerUsd['CNY'], greaterThan(1));
    expect(snapshot.ratesPerUsd['RUB'], greaterThan(1));
    expect(snapshot.rateDate, isNotEmpty);
  });

  test('出典名は想定した4つだけ通し、それ以外は自動に戻す', () {
    expect(normalizeRateSource(' auto '), 'auto');
    expect(normalizeRateSource('openEr'), 'openEr');
    expect(normalizeRateSource('cdn'), 'cdn');
    expect(normalizeRateSource('frankfurter'), 'frankfurter');
    expect(normalizeRateSource('https://evil.example'), 'auto');
    expect(normalizeRateSource(null), 'auto');
    expect(normalizeRateSource(''), 'auto');
  });

  test('指定した出典だけを試し、失敗時は同梱シード', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: 100),
        receiveTimeout: const Duration(milliseconds: 100),
      ),
    )..httpClientAdapter = adapter;

    final api = ExchangeRateApi(dio: dio);
    final snapshot = await api.fetchForCurrencies(const [
      'JPY',
    ], rateSource: 'frankfurter');

    expect(snapshot.isOfflineSeed, isTrue);
    expect(adapter.urls, isNotEmpty);
    expect(adapter.urls.every((url) => url.contains('frankfurter')), isTrue);
    expect(adapter.urls.any((url) => url.contains('open.er-api')), isFalse);
    expect(adapter.urls.any((url) => url.contains('jsdelivr')), isFalse);
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  final urls = <String>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    // どの出典へ通信したかだけ記録し、中身は返さない
    urls.add(options.uri.toString());
    return Future.error(
      DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: 'blocked for test',
      ),
    );
  }
}
