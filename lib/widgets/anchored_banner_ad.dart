import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ads/ad_ids.dart';
import '../ads/ads_service.dart';

/// 画面下部に固定するアダプティブバナー。
class AnchoredBannerAd extends StatefulWidget {
  const AnchoredBannerAd({super.key});

  @override
  State<AnchoredBannerAd> createState() => _AnchoredBannerAdState();
}

class _AnchoredBannerAdState extends State<AnchoredBannerAd> {
  BannerAd? _banner;
  bool _loaded = false;
  int? _loadedWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(_ensureLoaded());
  }

  Future<void> _ensureLoaded() async {
    if (!adsService.isSupported) {
      return;
    }
    if (!adsService.isReady) {
      await adsService.initialize();
      if (!mounted) {
        return;
      }
    }
    await _load();
  }

  Future<void> _load() async {
    if (!adsService.isReady) {
      return;
    }

    final width = MediaQuery.sizeOf(context).width.truncate();
    if (width <= 0 || _loadedWidth == width) {
      return;
    }

    _banner?.dispose();
    _banner = null;
    _loaded = false;
    _loadedWidth = width;

    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || size == null) {
      return;
    }

    final banner = BannerAd(
      adUnitId: AdIds.banner,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _banner = ad as BannerAd;
            _loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('バナーの読み込みに失敗しました: $error');
          ad.dispose();
          if (mounted) {
            setState(() {
              _banner = null;
              _loaded = false;
            });
          }
        },
      ),
    );

    _banner = banner;
    await banner.load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;
    if (!_loaded || banner == null) {
      return const SizedBox.shrink();
    }

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: banner.size.width.toDouble(),
          height: banner.size.height.toDouble(),
          child: AdWidget(ad: banner),
        ),
      ),
    );
  }
}
