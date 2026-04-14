import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitpal_frontend/core/l10n/app_localizations.dart';
import 'package:habitpal_frontend/core/theme/app_colors.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_provider.dart';
import 'package:habitpal_frontend/features/habits/presentation/widgets/calendar_heatmap.dart';
import 'package:habitpal_frontend/features/statistics/domain/stats_provider.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(statsProvider.notifier).loadStats());
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(habitsProvider, (_, __) {
      Future.microtask(() => ref.read(statsProvider.notifier).loadStats());
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statistics)),
      body:
          stats.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Activity heatmap card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.activity,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            Builder(
                              builder: (context) {
                                final habits = ref.watch(habitsProvider).habits;
                                final active =
                                    habits.where((h) => !h.isArchived).toList();
                                final byDay = _completionCountsByDay(active);
                                return CalendarHeatmap(
                                  completedDates:
                                      habits
                                          .expand((h) => h.completions)
                                          .map((c) => c.completedAt)
                                          .toList(),
                                  activeHabitCount:
                                      active.isEmpty ? null : active.length,
                                  completionCountByDay:
                                      active.isEmpty ? null : byDay,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Stats grid: 2 columns
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        _StatGridCard(
                          icon: Icons.checklist,
                          title: l10n.totalHabits,
                          value: '${stats.totalHabits}',
                        ),
                        _StatGridCard(
                          icon: Icons.local_fire_department,
                          iconColor: AppColors.streak,
                          title: l10n.bestStreak,
                          value: '${stats.bestStreak}',
                        ),
                        _StatGridCard(
                          icon: Icons.trending_up,
                          title: l10n.averageStreak,
                          value: '${stats.averageStreak}',
                        ),
                        _StatGridCard(
                          icon: Icons.percent,
                          title: l10n.completionRate,
                          value:
                              '${(stats.overallCompletionRate * 100).toStringAsFixed(1)}%',
                        ),
                        _StatGridCard(
                          icon: Icons.check_circle,
                          title: l10n.statTotalCompletions,
                          value: '${stats.totalCompletions}',
                        ),
                        _StatGridCard(
                          icon: Icons.calendar_today,
                          title: l10n.statActiveDays,
                          value: '${stats.activeDays}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/habits');
            case 1:
              break;
            case 2:
              context.go('/profile');
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.check_circle_outline),
            selectedIcon: const Icon(Icons.check_circle),
            label: l10n.habits,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n.statistics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}

/// Local calendar day -> number of habit completions on that day (active habits only).
Map<DateTime, int> _completionCountsByDay(List<HabitModel> activeHabits) {
  final map = <DateTime, int>{};
  for (final h in activeHabits) {
    for (final c in h.completions) {
      final d = DateUtils.dateOnly(c.completedAt.toLocal());
      map[d] = (map[d] ?? 0) + 1;
    }
  }
  return map;
}

class _StatGridCard extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String value;

  const _StatGridCard({
    required this.icon,
    this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: iconColor ?? theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(179),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
