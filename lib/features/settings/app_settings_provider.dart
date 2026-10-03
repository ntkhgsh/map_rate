import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// アプリ共通の設定（言語・為替リストの開閉）。
class AppSettings {
  const AppSettings({
    this.localeTag,
    this.exchangeListCollapsed = false,
  });

  /// `en` / `ja` / `zh` / `zh_TW` / `pt_BR` など。null なら端末の言語。
  final String? localeTag;

  /// true のとき為替リスト本文を畳む。
  final bool exchangeListCollapsed;

  AppSettings copyWith({
    String? localeTag,
    bool clearLocale = false,
    bool? exchangeListCollapsed,
  }) {
    return AppSettings(
      localeTag: clearLocale ? null : (localeTag ?? this.localeTag),
      exchangeListCollapsed:
          exchangeListCollapsed ?? this.exchangeListCollapsed,
    );
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);

class AppSettingsNotifier extends Notifier<AppSettings> {
  static const _localeKey = 'maprate_locale_tag_v1';
  static const _listCollapsedKey = 'maprate_exchange_list_collapsed_v1';

  @override
  AppSettings build() {
    Future.microtask(_load);
    return const AppSettings();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localeKey);
    final collapsed = prefs.getBool(_listCollapsedKey) ?? false;
    if (!ref.mounted) return;
    state = AppSettings(
      localeTag: _sanitizeLocaleTag(raw),
      exchangeListCollapsed: collapsed,
    );
  }

  Future<void> setLocaleTag(String? tag) async {
    final sanitized = _sanitizeLocaleTag(tag);
    final prefs = await SharedPreferences.getInstance();
    if (sanitized == null) {
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, sanitized);
    }
    if (!ref.mounted) return;
    state = state.copyWith(localeTag: sanitized, clearLocale: sanitized == null);
  }

  Future<void> setExchangeListCollapsed(bool collapsed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_listCollapsedKey, collapsed);
    if (!ref.mounted) return;
    state = state.copyWith(exchangeListCollapsed: collapsed);
  }

  Future<void> toggleExchangeListCollapsed() async {
    await setExchangeListCollapsed(!state.exchangeListCollapsed);
  }

  /// 想定外の文字列は弾いて、不正な言語設定を防ぐ。
  String? _sanitizeLocaleTag(String? raw) {
    if (raw == null) return null;
    final tag = raw.trim();
    const allowed = {
      'en',
      'ja',
      'zh',
      'zh_TW',
      'hi',
      'es',
      'ko',
      'de',
      'fr',
      'pt',
      'pt_BR',
      'id',
    };
    if (!allowed.contains(tag)) return null;
    return tag;
  }
}
