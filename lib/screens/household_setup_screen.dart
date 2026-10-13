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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('家族を用意する')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Text(
              '${widget.user.displayName}さん、こんにちは。\nいっしょに使う家族グループを用意します。',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.home_rounded, color: scheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    '新しくつくる',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'うちの名前を決めて、家族を招待できます。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    enabled: !_busy,
                    decoration: const InputDecoration(
                      labelText: '家族の名前',
                      hintText: '例: うちの家',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed:
                          _busy
                              ? null
                              : () => _run(() async {
                                await householdRepository.createHousehold(
                                  user: widget.user,
                                  name: _nameController.text,
                                );
                              }),
                      child: const Text('この名前でつくる'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.group_rounded, color: scheme.secondary),
                  const SizedBox(height: 8),
                  Text(
                    'すでに家族がいる',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'もらった6桁のコードを入力します。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    enabled: !_busy,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '招待コード（6桁）'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed:
                          _busy
                              ? null
                              : () => _run(() async {
                                await householdRepository.joinWithCode(
                                  user: widget.user,
                                  rawCode: _codeController.text,
                                );
                              }),
                      child: const Text('コードで参加'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
