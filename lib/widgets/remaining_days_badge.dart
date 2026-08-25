import 'package:flutter/material.dart';

import '../utils/remaining_days.dart';

class RemainingDaysBadge extends StatelessWidget {
  const RemainingDaysBadge({super.key, required this.remaining});

  final int remaining;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color background;
    final Color foreground;
    if (remaining < 0) {
      background = scheme.errorContainer;
      foreground = scheme.onErrorContainer;
    } else if (remaining == 0) {
      background = scheme.primaryContainer;
      foreground = scheme.onPrimaryContainer;
    } else {
      background = scheme.surfaceContainerHighest;
      foreground = scheme.onSurface;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        remainingDaysLabel(remaining),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
