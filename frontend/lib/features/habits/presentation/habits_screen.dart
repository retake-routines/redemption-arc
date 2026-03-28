import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_provider.dart';
import 'package:habitpal_frontend/features/habits/presentation/widgets/habit_card.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(habitsProvider.notifier).loadHabits());
  }

  @override
  Widget build(BuildContext context) {
    final habitsState = ref.watch(habitsProvider);

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
      body: habitsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : habitsState.habits.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.eco_outlined,
                        size: 80,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha(128),
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
                  onRefresh: () =>
                      ref.read(habitsProvider.notifier).loadHabits(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: habitsState.habits.length,
                    itemBuilder: (context, index) {
                      final habit = habitsState.habits[index];
                      return HabitCard(
                        habit: habit,
                        onTap: () => context.go('/habits/${habit.id}'),
                        onComplete: () => ref
                            .read(habitsProvider.notifier)
                            .completeHabit(habit.id),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add habit screen
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
