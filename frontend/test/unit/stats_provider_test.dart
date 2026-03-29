import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitpal_frontend/features/habits/data/habit_repository.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_provider.dart';
import 'package:habitpal_frontend/features/statistics/domain/stats_provider.dart';

void main() {
  group('StatsNotifier', () {
    test('calculates stats from habits list', () async {
      final container = ProviderContainer(
        overrides: [
          habitsProvider.overrideWith((ref) {
            final notifier = HabitsNotifier(_FakeHabitRepository());
            // Manually set state with test data
            return notifier;
          }),
          todayCompletionsProvider.overrideWith((ref) async => []),
        ],
      );
      addTearDown(container.dispose);

      final statsNotifier = container.read(statsProvider.notifier);
      await statsNotifier.loadStats();

      // With empty habits (initial state), everything should be zero
      final state = container.read(statsProvider);
      expect(state.totalHabits, 0);
      expect(state.bestStreak, 0);
      expect(state.averageStreak, 0);
      expect(state.overallCompletionRate, 0.0);
      expect(state.isLoading, false);
    });

    test('StatsState initial values are all zeros', () {
      const state = StatsState();

      expect(state.overallCompletionRate, 0.0);
      expect(state.totalCompletions, 0);
      expect(state.activeDays, 0);
      expect(state.totalHabits, 0);
      expect(state.bestStreak, 0);
      expect(state.averageStreak, 0);
      expect(state.isLoading, false);
    });

    test('StatsState copyWith updates specified fields', () {
      const state = StatsState();

      final updated = state.copyWith(
        totalHabits: 5,
        bestStreak: 10,
        averageStreak: 3,
        overallCompletionRate: 0.75,
      );

      expect(updated.totalHabits, 5);
      expect(updated.bestStreak, 10);
      expect(updated.averageStreak, 3);
      expect(updated.overallCompletionRate, 0.75);
      expect(updated.totalCompletions, 0);
      expect(updated.isLoading, false);
    });

    test('StatsState copyWith preserves unspecified fields', () {
      const state = StatsState(
        totalHabits: 5,
        bestStreak: 10,
        averageStreak: 3,
      );

      final updated = state.copyWith(isLoading: true);

      expect(updated.totalHabits, 5);
      expect(updated.bestStreak, 10);
      expect(updated.averageStreak, 3);
      expect(updated.isLoading, true);
    });

    test('stats computation with pre-populated habits in container', () async {
      // Create a container where habitsProvider already has data
      final container = ProviderContainer(
        overrides: [
          habitsProvider.overrideWith((ref) {
            return _PreloadedHabitsNotifier([
              HabitModel(
                id: 'h1',
                name: 'Run',
                createdAt: DateTime(2024, 1, 1),
                streak: const StreakModel(currentStreak: 5, longestStreak: 10),
              ),
              HabitModel(
                id: 'h2',
                name: 'Read',
                createdAt: DateTime(2024, 1, 1),
                streak: const StreakModel(currentStreak: 3, longestStreak: 7),
              ),
              HabitModel(
                id: 'h3',
                name: 'Archived',
                createdAt: DateTime(2024, 1, 1),
                isArchived: true,
                streak: const StreakModel(currentStreak: 0, longestStreak: 15),
              ),
            ]);
          }),
          todayCompletionsProvider.overrideWith((ref) async => []),
        ],
      );
      addTearDown(container.dispose);

      final statsNotifier = container.read(statsProvider.notifier);
      await statsNotifier.loadStats();

      final state = container.read(statsProvider);
      expect(state.totalHabits, 3);
      // bestStreak = max of all currentStreak and longestStreak = 15
      expect(state.bestStreak, 15);
      // averageStreak = (5 + 3 + 0) / 3 = 2.67 -> rounds to 3
      expect(state.averageStreak, 3);
    });

    test('completion rate calculation with active habits', () async {
      final container = ProviderContainer(
        overrides: [
          habitsProvider.overrideWith((ref) {
            return _PreloadedHabitsNotifier([
              HabitModel(
                id: 'h1',
                name: 'Run',
                createdAt: DateTime(2024, 1, 1),
              ),
              HabitModel(
                id: 'h2',
                name: 'Read',
                createdAt: DateTime(2024, 1, 1),
              ),
            ]);
          }),
          todayCompletionsProvider.overrideWith(
            (ref) async => [
              CompletionModel(id: 'c-1', completedAt: DateTime.now()),
            ],
          ),
        ],
      );
      addTearDown(container.dispose);

      final statsNotifier = container.read(statsProvider.notifier);
      await statsNotifier.loadStats();

      final state = container.read(statsProvider);
      // 1 completion out of 2 active habits = 0.5
      expect(state.overallCompletionRate, 0.5);
      expect(state.totalCompletions, 1);
    });

    test('empty habits list results in all zeros', () async {
      final container = ProviderContainer(
        overrides: [
          habitsProvider.overrideWith((ref) {
            return _PreloadedHabitsNotifier([]);
          }),
          todayCompletionsProvider.overrideWith((ref) async => []),
        ],
      );
      addTearDown(container.dispose);

      final statsNotifier = container.read(statsProvider.notifier);
      await statsNotifier.loadStats();

      final state = container.read(statsProvider);
      expect(state.totalHabits, 0);
      expect(state.bestStreak, 0);
      expect(state.averageStreak, 0);
      expect(state.overallCompletionRate, 0.0);
      expect(state.totalCompletions, 0);
    });
  });
}

/// A fake HabitRepository for creating a HabitsNotifier without real Dio.
class _FakeHabitRepository implements HabitRepository {
  @override
  Future<List<HabitModel>> getHabits({int page = 1, int limit = 100}) async =>
      [];

  @override
  Future<HabitModel> getHabitById(String id) async =>
      HabitModel(id: id, name: '', createdAt: DateTime.now());

  @override
  Future<HabitModel> createHabit(CreateHabitRequest request) async =>
      HabitModel(id: '', name: '', createdAt: DateTime.now());

  @override
  Future<HabitModel> updateHabit(String id, UpdateHabitRequest request) async =>
      HabitModel(id: id, name: '', createdAt: DateTime.now());

  @override
  Future<void> deleteHabit(String id) async {}

  @override
  Future<CompletionModel> completeHabit(String habitId, {String? note}) async =>
      CompletionModel(id: '', completedAt: DateTime.now());

  @override
  Future<void> uncompleteHabit(String completionId) async {}

  @override
  Future<List<CompletionModel>> getCompletions({
    String? habitId,
    int page = 1,
    int limit = 100,
  }) async => [];

  @override
  Future<StreakModel> getStreak(String habitId) async => const StreakModel();
}

/// A HabitsNotifier that starts with a pre-loaded list of habits.
class _PreloadedHabitsNotifier extends HabitsNotifier {
  _PreloadedHabitsNotifier(List<HabitModel> habits)
    : super(_FakeHabitRepository()) {
    state = HabitsState(habits: habits);
  }
}
