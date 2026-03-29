import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_provider.dart';
import 'package:habitpal_frontend/features/habits/presentation/widgets/calendar_heatmap.dart';
import 'package:habitpal_frontend/features/habits/presentation/widgets/streak_counter.dart';

class HabitDetailScreen extends ConsumerWidget {
  final String habitId;

  const HabitDetailScreen({required this.habitId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(habitsProvider.select((s) => s.errorMessage), (prev, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    final habitsState = ref.watch(habitsProvider);
    final habit = habitsState.habits.where((h) => h.id == habitId).firstOrNull;

    if (habit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Habit Detail')),
        body: const Center(child: Text('Habit not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit habit
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // TODO: Confirm and delete
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          habit.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                    if (habit.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        habit.description,
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
            StreakCounter(streak: habit.streak),
            const SizedBox(height: 16),
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
                      completedDates: habit.completions
                          .map((c) => c.completedAt)
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  ref.read(habitsProvider.notifier).completeHabit(habit.id);
                },
                icon: const Icon(Icons.check),
                label: const Text('Mark Complete'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
