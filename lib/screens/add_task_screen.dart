import 'package:flutter/material.dart';

import '../ads/ads_service.dart';
import '../repositories/repositories.dart';
import '../widgets/error_snackbar.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({
    super.key,
    required this.householdId,
    required this.uid,
  });

  final String householdId;
  final String uid;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  int _intervalDays = 7;
  bool _busy = false;

  static const _presets = [1, 7, 14, 30];

  @override
  void initState() {
    super.initState();
    adsService.preloadInterstitial();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await taskRepository.addTask(
        householdId: widget.householdId,
        uid: widget.uid,
        title: _titleController.text,
        intervalDays: _intervalDays,
      );
      if (!mounted) {
        return;
      }
      await adsService.showInterstitialAfterTaskAdded();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        showErrorSnackBar(context, error);
      }
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
      appBar: AppBar(title: const Text('家事を追加')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            '家族みんなの一覧に加わります。',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            enabled: !_busy,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: '家事の名前',
              hintText: '例: お風呂掃除',
            ),
          ),
          const SizedBox(height: 24),
          Text('どのくらいのペース？', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            '最後にやってから、この日数がたつと「今日やる」になります。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final days in _presets)
                ChoiceChip(
                  label: Text(_labelFor(days)),
                  selected: _intervalDays == days,
                  onSelected:
                      _busy
                          ? null
                          : (_) => setState(() => _intervalDays = days),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$_intervalDays日ごと',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Slider(
            min: 1,
            max: 90,
            divisions: 89,
            value: _intervalDays.toDouble(),
            label: '$_intervalDays日',
            onChanged:
                _busy
                    ? null
                    : (value) => setState(() => _intervalDays = value.round()),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(_busy ? '保存中…' : '追加する'),
            ),
          ),
        ],
      ),
    );
  }

  String _labelFor(int days) {
    switch (days) {
      case 1:
        return '毎日';
      case 7:
        return '週1';
      case 14:
        return '隔週';
      case 30:
        return '月1';
      default:
        return '$days日';
    }
  }
}
