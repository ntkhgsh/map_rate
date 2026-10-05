import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:map_rate/features/currency/country_geo.dart';
import 'package:map_rate/features/currency/country_names.dart';
import 'package:map_rate/features/currency/currency_info.dart';

/// 緯度が -90〜90 の有限値か。
bool isValidLatitude(double latitude) {
  return latitude.isFinite && latitude >= -90 && latitude <= 90;
}

/// 経度が -180〜180 の有限値か。
bool isValidLongitude(double longitude) {
  return longitude.isFinite && longitude >= -180 && longitude <= 180;
}

/// 国と通貨の判定結果。成功と失敗のどちらか一方だけが入る。
sealed class MapCurrencyLookup {
  const MapCurrencyLookup();
}

/// 逆ジオコーディングの結果から取り出した国と通貨。
class MapCurrencyFound extends MapCurrencyLookup {
  const MapCurrencyFound({
    required this.countryCode,
    this.countryName,
    this.currency,
  });

  final String countryCode;
  final String? countryName;

  /// 対応表に無い国のときは null。画面では「不明」と出す。
  final CurrencyInfo? currency;
}

/// 国を特定できなかった理由。
///
/// [messageKey] は AppLocalizations のゲッター名（例: countryNotFound）。
class MapCurrencyFailed extends MapCurrencyLookup {
  const MapCurrencyFailed(this.messageKey);

  final String messageKey;
}

/// 地図の中心座標から、国コードと通貨を調べる。
class MapCurrencyResolver {
  /// 未指定なら、呼び出したときに端末のジオコーダーを使う。
  MapCurrencyResolver({this._geocoding});

  final Geocoding? _geocoding;

  Geocoding get _client => _geocoding ?? Geocoding();

  Future<MapCurrencyLookup> resolve({
    required double latitude,
    required double longitude,
  }) async {
    if (!isValidLatitude(latitude) || !isValidLongitude(longitude)) {
      return const MapCurrencyFailed('invalidCoordinates');
    }

    try {
      final client = _client;
      // Android ではジオコーダーが無い端末がある。その場合は通信しない。
      final present = await client.isPresent();
      if (!present) {
        // オフライン／ジオコーダー無しでも、内蔵の国矩形で判定する
        return lookupFromCountryBoxes(latitude, longitude) ??
            const MapCurrencyFailed('geocoderUnavailable');
      }

      final placemarks = await client.placemarkFromCoordinates(
        latitude,
        longitude,
        // 国名は端末の言語に合わせる（多言語化）
        locale: WidgetsBinding.instance.platformDispatcher.locale,
      );
      final found = lookupFromPlacemarks(placemarks);
      if (found != null) return found;
      // 通信不良などで国が取れないときは、内蔵矩形で補う
      return lookupFromCountryBoxes(latitude, longitude) ??
          const MapCurrencyFailed('countryNotFound');
    } catch (_) {
      // 例外の本文には座標が入ることがあるので、画面にもログにも出さない
      return lookupFromCountryBoxes(latitude, longitude) ??
          const MapCurrencyFailed('countryLookupFailed');
    }
  }
}

/// 内蔵の国矩形から国・通貨を返す（オフライン用）。
MapCurrencyFound? lookupFromCountryBoxes(double latitude, double longitude) {
  final code = countryCodeAt(latitude: latitude, longitude: longitude);
  if (code == null) return null;
  // テストなど WidgetsBinding 未初期化のときは英語名に落とす
  LocaleKey localeKey = LocaleKey.en;
  try {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    localeKey = fromLocale(
      locale.languageCode,
      locale.countryCode,
      locale.scriptCode,
    );
  } catch (_) {}
  final name = localizedCountryName(code, localeKey);
  return MapCurrencyFound(
    countryCode: code,
    countryName: name.isEmpty ? null : name,
    currency: currencyForCountryCode(code),
  );
}

/// 逆ジオコーディングの候補から、最初の妥当な国コードを採用する。
///
/// 妥当な国コードが1件も無ければ null。
MapCurrencyFound? lookupFromPlacemarks(List<Placemark> placemarks) {
  for (final place in placemarks) {
    final code = normalizeCountryCode(place.isoCountryCode);
    if (code == null) continue;
    return MapCurrencyFound(
      countryCode: code,
      countryName: sanitizePlaceName(place.country),
      currency: currencyForCountryCode(code),
    );
  }
  return null;
}
