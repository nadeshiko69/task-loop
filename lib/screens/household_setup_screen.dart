import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../repositories/repositories.dart';
import '../widgets/error_snackbar.dart';

class HouseholdSetupScreen extends StatefulWidget {
  const HouseholdSetupScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<HouseholdSetupScreen> createState() => _HouseholdSetupScreenState();
}

class _HouseholdSetupScreenState extends State<HouseholdSetupScreen> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
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
      appBar: AppBar(title: const Text('世帯の準備')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            '${widget.user.displayName}さん、家族グループを用意します。',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            enabled: !_busy,
            decoration: const InputDecoration(
              labelText: '世帯名',
              hintText: '例: うちの家',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _busy
                ? null
                : () => _run(() async {
                      await householdRepository.createHousehold(
                        user: widget.user,
                        name: _nameController.text,
                      );
                    }),
            child: const Text('世帯をつくる'),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Text('すでに家族が作っている場合'),
          const SizedBox(height: 12),
          TextField(
            controller: _codeController,
            enabled: !_busy,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '招待コード（6桁）',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy
                ? null
                : () => _run(() async {
                      await householdRepository.joinWithCode(
                        user: widget.user,
                        rawCode: _codeController.text,
                      );
                    }),
            child: const Text('コードで参加'),
          ),
        ],
      ),
    );
  }
}
