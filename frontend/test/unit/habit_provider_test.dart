import 'package:flutter_test/flutter_test.dart';
import 'package:habitpal_frontend/features/habits/data/habit_repository.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  late MockHabitRepository mockRepository;
  late HabitsNotifier notifier;

  setUp(() {
    mockRepository = MockHabitRepository();
    notifier = HabitsNotifier(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      const CreateHabitRequest(title: 'fallback'),
    );
    registerFallbackValue(
      const UpdateHabitRequest(),
    );
  });

  group('HabitsNotifier', () {
    group('initial state', () {
      test('has empty habits list', () {
        expect(notifier.state.habits, isEmpty);
      });

      test('is not loading', () {
        expect(notifier.state.isLoading, false);
      });

      test('has no error message', () {
        expect(notifier.state.errorMessage, isNull);
      });
    });

    group('loadHabits', () {
      test('populates habits list on success', () async {
        final testHabits = [
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
        ];

        when(() => mockRepository.getHabits())
            .thenAnswer((_) async => testHabits);
        when(() => mockRepository.getStreak(any()))
            .thenAnswer((_) async => const StreakModel());

        await notifier.loadHabits();

        expect(notifier.state.habits.length, 2);
        expect(notifier.state.habits[0].name, 'Run');
        expect(notifier.state.habits[1].name, 'Read');
        expect(notifier.state.isLoading, false);
        expect(notifier.state.errorMessage, isNull);
      });

      test('sets error message on failure', () async {
        when(() => mockRepository.getHabits())
            .thenThrow(Exception('Network error'));

        await notifier.loadHabits();

        expect(notifier.state.errorMessage, isNotNull);
        expect(notifier.state.isLoading, false);
      });

      test('enriches habits with streak data', () async {
        final testHabits = [
          HabitModel(
            id: 'h1',
            name: 'Run',
            createdAt: DateTime(2024, 1, 1),
          ),
        ];
        final testStreak = const StreakModel(
          habitId: 'h1',
          currentStreak: 5,
          longestStreak: 10,
        );

        when(() => mockRepository.getHabits())
            .thenAnswer((_) async => testHabits);
        when(() => mockRepository.getStreak('h1'))
            .thenAnswer((_) async => testStreak);

        await notifier.loadHabits();

        expect(notifier.state.habits.first.streak.currentStreak, 5);
        expect(notifier.state.habits.first.streak.longestStreak, 10);
      });

      test('handles streak fetch failure gracefully', () async {
        final testHabits = [
          HabitModel(
            id: 'h1',
            name: 'Run',
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        when(() => mockRepository.getHabits())
            .thenAnswer((_) async => testHabits);
        when(() => mockRepository.getStreak(any()))
            .thenThrow(Exception('Streak error'));

        await notifier.loadHabits();

        // Should still have the habit, just without enriched streak data
        expect(notifier.state.habits.length, 1);
        expect(notifier.state.errorMessage, isNull);
      });

      test('transitions through loading state', () async {
        when(() => mockRepository.getHabits())
            .thenAnswer((_) async => []);
        when(() => mockRepository.getStreak(any()))
            .thenAnswer((_) async => const StreakModel());

        await notifier.loadHabits();

        // After load completes, loading should be false and no error
        expect(notifier.state.isLoading, false);
        expect(notifier.state.errorMessage, isNull);
      });
    });

    group('createHabit', () {
      test('adds new habit to list', () async {
        final newHabit = HabitModel(
          id: 'h-new',
          name: 'New Habit',
          createdAt: DateTime(2024, 1, 1),
        );

        when(() => mockRepository.createHabit(any()))
            .thenAnswer((_) async => newHabit);

        await notifier.createHabit(
          const CreateHabitRequest(title: 'New Habit'),
        );

        expect(notifier.state.habits.length, 1);
        expect(notifier.state.habits.first.name, 'New Habit');
      });

      test('sets error message on failure', () async {
        when(() => mockRepository.createHabit(any()))
            .thenThrow(Exception('Create failed'));

        await notifier.createHabit(
          const CreateHabitRequest(title: 'Failing Habit'),
        );

        expect(notifier.state.errorMessage, isNotNull);
      });
    });

    group('deleteHabit', () {
      test('removes habit from list', () async {
        // Seed with habits
        final testHabits = [
          HabitModel(
            id: 'h1',
            name: 'Keep',
            createdAt: DateTime(2024, 1, 1),
          ),
          HabitModel(
            id: 'h2',
            name: 'Delete',
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        when(() => mockRepository.getHabits())
            .thenAnswer((_) async => testHabits);
        when(() => mockRepository.getStreak(any()))
            .thenAnswer((_) async => const StreakModel());

        await notifier.loadHabits();
        expect(notifier.state.habits.length, 2);

        when(() => mockRepository.deleteHabit('h2'))
            .thenAnswer((_) async {});

        await notifier.deleteHabit('h2');

        expect(notifier.state.habits.length, 1);
        expect(notifier.state.habits.first.id, 'h1');
      });

      test('sets error message on failure', () async {
        when(() => mockRepository.deleteHabit(any()))
            .thenThrow(Exception('Delete failed'));

        await notifier.deleteHabit('h1');

        expect(notifier.state.errorMessage, isNotNull);
      });
    });

    group('completeHabit', () {
      test('calls repository and reloads habits', () async {
        when(() => mockRepository.completeHabit('h1'))
            .thenAnswer((_) async => CompletionModel(
                  id: 'c-1',
                  completedAt: DateTime.now(),
                ));
        when(() => mockRepository.getHabits())
            .thenAnswer((_) async => []);
        when(() => mockRepository.getStreak(any()))
            .thenAnswer((_) async => const StreakModel());

        await notifier.completeHabit('h1');

        verify(() => mockRepository.completeHabit('h1')).called(1);
        verify(() => mockRepository.getHabits()).called(1);
      });

      test('sets error message on failure', () async {
        when(() => mockRepository.completeHabit(any()))
            .thenThrow(Exception('Complete failed'));

        await notifier.completeHabit('h1');

        expect(notifier.state.errorMessage, isNotNull);
      });
    });

    group('updateHabit', () {
      test('updates habit in list', () async {
        // Seed with a habit
        final testHabits = [
          HabitModel(
            id: 'h1',
            name: 'Original',
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        when(() => mockRepository.getHabits())
            .thenAnswer((_) async => testHabits);
        when(() => mockRepository.getStreak(any()))
            .thenAnswer((_) async => const StreakModel());

        await notifier.loadHabits();

        final updatedHabit = HabitModel(
          id: 'h1',
          name: 'Updated',
          createdAt: DateTime(2024, 1, 1),
        );

        when(() => mockRepository.updateHabit('h1', any()))
            .thenAnswer((_) async => updatedHabit);

        await notifier.updateHabit(
          'h1',
          const UpdateHabitRequest(title: 'Updated'),
        );

        expect(notifier.state.habits.first.name, 'Updated');
      });
    });
  });
}
