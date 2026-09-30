import 'package:flutter_test/flutter_test.dart';
import 'package:task_loop/ads/ad_ids.dart';

void main() {
  test('debug では Google のテスト用ユニット ID を使う', () {
    expect(AdIds.useTestAds, isTrue);
    expect(AdIds.banner, contains('ca-app-pub-3940256099942544'));
    expect(AdIds.interstitial, contains('ca-app-pub-3940256099942544'));
  });
}
