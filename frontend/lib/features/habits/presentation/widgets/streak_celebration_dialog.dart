import 'package:flutter/material.dart';

/// Milestone values that trigger the celebration dialog.
const _milestones = {7, 14, 30, 50, 100};

/// Returns true if [streak] is a celebration-worthy milestone.
bool isStreakMilestone(int streak) => _milestones.contains(streak);

/// Shows a celebratory dialog when the user hits a streak milestone.
Future<void> showStreakCelebration(BuildContext context, int streak) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _StreakCelebrationContent(streak: streak);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
      );
      return ScaleTransition(scale: curved, child: child);
    },
  );
}

class _StreakCelebrationContent extends StatelessWidget {
  final int streak;

  const _StreakCelebrationContent({required this.streak});

  String get _message {
    if (streak >= 100) return 'Incredible dedication! You are unstoppable!';
    if (streak >= 50) return 'Half a century of consistency. Legendary!';
    if (streak >= 30) return 'A full month! This habit is part of you now.';
    if (streak >= 14)
      return 'Two weeks strong! You are building real momentum.';
    return 'One week done! Great start, keep it up!';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: AlertDialog(
        icon: Text(
          '\u{1F525}',
          style: theme.textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
        title: Text(
          '$streak-Day Streak!',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        content: Text(
          _message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Going!'),
          ),
        ],
      ),
    );
  }
}
