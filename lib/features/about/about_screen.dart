import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:map_rate/features/update/app_update_provider.dart';
import 'package:map_rate/l10n/app_localizations.dart';

/// アプリの説明ページ。
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final update = ref.watch(appUpdateProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/app_icon.png',
                  width: 56,
                  height: 56,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.map,
                    size: 56,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (update.currentVersion.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.appVersionLabel(update.currentVersion),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 更新確認ボタン（結果は SnackBar で知らせる）
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: update.isChecking
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    update.isUpdateAvailable
                        ? Icons.system_update_alt
                        : Icons.verified_outlined,
                    color: update.isUpdateAvailable
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
            title: Text(l10n.checkForUpdate),
            subtitle: Text(
              update.isUpdateAvailable
                  ? l10n.updateAvailableBody(update.latestVersion ?? '')
                  : (update.currentVersion.isEmpty
                      ? l10n.updateCheckFailed
                      : l10n.updateUpToDate),
            ),
            trailing: update.isUpdateAvailable
                ? FilledButton(
                    onPressed: () async {
                      final opened =
                          await ref.read(appUpdateProvider.notifier).openStore();
                      if (!context.mounted) return;
                      if (!opened) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.updateOpenFailed)),
                        );
                      }
                    },
                    child: Text(l10n.updateNow),
                  )
                : null,
            onTap: update.isChecking
                ? null
                : () async {
                    await ref.read(appUpdateProvider.notifier).checkForUpdate();
                    if (!context.mounted) return;
                    final next = ref.read(appUpdateProvider);
                    final message = next.isUpdateAvailable
                        ? l10n.updateAvailableBody(next.latestVersion ?? '')
                        : (next.currentVersion.isEmpty
                            ? l10n.updateCheckFailed
                            : l10n.updateUpToDate);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  },
          ),
          const SizedBox(height: 12),
          Text(
            l10n.aboutBody,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.dataSourceTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(l10n.dataSourceBody),
          const SizedBox(height: 24),
          Text(l10n.mapAttribution),
        ],
      ),
    );
  }
}
