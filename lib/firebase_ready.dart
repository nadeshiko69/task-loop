import 'firebase_options.dart';

/// `flutterfire configure` 済みなら true。
/// 未設定でもアプリは起動し、セットアップ画面を出す。
bool isFirebaseConfigured() {
  try {
    return DefaultFirebaseOptions.currentPlatform.apiKey.isNotEmpty;
  } catch (_) {
    return false;
  }
}
