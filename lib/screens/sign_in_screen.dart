import 'package:flutter/material.dart';

import '../repositories/repositories.dart';
import '../widgets/error_snackbar.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _busy = false;

  Future<void> _signIn() async {
    setState(() => _busy = true);
    try {
      final result = await authRepository.signInWithApple();
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
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : _signIn,
                  child: Text(_busy ? 'ログイン中…' : 'Apple でサインイン'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
