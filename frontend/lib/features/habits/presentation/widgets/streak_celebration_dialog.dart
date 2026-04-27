import 'package:flutter/material.dart';
import 'package:habitpal_frontend/core/l10n/app_localizations.dart';

/// Milestone values that trigger the celebration dialog.
const _milestones = {7, 14, 30, 50, 100};

/// Returns true if [streak] is a celebration-worthy milestone.
bool isStreakMilestone(int streak) => _milestones.contains(streak);

/// Shows a celebratory dialog when the user hits a streak milestone.
Future<void> showStreakCelebration(BuildContext context, int streak) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
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

  String _message(AppLocalizations l10n) {
    if (streak >= 100) return l10n.streakMessage100;
    if (streak >= 50) return l10n.streakMessage50;
    if (streak >= 30) return l10n.streakMessage30;
    if (streak >= 14) return l10n.streakMessage14;
    return l10n.streakMessage7;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: AlertDialog(
        icon: Text(
          '\u{1F525}',
          style: theme.textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
        title: Text(
          l10n.streakDayTitle(streak),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        content: Text(
          _message(l10n),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.keepGoing),
          ),
        ],
      ),
    );
  }
}
