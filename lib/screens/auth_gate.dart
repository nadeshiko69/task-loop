import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../firebase_ready.dart';
import '../models/app_user.dart';
import '../models/household.dart';
import '../repositories/repositories.dart';
import 'household_setup_screen.dart';
import 'setup_required_screen.dart';
import 'sign_in_screen.dart';
import 'task_list_screen.dart';

/// ログイン状態 → 世帯の有無 の順で画面を切り替える。
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (!isFirebaseConfigured()) {
      return const SetupRequiredScreen();
    }

    return StreamBuilder<User?>(
      stream: authRepository.authState(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const _LoadingScaffold();
        }

        final firebaseUser = authSnap.data;
        if (firebaseUser == null) {
          return const SignInScreen();
        }

        return StreamBuilder<AppUser?>(
          stream: userRepository.watch(firebaseUser.uid),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const _LoadingScaffold();
            }

            final appUser = userSnap.data;
            if (appUser == null) {
              return _EnsureUserScreen(firebaseUser: firebaseUser);
            }
            if (!appUser.hasHousehold) {
              return HouseholdSetupScreen(user: appUser);
            }
            return _HouseholdLoader(user: appUser);
          },
        );
      },
    );
  }
}

class _EnsureUserScreen extends StatefulWidget {
  const _EnsureUserScreen({required this.firebaseUser});

  final User firebaseUser;

  @override
  State<_EnsureUserScreen> createState() => _EnsureUserScreenState();
}

class _EnsureUserScreenState extends State<_EnsureUserScreen> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    _ensure();
  }

  Future<void> _ensure() async {
    try {
      await userRepository.ensureUser(authUser: widget.firebaseUser);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ユーザー情報の準備に失敗しました\n$_error'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    setState(() => _error = null);
                    _ensure();
                  },
                  child: const Text('再試行'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const _LoadingScaffold();
  }
}

class _HouseholdLoader extends StatelessWidget {
  const _HouseholdLoader({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Household?>(
      stream: householdRepository.watch(user.householdId!),
      builder: (context, snap) {
        if (snap.hasError) {
          return Scaffold(
            body: Center(child: Text('世帯の読み込みに失敗しました\n${snap.error}')),
          );
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return const _LoadingScaffold();
        }
        final household = snap.data;
        if (household == null) {
          return HouseholdSetupScreen(user: user);
        }
        return TaskListScreen(user: user, household: household);
      },
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
