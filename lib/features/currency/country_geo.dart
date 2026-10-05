import 'package:flutter_map/flutter_map.dart';
import 'package:map_rate/features/currency/currency_info.dart';

/// 地図上で「この国が見えているか」を近似判定するための矩形。
///
/// 正確な国境ではなく、画面内に国が含まれるかの目安に使う。
/// 日付変更線をまたぐ国は、重ならない矩形を複数持つ。
class CountryBox {
  const CountryBox({
    required this.countryCode,
    required this.north,
    required this.south,
    required this.east,
    required this.west,
  });

  final String countryCode;
  final double north;
  final double south;
  final double east;
  final double west;

  /// 地図の表示範囲と重なるか。
  bool intersects(LatLngBounds view) {
    if (south > view.north || north < view.south) return false;
    if (west > view.east || east < view.west) return false;
    return true;
  }

  /// 点がこの矩形の内側（境界含む）にあるか。
  /// 日付変更線をまたぐ矩形（west > east）にも対応する。
  bool contains(double lat, double lng) {
    if (lat < south || lat > north) return false;
    if (west <= east) {
      return lng >= west && lng <= east;
    }
    // 日付変更線越え：west〜180 または -180〜east
    return lng >= west || lng <= east;
  }

  /// 面積の目安（度²）。小さいほど「狭い国」として優先する。
  double get areaDegrees {
    final width = west <= east ? (east - west) : ((180 - west) + (east + 180));
    return (north - south) * width;
  }
}

/// 点から国の矩形までの距離スコア（小さいほど近い）。
///
/// 矩形の「中心」ではなく、最も近い点までの距離を使う。
/// 中国・ロシアのように大きな国の上に十字があるとき、中心距離だと
/// 周辺の小国より遠と判定され、一覧から落ちるのを防ぐ。
/// 矩形内なら 0。矩形が無い国は null。
double? distanceScoreForCountry({
  required String countryCode,
  required double centerLat,
  required double centerLng,
}) {
  final code = normalizeCountryCode(countryCode);
  if (code == null) return null;
  double? best;
  for (final box in countryBoxes) {
    if (normalizeCountryCode(box.countryCode) != code) continue;
    final score = _distanceScoreToBox(box, centerLat, centerLng);
    if (best == null || score < best) best = score;
  }
  return best;
}

/// 緯度経度から、含まれる国コードを返す（オフライン用）。
///
/// 複数の矩形に入るときは、面積が小さい方を優先する（香港 vs 中国など）。
/// どの矩形にも入らないときは、最近接点までの距離が最も近い国を返す。
/// 矩形表に無い場所は null。
String? countryCodeAt({
  required double latitude,
  required double longitude,
}) {
  if (!latitude.isFinite || !longitude.isFinite) return null;
  if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
    return null;
  }

  String? bestInside;
  var bestInsideArea = double.infinity;
  String? bestNear;
  var bestNearScore = double.infinity;

  for (final box in countryBoxes) {
    final code = normalizeCountryCode(box.countryCode);
    if (code == null || currencyForCountryCode(code) == null) continue;
    if (box.contains(latitude, longitude)) {
      final area = box.areaDegrees;
      if (area < bestInsideArea) {
        bestInsideArea = area;
        bestInside = code;
      }
      continue;
    }
    final score = _distanceScoreToBox(box, latitude, longitude);
    if (score < bestNearScore) {
      bestNearScore = score;
      bestNear = code;
    }
  }

  // 海上など「どの矩形にも入らない」ときだけ、近い国を候補にする。
  // ただしあまり遠い（おおよそ 3° 超）場合は不明扱い。
  if (bestInside != null) return bestInside;
  if (bestNear != null && bestNearScore <= 9.0) return bestNear;
  return null;
}

/// 緯度経度から矩形の最近接点までの距離の二乗。矩形内は 0。
double _distanceScoreToBox(CountryBox box, double lat, double lng) {
  final nearestLat = lat.clamp(box.south, box.north);
  final dLat = nearestLat - lat;
  if (box.contains(lat, lng)) return dLat * dLat;

  late final double nearestLng;
  if (box.west <= box.east) {
    nearestLng = lng.clamp(box.west, box.east);
  } else {
    // 日付変更線越え：左右どちらの帯に近いか選ぶ
    final distWestSide = lng >= box.west ? 0.0 : (box.west - lng);
    final distEastSide = lng <= box.east ? 0.0 : (lng - box.east);
    if (distWestSide <= distEastSide) {
      nearestLng = lng < box.west ? box.west : lng;
    } else {
      nearestLng = lng > box.east ? box.east : lng;
    }
  }
  final dLng = nearestLng - lng;
  return dLat * dLat + dLng * dLng;
}

