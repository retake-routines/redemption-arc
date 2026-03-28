import 'package:flutter/material.dart';
import 'package:habitpal_frontend/core/theme/app_colors.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';

class StreakCounter extends StatelessWidget {
  final StreakModel streak;

  const StreakCounter({required this.streak, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _StreakItem(
                icon: Icons.local_fire_department,
                iconColor: AppColors.streak,
                label: 'Current Streak',
                value: '${streak.currentStreak} days',
              ),
            ),
            Container(
              width: 1,
              height: 48,
              color: Theme.of(context).dividerColor,
            ),
            Expanded(
              child: _StreakItem(
                icon: Icons.emoji_events,
                iconColor: AppColors.streakGold,
                label: 'Longest Streak',
                value: '${streak.longestStreak} days',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StreakItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
