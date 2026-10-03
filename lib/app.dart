import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:map_rate/features/map/map_screen.dart';
import 'package:map_rate/features/settings/app_settings_provider.dart';
import 'package:map_rate/l10n/app_localizations.dart';

/// MapRate の起点。地図を全画面にし、端末のライト／ダーク設定に合わせる。
class MapRateApp extends ConsumerWidget {
  const MapRateApp({super.key, this.locale});

  /// テストで言語を固定するときだけ渡す。通常は設定または端末の言語に従う。
  final Locale? locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final resolvedLocale = locale ?? _localeFromTag(settings.localeTag);

    return MaterialApp(
      locale: resolvedLocale,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // 端末言語が未対応のとき、英語に落とす（Play のデフォルト言語と揃える）
      localeResolutionCallback: (deviceLocale, supported) {
        const english = Locale('en');
        if (resolvedLocale != null) {
          return _matchSupported(resolvedLocale, supported) ?? english;
        }
        if (deviceLocale == null) return english;
        return _matchSupported(deviceLocale, supported) ?? english;
      },
      home: const MapScreen(),
    );
  }

  Locale? _localeFromTag(String? tag) {
    if (tag == null || tag.isEmpty) return null;
    final parts = tag.split('_');
    if (parts.length == 1) return Locale(parts[0]);
    return Locale(parts[0], parts[1]);
  }

  Locale? _matchSupported(Locale wanted, Iterable<Locale> supported) {
    for (final locale in supported) {
      if (locale.languageCode == wanted.languageCode &&
          locale.countryCode == wanted.countryCode) {
        return locale;
      }
    }
    for (final locale in supported) {
      if (locale.languageCode == wanted.languageCode) {
        return locale;
      }
    }
    return null;
  }
}

ThemeData _theme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF1578B5),
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
  );
}
