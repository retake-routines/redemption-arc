/// All API endpoint constants matching the backend REST API contract.
///
/// Base URL uses 10.0.2.2 for Android emulator (maps to host localhost).
/// For web or iOS simulator, use localhost directly.
abstract class ApiEndpoints {
  /// Android emulator: 10.0.2.2 maps to host machine's localhost.
  /// For web: change to http://localhost:8080/api/v1
  /// For iOS simulator: use http://localhost:8080/api/v1
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1';

  // --------------- Auth ---------------
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // --------------- Habits ---------------
  static const String habits = '/habits';
  static String habitById(String id) => '/habits/$id';

  // --------------- Completions ---------------
  static const String completions = '/completions';
  static String completionById(String id) => '/completions/$id';
  static String streak(String habitId) => '/completions/streak/$habitId';
}
