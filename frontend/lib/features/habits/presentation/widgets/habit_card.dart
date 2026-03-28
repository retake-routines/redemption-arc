import 'package:flutter/material.dart';
import 'package:habitpal_frontend/core/theme/app_colors.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';

class HabitCard extends StatelessWidget {
  final HabitModel habit;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  const HabitCard({
    required this.habit,
    super.key,
    this.onTap,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: onComplete,
                icon: const Icon(Icons.check_circle_outline),
                color: Theme.of(context).colorScheme.primary,
                iconSize: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (habit.description.isNotEmpty)
                      Text(
                        habit.description,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (habit.streak.currentStreak > 0) ...[
                const Icon(
                  Icons.local_fire_department,
                  color: AppColors.streak,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${habit.streak.currentStreak}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.streak,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
