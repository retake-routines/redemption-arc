import 'package:flutter_test/flutter_test.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';

void main() {
  group('UserModel', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'id': 'user-1',
        'email': 'test@example.com',
        'display_name': 'Test User',
        'created_at': '2024-01-15T10:30:00.000Z',
        'updated_at': '2024-01-16T12:00:00.000Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'user-1');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.createdAt, DateTime.parse('2024-01-15T10:30:00.000Z'));
      expect(user.updatedAt, DateTime.parse('2024-01-16T12:00:00.000Z'));
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final user = UserModel.fromJson(json);

      expect(user.id, '');
      expect(user.email, '');
      expect(user.displayName, '');
    });

    test('fromJson handles null values', () {
      final json = <String, dynamic>{
        'id': null,
        'email': null,
        'display_name': null,
        'created_at': null,
        'updated_at': null,
      };

      final user = UserModel.fromJson(json);

      expect(user.id, '');
      expect(user.email, '');
      expect(user.displayName, '');
    });

    test('toJson produces correct map', () {
      final now = DateTime(2024, 1, 15, 10, 30);
      final user = UserModel(
        id: 'user-1',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: now,
        updatedAt: now,
      );

      final json = user.toJson();

      expect(json['id'], 'user-1');
      expect(json['email'], 'test@example.com');
      expect(json['display_name'], 'Test User');
      expect(json['created_at'], now.toIso8601String());
      expect(json['updated_at'], now.toIso8601String());
    });

    test('toJson/fromJson roundtrip preserves data', () {
      final now = DateTime(2024, 1, 15, 10, 30);
      final original = UserModel(
        id: 'user-1',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: now,
        updatedAt: now,
      );

      final restored = UserModel.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.email, original.email);
      expect(restored.displayName, original.displayName);
      expect(restored.createdAt, original.createdAt);
      expect(restored.updatedAt, original.updatedAt);
    });
  });

  group('HabitModel', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'id': 'habit-1',
        'user_id': 'user-1',
        'title': 'Morning Run',
        'description': 'Run every morning',
        'icon': 'run',
        'color': '#FF0000',
        'frequency_type': 'daily',
        'frequency_value': 1,
        'is_archived': false,
        'created_at': '2024-01-15T10:30:00.000Z',
        'updated_at': '2024-01-16T12:00:00.000Z',
        'streak': {
          'habit_id': 'habit-1',
          'current_streak': 5,
          'longest_streak': 10,
        },
        'completions': [
          {
            'id': 'c-1',
            'habit_id': 'habit-1',
            'user_id': 'user-1',
            'completed_at': '2024-01-15T10:00:00.000Z',
            'note': 'Great run',
          }
        ],
      };

      final habit = HabitModel.fromJson(json);

      expect(habit.id, 'habit-1');
      expect(habit.userId, 'user-1');
      expect(habit.name, 'Morning Run');
      expect(habit.description, 'Run every morning');
      expect(habit.icon, 'run');
      expect(habit.color, '#FF0000');
      expect(habit.frequency, 'daily');
      expect(habit.targetCount, 1);
      expect(habit.isArchived, false);
      expect(habit.streak.currentStreak, 5);
      expect(habit.streak.longestStreak, 10);
      expect(habit.completions.length, 1);
      expect(habit.completions.first.note, 'Great run');
    });

    test('fromJson maps API field title to model field name', () {
      final json = {
        'title': 'Meditate',
        'created_at': '2024-01-01T00:00:00.000Z',
      };

      final habit = HabitModel.fromJson(json);

      expect(habit.name, 'Meditate');
    });

    test('fromJson maps API field frequency_type to model field frequency', () {
      final json = {
        'frequency_type': 'weekly',
        'created_at': '2024-01-01T00:00:00.000Z',
      };

      final habit = HabitModel.fromJson(json);

      expect(habit.frequency, 'weekly');
    });

    test('fromJson maps API field frequency_value to model field targetCount',
        () {
      final json = {
        'frequency_value': 3,
        'created_at': '2024-01-01T00:00:00.000Z',
      };

      final habit = HabitModel.fromJson(json);

      expect(habit.targetCount, 3);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final habit = HabitModel.fromJson(json);

      expect(habit.id, '');
      expect(habit.userId, '');
      expect(habit.name, '');
      expect(habit.description, '');
      expect(habit.frequency, 'daily');
      expect(habit.targetCount, 1);
      expect(habit.isArchived, false);
      expect(habit.streak.currentStreak, 0);
      expect(habit.completions, isEmpty);
    });

    test('fromJson handles null streak and completions', () {
      final json = {
        'id': 'h1',
        'streak': null,
        'completions': null,
        'created_at': '2024-01-01T00:00:00.000Z',
      };

      final habit = HabitModel.fromJson(json);

      expect(habit.streak.currentStreak, 0);
      expect(habit.completions, isEmpty);
    });

    test('toJson maps model field name to API field title', () {
      final habit = HabitModel(
        id: 'habit-1',
        name: 'Meditate',
        createdAt: DateTime(2024, 1, 1),
      );

      final json = habit.toJson();

      expect(json['title'], 'Meditate');
      expect(json.containsKey('name'), false);
    });

    test('toJson maps model field frequency to API field frequency_type', () {
      final habit = HabitModel(
        id: 'habit-1',
        name: 'Run',
        frequency: 'weekly',
        createdAt: DateTime(2024, 1, 1),
      );

      final json = habit.toJson();

      expect(json['frequency_type'], 'weekly');
    });

    test('toJson maps model field targetCount to API field frequency_value',
        () {
      final habit = HabitModel(
        id: 'habit-1',
        name: 'Run',
        targetCount: 5,
        createdAt: DateTime(2024, 1, 1),
      );

      final json = habit.toJson();

      expect(json['frequency_value'], 5);
    });

    test('updatedAt defaults to createdAt when not provided', () {
      final created = DateTime(2024, 1, 1);
      final habit = HabitModel(
        id: 'habit-1',
        name: 'Test',
        createdAt: created,
      );

      expect(habit.updatedAt, created);
    });

    test('copyWith creates a new instance with updated fields', () {
      final habit = HabitModel(
        id: 'habit-1',
        name: 'Original',
        createdAt: DateTime(2024, 1, 1),
      );

      final updated = habit.copyWith(name: 'Updated');

      expect(updated.name, 'Updated');
      expect(updated.id, 'habit-1');
    });
  });

  group('CompletionModel', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'id': 'c-1',
        'habit_id': 'habit-1',
        'user_id': 'user-1',
        'completed_at': '2024-01-15T10:30:00.000Z',
        'note': 'Done!',
      };

      final completion = CompletionModel.fromJson(json);

      expect(completion.id, 'c-1');
      expect(completion.habitId, 'habit-1');
      expect(completion.userId, 'user-1');
      expect(
          completion.completedAt, DateTime.parse('2024-01-15T10:30:00.000Z'));
      expect(completion.note, 'Done!');
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final completion = CompletionModel.fromJson(json);

      expect(completion.id, '');
      expect(completion.habitId, '');
      expect(completion.userId, '');
      expect(completion.note, '');
    });

    test('toJson produces correct map', () {
      final completedAt = DateTime(2024, 1, 15, 10, 30);
      final completion = CompletionModel(
        id: 'c-1',
        habitId: 'habit-1',
        userId: 'user-1',
        completedAt: completedAt,
        note: 'Done!',
      );

      final json = completion.toJson();

      expect(json['id'], 'c-1');
      expect(json['habit_id'], 'habit-1');
      expect(json['user_id'], 'user-1');
      expect(json['completed_at'], completedAt.toIso8601String());
      expect(json['note'], 'Done!');
    });

    test('toJson/fromJson roundtrip preserves data', () {
      final original = CompletionModel(
        id: 'c-1',
        habitId: 'habit-1',
        userId: 'user-1',
        completedAt: DateTime(2024, 1, 15, 10, 30),
        note: 'Done!',
      );

      final restored = CompletionModel.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.habitId, original.habitId);
      expect(restored.userId, original.userId);
      expect(restored.completedAt, original.completedAt);
      expect(restored.note, original.note);
    });
  });

  group('StreakModel', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'habit_id': 'habit-1',
        'current_streak': 5,
        'longest_streak': 10,
        'last_completed_at': '2024-01-15T10:30:00.000Z',
      };

      final streak = StreakModel.fromJson(json);

      expect(streak.habitId, 'habit-1');
      expect(streak.currentStreak, 5);
      expect(streak.longestStreak, 10);
      expect(streak.lastCompletedAt,
          DateTime.parse('2024-01-15T10:30:00.000Z'));
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final streak = StreakModel.fromJson(json);

      expect(streak.habitId, '');
      expect(streak.currentStreak, 0);
      expect(streak.longestStreak, 0);
      expect(streak.lastCompletedAt, isNull);
    });

    test('default constructor has zero values', () {
      const streak = StreakModel();

      expect(streak.habitId, '');
      expect(streak.currentStreak, 0);
      expect(streak.longestStreak, 0);
      expect(streak.lastCompletedAt, isNull);
    });

    test('toJson produces correct map', () {
      final lastCompleted = DateTime(2024, 1, 15, 10, 30);
      final streak = StreakModel(
        habitId: 'habit-1',
        currentStreak: 5,
        longestStreak: 10,
        lastCompletedAt: lastCompleted,
      );

      final json = streak.toJson();

      expect(json['habit_id'], 'habit-1');
      expect(json['current_streak'], 5);
      expect(json['longest_streak'], 10);
      expect(json['last_completed_at'], lastCompleted.toIso8601String());
    });

    test('toJson handles null lastCompletedAt', () {
      const streak = StreakModel(habitId: 'habit-1');

      final json = streak.toJson();

      expect(json['last_completed_at'], isNull);
    });

    test('toJson/fromJson roundtrip preserves data', () {
      final original = StreakModel(
        habitId: 'habit-1',
        currentStreak: 5,
        longestStreak: 10,
        lastCompletedAt: DateTime(2024, 1, 15, 10, 30),
      );

      final restored = StreakModel.fromJson(original.toJson());

      expect(restored.habitId, original.habitId);
      expect(restored.currentStreak, original.currentStreak);
      expect(restored.longestStreak, original.longestStreak);
      expect(restored.lastCompletedAt, original.lastCompletedAt);
    });
  });

  group('AuthResponse', () {
    test('fromJson parses token and user correctly', () {
      final json = {
        'token': 'jwt-token-123',
        'user': {
          'id': 'user-1',
          'email': 'test@example.com',
          'display_name': 'Test User',
          'created_at': '2024-01-15T10:30:00.000Z',
          'updated_at': '2024-01-15T10:30:00.000Z',
        },
      };

      final response = AuthResponse.fromJson(json);

      expect(response.token, 'jwt-token-123');
      expect(response.user.id, 'user-1');
      expect(response.user.email, 'test@example.com');
      expect(response.user.displayName, 'Test User');
    });

    test('fromJson handles missing token', () {
      final json = {
        'user': {
          'id': 'user-1',
          'email': 'test@example.com',
          'created_at': '2024-01-15T10:30:00.000Z',
          'updated_at': '2024-01-15T10:30:00.000Z',
        },
      };

      final response = AuthResponse.fromJson(json);

      expect(response.token, '');
    });
  });

  group('CreateHabitRequest', () {
    test('toJson produces correct map with all fields', () {
      const request = CreateHabitRequest(
        title: 'Morning Run',
        description: 'Run 5k',
        icon: 'run',
        color: '#FF0000',
        frequencyType: 'daily',
        frequencyValue: 1,
      );

      final json = request.toJson();

      expect(json['title'], 'Morning Run');
      expect(json['description'], 'Run 5k');
      expect(json['icon'], 'run');
      expect(json['color'], '#FF0000');
      expect(json['frequency_type'], 'daily');
      expect(json['frequency_value'], 1);
    });

    test('toJson uses default values when not specified', () {
      const request = CreateHabitRequest(title: 'Meditate');

      final json = request.toJson();

      expect(json['title'], 'Meditate');
      expect(json['description'], '');
      expect(json['icon'], '');
      expect(json['color'], '');
      expect(json['frequency_type'], 'daily');
      expect(json['frequency_value'], 1);
    });
  });

  group('UpdateHabitRequest', () {
    test('toJson includes only non-null fields', () {
      const request = UpdateHabitRequest(
        title: 'Updated Title',
        frequencyValue: 3,
      );

      final json = request.toJson();

      expect(json['title'], 'Updated Title');
      expect(json['frequency_value'], 3);
      expect(json.containsKey('description'), false);
      expect(json.containsKey('icon'), false);
      expect(json.containsKey('color'), false);
      expect(json.containsKey('frequency_type'), false);
      expect(json.containsKey('is_archived'), false);
    });

    test('toJson returns empty map when all fields are null', () {
      const request = UpdateHabitRequest();

      final json = request.toJson();

      expect(json, isEmpty);
    });

    test('toJson includes all fields when all are set', () {
      const request = UpdateHabitRequest(
        title: 'Title',
        description: 'Desc',
        icon: 'icon',
        color: '#000',
        frequencyType: 'weekly',
        frequencyValue: 2,
        isArchived: true,
      );

      final json = request.toJson();

      expect(json.length, 7);
      expect(json['title'], 'Title');
      expect(json['description'], 'Desc');
      expect(json['icon'], 'icon');
      expect(json['color'], '#000');
      expect(json['frequency_type'], 'weekly');
      expect(json['frequency_value'], 2);
      expect(json['is_archived'], true);
    });
  });
}
