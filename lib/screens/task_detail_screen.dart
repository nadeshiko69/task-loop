import 'package:flutter/material.dart';

import '../models/chore_task.dart';
import '../models/task_execution.dart';
import '../repositories/repositories.dart';
import '../utils/execution_share.dart';
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
            return const _EmptyHistory();
          }

          final shareSummary = summarizeExecutionShares(
            data.executions.map((execution) => execution.executedBy),
          );

          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            children: [
              _ExecutionShareSection(
                summary: shareSummary,
                nameFor: (uid) => _executorName(data.memberNames, uid),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'いままでの記録',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Card(
                child: Column(
                  children: [
                    for (
                      var index = 0;
                      index < data.executions.length;
                      index++
                    ) ...[
                      if (index > 0)
                        const Divider(height: 1, indent: 68, endIndent: 16),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                          foregroundColor:
                              Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                          child: const Icon(Icons.person_rounded, size: 20),
                        ),
                        title: Text(
                          _executorName(
                            data.memberNames,
                            data.executions[index].executedBy,
                          ),
                        ),
                        subtitle: Text(
                          JstDate.formatDateTime(
                            data.executions[index].executedAt,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 40, color: scheme.primary),
            const SizedBox(height: 12),
            Text('まだ記録がありません', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '一覧で「できた」を押すと、ここに残ります。',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskDetailData {
  const _TaskDetailData({required this.executions, required this.memberNames});

  final List<TaskExecution> executions;
  final Map<String, String> memberNames;
}

class _ExecutionShareSection extends StatelessWidget {
  const _ExecutionShareSection({required this.summary, required this.nameFor});

  final ExecutionShareSummary summary;
  final String Function(String uid) nameFor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '最近${summary.sampleCount}回、だれがやった？',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 14),
            for (final share in summary.shares) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      nameFor(share.executedBy),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  Text(
                    '${share.count}回',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 48,
                    child: Text(
                      '${share.percent}%',
                      textAlign: TextAlign.end,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: share.percent / 100,
                  minHeight: 10,
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }
}
