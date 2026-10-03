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
}
