import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_provider.dart';

class StatsState {
  final double overallCompletionRate;
  final int totalCompletions;
  final int activeDays;
  final int totalHabits;
  final int bestStreak;
  final int averageStreak;
  final bool isLoading;

  const StatsState({
    this.overallCompletionRate = 0.0,
    this.totalCompletions = 0,
    this.activeDays = 0,
    this.totalHabits = 0,
    this.bestStreak = 0,
    this.averageStreak = 0,
    this.isLoading = false,
  });

  StatsState copyWith({
    double? overallCompletionRate,
    int? totalCompletions,
    int? activeDays,
    int? totalHabits,
    int? bestStreak,
    int? averageStreak,
    bool? isLoading,
  }) {
    return StatsState(
      overallCompletionRate:
          overallCompletionRate ?? this.overallCompletionRate,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      activeDays: activeDays ?? this.activeDays,
      totalHabits: totalHabits ?? this.totalHabits,
      bestStreak: bestStreak ?? this.bestStreak,
      averageStreak: averageStreak ?? this.averageStreak,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class StatsNotifier extends StateNotifier<StatsState> {
  final Ref _ref;

  StatsNotifier(this._ref) : super(const StatsState());

  /// Derives statistics from the currently loaded habits list (including
  /// [HabitModel.completions] and [HabitModel.completedToday] filled by
  /// [HabitsNotifier.loadHabits]).
  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true);

    final habits = _ref.read(habitsProvider).habits;

    final totalHabits = habits.length;
    final activeHabits = habits.where((h) => !h.isArchived).toList();
    final activeCount = activeHabits.length;

    var bestStreak = 0;
    var totalStreak = 0;
    for (final habit in habits) {
      final current = habit.streak.currentStreak;
      final longest = habit.streak.longestStreak;
      if (longest > bestStreak) bestStreak = longest;
      if (current > bestStreak) bestStreak = current;
      totalStreak += current;
    }
    final averageStreak =
        habits.isNotEmpty ? (totalStreak / habits.length).round() : 0;

    var totalCompletionsAllTime = 0;
    final distinctDays = <DateTime>{};
    for (final h in habits) {
      totalCompletionsAllTime += h.completions.length;
      for (final c in h.completions) {
        distinctDays.add(DateUtils.dateOnly(c.completedAt.toLocal()));
      }
    }

    final completedTodayCount =
        activeHabits.where((h) => h.completedToday).length;
    final completionRate =
        activeCount > 0 ? completedTodayCount / activeCount : 0.0;

    state = StatsState(
      overallCompletionRate: completionRate,
      totalCompletions: totalCompletionsAllTime,
      activeDays: distinctDays.length,
      totalHabits: totalHabits,
      bestStreak: bestStreak,
      averageStreak: averageStreak,
      isLoading: false,
    );
  }
}

final statsProvider = StateNotifierProvider<StatsNotifier, StatsState>((ref) {
  return StatsNotifier(ref);
});
