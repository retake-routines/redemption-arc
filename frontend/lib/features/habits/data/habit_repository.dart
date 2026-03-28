import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitpal_frontend/core/network/api_client.dart';
import 'package:habitpal_frontend/core/network/api_endpoints.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository(dio: ref.read(dioProvider));
});

class HabitRepository {
  final Dio _dio;

  HabitRepository({required Dio dio}) : _dio = dio;

  /// Fetches the paginated list of habits for the authenticated user.
  Future<List<HabitModel>> getHabits({int page = 1, int limit = 100}) async {
    final response = await _dio.get(
      ApiEndpoints.habits,
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data as Map<String, dynamic>;
    final habitsJson = data['habits'] as List<dynamic>? ?? [];
    return habitsJson
        .map((json) => HabitModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetches a single habit by its ID.
  Future<HabitModel> getHabitById(String id) async {
    final response = await _dio.get(ApiEndpoints.habitById(id));
    return HabitModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Creates a new habit.
  Future<HabitModel> createHabit(CreateHabitRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.habits,
      data: request.toJson(),
    );
    return HabitModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Updates an existing habit.
  Future<HabitModel> updateHabit(String id, UpdateHabitRequest request) async {
    final response = await _dio.put(
      ApiEndpoints.habitById(id),
      data: request.toJson(),
    );
    return HabitModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Deletes a habit and all its completions.
  Future<void> deleteHabit(String id) async {
    await _dio.delete(ApiEndpoints.habitById(id));
  }

  /// Records a completion for the given habit.
  Future<CompletionModel> completeHabit(String habitId, {String? note}) async {
    final data = <String, dynamic>{'habit_id': habitId};
    if (note != null && note.isNotEmpty) {
      data['note'] = note;
    }
    final response = await _dio.post(
      ApiEndpoints.completions,
      data: data,
    );
    return CompletionModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Removes a previously recorded completion.
  Future<void> uncompleteHabit(String completionId) async {
    await _dio.delete(ApiEndpoints.completionById(completionId));
  }

  /// Fetches completions, optionally filtered by habit ID.
  Future<List<CompletionModel>> getCompletions({
    String? habitId,
    int page = 1,
    int limit = 100,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (habitId != null) {
      queryParams['habit_id'] = habitId;
    }
    final response = await _dio.get(
      ApiEndpoints.completions,
      queryParameters: queryParams,
    );
    final data = response.data as Map<String, dynamic>;
    final completionsJson = data['completions'] as List<dynamic>? ?? [];
    return completionsJson
        .map((json) => CompletionModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetches streak data for a specific habit.
  Future<StreakModel> getStreak(String habitId) async {
    final response = await _dio.get(ApiEndpoints.streak(habitId));
    return StreakModel.fromJson(response.data as Map<String, dynamic>);
  }
}
