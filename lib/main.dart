import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:map_rate/app.dart';

Future<void> main() async {
  // プラグイン（地図・位置情報・広告）を使う前に、Flutter の初期化を済ませる
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await MobileAds.instance.initialize();
  } catch (error) {
    // 広告の初期化失敗でもアプリ自体は起動する
    debugPrint('MapRate MobileAds init failed: $error');
  }
  runApp(const ProviderScope(child: MapRateApp()));
}
