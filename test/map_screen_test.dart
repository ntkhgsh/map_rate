import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_rate/app.dart';
import 'package:map_rate/features/currency/exchange_list_provider.dart';
import 'package:map_rate/features/currency/exchange_rate_api.dart';
import 'package:map_rate/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// テスト用。通信せず、固定レートをすぐ返す。
class _FakeExchangeRateApi extends ExchangeRateApi {
  @override
  Future<ExchangeRateSnapshot> fetchForCurrencies(
    Iterable<String> currencyCodes, {
    CancelToken? cancelToken,
  }) async {
    return ExchangeRateSnapshot(
      ratesPerUsd: const {
        'USD': 1.0,
        'JPY': 150.0,
        'EUR': 0.9,
        'CNY': 7.2,
        'KRW': 1350.0,
      },
      historyPerUsd: const {
        'USD': [1.0, 1.0],
        'JPY': [148.0, 149.0, 150.0],
        'EUR': [0.88, 0.89, 0.9],
        'CNY': [7.1, 7.15, 7.2],
        'KRW': [1340.0, 1345.0, 1350.0],
      },
      rateDate: '2026-09-30',
      fetchedAt: DateTime.utc(2026, 9, 30, 12),
      sourceName: 'Frankfurter',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ProviderScope mapApp({required Locale locale}) {
    return ProviderScope(
      overrides: [
        exchangeRateApiProvider.overrideWithValue(_FakeExchangeRateApi()),
      ],
      child: MapRateApp(locale: locale),
    );
  }

  testWidgets('地図画面にタイトルと為替パネルが出る', (tester) async {
    await tester.pumpWidget(mapApp(locale: const Locale('ja')));

    // タイトルは為替パネル見出し側に表示（上部ブランドバーは無し）
    expect(find.text('MapRate'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    // テスト環境ではジオコーダーが無いので、失敗メッセージかヒントが出る
    expect(
      find.textContaining('国'),
      findsWidgets,
    );
  });

  testWidgets('英語ロケールで文言が切り替わる', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(l10n.exchangeListTitle, 'Exchange rates on map');
    expect(l10n.dataSourceTitle, 'About exchange data');
    expect(l10n.retry, 'Retry');
  });
}
