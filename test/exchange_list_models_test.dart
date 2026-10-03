import 'package:flutter_test/flutter_test.dart';
import 'package:map_rate/features/currency/exchange_list_models.dart';

void main() {
  test('USD 経由の換算', () {
    final rates = {
      'USD': 1.0,
      'JPY': 150.0,
      'EUR': 0.9,
    };
    expect(
      convertViaUsd(
        fromAmount: 1500,
        fromCurrency: 'JPY',
        toCurrency: 'USD',
        ratesPerUsd: rates,
      ),
      closeTo(10, 1e-9),
    );
    expect(
      convertViaUsd(
        fromAmount: 1500,
        fromCurrency: 'JPY',
        toCurrency: 'EUR',
        ratesPerUsd: rates,
      ),
      closeTo(9, 1e-9),
    );
    expect(
      convertViaUsd(
        fromAmount: 10,
        fromCurrency: 'usd',
        toCurrency: 'jpy',
        ratesPerUsd: rates,
      ),
      closeTo(1500, 1e-9),
    );
  });

  test('不正な換算は null', () {
    expect(
      convertViaUsd(
        fromAmount: -1,
        fromCurrency: 'USD',
        toCurrency: 'JPY',
        ratesPerUsd: const {'USD': 1, 'JPY': 150},
      ),
      isNull,
    );
    expect(
      convertViaUsd(
        fromAmount: 10,
        fromCurrency: 'USD',
        toCurrency: 'THB',
        ratesPerUsd: const {'USD': 1, 'JPY': 150},
      ),
      isNull,
    );
  });

  test('表示順は固定→十字下→距離順', () {
    final order = buildDisplayOrder(
      eligible: {'JP', 'US', 'TH', 'KR'},
      pinned: ['TH', 'US'],
      order: ['KR', 'JP'],
      focusCountryCode: 'JP',
    );
    // 固定 TH, US → 十字下 JP → 残り KR
    expect(order, ['TH', 'US', 'JP', 'KR']);
  });

  test('固定以外は地図中心に近い順', () {
    final order = buildDisplayOrder(
      eligible: {'JP', 'US', 'KR'},
      pinned: const [],
      order: const [],
      distanceScores: {'US': 10, 'KR': 2, 'JP': 1},
    );
    expect(order, ['JP', 'KR', 'US']);
  });

  test('十字下の国は固定の次', () {
    final order = buildDisplayOrder(
      eligible: {'CN', 'JP', 'KR'},
      pinned: ['JP'],
      order: const [],
      focusCountryCode: 'CN',
      distanceScores: {'CN': 5, 'JP': 1, 'KR': 2},
    );
    expect(order, ['JP', 'CN', 'KR']);
  });

  test('並び替え後の order は固定を除く', () {
    final display = ['JP', 'US', 'TH'];
    // onReorderItem 形式: TH(2) を US の位置(1)へ → 挿入位置はすでに調整済み
    final order = orderAfterReorder(
      displayCodes: display,
      oldIndex: 2,
      newIndex: 1,
      pinnedSet: {'JP'},
    );
    // JP 固定、TH を US の前へ → 表示は JP, TH, US。order は TH, US
    expect(order, ['TH', 'US']);
  });
}
