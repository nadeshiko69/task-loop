import 'package:flutter/foundation.dart';

/// AdMob のアプリ ID / ユニット ID。
///
/// デバッグとプロファイルでは Google のテスト用 ID を使う。
/// 本番 ID を開発中に叩くとアカウント停止の原因になる。
class AdIds {
  static const iosAppId = 'ca-app-pub-7526340356579081~4034683504';
  static const androidAppId = 'ca-app-pub-7526340356579081~8192586216';

  static const _iosBanner = 'ca-app-pub-7526340356579081/3008542297';
  static const _androidBanner = 'ca-app-pub-7526340356579081/9382378954';
  static const _iosInterstitial = 'ca-app-pub-7526340356579081/3843111818';
  static const _androidInterstitial = 'ca-app-pub-7526340356579081/6879504545';

  static const _testIosBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const _testAndroidBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _testIosInterstitial = 'ca-app-pub-3940256099942544/4411468910';
  static const _testAndroidInterstitial =
      'ca-app-pub-3940256099942544/1033173712';

  static bool get useTestAds => !kReleaseMode;

  static bool get _isIos => defaultTargetPlatform == TargetPlatform.iOS;

  static String get banner {
    if (useTestAds) {
      return _isIos ? _testIosBanner : _testAndroidBanner;
    }
    return _isIos ? _iosBanner : _androidBanner;
  }

  static String get interstitial {
    if (useTestAds) {
      return _isIos ? _testIosInterstitial : _testAndroidInterstitial;
    }
    return _isIos ? _iosInterstitial : _androidInterstitial;
  }
}
