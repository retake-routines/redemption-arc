import 'package:flutter/material.dart';
import 'package:habitpal_frontend/core/theme/app_colors.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';
import 'package:habitpal_frontend/shared/utils/habit_icons.dart';

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
    final borderColor = parseHabitColor(
      habit.color,
      Theme.of(context).colorScheme.primary,
    );
    final habitIcon = resolveHabitIcon(habit.icon);

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
        border: Border(left: BorderSide(color: borderColor, width: 4)),
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
                // Leading icon with completion badge overlay
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: onComplete,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          isCompleted ? Icons.check_circle : habitIcon,
                          key: ValueKey<bool>(isCompleted),
                          color:
                              isCompleted
                                  ? Theme.of(context).colorScheme.primary
                                  : borderColor,
                          size: 32,
                        ),
                      ),
                    ),
                    if (isCompleted)
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.completed,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
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
