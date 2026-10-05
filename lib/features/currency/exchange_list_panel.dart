import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:map_rate/features/currency/country_names.dart';
import 'package:map_rate/features/currency/exchange_list_models.dart';
import 'package:map_rate/features/currency/exchange_list_provider.dart';
import 'package:map_rate/features/currency/rate_history_sheet.dart';
import 'package:map_rate/features/currency/rate_sparkline.dart';
import 'package:map_rate/features/settings/app_settings_provider.dart';
import 'package:map_rate/features/update/app_update_provider.dart';
import 'package:map_rate/features/update/version_compare.dart';
import 'package:map_rate/l10n/app_localizations.dart';

/// 地図の下に重ねる為替リスト（国名・金額・推移サムネ）。
class ExchangeListPanel extends ConsumerWidget {
  const ExchangeListPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(exchangeListProvider);
    final settings = ref.watch(appSettingsProvider);
    final update = ref.watch(appUpdateProvider);
    final collapsed = settings.exchangeListCollapsed;
    final colorScheme = Theme.of(context).colorScheme;
    // タイトル横の短い版表示（例: 0.0.1 → v1）
    final versionLabel = update.currentVersion.isEmpty
        ? 'v1'
        : formatDisplayVersion(update.currentVersion);
    final locale = Localizations.localeOf(context);
    final localeTag = locale.toString();
    final localeKey = fromLocale(
      locale.languageCode,
      locale.countryCode,
      locale.scriptCode,
    );

    // 親（地図下段）の残り高さに必ず収める。固定％だけだとキーボードで溢れる
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaHeight = MediaQuery.sizeOf(context).height;
        final preferred = mediaHeight * 0.46;
        final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
        // 親から渡る有限高さがあるときは、それを絶対に超えない
        final available = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : preferred;
        final maxHeight = collapsed
            ? 56.0
            : keyboardOpen
                // 入力中は親の上限いっぱい（広告・FABは親側で非表示）
                ? available
                : available.clamp(80.0, preferred);

