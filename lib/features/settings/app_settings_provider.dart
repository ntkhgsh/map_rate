import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:map_rate/features/currency/exchange_rate_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// アプリ共通の設定（言語・為替リストの開閉・計算方法）。
class AppSettings {
  const AppSettings({
    this.localeTag,
    this.exchangeListCollapsed = false,
    this.rateSource = rateSourceAuto,
  });

  /// `en` / `ja` / `zh` / `zh_TW` / `pt_BR` など。null なら端末の言語。
  final String? localeTag;

  /// true のとき為替リスト本文を畳む。
  final bool exchangeListCollapsed;

  /// 金額計算に使うレートの出典。`auto` / `openEr` / `cdn` / `frankfurter`。
  final String rateSource;

  AppSettings copyWith({
    String? localeTag,
    bool clearLocale = false,
    bool? exchangeListCollapsed,
    String? rateSource,
  }) {
    return AppSettings(
      localeTag: clearLocale ? null : (localeTag ?? this.localeTag),
      exchangeListCollapsed:
          exchangeListCollapsed ?? this.exchangeListCollapsed,
      rateSource: rateSource ?? this.rateSource,
    );
  }
}

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);

class AppSettingsNotifier extends Notifier<AppSettings> {
  static const _localeKey = 'maprate_locale_tag_v1';
  static const _listCollapsedKey = 'maprate_exchange_list_collapsed_v1';
  static const _rateSourceKey = 'maprate_rate_source_v1';

  @override
  AppSettings build() {
    Future.microtask(_load);
    return const AppSettings();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localeKey);
    final collapsed = prefs.getBool(_listCollapsedKey) ?? false;
    // 保存値が壊れていても、知らない出典名は自動に戻す
    final rateSource = normalizeRateSource(prefs.getString(_rateSourceKey));
    if (!ref.mounted) return;
    state = AppSettings(
      localeTag: _sanitizeLocaleTag(raw),
      exchangeListCollapsed: collapsed,
      rateSource: rateSource,
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
    state = state.copyWith(
      localeTag: sanitized,
      clearLocale: sanitized == null,
    );
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

  /// 計算方法（レートの出典）を保存する。想定外の値は自動に戻す。
  Future<void> setRateSource(String raw) async {
    final source = normalizeRateSource(raw);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rateSourceKey, source);
    if (!ref.mounted) return;
    if (state.rateSource == source) return;
    state = state.copyWith(rateSource: source);
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
