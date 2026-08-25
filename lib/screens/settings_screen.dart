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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('招待コードをコピーしました')),
    );
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
            'この操作は取り消せません。世帯からは外れますが、'
            '他の家族のタスクは残ります。',
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
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('招待コード'),
            subtitle: Text(widget.household.inviteCode),
            trailing: IconButton(
              tooltip: 'コピー',
              onPressed: _copyCode,
              icon: const Icon(Icons.copy),
            ),
          ),
          ListTile(
            title: const Text('ログイン中'),
            subtitle: Text(widget.user.displayName),
          ),
          const Divider(),
          ListTile(
            title: const Text('サインアウト'),
            onTap: _busy ? null : _signOut,
          ),
          ListTile(
            title: const Text('アカウントを削除'),
            textColor: Theme.of(context).colorScheme.error,
            onTap: _busy ? null : _deleteAccount,
          ),
        ],
      ),
    );
  }
}