        return Material(
          elevation: 3,
          // うっすら地図が見える透過パネル
          color: colorScheme.surface.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: maxHeight,
            width: double.infinity,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 4, 0),
                  child: Row(
                    children: [
                      // アプリアイコン＋タイトル＋バージョン
                      Expanded(
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/app_icon.png',
                                width: 28,
                                height: 28,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                  Icons.map_rounded,
                                  size: 28,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                l10n.appTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                // 同梱フォント Sora（通信不要）。ブランド名はラテン表記。
                                style: TextStyle(
                                  fontFamily: 'Sora',
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                  height: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                versionLabel,
                                style: TextStyle(
                                  fontFamily: 'Sora',
                                  color: colorScheme.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            // 更新があるときは小さな点で知らせる
                            if (update.shouldShowBanner) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: colorScheme.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (state.isLoading)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      IconButton(
                        tooltip: l10n.retry,
                        visualDensity: VisualDensity.compact,
                        onPressed: state.isLoading
                            ? null
                            : () => ref
                                .read(exchangeListProvider.notifier)
                                .refreshRates(),
                        icon: const Icon(Icons.refresh, size: 20),
                      ),
                      // 為替リストの表示／非表示
                      IconButton(
                        tooltip: collapsed
                            ? l10n.showExchangeList
                            : l10n.hideExchangeList,
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          ref
                              .read(appSettingsProvider.notifier)
                              .toggleExchangeListCollapsed();
                        },
                        icon: Icon(
                          collapsed
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!collapsed) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                    child: Text(
                      [
                        _updateLine(l10n, state, localeTag),
                        if (state.sourceName == 'offline seed')
                          l10n.offlineSeedHint
                        else if (state.errorKey == 'ratesLoadFailed')
                          l10n.ratesLoadFailed,
                      ].where((s) => s.isNotEmpty).join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: state.errorKey != null ||
                                    state.sourceName == 'offline seed'
                                ? colorScheme.error
                                : null,
                          ),
                    ),
                  ),
                  Expanded(
                    child: state.rows.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                            child: Text(
                              l10n.noCountriesOnMap,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          )
                        : ReorderableListView.builder(
                            buildDefaultDragHandles: false,
                            padding: const EdgeInsets.only(bottom: 8),
                            itemCount: state.rows.length,
                            onReorderItem: (oldIndex, newIndex) {
                              ref
                                  .read(exchangeListProvider.notifier)
                                  .reorder(oldIndex, newIndex);
                            },
                            itemBuilder: (context, index) {
                              final row = state.rows[index];
                              return _ExchangeRowTile(
                                key: ValueKey(row.countryCode),
                                row: row,
                                index: index,
                                locale: localeTag,
                                localeKey: localeKey,
                                rateDate: state.rateDate,
                              );
                            },
                          ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _updateLine(
    AppLocalizations l10n,
    ExchangeListState state,
    String locale,
  ) {
    if (state.fetchedAt == null && state.rateDate == null) {
      return l10n.notUpdatedYet;
    }
    final parts = <String>[];
    if (state.fetchedAt != null) {
      final local = state.fetchedAt!.toLocal();
      final formatted = DateFormat.MMMd(locale).add_Hm().format(local);
      parts.add(l10n.updatedAt(formatted));
    }
    if (state.rateDate != null) {
      parts.add(state.rateDate!);
    }
    return parts.join(' · ');
  }
}

class _ExchangeRowTile extends ConsumerStatefulWidget {
  const _ExchangeRowTile({
    super.key,
    required this.row,
    required this.index,
    required this.locale,
    required this.localeKey,
    this.rateDate,
  });

  final ExchangeRow row;
  final int index;
  final String locale;
  final LocaleKey localeKey;
  final String? rateDate;

  @override
  ConsumerState<_ExchangeRowTile> createState() => _ExchangeRowTileState();
}

class _ExchangeRowTileState extends ConsumerState<_ExchangeRowTile> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  /// いまこの行をキーボード入力中か（true の間だけ TextFieldを出す）
  var _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!mounted) return;
    if (_focusNode.hasFocus) {
      if (!_isEditing) {
        setState(() => _isEditing = true);
      }
      return;
    }
    // フォーカス喪失時にだけ確定→表示モードへ（入力中の即時換算は onChanged 済み）
    if (!_isEditing) return;
    final parsed = _parseAmount(_controller.text);
    if (parsed != null) {
      unawaited(
        ref.read(exchangeListProvider.notifier).setAmountForCountry(
              countryCode: widget.row.countryCode,
              amount: parsed,
            ),
      );
    }
    setState(() => _isEditing = false);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// 表示用の枠線（入力欄と同じ見た目にする）
  InputDecoration _amountDecoration({
    required bool isBase,
    required ColorScheme colorScheme,
    required String? hintText,
  }) {
    final borderColor = isBase ? colorScheme.primary : colorScheme.outline;
    final width = isBase ? 2.0 : 1.0;
    return InputDecoration(
      isDense: true,
      hintText: hintText,
      filled: isBase,
      fillColor: isBase ? colorScheme.surface.withValues(alpha: 0.9) : null,
      prefixIcon: isBase
          ? Icon(Icons.edit, size: 16, color: colorScheme.primary)
          : null,
      prefixIconConstraints: isBase
          ? const BoxConstraints(minWidth: 28, minHeight: 28)
          : null,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: width),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: width),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }

  /// タップで入力開始。controller に今の金額を載せてからフォーカスする
  void _beginEditing() {
    final row = widget.row;
    // 入力欄は整数なら小数なし。小数を使うときだけ小数を出す
    _controller.text =
        row.hasRate ? _formatAmountForInput(row.amount, widget.locale) : '';
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
    setState(() => _isEditing = true);
    // 次フレームでフォーカス（TextField が build されたあと）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final row = widget.row;
    final colorScheme = Theme.of(context).colorScheme;
    final countryName =
        localizedCountryName(row.countryCode, widget.localeKey);

    final isBase = row.isBaseInput;

    return Material(
      key: ValueKey('row-${row.countryCode}'),
      // 手入力した基準行は背景色で一目で分かるようにする
      color: isBase
          ? colorScheme.primaryContainer.withValues(alpha: 0.45)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(row.flagEmoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            SizedBox(
              width: 88,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    countryName.isEmpty ? row.countryCode : countryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight:
                              isBase ? FontWeight.w700 : FontWeight.w500,
                        ),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          row.currency.code,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ),
                      if (isBase) ...[
                        const SizedBox(width: 4),
                        Text(
                          l10n.baseInputLabel,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: row.hasRate
                  ? ConstrainedBox(
                      // 桁が多くても切らず、必要なら高さを広げて全桁見せる
                      constraints: const BoxConstraints(minHeight: 40),
                      child: _isEditing
                          ? TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              autofocus: true,
                              // 金額は右寄せで揃える
                              textAlign: TextAlign.right,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: isBase
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                  ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              // 長い数値も横スクロールで全部見える
                              scrollPhysics: const BouncingScrollPhysics(),
                              scrollPadding: const EdgeInsets.only(
                                bottom: 80,
                                top: 24,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.,]'),
                                ),
                              ],
                              decoration: _amountDecoration(
                                isBase: isBase,
                                colorScheme: colorScheme,
                                hintText: row.currency.symbol,
                              ),
                              onChanged: (value) {
                                final parsed = _parseAmount(value);
                                if (parsed == null) return;
                                // 1文字ごとに全行（固定含む）を換算し直す
                                unawaited(
                                  ref
                                      .read(exchangeListProvider.notifier)
                                      .setAmountForCountry(
                                        countryCode: widget.row.countryCode,
                                        amount: parsed,
                                      ),
                                );
                              },
                              // 確定処理はフォーカス喪失（_onFocusChange）に集約
                              onEditingComplete: () => _focusNode.unfocus(),
                              onSubmitted: (_) => _focusNode.unfocus(),
                              onTapOutside: (_) => _focusNode.unfocus(),
                            )
                          : InkWell(
                              onTap: _beginEditing,
                              borderRadius: BorderRadius.circular(4),
                              child: InputDecorator(
                                decoration: _amountDecoration(
                                  isBase: isBase,
                                  colorScheme: colorScheme,
                                  hintText: row.currency.symbol,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  // 表示も右寄せ
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _formatAmount(row.amount, widget.locale),
                                    textAlign: TextAlign.right,
                                    // ellipsis にせず、縮めてでも全桁を出す
                                    softWrap: false,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: isBase
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                    )
                  : Text(
                      l10n.rateUnavailable,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
            ),
            const SizedBox(width: 6),
            // サムネをタップすると大きな推移グラフを開く
            Tooltip(
              message: l10n.showTrendChart,
              child: InkWell(
                onTap: () {
                  showRateHistorySheet(
                    context: context,
                    title: '$countryName · ${row.currency.code}',
                    values: row.history,
                    currencyCode: row.currency.code,
                    rateDate: widget.rateDate,
                  );
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: RateSparkline(
                    values: row.history,
                    width: 48,
                    height: 28,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: row.isPinned ? l10n.unpinCountry : l10n.pinCountry,
              visualDensity: VisualDensity.compact,
              onPressed: () {
                ref
                    .read(exchangeListProvider.notifier)
                    .togglePinned(row.countryCode);
              },
              icon: Icon(
                row.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                size: 18,
                color: row.isPinned ? colorScheme.primary : null,
              ),
            ),
            ReorderableDragStartListener(
              index: widget.index,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Icon(Icons.drag_handle, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double value, String locale) {
    if (!value.isFinite) return '0';
    // 実質整数なら小数点以下を出さない
    if (_isWholeNumber(value)) {
      return NumberFormat.decimalPatternDigits(
        locale: locale,
        decimalDigits: 0,
      ).format(value.round());
    }
    // 表示は小数点以下最大2桁まで
    return NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 2,
    ).format(value);
  }

  /// 入力欄用。整数は小数なし。小数があるときも最大2桁。
  String _formatAmountForInput(double value, String locale) {
    if (!value.isFinite) return '0';
    if (_isWholeNumber(value)) {
      return NumberFormat.decimalPatternDigits(
        locale: locale,
        decimalDigits: 0,
      ).format(value.round());
    }
    // 小数点以下は最大2桁（例: 12.5 → "12.5"、12.345 → "12.35"）
    return NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 2,
    ).format(value);
  }

  /// 浮動小数の誤差を無視して整数とみなせるか。
  bool _isWholeNumber(double value) {
    if (!value.isFinite) return false;
    return (value - value.roundToDouble()).abs() < 1e-9;
  }

  double? _parseAmount(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    var text = trimmed.replaceAll(' ', '');
    if (text.contains(',') && text.contains('.')) {
      if (text.lastIndexOf(',') > text.lastIndexOf('.')) {
        text = text.replaceAll('.', '').replaceAll(',', '.');
      } else {
        text = text.replaceAll(',', '');
      }
    } else if (text.contains(',')) {
      text = text.replaceAll(',', '.');
    }
    final value = double.tryParse(text);
    if (value == null || !value.isFinite || value < 0 || value > 1e12) {
      return null;
    }
    return value;
  }
}
