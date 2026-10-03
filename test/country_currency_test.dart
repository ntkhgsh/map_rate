import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:map_rate/features/currency/currency_info.dart';
import 'package:map_rate/features/currency/map_currency_resolver.dart';

void main() {
  test('主な国の通貨コード', () {
    expect(currencyForCountryCode('JP')?.code, 'JPY');
    expect(currencyForCountryCode('jp')?.symbol, '¥');
    expect(currencyForCountryCode('US')?.code, 'USD');
    expect(currencyForCountryCode('TH')?.code, 'THB');
    expect(currencyForCountryCode('FR')?.code, 'EUR');
    expect(currencyForCountryCode('DE')?.code, 'EUR');
    expect(currencyForCountryCode('BG')?.code, 'EUR');
    expect(currencyForCountryCode('GB')?.code, 'GBP');
    expect(currencyForCountryCode('UK')?.code, 'GBP');
    expect(currencyForCountryCode('CN')?.code, 'CNY');
    expect(currencyForCountryCode('KR')?.code, 'KRW');
  });

  test('不正な国コードは受け取らない', () {
    expect(normalizeCountryCode('jp'), 'JP');
    expect(normalizeCountryCode(' UK '), 'GB');
    expect(normalizeCountryCode('JPN'), isNull);
    expect(normalizeCountryCode('J1'), isNull);
    expect(normalizeCountryCode(''), isNull);
    expect(normalizeCountryCode(null), isNull);
    expect(currencyForCountryCode('ZZ'), isNull);
  });

  test('緯度経度の範囲', () {
    expect(isValidLatitude(35.6), isTrue);
    expect(isValidLatitude(90), isTrue);
    expect(isValidLatitude(-90), isTrue);
    expect(isValidLatitude(90.1), isFalse);
    expect(isValidLatitude(double.nan), isFalse);
    expect(isValidLatitude(double.infinity), isFalse);
    expect(isValidLongitude(180), isTrue);
    expect(isValidLongitude(-180), isTrue);
    expect(isValidLongitude(180.1), isFalse);
    expect(isValidLongitude(double.nan), isFalse);
  });

  test('国名から制御文字を除く', () {
    expect(sanitizePlaceName(' 日本\n'), '日本');
    expect(sanitizePlaceName('\n'), isNull);
    expect(sanitizePlaceName('   '), isNull);
    expect(sanitizePlaceName(null), isNull);
    expect(sanitizePlaceName('あ' * 90)!.length, 80);
  });

  test('プレイスマークから国と通貨を取る', () {
    final found = lookupFromPlacemarks(const [
      Placemark(isoCountryCode: 'JPN', country: '不正'),
      Placemark(isoCountryCode: 'th', country: 'タイ'),
    ]);
    expect(found, isNotNull);
    expect(found!.countryCode, 'TH');
    expect(found.countryName, 'タイ');
    expect(found.currency?.code, 'THB');
    expect(found.currency?.label, 'THB（฿）タイ・バーツ');
  });

  test('国が取れない結果は null', () {
    expect(lookupFromPlacemarks(const []), isNull);
    expect(
      lookupFromPlacemarks(const [Placemark(isoCountryCode: '12')]),
      isNull,
    );
  });

  test('通貨表のコード形式', () {
    expect(countryCurrencyTable.length, greaterThan(150));
    for (final entry in countryCurrencyTable.entries) {
      expect(entry.key, matches(RegExp(r'^[A-Z]{2}$')));
      expect(entry.value.code, matches(RegExp(r'^[A-Z]{3}$')));
      expect(entry.value.symbol, isNotEmpty);
      expect(entry.value.nameJa, isNotEmpty);
    }
    expect(countryCurrencyTable.containsKey('UK'), isFalse);
  });

  test('国旗絵文字', () {
    expect(flagEmojiFromCountryCode('JP'), '🇯🇵');
    expect(flagEmojiFromCountryCode('us'), '🇺🇸');
    expect(flagEmojiFromCountryCode('JPN'), isNull);
  });
}
