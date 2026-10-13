import 'package:flutter/material.dart';

import '../models/chore_task.dart';
import '../utils/jst_date.dart';
import 'remaining_days_badge.dart';
import 'sparkle_burst.dart';

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
                Expanded(child: _DoneButton(onPressed: onComplete)),
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

class _DoneButton extends StatefulWidget {
  const _DoneButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_DoneButton> createState() => _DoneButtonState();
}

class _DoneButtonState extends State<_DoneButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop;
  late final CurvedAnimation _curve;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _curve = CurvedAnimation(parent: _pop, curve: Curves.easeOut);
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 0.94), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.05), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1), weight: 25),
    ]).animate(_curve);
  }

  @override
  void dispose() {
    _curve.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FilledButton.icon(
        onPressed: () {
          showSparkleBurst(context);
          if (!MediaQuery.disableAnimationsOf(context)) {
            _pop.forward(from: 0);
          }
          widget.onPressed();
        },
        icon: const Icon(Icons.check_rounded, size: 18),
        label: const Text('できた'),
      ),
    );
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
