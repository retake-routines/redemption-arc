import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_provider.dart';
import 'package:habitpal_frontend/features/habits/presentation/widgets/create_habit_dialog.dart';
import 'package:habitpal_frontend/features/habits/presentation/widgets/habit_card.dart';

enum _HabitFilter { all, active, archived }

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  _HabitFilter _filter = _HabitFilter.all;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(habitsProvider.notifier).loadHabits());
  }

  List<HabitModel> _applyFilter(List<HabitModel> habits) {
    switch (_filter) {
      case _HabitFilter.active:
        return habits.where((h) => !h.isArchived).toList();
      case _HabitFilter.archived:
        return habits.where((h) => h.isArchived).toList();
      case _HabitFilter.all:
        return habits;
    }
  }

  @override
  Widget build(BuildContext context) {
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
    final filteredHabits = _applyFilter(habitsState.habits);
    final activeHabits =
        habitsState.habits.where((h) => !h.isArchived).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.go('/statistics'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body:
          habitsState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : habitsState.habits.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.eco_outlined,
                      size: 80,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(128),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No habits yet',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text('Tap + to create your first habit'),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: () => ref.read(habitsProvider.notifier).loadHabits(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Today's progress banner
                    _TodayProgressBanner(activeHabits: activeHabits),
                    const SizedBox(height: 12),
                    // Filter chips
                    _FilterChipRow(
                      currentFilter: _filter,
                      onFilterChanged: (f) => setState(() => _filter = f),
                    ),
                    const SizedBox(height: 12),
                    // Habit list
                    ...List.generate(filteredHabits.length, (index) {
                      final habit = filteredHabits[index];
                      return _StaggeredListItem(
                        index: index,
                        child: HabitCard(
                          habit: habit,
                          onTap: () => context.go('/habits/${habit.id}'),
                          onComplete:
                              () => ref
                                  .read(habitsProvider.notifier)
                                  .completeHabit(habit.id),
                        ),
                      );
                    }),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => const CreateHabitDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              context.go('/statistics');
            case 2:
              context.go('/profile');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Today's progress banner showing completion ratio and motivational message.
class _TodayProgressBanner extends StatelessWidget {
  final List<HabitModel> activeHabits;

  const _TodayProgressBanner({required this.activeHabits});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalCount = activeHabits.length;
    final completedCount = activeHabits.where((h) => h.completedToday).length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    String message;
    if (progress == 0) {
      message = "Let's get started!";
    } else if (progress < 0.5) {
      message = 'Keep going!';
    } else if (progress < 1.0) {
      message = 'Almost there!';
    } else {
      message = 'All done! Great job!';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  progress >= 1.0 ? Icons.emoji_events : Icons.today,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '$completedCount of $totalCount habits completed today',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A row of filter chips for All / Active / Archived.
class _FilterChipRow extends StatelessWidget {
  final _HabitFilter currentFilter;
  final ValueChanged<_HabitFilter> onFilterChanged;

  const _FilterChipRow({
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children:
          _HabitFilter.values.map((filter) {
            final label = switch (filter) {
              _HabitFilter.all => 'All',
              _HabitFilter.active => 'Active',
              _HabitFilter.archived => 'Archived',
            };
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(label),
                selected: currentFilter == filter,
                onSelected: (_) => onFilterChanged(filter),
              ),
            );
          }).toList(),
    );
  }
}

/// Animates a list item with a staggered fade + slide effect.
class _StaggeredListItem extends StatelessWidget {
  final int index;
  final Widget child;

  const _StaggeredListItem({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final delay = Duration(milliseconds: 80 * index);
    final totalDuration = const Duration(milliseconds: 400) + delay;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: totalDuration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        // Calculate the effective progress accounting for stagger delay
        final delayFraction =
            delay.inMilliseconds / totalDuration.inMilliseconds;
        final effectiveValue = ((value - delayFraction) / (1.0 - delayFraction))
            .clamp(0.0, 1.0);

        return Opacity(
          opacity: effectiveValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - effectiveValue)),
            child: child,
          ),
        );
      },
    );
  }
}
