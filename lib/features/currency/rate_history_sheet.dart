import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:map_rate/features/currency/rate_sparkline.dart';
import 'package:map_rate/l10n/app_localizations.dart';

/// スパークラインをタップしたときに出す、大きめの推移グラフ。
Future<void> showRateHistorySheet({
  required BuildContext context,
  required String title,
  required List<double> values,
  required String currencyCode,
  String? rateDate,
}) {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toString();
  // 通貨コードは表示用に整形（不正文字は落とす）
  final safeCode = currencyCode.trim().toUpperCase();
  final code = RegExp(r'^[A-Z]{3}$').hasMatch(safeCode) ? safeCode : '---';

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      final latest = values.isEmpty ? null : values.last;
      final change = _changeInfo(values);
      final changeColor = change == null
          ? colorScheme.onSurfaceVariant
          : change.pct >= 0
              ? const Color(0xFF1B7F4A)
              : colorScheme.error;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 見出しは短く。国・通貨名を主役にする
              Text(
                l10n.trendChartTitle,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 0.3,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.trendYAxisUnit(code),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              // 最新値と期間変化を大きく見せる
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      latest == null
                          ? l10n.rateUnavailable
                          : _formatRate(latest, locale),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.05,
                            letterSpacing: -0.5,
                          ),
                    ),
                  ),
                  if (change != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: changeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            change.pct >= 0
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: 18,
                            color: changeColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            change.label,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: changeColor,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              // グラフ本体（余計な枠・単位ラベルを減らして線を見やすく）
              AspectRatio(
                aspectRatio: 1.55,
                child: _TrendChart(
                  values: values,
                  rateDate: rateDate,
                  locale: locale,
                  lineColor: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.close),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ChangeInfo {
  const _ChangeInfo({required this.pct, required this.label});

  final double pct;
  final String label;
}

_ChangeInfo? _changeInfo(List<double> values) {
  if (values.length < 2) return null;
  final first = values.first;
  final last = values.last;
  if (!first.isFinite || !last.isFinite || first == 0) return null;
  final pct = (last - first) / first * 100;
  final sign = pct >= 0 ? '+' : '';
  return _ChangeInfo(
    pct: pct,
    label: '$sign${pct.toStringAsFixed(2)}%',
  );
}

String _formatRate(double value, String locale) {
  if (!value.isFinite) return '—';
  // 整数に近い値は小数なし。それ以外は読みやすい桁数
  if ((value - value.roundToDouble()).abs() < 1e-9) {
    return NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 0,
    ).format(value.round());
  }
  final digits = value.abs() >= 1000
      ? 2
      : value.abs() >= 1
          ? 2
          : 4;
  return NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: digits,
  ).format(value);
}

/// 縦軸（高・低）と横軸（始・終）だけ付けたシンプルな推移図。
class _TrendChart extends StatelessWidget {
  const _TrendChart({
    required this.values,
    required this.rateDate,
    required this.locale,
    required this.lineColor,
  });

  final List<double> values;
  final String? rateDate;
  final String locale;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tickStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontSize: 11,
        );
    final y = _yExtremes();
    final x = _xLabels();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 縦軸は最高・最低だけ
                  SizedBox(
                    width: 56,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(y.maxLabel, style: tickStyle),
                        const Spacer(),
                        Text(y.minLabel, style: tickStyle),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RateSparkline(
                      values: values,
                      width: double.infinity,
                      height: double.infinity,
                      filled: true,
                      showEndDot: true,
                      strokeWidth: 2.4,
                      color: lineColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // 横軸は開始日と終了日だけ
            Padding(
              padding: const EdgeInsets.only(left: 64),
              child: Row(
                children: [
                  Text(x.start, style: tickStyle),
                  const Spacer(),
                  Text(x.end, style: tickStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ({String maxLabel, String minLabel}) _yExtremes() {
    if (values.isEmpty) {
      return (maxLabel: '—', minLabel: '—');
    }
    var minV = values.first;
    var maxV = values.first;
    for (final v in values) {
      if (!v.isFinite) continue;
      if (v < minV) minV = v;
      if (v > maxV) maxV = v;
    }
    if (!minV.isFinite || !maxV.isFinite) {
      return (maxLabel: '—', minLabel: '—');
    }
    return (
      maxLabel: _formatRate(maxV, locale),
      minLabel: _formatRate(minV, locale),
    );
  }

  ({String start, String end}) _xLabels() {
    final formatter = DateFormat.Md(locale);
    final end = _parseRateDate(rateDate) ?? DateTime.now().toUtc();
    if (values.length <= 1) {
      final label = formatter.format(end.toLocal());
      return (start: label, end: label);
    }
    final start = end.subtract(Duration(days: values.length - 1));
    return (
      start: formatter.format(start.toLocal()),
      end: formatter.format(end.toLocal()),
    );
  }

  DateTime? _parseRateDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)) return null;
    return DateTime.tryParse('${raw}T00:00:00Z');
  }
}
