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

  static const _markColors = [
    Color(0xFFFFE3D6),
    Color(0xFFDCEBDF),
    Color(0xFFFFF0C9),
    Color(0xFFD9E8F6),
  ];

  @override
  Widget build(BuildContext context) {
    final remaining = task.remainingDaysOn(JstDate.today());
    final scheme = Theme.of(context).colorScheme;
    final markColor =
        _markColors[task.title.hashCode.abs() % _markColors.length];

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 6, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TitleMark(label: _initial(task.title), color: markColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${task.intervalDays}日ごと',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                RemainingDaysBadge(remaining: remaining),
                PopupMenuButton<String>(
                  tooltip: 'その他',
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                  onSelected: (value) {
                    if (value == 'archive') {
                      onArchive();
                    }
                  },
                  itemBuilder:
                      (context) => const [
                        PopupMenuItem(value: 'archive', child: Text('リストから外す')),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onShowDetails,
                    child: const Text('記録を見る'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('できた'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _initial(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return '家';
    }
    return String.fromCharCodes([trimmed.runes.first]);
  }
}

class _TitleMark extends StatelessWidget {
  const _TitleMark({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: const Color(0xFF3A2E29)),
      ),
    );
  }
}
