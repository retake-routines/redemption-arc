import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_provider.dart';

class StatsState {
  /// Share of active habits completed today (0..1).
  final double todayCompletionRate;

  /// Share of expected completions met over the last 30 days (0..1, capped).
  final double last30DaysCompletionRate;
  final int totalCompletions;
  final int activeDays;
  final int totalHabits;
  final int bestStreak;
  final int averageStreak;
  final bool isLoading;

  const StatsState({
    this.todayCompletionRate = 0.0,
    this.last30DaysCompletionRate = 0.0,
    this.totalCompletions = 0,
    this.activeDays = 0,
    this.totalHabits = 0,
    this.bestStreak = 0,
    this.averageStreak = 0,
    this.isLoading = false,
  });

  StatsState copyWith({
    double? todayCompletionRate,
    double? last30DaysCompletionRate,
    int? totalCompletions,
    int? activeDays,
    int? totalHabits,
    int? bestStreak,
    int? averageStreak,
    bool? isLoading,
  }) {
    return StatsState(
      todayCompletionRate: todayCompletionRate ?? this.todayCompletionRate,
      last30DaysCompletionRate:
          last30DaysCompletionRate ?? this.last30DaysCompletionRate,
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
    final todayRate = activeCount > 0 ? completedTodayCount / activeCount : 0.0;

    final last30Rate = _last30DaysCompletionRate(activeHabits);

    state = StatsState(
      todayCompletionRate: todayRate,
      last30DaysCompletionRate: last30Rate,
      totalCompletions: totalCompletionsAllTime,
      activeDays: distinctDays.length,
      totalHabits: totalHabits,
      bestStreak: bestStreak,
      averageStreak: averageStreak,
      isLoading: false,
    );
  }

  /// Completions in the last 30 days vs. expected, summed across active
  /// habits. Daily habits expect 30 × targetCount; weekly habits expect
  /// (30/7) × targetCount. Capped at 1.0.
  static double _last30DaysCompletionRate(List<HabitModel> activeHabits) {
    if (activeHabits.isEmpty) return 0.0;
    final now = DateTime.now();
    final windowStart = now.subtract(const Duration(days: 30));

    var expected = 0.0;
    var done = 0.0;
    for (final h in activeHabits) {
      final inWindow =
          h.completions.where((c) {
            final t = c.completedAt;
            return t.isAfter(windowStart) && !t.isAfter(now);
          }).length;
      done += inWindow.toDouble();
      final target = h.targetCount.toDouble();
      if (h.frequency == 'weekly') {
        expected += (30.0 / 7.0) * target;
      } else {
        expected += 30.0 * target;
      }
    }
    if (expected <= 0) return 0.0;
    return math.min(1.0, done / expected);
  }
}

final statsProvider = StateNotifierProvider<StatsNotifier, StatsState>((ref) {
  return StatsNotifier(ref);
});
