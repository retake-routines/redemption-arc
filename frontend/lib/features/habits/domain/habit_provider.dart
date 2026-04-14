import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitpal_frontend/features/habits/data/habit_repository.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_error_codes.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_week_utils.dart';

/// State class holding the habits list, loading flag, and optional error.
/// Kept compatible with the existing presentation layer.
class HabitsState {
  final List<HabitModel> habits;
  final bool isLoading;
  final String? errorMessage;

  const HabitsState({
    this.habits = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  HabitsState copyWith({
    List<HabitModel>? habits,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HabitsState(
      habits: habits ?? this.habits,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class HabitsNotifier extends StateNotifier<HabitsState> {
  final HabitRepository _repository;

  HabitsNotifier(this._repository) : super(const HabitsState());

  /// Loads all habits for the current user. Also fetches streaks for each habit.
  Future<void> loadHabits() async {
    state = state.copyWith(isLoading: true);
    try {
      final habits = await _repository.getHabits();

      // List endpoint does not embed completions; load once and attach per habit.
      List<CompletionModel> allCompletions = [];
      try {
        allCompletions = await _repository.getCompletions(limit: 500);
      } catch (_) {
        // Completions optional for streak-only view; UI will show empty activity.
      }

      final byHabit = <String, List<CompletionModel>>{};
      for (final c in allCompletions) {
        if (c.habitId.isEmpty) continue;
        byHabit.putIfAbsent(c.habitId, () => []).add(c);
      }
      final today = DateUtils.dateOnly(DateTime.now());
      final now = DateTime.now();

      // Fetch streak data for each habit in parallel
      final enrichedHabits = await Future.wait(
        habits.map((habit) async {
          final forHabit = List<CompletionModel>.from(
            byHabit[habit.id] ?? const [],
          )..sort((a, b) => b.completedAt.compareTo(a.completedAt));

          // Daily: completion today. Weekly: current local week meets frequency_value.
          final completedToday =
              habit.frequency == 'weekly'
                  ? forHabit
                          .where(
                            (c) => isSameLocalCalendarWeek(c.completedAt, now),
                          )
                          .length >=
                      habit.targetCount
                  : forHabit.any(
                    (c) => DateUtils.dateOnly(c.completedAt.toLocal()) == today,
                  );

          try {
            final streak = await _repository.getStreak(habit.id);
            return habit.copyWith(
              streak: streak,
              completions: forHabit,
              completedToday: completedToday,
            );
          } catch (_) {
            return habit.copyWith(
              completions: forHabit,
              completedToday: completedToday,
            );
          }
        }),
      );

      state = HabitsState(habits: enrichedHabits);
    } catch (e) {
      state = HabitsState(
        habits: state.habits,
        errorMessage: _friendlyError(e),
      );
    }
  }

  /// Creates a new habit using a [CreateHabitRequest] and appends it to the list.
  Future<void> createHabit(CreateHabitRequest request) async {
    try {
      final created = await _repository.createHabit(request);
      state = state.copyWith(habits: [...state.habits, created]);
    } catch (e) {
      state = state.copyWith(errorMessage: _friendlyError(e));
    }
  }

  /// Updates an existing habit by ID.
  Future<void> updateHabit(String id, UpdateHabitRequest request) async {
    try {
      final updated = await _repository.updateHabit(id, request);
      final habits =
          state.habits.map((h) => h.id == updated.id ? updated : h).toList();
      state = state.copyWith(habits: habits);
    } catch (e) {
      state = state.copyWith(errorMessage: _friendlyError(e));
    }
  }

  /// Deletes a habit by ID.
  Future<void> deleteHabit(String id) async {
    try {
      await _repository.deleteHabit(id);
      final habits = state.habits.where((h) => h.id != id).toList();
      state = state.copyWith(habits: habits);
    } catch (e) {
      state = state.copyWith(errorMessage: _friendlyError(e));
    }
  }

  /// Records a completion for a habit and refreshes habits.
  /// Returns the new current streak value, or null on failure.
  Future<int?> completeHabit(String habitId, {String? note}) async {
    try {
      await _repository.completeHabit(habitId, note: note);
      await loadHabits();
      final habit = state.habits.where((h) => h.id == habitId).firstOrNull;
      return habit?.streak.currentStreak;
    } catch (e) {
      state = state.copyWith(errorMessage: _friendlyError(e));
      return null;
    }
  }

  /// Removes a completion and refreshes habits.
  Future<void> uncompleteHabit(String habitId, String completionId) async {
    try {
      await _repository.uncompleteHabit(completionId);
      await loadHabits();
    } catch (e) {
      state = state.copyWith(errorMessage: _friendlyError(e));
    }
  }

  /// Undoes today's completion, or for weekly habits all completions in the
  /// current calendar week (Mon–Sun, local).
  Future<void> undoTodayCompletion(String habitId) async {
    final habit = state.habits.where((h) => h.id == habitId).firstOrNull;
    if (habit == null) return;
    try {
      if (habit.frequency == 'weekly') {
        final now = DateTime.now();
        final ids =
            habit.completions
                .where((c) => isSameLocalCalendarWeek(c.completedAt, now))
                .map((c) => c.id)
                .toList();
        for (final id in ids) {
          await _repository.uncompleteHabit(id);
        }
      } else {
        final today = DateUtils.dateOnly(DateTime.now());
        final todayCompletions =
            habit.completions
                .where(
                  (c) => DateUtils.dateOnly(c.completedAt.toLocal()) == today,
                )
                .toList()
              ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
        if (todayCompletions.isEmpty) return;
        await _repository.uncompleteHabit(todayCompletions.first.id);
      }
      await loadHabits();
    } catch (e) {
      state = state.copyWith(errorMessage: _friendlyError(e));
    }
  }

  String _friendlyError(Object e) {
    if (e is DioException && e.response?.statusCode == 409) {
      final data = e.response?.data;
      if (data is Map &&
          data['error'] == 'template_habit_already_exists') {
        return kHabitErrorTemplateAlreadyExists;
      }
    }
    return e.toString().replaceFirst('Exception: ', '');
  }
}

final habitsProvider = StateNotifierProvider<HabitsNotifier, HabitsState>((
  ref,
) {
  final repository = ref.read(habitRepositoryProvider);
  return HabitsNotifier(repository);
});

/// Provider to get a single habit from the already-loaded list.
final selectedHabitProvider = Provider.family<HabitModel?, String>((
  ref,
  habitId,
) {
  final habitsState = ref.watch(habitsProvider);
  final matches = habitsState.habits.where((h) => h.id == habitId);
  return matches.isNotEmpty ? matches.first : null;
});

/// Provider that returns today's completions across all habits.
final todayCompletionsProvider = FutureProvider<List<CompletionModel>>((
  ref,
) async {
  final repo = ref.read(habitRepositoryProvider);
  final completions = await repo.getCompletions();
  final now = DateTime.now();
  return completions.where((c) {
    return c.completedAt.year == now.year &&
        c.completedAt.month == now.month &&
        c.completedAt.day == now.day;
  }).toList();
});
