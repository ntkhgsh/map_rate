import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:map_rate/l10n/app_localizations.dart';

/// 画面下のバナー広告（Google 公式テストユニット）。
///
/// 狭い画面は標準バナー、広い画面は幅いっぱいの大きいアダプティブバナー。
class MapRateBannerAd extends StatefulWidget {
  const MapRateBannerAd({super.key});

  @override
  State<MapRateBannerAd> createState() => _MapRateBannerAdState();
}

class _MapRateBannerAdState extends State<MapRateBannerAd> {
  BannerAd? _bannerAd;
  AdSize? _pendingSize;
  var _pendingWidth = 0;
  var _isLoaded = false;
  var _retryCount = 0;
  var _loadToken = 0;
  /// 再試行上限まで失敗したとき true（「読み込み中」を出し続けない）
  var _loadGaveUp = false;

  /// 失敗時の再試行上限（無限ループを防ぐ）
  static const _maxRetries = 3;

  /// これ以上の幅なら大きいアダプティブバナーを使う
  static const _largeAdMinWidth = 468;

  static String get _adUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    return 'ca-app-pub-3940256099942544/2934735716';
  }

  static bool get _supported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> _ensureAdForWidth(double maxWidth) async {
    if (!mounted) return;
    final width = maxWidth.floor().clamp(1, 4096);

    // 同じ幅で読み込み中／表示中ならやり直さない
    if (_pendingWidth == width) {
      if (_isLoaded && _bannerAd != null) return;
      if (_pendingSize != null && !_isLoaded) return;
    }

    final size = await _resolveAdSize(width);
    if (!mounted) return;

    // すでに同じサイズなら読み直さない
    if (_bannerAd != null &&
        _isLoaded &&
        _bannerAd!.size.width == size.width &&
        _bannerAd!.size.height == size.height) {
      _pendingWidth = width;
      return;
    }
    if (_pendingSize != null &&
        _pendingSize!.width == size.width &&
        _pendingSize!.height == size.height &&
        !_isLoaded) {
      _pendingWidth = width;
      return;
    }

    _pendingWidth = width;
    _pendingSize = size;
    _retryCount = 0;
    _loadGaveUp = false;
    await _loadAd(size);
  }

  /// 親の実幅に合う広告サイズを選ぶ。
  Future<AdSize> _resolveAdSize(int width) async {
    try {
      // 広い画面：親幅いっぱいの大きいアダプティブバナー
      if (width >= _largeAdMinWidth) {
        final adaptive =
            await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
        if (adaptive != null) return adaptive;
        // 取得できないときの固定サイズの控え
        if (width >= 728) return AdSize.leaderboard;
        return AdSize.fullBanner;
      }

      // 現在地ボタン分で 320 未満になることがあるので、狭いときも幅に合わせる
      if (width < AdSize.banner.width) {
        final adaptive =
            await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
        if (adaptive != null) return adaptive;
      }
    } catch (error) {
      // 端末側でサイズ取得に失敗しても、固定バナーで表示を続ける
      debugPrint('MapRate BannerAd size resolve failed: $error');
    }
    return AdSize.banner;
  }

  Future<void> _loadAd(AdSize size) async {
    final token = ++_loadToken;
    final previous = _bannerAd;
    _bannerAd = null;
    _isLoaded = false;
    previous?.dispose();
    if (mounted) setState(() {});

    // main で待たずに初期化しているので、読み込み直前にも一度呼ぶ（多重呼び出し可）
    try {
      await MobileAds.instance.initialize();
    } catch (_) {}
    if (!mounted || token != _loadToken) return;

    final banner = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint(
            'MapRate BannerAd loaded ${size.width}x${size.height}',
          );
          if (!mounted || token != _loadToken) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
            _loadGaveUp = false;
            _pendingSize = size;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            'MapRate BannerAd failedToLoad: ${error.message} '
            '(code=${error.code}, domain=${error.domain})',
          );
          ad.dispose();
          if (!mounted || token != _loadToken) return;
          if (_retryCount >= _maxRetries) {
            // 上限まで失敗したら枠を畳む（読み込み中のまま残さない）
            setState(() {
              _bannerAd = null;
              _isLoaded = false;
              _loadGaveUp = true;
            });
            return;
          }
          _retryCount += 1;
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
          });
          Future<void>.delayed(const Duration(seconds: 5), () {
            if (mounted && !_isLoaded && !_loadGaveUp && token == _loadToken) {
              unawaited(_loadAd(size));
            }
          });
        },
      ),
    );
    await banner.load();
  }

  @override
  void dispose() {
    _loadToken += 1;
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_supported) {
      return const SizedBox.shrink();
    }

    // 親の実幅でサイズを決める（横に現在地ボタンがあるときも幅いっぱい使う）
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        // レイアウト確定後に読み込み（build 中の setState を避ける）
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(_ensureAdForWidth(maxWidth));
        });

        // 読み込み失敗で諦めたときは高さを 0 にして地図を広く使う
        if (_loadGaveUp && !_isLoaded) {
          return const SizedBox.shrink();
        }

        final height = (_isLoaded && _bannerAd != null)
            ? _bannerAd!.size.height.toDouble()
            : (_pendingSize?.height.toDouble() ??
                AdSize.banner.height.toDouble());
        final width = (_isLoaded && _bannerAd != null)
            ? _bannerAd!.size.width.toDouble()
            : double.infinity;

        return SizedBox(
          height: height,
          width: double.infinity,
          child: Center(
            child: _isLoaded && _bannerAd != null
                ? SizedBox(
                    width: width,
                    height: height,
                    child: AdWidget(ad: _bannerAd!),
                  )
                : Text(
                    AppLocalizations.of(context).adLoading,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
          ),
        );
      },
    );
  }
}
