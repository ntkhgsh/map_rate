import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:map_rate/features/update/version_compare.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// ストア／マニフェスト照会の結果。
class AppUpdateCheckResult {
  const AppUpdateCheckResult({
    required this.currentVersion,
    this.latestVersion,
    this.storeUrl,
  });

  final String currentVersion;
  final String? latestVersion;
  final String? storeUrl;

  bool get isUpdateAvailable =>
      latestVersion != null &&
      compareVersions(latestVersion!, currentVersion) > 0;
}

/// アプリの更新有無を調べる。
///
/// 優先順位:
/// 1. `--dart-define=MAPRATE_FORCE_LATEST_VERSION=x.y.z`（動作確認用）
/// 2. `--dart-define=MAPRATE_VERSION_URL=https://...` の JSON マニフェスト
/// 3. App Store / Google Play の公開情報
class AppUpdateService {
  AppUpdateService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const androidPackageId = 'com.maprate.map_rate';
  static const iosBundleId = 'com.maprate.mapRate';

  /// デバッグや社内配布で最新版を差し込むとき用。
  static const forcedLatestVersion = String.fromEnvironment(
    'MAPRATE_FORCE_LATEST_VERSION',
  );

  /// 自前ホストの版数 JSON。例: `{"latestVersion":"1.0.1","androidStoreUrl":"...","iosStoreUrl":"..."}`
  static const versionManifestUrl = String.fromEnvironment(
    'MAPRATE_VERSION_URL',
  );

  Future<AppUpdateCheckResult> check() async {
    final info = await PackageInfo.fromPlatform();
    final current = info.version.trim();
    if (current.isEmpty) {
      return const AppUpdateCheckResult(currentVersion: '0.0.0');
    }

    // 1) 強制上書き（テスト用）
    if (forcedLatestVersion.trim().isNotEmpty) {
      return AppUpdateCheckResult(
        currentVersion: current,
        latestVersion: forcedLatestVersion.trim(),
        storeUrl: _defaultStoreUrl(),
      );
    }

    // 2) マニフェスト
    if (versionManifestUrl.trim().isNotEmpty) {
      final fromManifest = await _checkManifest(current);
      if (fromManifest != null) return fromManifest;
    }

    // 3) ストア
    if (kIsWeb) {
      return AppUpdateCheckResult(currentVersion: current);
    }
    try {
      if (Platform.isIOS) {
        return await _checkAppStore(current);
      }
      if (Platform.isAndroid) {
        return await _checkPlayStore(current);
      }
    } catch (error) {
      debugPrint('MapRate update check failed: $error');
    }
    return AppUpdateCheckResult(currentVersion: current);
  }

  Future<AppUpdateCheckResult?> _checkManifest(String current) async {
    try {
      final response = await _dio.get<dynamic>(
        versionManifestUrl.trim(),
        options: Options(
          responseType: ResponseType.json,
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );
      final data = response.data;
      if (data is! Map) return null;
      final latest = data['latestVersion']?.toString().trim();
      if (latest == null || latest.isEmpty) return null;
      final androidUrl = data['androidStoreUrl']?.toString();
      final iosUrl = data['iosStoreUrl']?.toString();
      final storeUrl = (!kIsWeb && Platform.isIOS)
          ? (iosUrl?.isNotEmpty == true ? iosUrl : _defaultStoreUrl())
          : (androidUrl?.isNotEmpty == true ? androidUrl : _defaultStoreUrl());
      return AppUpdateCheckResult(
        currentVersion: current,
        latestVersion: latest,
        storeUrl: storeUrl,
      );
    } catch (error) {
      debugPrint('MapRate version manifest failed: $error');
      return null;
    }
  }

  Future<AppUpdateCheckResult> _checkAppStore(String current) async {
    Future<Response<dynamic>> lookup(String? country) {
      return _dio.get<dynamic>(
        'https://itunes.apple.com/lookup',
        queryParameters: {
          'bundleId': iosBundleId,
          'country': ?country,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );
    }

    // 日本向けアプリなので jp を先に試し、無ければ国指定なし
    for (final country in <String?>['jp', 'us', null]) {
      final response = await lookup(country);
      final data = response.data;
      if (data is! Map) continue;
      final results = data['results'];
      if (results is! List || results.isEmpty) continue;
      final first = results.first;
      if (first is! Map) continue;
      final latest = first['version']?.toString().trim();
      final trackViewUrl = first['trackViewUrl']?.toString().trim();
      if (latest == null || latest.isEmpty) continue;
      return AppUpdateCheckResult(
        currentVersion: current,
        latestVersion: latest,
        storeUrl: (trackViewUrl != null && trackViewUrl.isNotEmpty)
            ? trackViewUrl
            : _defaultStoreUrl(),
      );
    }
    return AppUpdateCheckResult(currentVersion: current);
  }

  Future<AppUpdateCheckResult> _checkPlayStore(String current) async {
    final url =
        'https://play.google.com/store/apps/details?id=$androidPackageId&hl=en&gl=US';
    final response = await _dio.get<String>(
      url,
      options: Options(
        responseType: ResponseType.plain,
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 8),
        headers: const {
          // デスクトップ相当の UA の方が版数文字列が取りやすい
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
      ),
    );
    final body = response.data ?? '';
    final latest = _extractPlayStoreVersion(body);
    return AppUpdateCheckResult(
      currentVersion: current,
      latestVersion: latest,
      storeUrl: url,
    );
  }

  /// Play の HTML / 埋め込み JSON から版数を拾う（表記ゆれに複数パターン）。
  String? _extractPlayStoreVersion(String body) {
    final patterns = <RegExp>[
      RegExp(r'\[\[\["(\d+\.\d+(?:\.\d+)*)"\]\]'),
      RegExp(
        r'Current Version</div><span class="[^"]*">([^<]+)</span>',
        caseSensitive: false,
      ),
      RegExp(r'"softwareVersion"\s*:\s*"([^"]+)"'),
      RegExp(r'\[null,\[\[\["(\d+\.\d+(?:\.\d+)*)"\]\]'),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(body);
      final value = match?.group(1)?.trim();
      if (value != null && RegExp(r'^\d+(\.\d+)+$').hasMatch(value)) {
        return value;
      }
    }
    return null;
  }

  String _defaultStoreUrl() {
    if (!kIsWeb && Platform.isIOS) {
      return 'https://apps.apple.com/search?term=MapRate';
    }
    return 'https://play.google.com/store/apps/details?id=$androidPackageId';
  }
}
