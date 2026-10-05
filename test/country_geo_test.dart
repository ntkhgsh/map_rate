import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_rate/features/currency/country_geo.dart';

void main() {
  test('中国の矩形内では距離スコアが 0（中心距離だと沿岸で不利になる問題の回帰）', () {
    // 上海付近。旧ロジックでは中国矩形の中心（内陸）までの距離が大きく、
    // 周辺国より遠と判定されて一覧から落ちることがあった。
    final score = distanceScoreForCountry(
      countryCode: 'CN',
      centerLat: 31.23,
      centerLng: 121.47,
    );
    expect(score, 0);
  });

  test('十字が中国の上にある広域表示でも CN が候補に入る', () {
    // 東アジアを広く表示した状態（下段パネルを想定し、十字は上海）
    final view = LatLngBounds(
      const LatLng(15.0, 95.0),
      const LatLng(45.0, 140.0),
    );
    final codes = visibleCountryCodes(
      view: view,
      focusLat: 31.23,
      focusLng: 121.47,
      extraCountryCodes: const ['CN'],
      maxCount: 12,
    );
    expect(codes.contains('CN'), isTrue);
  });

  test('オフライン国判定：東京は JP、上海は CN、香港は HK', () {
    expect(countryCodeAt(latitude: 35.68, longitude: 139.76), 'JP');
    expect(countryCodeAt(latitude: 31.23, longitude: 121.47), 'CN');
    // 香港は中国矩形にも入るが、面積の小さい HK を優先する
    expect(countryCodeAt(latitude: 22.3, longitude: 114.2), 'HK');
  });

  test('オフライン国判定：遠い海上は null', () {
    expect(countryCodeAt(latitude: 0, longitude: -150), isNull);
  });
}
