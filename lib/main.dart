import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:map_rate/app.dart';

Future<void> main() async {
  // プラグインを使う前に、Flutter の初期化を済ませる
  WidgetsFlutterBinding.ensureInitialized();

  // 広告 SDK の初期化は待たない（ネット不通時に数十秒ブロックして起動が遅くなるため）
  runApp(const ProviderScope(child: MapRateApp()));
  unawaited(_initMobileAds());
}

/// 画面を出したあとに AdMob を用意する。
Future<void> _initMobileAds() async {
  try {
    await MobileAds.instance.initialize();
  } catch (error) {
    // 広告の初期化失敗でもアプリ自体は使える
    debugPrint('MapRate MobileAds init failed: $error');
  }
}
