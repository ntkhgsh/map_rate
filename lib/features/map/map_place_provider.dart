import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:map_rate/features/currency/currency_info.dart';
import 'package:map_rate/features/currency/map_currency_resolver.dart';

/// 地図の中心と、そこから判定した国・通貨。
class MapPlace {
  const MapPlace({
    required this.latitude,
    required this.longitude,
    this.countryCode,
    this.countryName,
    this.currency,
    this.isResolving = false,
    this.messageKey,
  });

  /// 起動直後の中心。東京駅付近（日本円が初期の想定に合う）。
  static const initialLatitude = 35.681236;
  static const initialLongitude = 139.767125;

  factory MapPlace.initial() {
    return const MapPlace(
      latitude: initialLatitude,
      longitude: initialLongitude,
    );
  }

  final double latitude;
  final double longitude;
  final String? countryCode;
  final String? countryName;
  final CurrencyInfo? currency;
  final bool isResolving;

  /// AppLocalizations のキー。成功時は null。
  final String? messageKey;
}

/// 地図中心の国・通貨を保持する。
final mapPlaceProvider = NotifierProvider<MapPlaceNotifier, MapPlace>(
  MapPlaceNotifier.new,
);

class MapPlaceNotifier extends Notifier<MapPlace> {
  MapCurrencyResolver? _resolver;
  var _requestId = 0;

  @override
  MapPlace build() {
    ref.onDispose(() {
      // 画面を閉じたあとの結果で state を更新しないよう、進行中の番号を無効にする
      _requestId++;
    });
    return MapPlace.initial();
  }

  /// 地図の中心が止まったときに呼ぶ。
  ///
  /// ほぼ同じ地点で、すでに国が分かっている場合は再取得しない。
  Future<void> resolveCenter({
    required double latitude,
    required double longitude,
  }) async {
    if (!isValidLatitude(latitude) || !isValidLongitude(longitude)) {
      _requestId++;
      state = MapPlace(
        latitude: state.latitude,
        longitude: state.longitude,
        messageKey: 'invalidCoordinates',
      );
      return;
    }

    final current = state;
    final samePoint = (current.latitude - latitude).abs() < 0.0001 &&
        (current.longitude - longitude).abs() < 0.0001;
    // 約11m以内で、判定中または判定済みなら取り直さない
    if (samePoint && (current.isResolving || current.countryCode != null)) {
      return;
    }

    final requestId = ++_requestId;
    state = MapPlace(
      latitude: latitude,
      longitude: longitude,
      // 判定中も直前の国を残す。消すと一覧から一瞬落ちてチラつく
      countryCode: current.countryCode,
      countryName: current.countryName,
      currency: current.currency,
      isResolving: true,
    );

    final result = await _resolverOrCreate().resolve(
      latitude: latitude,
      longitude: longitude,
    );
    if (!ref.mounted || requestId != _requestId) return;

    switch (result) {
      case MapCurrencyFound():
        state = MapPlace(
          latitude: latitude,
          longitude: longitude,
          countryCode: result.countryCode,
          countryName: result.countryName,
          currency: result.currency,
        );
      case MapCurrencyFailed():
        state = MapPlace(
          latitude: latitude,
          longitude: longitude,
          messageKey: result.messageKey,
        );
    }
  }

  MapCurrencyResolver _resolverOrCreate() {
    return _resolver ??= MapCurrencyResolver();
  }
}
