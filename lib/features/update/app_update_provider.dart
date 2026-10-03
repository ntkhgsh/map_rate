import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:map_rate/features/update/app_update_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final appUpdateServiceProvider = Provider<AppUpdateService>(
  (ref) => AppUpdateService(),
);

final appUpdateProvider =
    NotifierProvider<AppUpdateNotifier, AppUpdateState>(AppUpdateNotifier.new);

class AppUpdateState {
  const AppUpdateState({
    this.currentVersion = '',
    this.latestVersion,
    this.storeUrl,
    this.isUpdateAvailable = false,
    this.isChecking = false,
    this.dismissed = false,
  });

  final String currentVersion;
  final String? latestVersion;
  final String? storeUrl;
  final bool isUpdateAvailable;
  final bool isChecking;

  /// この最新版について「あとで」を押したか。
  final bool dismissed;

  /// 地図上のバナーを出す条件。
  bool get shouldShowBanner => isUpdateAvailable && !dismissed;

  AppUpdateState copyWith({
    String? currentVersion,
    String? latestVersion,
    String? storeUrl,
    bool? isUpdateAvailable,
    bool? isChecking,
    bool? dismissed,
    bool clearLatest = false,
    bool clearStoreUrl = false,
  }) {
    return AppUpdateState(
      currentVersion: currentVersion ?? this.currentVersion,
      latestVersion:
          clearLatest ? null : (latestVersion ?? this.latestVersion),
      storeUrl: clearStoreUrl ? null : (storeUrl ?? this.storeUrl),
      isUpdateAvailable: isUpdateAvailable ?? this.isUpdateAvailable,
      isChecking: isChecking ?? this.isChecking,
      dismissed: dismissed ?? this.dismissed,
    );
  }
}

class AppUpdateNotifier extends Notifier<AppUpdateState> {
  static const _dismissedKey = 'maprate_update_dismissed_version_v1';

  late final AppUpdateService _service;

  @override
  AppUpdateState build() {
    _service = ref.watch(appUpdateServiceProvider);
    // 起動直後に1回だけ調べる（失敗してもアプリは止めない）
    Future.microtask(checkForUpdate);
    return const AppUpdateState(isChecking: true);
  }

  Future<void> checkForUpdate() async {
    state = state.copyWith(isChecking: true);
    try {
      final result = await _service.check();
      if (!ref.mounted) return;
      final dismissedVersion = await _loadDismissedVersion();
      if (!ref.mounted) return;
      final available = result.isUpdateAvailable;
      final dismissed = available &&
          result.latestVersion != null &&
          result.latestVersion == dismissedVersion;
      state = AppUpdateState(
        currentVersion: result.currentVersion,
        latestVersion: result.latestVersion,
        storeUrl: result.storeUrl,
        isUpdateAvailable: available,
        isChecking: false,
        dismissed: dismissed,
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(isChecking: false);
    }
  }

  Future<void> dismiss() async {
    final latest = state.latestVersion;
    if (latest == null || latest.isEmpty) {
      state = state.copyWith(dismissed: true);
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_dismissedKey, latest);
    } catch (_) {
      // 保存できなくても表示は閉じる
    }
    if (!ref.mounted) return;
    state = state.copyWith(dismissed: true);
  }

  Future<bool> openStore() async {
    final raw = state.storeUrl;
    if (raw == null || raw.isEmpty) return false;
    final uri = Uri.tryParse(raw);
    if (uri == null) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  Future<String?> _loadDismissedVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_dismissedKey);
    } catch (_) {
      return null;
    }
  }
}
