import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:map_rate/features/settings/app_settings_provider.dart';
import 'package:map_rate/l10n/app_localizations.dart';

/// 言語などの設定画面。
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _languageChoices = <({String? tag, String labelEn})>[
    (tag: null, labelEn: 'System'),
    (tag: 'en', labelEn: 'English'),
    (tag: 'ja', labelEn: '日本語'),
    (tag: 'zh', labelEn: '简体中文'),
    (tag: 'zh_TW', labelEn: '繁體中文'),
    (tag: 'hi', labelEn: 'हिन्दी'),
    (tag: 'es', labelEn: 'Español'),
    (tag: 'ko', labelEn: '한국어'),
    (tag: 'de', labelEn: 'Deutsch'),
    (tag: 'fr', labelEn: 'Français'),
    (tag: 'pt', labelEn: 'Português'),
    (tag: 'pt_BR', labelEn: 'Português (Brasil)'),
    (tag: 'id', labelEn: 'Bahasa Indonesia'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(appSettingsProvider);
    final currentTag = settings.localeTag;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.languageTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final choice in _languageChoices)
            ListTile(
              title: Text(
                choice.tag == null ? l10n.languageSystem : choice.labelEn,
              ),
              trailing: Icon(
                currentTag == choice.tag
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: currentTag == choice.tag
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              onTap: () {
                ref.read(appSettingsProvider.notifier).setLocaleTag(choice.tag);
              },
            ),
        ],
      ),
    );
  }
}
