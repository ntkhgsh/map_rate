import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:map_rate/features/update/app_update_provider.dart';
import 'package:map_rate/l10n/app_localizations.dart';

/// 更新があるときに地図上部へ出す案内。
class UpdateAvailableBanner extends ConsumerWidget {
  const UpdateAvailableBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final update = ref.watch(appUpdateProvider);
    if (!update.shouldShowBanner) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final latest = update.latestVersion ?? '';

    return Material(
      elevation: 4,
      color: colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.system_update_alt,
              color: colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.updateAvailableTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.updateAvailableBody(latest),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilledButton.tonal(
                        onPressed: () async {
                          final opened = await ref
                              .read(appUpdateProvider.notifier)
                              .openStore();
                          if (!context.mounted) return;
                          if (!opened) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.updateOpenFailed)),
                            );
                          }
                        },
                        child: Text(l10n.updateNow),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(appUpdateProvider.notifier).dismiss();
                        },
                        child: Text(l10n.updateLater),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.close,
              visualDensity: VisualDensity.compact,
              onPressed: () {
                ref.read(appUpdateProvider.notifier).dismiss();
              },
              icon: const Icon(Icons.close, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
