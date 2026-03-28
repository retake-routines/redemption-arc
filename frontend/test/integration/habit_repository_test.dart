import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitpal_frontend/core/network/api_endpoints.dart';
import 'package:habitpal_frontend/features/habits/data/habit_repository.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late HabitRepository repository;

  setUp(() {
    mockDio = MockDio();
    repository = HabitRepository(dio: mockDio);
  });

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  group('HabitRepository', () {
    group('getHabits', () {
      test('calls GET /habits with default pagination', () async {
        when(() => mockDio.get(
              ApiEndpoints.habits,
              queryParameters: {'page': 1, 'limit': 100},
            )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ApiEndpoints.habits),
              statusCode: 200,
              data: {
                'habits': [
                  {
                    'id': 'h1',
                    'title': 'Run',
                    'description': 'Morning run',
                    'frequency_type': 'daily',
                    'frequency_value': 1,
                    'created_at': '2024-01-01T00:00:00.000Z',
                    'updated_at': '2024-01-01T00:00:00.000Z',
                  },
                ],
              },
            ));

        final habits = await repository.getHabits();

        expect(habits.length, 1);
        expect(habits.first.name, 'Run');
        expect(habits.first.description, 'Morning run');
        verify(() => mockDio.get(
              ApiEndpoints.habits,
              queryParameters: {'page': 1, 'limit': 100},
            )).called(1);
      });

      test('returns empty list when habits key is null', () async {
        when(() => mockDio.get(
              ApiEndpoints.habits,
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ApiEndpoints.habits),
              statusCode: 200,
              data: {'habits': null},
            ));

        final habits = await repository.getHabits();

        expect(habits, isEmpty);
      });
    });

    group('createHabit', () {
      test('calls POST /habits with correct body', () async {
        const request = CreateHabitRequest(
          title: 'Meditate',
          description: '10 minutes',
          frequencyType: 'daily',
          frequencyValue: 1,
        );

        when(() => mockDio.post(
              ApiEndpoints.habits,
              data: request.toJson(),
            )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ApiEndpoints.habits),
              statusCode: 201,
              data: {
                'id': 'h-new',
                'title': 'Meditate',
                'description': '10 minutes',
                'frequency_type': 'daily',
                'frequency_value': 1,
                'created_at': '2024-01-01T00:00:00.000Z',
                'updated_at': '2024-01-01T00:00:00.000Z',
              },
            ));

        final created = await repository.createHabit(request);

        expect(created.id, 'h-new');
        expect(created.name, 'Meditate');
        verify(() => mockDio.post(
              ApiEndpoints.habits,
              data: request.toJson(),
            )).called(1);
      });
    });

    group('updateHabit', () {
      test('calls PUT /habits/:id with correct body', () async {
        const request = UpdateHabitRequest(
          title: 'Updated Habit',
          description: 'Updated desc',
        );

        when(() => mockDio.put(
              ApiEndpoints.habitById('h1'),
              data: request.toJson(),
            )).thenAnswer((_) async => Response(
              requestOptions:
                  RequestOptions(path: ApiEndpoints.habitById('h1')),
              statusCode: 200,
              data: {
                'id': 'h1',
                'title': 'Updated Habit',
                'description': 'Updated desc',
                'frequency_type': 'daily',
                'frequency_value': 1,
                'created_at': '2024-01-01T00:00:00.000Z',
                'updated_at': '2024-01-02T00:00:00.000Z',
              },
            ));

        final updated = await repository.updateHabit('h1', request);

        expect(updated.id, 'h1');
        expect(updated.name, 'Updated Habit');
        verify(() => mockDio.put(
              ApiEndpoints.habitById('h1'),
              data: request.toJson(),
            )).called(1);
      });
    });

    group('deleteHabit', () {
      test('calls DELETE /habits/:id', () async {
        when(() => mockDio.delete(ApiEndpoints.habitById('h1')))
            .thenAnswer((_) async => Response(
                  requestOptions:
                      RequestOptions(path: ApiEndpoints.habitById('h1')),
                  statusCode: 204,
                ));

        await repository.deleteHabit('h1');

        verify(() => mockDio.delete(ApiEndpoints.habitById('h1'))).called(1);
      });
    });

    group('completeHabit', () {
      test('calls POST /completions with habit_id', () async {
        when(() => mockDio.post(
              ApiEndpoints.completions,
              data: {'habit_id': 'h1'},
            )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ApiEndpoints.completions),
              statusCode: 201,
              data: {
                'id': 'c-1',
                'habit_id': 'h1',
                'user_id': 'user-1',
                'completed_at': '2024-01-15T10:00:00.000Z',
                'note': '',
              },
            ));

        final completion = await repository.completeHabit('h1');

        expect(completion.id, 'c-1');
        expect(completion.habitId, 'h1');
        verify(() => mockDio.post(
              ApiEndpoints.completions,
              data: {'habit_id': 'h1'},
            )).called(1);
      });

      test('includes note when provided', () async {
        when(() => mockDio.post(
              ApiEndpoints.completions,
              data: {'habit_id': 'h1', 'note': 'Great session'},
            )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ApiEndpoints.completions),
              statusCode: 201,
              data: {
                'id': 'c-1',
                'habit_id': 'h1',
                'user_id': 'user-1',
                'completed_at': '2024-01-15T10:00:00.000Z',
                'note': 'Great session',
              },
            ));

        final completion =
            await repository.completeHabit('h1', note: 'Great session');

        expect(completion.note, 'Great session');
      });
    });

    group('getStreak', () {
      test('calls GET /completions/streak/:id', () async {
        when(() => mockDio.get(ApiEndpoints.streak('h1')))
            .thenAnswer((_) async => Response(
                  requestOptions:
                      RequestOptions(path: ApiEndpoints.streak('h1')),
                  statusCode: 200,
                  data: {
                    'habit_id': 'h1',
                    'current_streak': 5,
                    'longest_streak': 10,
                    'last_completed_at': '2024-01-15T10:00:00.000Z',
                  },
                ));

        final streak = await repository.getStreak('h1');

        expect(streak.habitId, 'h1');
        expect(streak.currentStreak, 5);
        expect(streak.longestStreak, 10);
        verify(() => mockDio.get(ApiEndpoints.streak('h1'))).called(1);
      });
    });

    group('getCompletions', () {
      test('calls GET /completions with pagination', () async {
        when(() => mockDio.get(
              ApiEndpoints.completions,
              queryParameters: {'page': 1, 'limit': 100},
            )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ApiEndpoints.completions),
              statusCode: 200,
              data: {
                'completions': [
                  {
                    'id': 'c-1',
                    'habit_id': 'h1',
                    'user_id': 'user-1',
                    'completed_at': '2024-01-15T10:00:00.000Z',
                    'note': '',
                  },
                ],
              },
            ));

        final completions = await repository.getCompletions();

        expect(completions.length, 1);
        expect(completions.first.id, 'c-1');
      });

      test('includes habit_id filter when provided', () async {
        when(() => mockDio.get(
              ApiEndpoints.completions,
              queryParameters: {
                'page': 1,
                'limit': 100,
                'habit_id': 'h1',
              },
            )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ApiEndpoints.completions),
              statusCode: 200,
              data: {'completions': []},
            ));

        await repository.getCompletions(habitId: 'h1');

        verify(() => mockDio.get(
              ApiEndpoints.completions,
              queryParameters: {
                'page': 1,
                'limit': 100,
                'habit_id': 'h1',
              },
            )).called(1);
      });
    });

    group('uncompleteHabit', () {
      test('calls DELETE /completions/:id', () async {
        when(() => mockDio.delete(ApiEndpoints.completionById('c-1')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(
                      path: ApiEndpoints.completionById('c-1')),
                  statusCode: 204,
                ));

        await repository.uncompleteHabit('c-1');

        verify(() => mockDio.delete(ApiEndpoints.completionById('c-1')))
            .called(1);
      });
    });
  });
}
