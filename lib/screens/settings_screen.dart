import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/app_user.dart';
import '../models/household.dart';
import '../repositories/repositories.dart';
import '../widgets/error_snackbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.user,
    required this.household,
  });

  final AppUser user;
  final Household household;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _busy = false;

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: widget.household.inviteCode));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('招待コードをコピーしました')));
  }

  Future<void> _signOut() async {
    await authRepository.signOut();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('アカウントを削除しますか？'),
          content: const Text(
            'この操作は取り消せません。家族グループからは外れますが、'
            'ほかの人の家事はそのまま残ります。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('やめる'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('削除する'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }

    setState(() => _busy = true);
    try {
      await householdRepository.leaveHousehold(
        uid: widget.user.uid,
        householdId: widget.household.id,
      );
      await userRepository.deleteUserDoc(widget.user.uid);
      await authRepository.deleteAccount();
    } catch (error) {
      if (!mounted) {
        return;
      }
      showErrorSnackBar(
        context,
        '削除に失敗しました。もう一度 Apple でサインインしてから試してください。\n$error',
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.key_rounded, color: scheme.primary),
                  title: const Text('招待コード'),
                  subtitle: Text(
                    widget.household.inviteCode,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      letterSpacing: 4,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  trailing: IconButton(
                    tooltip: 'コピー',
                    onPressed: _copyCode,
                    icon: const Icon(Icons.copy_rounded),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    'このコードを家族に伝えると、同じ一覧に参加できます。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.person_rounded, color: scheme.secondary),
                  title: const Text('いま使っている人'),
                  subtitle: Text(widget.user.displayName),
                ),
                const Divider(indent: 16, endIndent: 16),
                ListTile(
                  title: const Text('サインアウト'),
                  onTap: _busy ? null : _signOut,
                ),
                ListTile(
                  title: const Text('アカウントを削除'),
                  textColor: scheme.error,
                  onTap: _busy ? null : _deleteAccount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