/// 表示中の国コードを、重複なしで返す。
///
/// [extraCountryCodes] は地図中心で分かった国など、必ず含めたいコード。
/// [focusLat] / [focusLng] があれば十字位置で近さを測る（無いときだけ表示範囲の中心）。
/// 画面が広すぎて国が多すぎるときは、中心に近い順に [maxCount] 件までにする。
Set<String> visibleCountryCodes({
  required LatLngBounds view,
  Iterable<String> extraCountryCodes = const [],
  double? focusLat,
  double? focusLng,
  int maxCount = 12,
}) {
  final scored = <({String code, double score})>[];
  // 下段パネルがあるため、十字位置と表示範囲の幾何中心はずれる
  final centerLat = focusLat ?? (view.north + view.south) / 2;
  final centerLng = focusLng ?? (view.east + view.west) / 2;

  for (final box in countryBoxes) {
    if (!box.intersects(view)) continue;
    final code = normalizeCountryCode(box.countryCode);
    if (code == null || currencyForCountryCode(code) == null) continue;
    final score = distanceScoreForCountry(
          countryCode: code,
          centerLat: centerLat,
          centerLng: centerLng,
        ) ??
        double.infinity;
    scored.add((code: code, score: score));
  }

  scored.sort((a, b) => a.score.compareTo(b.score));
  final found = <String>{};
  for (final item in scored) {
    if (found.length >= maxCount) break;
    found.add(item.code);
  }

  for (final raw in extraCountryCodes) {
    final code = normalizeCountryCode(raw);
    if (code != null && currencyForCountryCode(code) != null) {
      found.add(code);
    }
  }
  return found;
}

