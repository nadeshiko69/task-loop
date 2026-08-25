import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('タスクを追加')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _titleController,
            enabled: !_busy,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'タスク名',
              hintText: '例: お風呂掃除',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          const Text('何日ごとにやる？'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final days in _presets)
                ChoiceChip(
                  label: Text(_labelFor(days)),
                  selected: _intervalDays == days,
                  onSelected: _busy
                      ? null
                      : (_) => setState(() => _intervalDays = days),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('選択中: $_intervalDays 日ごと'),
          Slider(
            min: 1,
            max: 90,
            divisions: 89,
            value: _intervalDays.toDouble(),
            label: '$_intervalDays日',
            onChanged: _busy
                ? null
                : (value) => setState(() => _intervalDays = value.round()),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: Text(_busy ? '保存中…' : '追加する'),
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
