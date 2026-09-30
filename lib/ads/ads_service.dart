import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';

/// Mobile Ads の初期化と、セッション内 1 回のインタースティシャル。
class AdsService {
  bool _initialized = false;
  bool _loadingInterstitial = false;
  bool _shownInterstitialThisSession = false;
  Future<void>? _initializing;
  InterstitialAd? _interstitial;

  bool get isReady => _initialized;

  bool get isSupported {
    if (kIsWeb) {
      return false;
    }
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return false;
    }
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  Future<void> initialize() async {
    if (_initialized || !isSupported) {
      return;
    }
    if (_initializing != null) {
      await _initializing;
      return;
    }
    final future = _initialize();
    _initializing = future;
    try {
      await future;
    } finally {
      _initializing = null;
    }
  }

  Future<void> _initialize() async {
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      preloadInterstitial();
    } catch (error) {
      debugPrint('AdMob の初期化に失敗しました: $error');
    }
  }

  void preloadInterstitial() {
    if (!isReady ||
        _shownInterstitialThisSession ||
        _interstitial != null ||
        _loadingInterstitial) {
      return;
    }

    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _loadingInterstitial = false;
        },
        onAdFailedToLoad: (error) {
          _loadingInterstitial = false;
          debugPrint('インタースティシャルの読み込みに失敗しました: $error');
        },
      ),
    );
  }

  /// 準備できていなければすぐ戻る。タスク追加自体は止めない。
  Future<void> showInterstitialAfterTaskAdded() async {
    final ad = _interstitial;
    if (!isReady || _shownInterstitialThisSession || ad == null) {
      return;
    }

    final dismissed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        _shownInterstitialThisSession = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!dismissed.isCompleted) {
          dismissed.complete();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('インタースティシャルの表示に失敗しました: $error');
        ad.dispose();
        if (!dismissed.isCompleted) {
          dismissed.complete();
        }
      },
    );

    _interstitial = null;
    try {
      await ad.show();
      await dismissed.future;
    } catch (error) {
      debugPrint('インタースティシャルの表示に失敗しました: $error');
      ad.dispose();
    }
  }
}

final adsService = AdsService();