/// 主要国の大まかな矩形。旅行・出張でよく見る国を優先して載せている。
///
/// 値は公開の概形に基づく近似であり、国境の公式データではない。
const countryBoxes = <CountryBox>[
  CountryBox(countryCode: 'JP', north: 45.6, south: 24.0, east: 146.0, west: 122.9),
  CountryBox(countryCode: 'KR', north: 38.7, south: 33.0, east: 129.6, west: 124.5),
  CountryBox(countryCode: 'KP', north: 43.1, south: 37.6, east: 130.7, west: 124.1),
  CountryBox(countryCode: 'CN', north: 53.6, south: 18.0, east: 134.8, west: 73.4),
  CountryBox(countryCode: 'TW', north: 25.4, south: 21.8, east: 122.1, west: 119.3),
  CountryBox(countryCode: 'HK', north: 22.6, south: 22.1, east: 114.5, west: 113.8),
  CountryBox(countryCode: 'MO', north: 22.3, south: 22.1, east: 113.6, west: 113.5),
  CountryBox(countryCode: 'MN', north: 52.2, south: 41.5, east: 120.0, west: 87.7),
  CountryBox(countryCode: 'RU', north: 77.0, south: 41.0, east: 180.0, west: 27.0),
  CountryBox(countryCode: 'RU', north: 71.0, south: 51.0, east: -169.0, west: -180.0),
  CountryBox(countryCode: 'US', north: 49.4, south: 24.4, east: -66.9, west: -125.0),
  CountryBox(countryCode: 'US', north: 71.5, south: 51.2, east: -129.9, west: -180.0),
  CountryBox(countryCode: 'US', north: 22.3, south: 18.9, east: -154.8, west: -160.3),
  CountryBox(countryCode: 'CA', north: 83.2, south: 41.7, east: -52.6, west: -141.0),
  CountryBox(countryCode: 'MX', north: 32.8, south: 14.5, east: -86.7, west: -118.5),
  CountryBox(countryCode: 'GT', north: 17.9, south: 13.7, east: -88.2, west: -92.3),
  CountryBox(countryCode: 'BZ', north: 18.5, south: 15.8, east: -87.4, west: -89.3),
  CountryBox(countryCode: 'HN', north: 16.6, south: 12.9, east: -83.1, west: -89.4),
  CountryBox(countryCode: 'SV', north: 14.5, south: 13.1, east: -87.6, west: -90.2),
  CountryBox(countryCode: 'NI', north: 15.1, south: 10.7, east: -83.1, west: -87.8),
  CountryBox(countryCode: 'CR', north: 11.3, south: 8.0, east: -82.5, west: -86.0),
  CountryBox(countryCode: 'PA', north: 9.7, south: 7.1, east: -77.1, west: -83.1),
  CountryBox(countryCode: 'CU', north: 23.3, south: 19.8, east: -74.1, west: -85.0),
  CountryBox(countryCode: 'JM', north: 18.6, south: 17.6, east: -76.1, west: -78.5),
  CountryBox(countryCode: 'HT', north: 20.1, south: 18.0, east: -71.6, west: -74.5),
  CountryBox(countryCode: 'DO', north: 19.9, south: 17.4, east: -68.3, west: -72.1),
  CountryBox(countryCode: 'PR', north: 18.6, south: 17.8, east: -65.5, west: -67.3),
  CountryBox(countryCode: 'CO', north: 13.5, south: -4.3, east: -66.8, west: -79.1),
  CountryBox(countryCode: 'VE', north: 12.3, south: 0.6, east: -59.7, west: -73.4),
  CountryBox(countryCode: 'GY', north: 8.6, south: 1.1, east: -56.4, west: -61.5),
  CountryBox(countryCode: 'SR', north: 6.1, south: 1.8, east: -53.9, west: -58.2),
  CountryBox(countryCode: 'BR', north: 5.3, south: -33.8, east: -34.7, west: -74.0),
  CountryBox(countryCode: 'EC', north: 1.7, south: -5.1, east: -75.1, west: -81.1),
  CountryBox(countryCode: 'PE', north: 0.0, south: -18.4, east: -68.6, west: -81.4),
  CountryBox(countryCode: 'BO', north: -9.6, south: -23.0, east: -57.4, west: -69.7),
  CountryBox(countryCode: 'PY', north: -19.2, south: -27.7, east: -54.2, west: -62.7),
  CountryBox(countryCode: 'CL', north: -17.4, south: -56.0, east: -66.3, west: -75.7),
  CountryBox(countryCode: 'AR', north: -21.7, south: -55.1, east: -53.5, west: -73.6),
  CountryBox(countryCode: 'UY', north: -30.0, south: -35.0, east: -53.0, west: -58.5),
  CountryBox(countryCode: 'IS', north: 66.6, south: 63.2, east: -13.4, west: -24.6),
  CountryBox(countryCode: 'GL', north: 83.7, south: 59.7, east: -11.3, west: -73.3),
  CountryBox(countryCode: 'NO', north: 71.3, south: 57.9, east: 31.3, west: 4.5),
  CountryBox(countryCode: 'SE', north: 69.1, south: 55.2, east: 24.2, west: 10.9),
  CountryBox(countryCode: 'FI', north: 70.1, south: 59.7, east: 31.6, west: 20.5),
  CountryBox(countryCode: 'DK', north: 57.8, south: 54.5, east: 15.3, west: 8.0),
  CountryBox(countryCode: 'IE', north: 55.5, south: 51.4, east: -5.9, west: -10.7),
  CountryBox(countryCode: 'GB', north: 59.0, south: 49.8, east: 1.8, west: -8.7),
  CountryBox(countryCode: 'FR', north: 51.2, south: 41.3, east: 9.6, west: -5.2),
  CountryBox(countryCode: 'BE', north: 51.6, south: 49.4, east: 6.5, west: 2.5),
  CountryBox(countryCode: 'NL', north: 53.6, south: 50.7, east: 7.3, west: 3.3),
  CountryBox(countryCode: 'LU', north: 50.2, south: 49.4, east: 6.6, west: 5.7),
  CountryBox(countryCode: 'DE', north: 55.1, south: 47.2, east: 15.1, west: 5.8),
  CountryBox(countryCode: 'CH', north: 47.9, south: 45.8, east: 10.5, west: 5.9),
  CountryBox(countryCode: 'AT', north: 49.1, south: 46.3, east: 17.2, west: 9.5),
  CountryBox(countryCode: 'IT', north: 47.2, south: 36.6, east: 18.6, west: 6.6),
  CountryBox(countryCode: 'ES', north: 43.9, south: 35.9, east: 4.4, west: -9.4),
  CountryBox(countryCode: 'PT', north: 42.2, south: 36.9, east: -6.1, west: -9.6),
  CountryBox(countryCode: 'PL', north: 54.9, south: 49.0, east: 24.2, west: 14.1),
  CountryBox(countryCode: 'CZ', north: 51.1, south: 48.5, east: 18.9, west: 12.0),
  CountryBox(countryCode: 'SK', north: 49.7, south: 47.7, east: 22.6, west: 16.8),
  CountryBox(countryCode: 'HU', north: 48.7, south: 45.7, east: 22.9, west: 16.1),
  CountryBox(countryCode: 'RO', north: 48.3, south: 43.6, east: 30.0, west: 20.2),
  CountryBox(countryCode: 'BG', north: 44.3, south: 41.2, east: 28.7, west: 22.3),
  CountryBox(countryCode: 'GR', north: 41.8, south: 34.8, east: 29.7, west: 19.3),
  CountryBox(countryCode: 'TR', north: 42.2, south: 35.8, east: 44.9, west: 25.6),
  CountryBox(countryCode: 'UA', north: 52.5, south: 44.3, east: 40.3, west: 22.1),
  CountryBox(countryCode: 'BY', north: 56.2, south: 51.2, east: 32.9, west: 23.1),
  CountryBox(countryCode: 'MD', north: 48.5, south: 45.4, east: 30.2, west: 26.6),
  CountryBox(countryCode: 'RS', north: 46.3, south: 42.2, east: 23.1, west: 18.8),
  CountryBox(countryCode: 'BA', north: 45.3, south: 42.5, east: 19.7, west: 15.7),
  CountryBox(countryCode: 'HR', north: 46.6, south: 42.3, east: 19.5, west: 13.4),
  CountryBox(countryCode: 'SI', north: 46.9, south: 45.4, east: 16.7, west: 13.3),
  CountryBox(countryCode: 'AL', north: 42.7, south: 39.6, east: 21.1, west: 19.2),
  CountryBox(countryCode: 'MK', north: 42.4, south: 40.8, east: 23.1, west: 20.4),
  CountryBox(countryCode: 'ME', north: 43.6, south: 41.8, east: 20.4, west: 18.4),
  CountryBox(countryCode: 'XK', north: 43.3, south: 41.8, east: 21.8, west: 20.0),
  CountryBox(countryCode: 'EE', north: 59.8, south: 57.5, east: 28.3, west: 21.7),
  CountryBox(countryCode: 'LV', north: 58.1, south: 55.6, east: 28.3, west: 20.9),
  CountryBox(countryCode: 'LT', north: 56.5, south: 53.8, east: 26.9, west: 20.9),
  CountryBox(countryCode: 'GE', north: 43.7, south: 41.0, east: 46.8, west: 39.9),
  CountryBox(countryCode: 'AM', north: 41.4, south: 38.8, east: 46.7, west: 43.4),
  CountryBox(countryCode: 'AZ', north: 41.9, south: 38.3, east: 50.5, west: 44.7),
  CountryBox(countryCode: 'KZ', north: 55.5, south: 40.9, east: 87.4, west: 46.4),
  CountryBox(countryCode: 'UZ', north: 45.6, south: 37.1, east: 73.2, west: 55.9),
  CountryBox(countryCode: 'TM', north: 42.9, south: 35.1, east: 66.8, west: 52.4),
  CountryBox(countryCode: 'KG', north: 43.3, south: 39.1, east: 80.4, west: 69.2),
  CountryBox(countryCode: 'TJ', north: 41.1, south: 36.6, east: 75.2, west: 67.3),
  CountryBox(countryCode: 'AF', north: 38.6, south: 29.3, east: 74.9, west: 60.4),
  CountryBox(countryCode: 'PK', north: 37.1, south: 23.6, east: 77.9, west: 60.8),
  CountryBox(countryCode: 'IN', north: 35.6, south: 6.7, east: 97.5, west: 68.1),
  CountryBox(countryCode: 'NP', north: 30.5, south: 26.3, east: 88.3, west: 80.0),
  CountryBox(countryCode: 'BT', north: 28.4, south: 26.7, east: 92.2, west: 88.7),
  CountryBox(countryCode: 'BD', north: 26.7, south: 20.5, east: 92.8, west: 88.0),
  CountryBox(countryCode: 'LK', north: 9.9, south: 5.8, east: 82.0, west: 79.5),
  CountryBox(countryCode: 'MV', north: 7.2, south: -0.8, east: 73.8, west: 72.6),
  CountryBox(countryCode: 'MM', north: 28.6, south: 9.5, east: 101.2, west: 92.1),
  CountryBox(countryCode: 'TH', north: 20.5, south: 5.6, east: 105.7, west: 97.3),
  CountryBox(countryCode: 'LA', north: 22.6, south: 13.9, east: 107.7, west: 100.0),
  CountryBox(countryCode: 'KH', north: 14.8, south: 10.3, east: 107.7, west: 102.3),
  CountryBox(countryCode: 'VN', north: 23.5, south: 8.4, east: 109.6, west: 102.1),
  CountryBox(countryCode: 'MY', north: 7.5, south: 0.8, east: 119.4, west: 99.6),
  CountryBox(countryCode: 'SG', north: 1.5, south: 1.1, east: 104.1, west: 103.6),
  CountryBox(countryCode: 'ID', north: 6.0, south: -11.1, east: 141.1, west: 95.0),
  CountryBox(countryCode: 'BN', north: 5.1, south: 4.0, east: 115.4, west: 114.0),
  CountryBox(countryCode: 'PH', north: 21.2, south: 4.5, east: 127.0, west: 116.9),
  CountryBox(countryCode: 'TL', north: -8.1, south: -9.5, east: 127.5, west: 124.0),
  CountryBox(countryCode: 'AU', north: -10.0, south: -44.0, east: 154.0, west: 112.0),
  CountryBox(countryCode: 'NZ', north: -34.1, south: -47.4, east: 179.1, west: 166.3),
  CountryBox(countryCode: 'PG', north: -1.3, south: -11.7, east: 156.1, west: 140.8),
  CountryBox(countryCode: 'FJ', north: -12.4, south: -20.8, east: -178.0, west: 180.0),
  CountryBox(countryCode: 'FJ', north: -15.5, south: -19.3, east: 180.0, west: 177.0),
  CountryBox(countryCode: 'NC', north: -19.5, south: -23.0, east: 168.2, west: 163.5),
  CountryBox(countryCode: 'SA', north: 32.3, south: 16.3, east: 55.7, west: 34.4),
  CountryBox(countryCode: 'AE', north: 26.1, south: 22.6, east: 56.5, west: 51.5),
  CountryBox(countryCode: 'QA', north: 26.2, south: 24.4, east: 51.7, west: 50.7),
  CountryBox(countryCode: 'BH', north: 26.4, south: 25.7, east: 50.8, west: 50.3),
  CountryBox(countryCode: 'KW', north: 30.2, south: 28.5, east: 48.5, west: 46.5),
  CountryBox(countryCode: 'OM', north: 26.5, south: 16.6, east: 59.9, west: 51.8),
  CountryBox(countryCode: 'YE', north: 19.0, south: 12.1, east: 54.6, west: 42.5),
  CountryBox(countryCode: 'IQ', north: 37.4, south: 29.0, east: 48.7, west: 38.7),
  CountryBox(countryCode: 'IR', north: 39.8, south: 25.0, east: 63.4, west: 44.0),
  CountryBox(countryCode: 'IL', north: 33.4, south: 29.4, east: 35.9, west: 34.2),
  CountryBox(countryCode: 'JO', north: 33.4, south: 29.1, east: 39.4, west: 34.9),
  CountryBox(countryCode: 'LB', north: 34.7, south: 33.0, east: 36.7, west: 35.1),
  CountryBox(countryCode: 'SY', north: 37.4, south: 32.3, east: 42.5, west: 35.7),
  CountryBox(countryCode: 'EG', north: 31.8, south: 22.0, east: 37.0, west: 24.6),
  CountryBox(countryCode: 'LY', north: 33.2, south: 19.5, east: 25.2, west: 9.3),
  CountryBox(countryCode: 'TN', north: 37.6, south: 30.2, east: 11.7, west: 7.5),
  CountryBox(countryCode: 'DZ', north: 37.2, south: 18.9, east: 12.0, west: -8.8),
  CountryBox(countryCode: 'MA', north: 35.9, south: 27.6, east: -0.9, west: -13.3),
  CountryBox(countryCode: 'EH', north: 27.7, south: 20.7, east: -8.6, west: -17.2),
  CountryBox(countryCode: 'MR', north: 27.4, south: 14.7, east: -4.8, west: -17.1),
  CountryBox(countryCode: 'SN', north: 16.8, south: 12.2, east: -11.3, west: -17.6),
  CountryBox(countryCode: 'GM', north: 13.9, south: 13.0, east: -13.7, west: -17.0),
  CountryBox(countryCode: 'GN', north: 12.7, south: 7.1, east: -7.6, west: -15.1),
  CountryBox(countryCode: 'SL', north: 10.1, south: 6.8, east: -10.2, west: -13.4),
  CountryBox(countryCode: 'LR', north: 8.6, south: 4.3, east: -7.3, west: -11.6),
  CountryBox(countryCode: 'CI', north: 10.8, south: 4.3, east: -2.4, west: -8.7),
  CountryBox(countryCode: 'GH', north: 11.2, south: 4.6, east: 1.3, west: -3.3),
  CountryBox(countryCode: 'TG', north: 11.2, south: 6.0, east: 1.9, west: -0.2),
  CountryBox(countryCode: 'BJ', north: 12.5, south: 6.2, east: 3.9, west: 0.7),
  CountryBox(countryCode: 'NG', north: 13.9, south: 4.2, east: 14.8, west: 2.6),
  CountryBox(countryCode: 'CM', north: 13.2, south: 1.6, east: 16.3, west: 8.4),
  CountryBox(countryCode: 'TD', north: 23.5, south: 7.4, east: 24.1, west: 13.4),
  CountryBox(countryCode: 'CF', north: 11.1, south: 2.2, east: 27.5, west: 14.4),
  CountryBox(countryCode: 'SD', north: 22.3, south: 8.6, east: 38.7, west: 21.7),
  CountryBox(countryCode: 'SS', north: 12.3, south: 3.4, east: 35.9, west: 24.1),
  CountryBox(countryCode: 'ET', north: 14.9, south: 3.3, east: 48.1, west: 32.9),
  CountryBox(countryCode: 'ER', north: 18.1, south: 12.3, east: 43.2, west: 36.4),
  CountryBox(countryCode: 'DJ', north: 12.8, south: 10.9, east: 43.5, west: 41.7),
  CountryBox(countryCode: 'SO', north: 12.0, south: -1.8, east: 51.5, west: 40.9),
  CountryBox(countryCode: 'KE', north: 5.1, south: -4.8, east: 42.0, west: 33.9),
  CountryBox(countryCode: 'UG', north: 4.3, south: -1.5, east: 35.1, west: 29.5),
  CountryBox(countryCode: 'TZ', north: -0.9, south: -11.8, east: 40.5, west: 29.3),
  CountryBox(countryCode: 'RW', north: -1.0, south: -2.9, east: 30.9, west: 28.8),
  CountryBox(countryCode: 'BI', north: -2.3, south: -4.5, east: 30.9, west: 29.0),
  CountryBox(countryCode: 'CD', north: 5.4, south: -13.5, east: 31.4, west: 12.1),
  CountryBox(countryCode: 'CG', north: 3.8, south: -5.1, east: 18.7, west: 11.0),
  CountryBox(countryCode: 'GA', north: 2.4, south: -4.0, east: 14.6, west: 8.6),
  CountryBox(countryCode: 'GQ', north: 2.4, south: 0.8, east: 11.4, west: 9.2),
  CountryBox(countryCode: 'AO', north: -4.3, south: -18.1, east: 24.1, west: 11.6),
  CountryBox(countryCode: 'ZM', north: -8.2, south: -18.1, east: 33.8, west: 21.9),
  CountryBox(countryCode: 'MW', north: -9.3, south: -17.2, east: 36.0, west: 32.6),
  CountryBox(countryCode: 'MZ', north: -10.4, south: -26.9, east: 40.9, west: 30.1),
  CountryBox(countryCode: 'ZW', north: -15.5, south: -22.5, east: 33.1, west: 25.2),
  CountryBox(countryCode: 'BW', north: -17.7, south: -27.0, east: 29.5, west: 19.9),
  CountryBox(countryCode: 'NA', north: -16.9, south: -29.0, east: 25.3, west: 11.6),
  CountryBox(countryCode: 'ZA', north: -22.1, south: -34.9, east: 33.0, west: 16.4),
  CountryBox(countryCode: 'LS', north: -28.5, south: -30.7, east: 29.5, west: 27.0),
  CountryBox(countryCode: 'SZ', north: -25.7, south: -27.4, east: 32.2, west: 30.7),
  CountryBox(countryCode: 'MG', north: -11.8, south: -25.7, east: 50.6, west: 43.1),
  CountryBox(countryCode: 'MU', north: -19.9, south: -20.6, east: 57.9, west: 57.2),
  CountryBox(countryCode: 'SC', north: -4.2, south: -10.0, east: 56.4, west: 46.0),
];
