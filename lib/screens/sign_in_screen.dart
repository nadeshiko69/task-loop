import 'dart:io';

import 'package:flutter/material.dart';

import '../repositories/auth_repository.dart';
import '../repositories/repositories.dart';
import '../widgets/error_snackbar.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _busy = false;

  Future<void> _runSignIn(
    Future<AppleSignInResult> Function() signIn,
  ) async {
    setState(() => _busy = true);
    try {
      final result = await signIn();
      await userRepository.ensureUser(
        authUser: result.user,
        fullNameFromApple: result.fullNameFromApple,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      showErrorSnackBar(context, error);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final showApple = Platform.isIOS;
    final showDevAnonymous = AuthRepository.allowsDevAnonymousSignIn;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                'Task-L',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              const Text('家族の家事を、最終実行日から数えて共有します。'),
              const Spacer(),
              if (showApple)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy
                        ? null
                        : () => _runSignIn(authRepository.signInWithApple),
                    child: Text(_busy ? 'ログイン中…' : 'Apple でサインイン'),
                  ),
                ),
              if (showDevAnonymous) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy
                        ? null
                        : () => _runSignIn(
                              authRepository.signInAnonymouslyForDev,
                            ),
                    child: Text(
                      _busy ? 'ログイン中…' : '開発用ログイン（匿名）',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Debug の Android だけ表示されます。'
                  ' Firebase Authentication で「匿名」を有効化してください。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (!showApple && !showDevAnonymous)
                Text(
                  'このビルドではログインできません。'
                  ' iOS、または Debug の Android で起動してください。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
