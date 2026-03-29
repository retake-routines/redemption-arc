import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';

/// Creates a [UserModel] with sensible defaults for testing.
UserModel createTestUser({
  String id = 'user-1',
  String email = 'test@example.com',
  String displayName = 'Test User',
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final now = DateTime(2024, 1, 1);
  return UserModel(
    id: id,
    email: email,
    displayName: displayName,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
  );
}

/// Creates a [HabitModel] with sensible defaults for testing.
HabitModel createTestHabit({
  String id = 'habit-1',
  String name = 'Test Habit',
  String description = 'A test habit',
  String frequency = 'daily',
  int targetCount = 1,
  bool isArchived = false,
  StreakModel? streak,
  List<CompletionModel>? completions,
  bool completedToday = false,
  DateTime? createdAt,
}) {
  return HabitModel(
    id: id,
    name: name,
    description: description,
    frequency: frequency,
    targetCount: targetCount,
    isArchived: isArchived,
    streak: streak ?? const StreakModel(),
    completions: completions ?? const [],
    completedToday: completedToday,
    createdAt: createdAt ?? DateTime(2024, 1, 1),
  );
}

/// Creates a [StreakModel] with sensible defaults for testing.
StreakModel createTestStreak({
  String habitId = 'habit-1',
  int currentStreak = 5,
  int longestStreak = 10,
  DateTime? lastCompletedAt,
}) {
  return StreakModel(
    habitId: habitId,
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    lastCompletedAt: lastCompletedAt,
  );
}

/// Creates a [CompletionModel] with sensible defaults for testing.
CompletionModel createTestCompletion({
  String id = 'completion-1',
  String habitId = 'habit-1',
  String userId = 'user-1',
  DateTime? completedAt,
  String note = '',
}) {
  return CompletionModel(
    id: id,
    habitId: habitId,
    userId: userId,
    completedAt: completedAt ?? DateTime(2024, 1, 1),
    note: note,
  );
}

/// Creates an [AuthResponse] with sensible defaults for testing.
AuthResponse createTestAuthResponse({
  String token = 'test-jwt-token',
  UserModel? user,
}) {
  return AuthResponse(token: token, user: user ?? createTestUser());
}
