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

  /// Derives statistics from the currently loaded habits list.
  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true);

    final habitsState = _ref.read(habitsProvider);
    final habits = habitsState.habits;

    final totalHabits = habits.length;
    final activeHabits = habits.where((h) => !h.isArchived).length;

    // Sum up streaks
    int bestStreak = 0;
    int totalStreak = 0;
    for (final habit in habits) {
      final current = habit.streak.currentStreak;
      final longest = habit.streak.longestStreak;
      if (longest > bestStreak) bestStreak = longest;
      if (current > bestStreak) bestStreak = current;
      totalStreak += current;
    }
    final averageStreak =
        habits.isNotEmpty ? (totalStreak / habits.length).round() : 0;

    // Count today's completions from todayCompletionsProvider
    int todayCompletions = 0;
    try {
      final completions = await _ref.read(todayCompletionsProvider.future);
      todayCompletions = completions.length;
    } catch (_) {
      // If fetch fails, keep 0
    }

    // Completion rate: today completions / active habits
    final completionRate =
        activeHabits > 0 ? todayCompletions / activeHabits : 0.0;

    state = StatsState(
      overallCompletionRate: completionRate,
      totalCompletions: todayCompletions,
      activeDays: totalHabits, // re-using as "active habits" count
      totalHabits: totalHabits,
      bestStreak: bestStreak,
      averageStreak: averageStreak,
    );
  }
}

final statsProvider =
    StateNotifierProvider<StatsNotifier, StatsState>((ref) {
  return StatsNotifier(ref);
});
