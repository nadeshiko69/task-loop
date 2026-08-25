import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Apple ログインとアカウント削除だけを担当する。
class AuthRepository {
  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> authState() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Apple は氏名を「初回ログインのときだけ」返すので、呼び出し側で保存する。
  Future<AppleSignInResult> signInWithApple() async {
    if (!Platform.isIOS) {
      throw StateError('Apple ログインは iOS のみです');
    }

    final rawNonce = _createNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final apple = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final credential = OAuthProvider('apple.com').credential(
      idToken: apple.identityToken,
      rawNonce: rawNonce,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final given = apple.givenName?.trim() ?? '';
    final family = apple.familyName?.trim() ?? '';
    final fullName = '$family$given'.trim();

    return AppleSignInResult(
      user: userCredential.user!,
      fullNameFromApple: fullName.isEmpty ? null : fullName,
    );
  }

  Future<void> signOut() => _auth.signOut();

  /// 削除前に再認証が必要なことがある。
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }
    await user.delete();
  }
}

class AppleSignInResult {
  const AppleSignInResult({
    required this.user,
    this.fullNameFromApple,
  });

  final User user;
  final String? fullNameFromApple;
}

String _createNonce([int length = 32]) {
  const charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(
    length,
    (_) => charset[random.nextInt(charset.length)],
  ).join();
}
