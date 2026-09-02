import 'package:flutter/material.dart';

import '../models/chore_task.dart';
import '../models/task_execution.dart';
import '../repositories/repositories.dart';
import '../utils/jst_date.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({
    super.key,
    required this.householdId,
    required this.task,
  });

  final String householdId;
  final ChoreTask task;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late final Future<_TaskDetailData> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _load();
  }

  Future<_TaskDetailData> _load() async {
    final results = await Future.wait([
      taskRepository.fetchRecentExecutions(
        householdId: widget.householdId,
        taskId: widget.task.id,
      ),
      householdRepository.fetchMemberDisplayNames(widget.householdId),
    ]);
    return _TaskDetailData(
      executions: results[0] as List<TaskExecution>,
      memberNames: results[1] as Map<String, String>,
    );
  }

  String _executorName(Map<String, String> memberNames, String uid) {
    final name = memberNames[uid];
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return '不明なメンバー';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.task.title)),
      body: FutureBuilder<_TaskDetailData>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('読み込みに失敗しました\n${snapshot.error}'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _detailFuture = _load();
                        });
                      },
                      child: const Text('再読み込み'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          if (data.executions.isEmpty) {
            return const Center(
              child: Text('まだ実行履歴がありません'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: data.executions.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final execution = data.executions[index];
              return ListTile(
                title: Text(
                  _executorName(data.memberNames, execution.executedBy),
                ),
                subtitle: Text(JstDate.formatDateTime(execution.executedAt)),
              );
            },
          );
        },
      ),
    );
  }
}

class _TaskDetailData {
  const _TaskDetailData({
    required this.executions,
    required this.memberNames,
  });

  final List<TaskExecution> executions;
  final Map<String, String> memberNames;
}
