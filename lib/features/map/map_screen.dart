import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_rate/features/about/about_screen.dart';
import 'package:map_rate/features/ads/banner_ad_widget.dart';
import 'package:map_rate/features/currency/exchange_list_panel.dart';
import 'package:map_rate/features/currency/exchange_list_provider.dart';
import 'package:map_rate/features/map/map_place_provider.dart';
import 'package:map_rate/features/settings/app_settings_provider.dart';
import 'package:map_rate/features/settings/settings_screen.dart';
import 'package:map_rate/features/update/app_update_provider.dart';
import 'package:map_rate/features/update/update_available_banner.dart';
import 'package:map_rate/l10n/app_localizations.dart';

/// 全画面の地図。動かしたあとの中心座標から、国と通貨を判定する。
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  /// 指が止まってから国を調べるまでの待ち時間。
  static const _resolveDelay = Duration(milliseconds: 600);

  /// 下段 UI 未計測時の仮の高さ（画面比）。
  static const _bottomUiFallbackFactor = 0.46;

  final MapController _mapController = MapController();
  final GlobalKey _bottomUiKey = GlobalKey();
  Timer? _debounce;
  var _locating = false;

  /// 実測した下段（広告＋為替リスト）の高さ。地図サイズに合わせて十字を置く。
  double _bottomUiHeight = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  /// 下段 UI を避けた、見える地図領域の中央。
  Offset _computeCrosshairOffset(Size mapSize) {
    if (mapSize.width <= 0 || mapSize.height <= 0) {
      return Offset(mapSize.width / 2, mapSize.height / 2);
    }
    final fallback = mapSize.height * _bottomUiFallbackFactor + 72;
    final bottomUi = (_bottomUiHeight > 0 ? _bottomUiHeight : fallback)
        .clamp(0.0, mapSize.height - 120);
    final visibleHeight = mapSize.height - bottomUi;
    return Offset(mapSize.width / 2, visibleHeight / 2);
  }

  Size _currentMapSize() {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) return box.size;
    return MediaQuery.sizeOf(context);
  }

  /// 下段パネルの実高さを測り、十字位置を地図の空き領域に合わせる。
  void _scheduleBottomUiMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box =
          _bottomUiKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      final next = box.size.height;
      if ((next - _bottomUiHeight).abs() < 1) return;
      final oldOffset = _computeCrosshairOffset(_currentMapSize());
      setState(() => _bottomUiHeight = next);
      final newOffset = _computeCrosshairOffset(_currentMapSize());
      // 十字が動いたときだけ、照準の国を取り直す
      if ((oldOffset - newOffset).distance > 1) {
        try {
          _resolveFromCamera(_mapController.camera);
        } catch (_) {}
      }
    });
  }

  /// 十字の下にある緯度経度を取る（取れなければ地図の幾何中心）。
  LatLng _focusLatLng(MapCamera camera) {
    try {
      final offset = _computeCrosshairOffset(_currentMapSize());
      return camera.screenOffsetToLatLng(offset);
    } catch (_) {
      return camera.center;
    }
  }

  void _resolveFromCamera(MapCamera camera) {
    final focus = _focusLatLng(camera);
    // 十字位置で距離ソートし、国判定は非同期で後から並びへ反映する
    ref.read(exchangeListProvider.notifier).onMapBoundsChanged(
          camera.visibleBounds,
          focusLat: focus.latitude,
          focusLng: focus.longitude,
        );
    unawaited(_resolveFocusCountry(focus));
  }

  Future<void> _resolveFocusCountry(LatLng focus) async {
    await ref.read(mapPlaceProvider.notifier).resolveCenter(
          latitude: focus.latitude,
          longitude: focus.longitude,
        );
    if (!mounted) return;
    final code = ref.read(mapPlaceProvider).countryCode;
    ref.read(exchangeListProvider.notifier).setFocusCountry(code);
  }

  void _onMapReady() {
    _resolveFromCamera(_mapController.camera);
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    _debounce?.cancel();
    _debounce = Timer(_resolveDelay, () {
      _resolveFromCamera(camera);
    });
  }

  Future<void> _goToMyLocation() async {
    final l10n = AppLocalizations.of(context);
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) {
        if (mounted) {
          _snack(l10n.locationServiceDisabled);
        }
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          _snack(l10n.locationPermissionDenied);
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
      // 緯度経度の妥当性を確認してから地図を動かす
      if (position.latitude < -90 ||
          position.latitude > 90 ||
          position.longitude < -180 ||
          position.longitude > 180) {
        if (mounted) _snack(l10n.locationFailed);
        return;
      }

      // 現在地が十字の真下に来るよう、画面上のズレを補正する
      // ズームは広め（国〜広域）に引いて、周辺通貨が一覧しやすいようにする
      final mapSize = _currentMapSize();
      final crosshair = _computeCrosshairOffset(mapSize);
      final offsetY = crosshair.dy - mapSize.height / 2;
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        5,
        offset: Offset(0, offsetY),
      );
      try {
        _resolveFromCamera(_mapController.camera);
      } catch (_) {}
    } catch (_) {
      if (mounted) _snack(l10n.locationFailed);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openAbout() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(mapPlaceProvider, (previous, next) {
      if (next.countryCode == previous?.countryCode) return;
      // 十字下の国が変わったら、並び（固定の次）を更新する
      ref.read(exchangeListProvider.notifier).setFocusCountry(next.countryCode);
    });

    // リスト開閉で下段高さが変わるので、十字位置を取り直す
    ref.listen(
      appSettingsProvider.select((s) => s.exchangeListCollapsed),
      (previous, next) {
        _bottomUiHeight = 0;
        _scheduleBottomUiMeasure();
      },
    );

    _scheduleBottomUiMeasure();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mapSize = Size(constraints.maxWidth, constraints.maxHeight);
          final crosshair = _computeCrosshairOffset(mapSize);
          final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
          // キーボードで縮んだ高さからはみ出さない上限（上部操作余白を少し残す）
          final maxBottomUiHeight = (mapSize.height - (keyboardOpen ? 8 : 48))
              .clamp(120.0, mapSize.height);

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(
                    MapPlace.initialLatitude,
                    MapPlace.initialLongitude,
                  ),
                  initialZoom: 5,
                  minZoom: 2,
                  maxZoom: 18,
                  backgroundColor: isDark
                      ? const Color(0xFF1A2332)
                      : const Color(0xFFD7E7F5),
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                  onMapReady: _onMapReady,
                  onPositionChanged: _onPositionChanged,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.maprate.map_rate',
                    maxNativeZoom: 19,
                    keepBuffer: 2,
                    panBuffer: 1,
                  ),
                ],
              ),
              // 為替取得の照準。下段パネルに隠れないよう、見える地図の中央に置く
              IgnorePointer(
                child: Stack(
                  children: [
                    Positioned(
                      left: crosshair.dx - 22,
                      top: crosshair.dy - 22,
                      child: const _MapCrosshair(size: 44),
                    ),
                  ],
                ),
              ),
              // 上部: ブランドバー + OSM 帰属 + メニュー（＋更新案内）
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // タイトルは為替パネル見出し側に集約。ここは OSM とメニューのみ
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),
                          // OSM 表記は地図に溶かす（黒背景チップは使わない）
                          Padding(
                            padding: const EdgeInsets.only(top: 6, right: 2),
                            child: Text(
                              l10n.mapAttribution,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.88)
                                    : const Color(0xFF1A2B3C)
                                        .withValues(alpha: 0.78),
                                shadows: [
                                  Shadow(
                                    color: (isDark ? Colors.black : Colors.white)
                                        .withValues(alpha: 0.7),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          _GlassIconButton(
                            tooltip: l10n.settingsTitle,
                            child: PopupMenuButton<String>(
                              tooltip: l10n.settingsTitle,
                              padding: EdgeInsets.zero,
                              onSelected: (value) {
                                if (value == 'about') _openAbout();
                                if (value == 'settings') _openSettings();
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'about',
                                  child: Text(l10n.menuAbout),
                                ),
                                PopupMenuItem(
                                  value: 'settings',
                                  child: Text(l10n.menuSettings),
                                ),
                              ],
                              child: const Icon(Icons.more_horiz, size: 22),
                            ),
                          ),
                        ],
                      ),
                      if (ref.watch(appUpdateProvider).shouldShowBanner) ...[
                        const SizedBox(height: 8),
                        const UpdateAvailableBanner(),
                      ],
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                // SafeArea 込みの高さで、見える地図領域の中央に十字を置く
                child: ConstrainedBox(
                  // キーボード表示時も広告＋リストが画面外へ押し出されないようにする
                  constraints: BoxConstraints(maxHeight: maxBottomUiHeight),
                  child: KeyedSubtree(
                    key: _bottomUiKey,
                    child: SafeArea(
                      top: false,
                      // Scaffold が既にキーボード分だけ持ち上げているため二重に足さない
                      bottom: !keyboardOpen,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        // Flexible(loose) で「親の上限まで」かつ「必要な高さだけ」取る
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 入力中は FAB・広告を隠し、キーボード用の高さを確保する
                            if (!keyboardOpen) ...[
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: FloatingActionButton.small(
                                    heroTag: 'my_location',
                                    tooltip: l10n.myLocationTooltip,
                                    onPressed:
                                        _locating ? null : _goToMyLocation,
                                    child: _locating
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.my_location),
                                  ),
                                ),
                              ),
                              const MapRateBannerAd(),
                              const SizedBox(height: 6),
                            ],
                            const Flexible(
                              fit: FlexFit.loose,
                              child: ExchangeListPanel(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

}

/// 地図上でも目立つ半透明のアイコンボタン枠。
class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.child,
    required this.tooltip,
  });

  final Widget child;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// 地図の照準用十字。白い縁取りでどんな地図上でも見えるようにする。
