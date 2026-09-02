import 'package:flutter/material.dart';

import '../models/chore_task.dart';
import '../utils/jst_date.dart';
import 'remaining_days_badge.dart';

class ChoreTaskTile extends StatelessWidget {
  const ChoreTaskTile({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onArchive,
    required this.onShowDetails,
  });

  final ChoreTask task;
  final VoidCallback onComplete;
  final VoidCallback onArchive;
  final VoidCallback onShowDetails;

  @override
  Widget build(BuildContext context) {
    final remaining = task.remainingDaysOn(JstDate.today());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                RemainingDaysBadge(remaining: remaining),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'archive') {
                      onArchive();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'archive',
                      child: Text('アーカイブ'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${task.intervalDays}日ごと',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onShowDetails,
                  child: const Text('詳細'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onComplete,
                  child: const Text('完了'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
