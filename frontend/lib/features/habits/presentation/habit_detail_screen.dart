import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitpal_frontend/core/l10n/app_localizations.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_localized_display.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_provider.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_week_utils.dart';
import 'package:habitpal_frontend/features/habits/presentation/habit_user_messages.dart';
import 'package:habitpal_frontend/features/habits/presentation/widgets/calendar_heatmap.dart';
import 'package:habitpal_frontend/features/habits/presentation/widgets/edit_habit_dialog.dart';
import 'package:habitpal_frontend/features/habits/presentation/widgets/streak_celebration_dialog.dart';
import 'package:habitpal_frontend/features/habits/presentation/widgets/streak_counter.dart';
import 'package:habitpal_frontend/shared/widgets/platform_widgets.dart';

class HabitDetailScreen extends ConsumerWidget {
  final String habitId;

  const HabitDetailScreen({required this.habitId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(habitsProvider.select((s) => s.errorMessage), (prev, next) {
      if (next != null) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(displayHabitErrorUserMessage(next, l10n)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    final habitsState = ref.watch(habitsProvider);
    final habit = habitsState.habits.where((h) => h.id == habitId).firstOrNull;
    final l10n = AppLocalizations.of(context)!;

    if (habit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Habit Detail')),
        body: const Center(child: Text('Habit not found')),
      );
    }

    final displayTitle = localizedHabitTitle(habit, l10n);
    final displayDesc = localizedHabitDescription(habit, l10n);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/habits');
            }
          },
        ),
        title: Text(displayTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => EditHabitDialog(habit: habit),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showAdaptiveConfirmDialog<bool>(
                context: context,
                title: 'Delete this habit?',
                content:
                    'This will permanently remove the habit and all its completions.',
                confirmText: 'Delete',
                isDestructive: true,
              );
              if (confirmed == true && context.mounted) {
                await ref.read(habitsProvider.notifier).deleteHabit(habit.id);
                if (context.mounted) {
                  context.go('/habits');
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Habit info card ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'habit-title-${habit.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          displayTitle,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                    if (displayDesc.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        displayDesc,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Chip(label: Text(habit.frequency)),
                        const SizedBox(width: 8),
                        Chip(label: Text('Target: ${habit.targetCount}')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Streak ---
            StreakCounter(streak: habit.streak),
            const SizedBox(height: 16),

            // --- Heatmap ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    CalendarHeatmap(
                      completedDates: heatmapCompletionDates(habit),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Recent Completions ---
            _RecentCompletions(completions: habit.completions),
            const SizedBox(height: 24),

            // --- Action buttons ---
            _ActionButtons(habit: habit),
          ],
        ),
      ),
    );
  }
}

/// Displays the last 5 completions sorted by date descending.
class _RecentCompletions extends StatelessWidget {
  final List<CompletionModel> completions;

  const _RecentCompletions({required this.completions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = List<CompletionModel>.from(completions)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    final recent = sorted.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Completions', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (recent.isEmpty)
              Text(
                'No completions yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...recent.map((c) => _CompletionTile(completion: c)),
          ],
        ),
      ),
    );
  }
}

class _CompletionTile extends StatelessWidget {
  final CompletionModel completion;

  const _CompletionTile({required this.completion});

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', //
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            _formatDate(completion.completedAt),
            style: theme.textTheme.bodyMedium,
          ),
          if (completion.note.isNotEmpty) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                completion.note,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Mark Complete button (with note sheet) and Undo button.
class _ActionButtons extends ConsumerWidget {
  final HabitModel habit;

  const _ActionButtons({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (habit.completedToday) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => _undoCompletion(ref),
          icon: const Icon(Icons.undo),
          label: const Text('Undo today'),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _showCompleteSheet(context, ref),
        icon: const Icon(Icons.check),
        label: const Text('Mark Complete'),
      ),
    );
  }

  void _showCompleteSheet(BuildContext context, WidgetRef ref) {
    final noteController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Complete Habit',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  hintText: 'How did it go?',
                  labelText: 'Note (optional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  Navigator.of(sheetContext).pop();
                  final note = noteController.text.trim();
                  final streak = await ref
                      .read(habitsProvider.notifier)
                      .completeHabit(
                        habit.id,
                        note: note.isNotEmpty ? note : null,
                      );
                  if (streak != null &&
                      isStreakMilestone(streak) &&
                      context.mounted) {
                    showStreakCelebration(context, streak);
                  }
                },
                child: const Text('Complete'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _undoCompletion(WidgetRef ref) {
    ref.read(habitsProvider.notifier).undoTodayCompletion(habit.id);
  }
}
