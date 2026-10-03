import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:map_rate/l10n/app_localizations.dart';

/// 画面下のバナー広告（Google 公式テストユニット）。
///
/// 画面幅に合わせてサイズを選ぶ（大画面ほど大きい枠）。
class MapRateBannerAd extends StatefulWidget {
  const MapRateBannerAd({super.key});

  @override
  State<MapRateBannerAd> createState() => _MapRateBannerAdState();
}

class _MapRateBannerAdState extends State<MapRateBannerAd> {
  BannerAd? _bannerAd;
  AdSize? _pendingSize;
  var _isLoaded = false;
  var _retryCount = 0;
  var _loadToken = 0;

  /// 失敗時の再試行上限（無限ループを防ぐ）
  static const _maxRetries = 3;

  static String get _adUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    return 'ca-app-pub-3940256099942544/2934735716';
  }

  static bool get _supported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_supported) return;
    // 画面サイズが分かるタイミングで読み込む（回転・折りたたみにも追従）
    unawaited(_ensureAdForCurrentSize());
  }

  Future<void> _ensureAdForCurrentSize() async {
    final size = await _resolveAdSize();
    if (!mounted || size == null) return;
    // 同じサイズなら作り直さない
    if (_bannerAd != null &&
        _isLoaded &&
        _bannerAd!.size.width == size.width &&
        _bannerAd!.size.height == size.height) {
      return;
    }
    if (_pendingSize != null &&
        _pendingSize!.width == size.width &&
        _pendingSize!.height == size.height &&
        !_isLoaded) {
      return;
    }
    _pendingSize = size;
    _retryCount = 0;
    await _loadAd(size);
  }

  /// 画面幅に合わせたラージ・アダプティブバナー（大画面ほど大きくなる）。
  Future<AdSize?> _resolveAdSize() async {
    final media = MediaQuery.of(context);
    final width = media.size.width.truncate();
    if (width <= 0) return AdSize.banner;

    final adaptive =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSizeWithOrientation(
      media.orientation,
      width,
    );
    return adaptive ?? AdSize.banner;
  }

  Future<void> _loadAd(AdSize size) async {
    final token = ++_loadToken;
    // 古い広告は破棄してから作り直す
    final previous = _bannerAd;
    _bannerAd = null;
    _isLoaded = false;
    previous?.dispose();
    if (mounted) setState(() {});

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
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
          });
          if (_retryCount >= _maxRetries) return;
          _retryCount += 1;
          Future<void>.delayed(const Duration(seconds: 5), () {
            if (mounted && !_isLoaded && token == _loadToken) {
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
    if (_isLoaded && _bannerAd != null) {
      return Center(
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    }
    // 読み込み中は見込み高さだけ確保
    final placeholderHeight =
        _pendingSize?.height.toDouble() ?? AdSize.banner.height.toDouble();
    return SizedBox(
      height: placeholderHeight,
      width: double.infinity,
      child: Center(
        child: Text(
          AppLocalizations.of(context).adLoading,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}