class _MapCrosshair extends StatelessWidget {
  const _MapCrosshair({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MapCrosshairPainter(
          color: const Color(0xFF1578B5),
          outline: Colors.white,
        ),
      ),
    );
  }
}

class _MapCrosshairPainter extends CustomPainter {
  _MapCrosshairPainter({required this.color, required this.outline});

  final Color color;
  final Color outline;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final arm = size.shortestSide * 0.42;
    final gap = size.shortestSide * 0.12;

    void drawCross(Paint paint) {
      // 横線（中央に隙間）
      canvas.drawLine(
        Offset(center.dx - arm, center.dy),
        Offset(center.dx - gap, center.dy),
        paint,
      );
      canvas.drawLine(
        Offset(center.dx + gap, center.dy),
        Offset(center.dx + arm, center.dy),
        paint,
      );
      // 縦線（中央に隙間）
      canvas.drawLine(
        Offset(center.dx, center.dy - arm),
        Offset(center.dx, center.dy - gap),
        paint,
      );
      canvas.drawLine(
        Offset(center.dx, center.dy + gap),
        Offset(center.dx, center.dy + arm),
        paint,
      );
      canvas.drawCircle(center, 2.2, paint..style = PaintingStyle.fill);
      paint.style = PaintingStyle.stroke;
    }

    final outlinePaint = Paint()
      ..color = outline
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final colorPaint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    drawCross(outlinePaint);
    drawCross(colorPaint);
  }

  @override
  bool shouldRepaint(covariant _MapCrosshairPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.outline != outline;
  }
}
