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
    final isCompleted = habit.completedToday;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            isCompleted
                ? Theme.of(context).colorScheme.primary.withAlpha(30)
                : Theme.of(context).cardTheme.color ??
                    Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                isCompleted
                    ? Theme.of(context).colorScheme.primary.withAlpha(40)
                    : Colors.black12,
            blurRadius: isCompleted ? 8.0 : 4.0,
            offset: Offset(0, isCompleted ? 2 : 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: onComplete,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      isCompleted
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      key: ValueKey<bool>(isCompleted),
                      color:
                          isCompleted
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Hero(
                    tag: 'habit-title-${habit.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration:
                                  isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
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
      ),
    );
  }
}
