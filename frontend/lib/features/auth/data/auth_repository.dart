import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitpal_frontend/core/network/api_client.dart';
import 'package:habitpal_frontend/core/network/api_endpoints.dart';
import 'package:habitpal_frontend/core/storage/local_storage.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.read(dioProvider),
    storage: ref.read(localStorageProvider),
  );
});

class AuthRepository {
  final Dio _dio;
  final LocalStorage _storage;

  AuthRepository({required Dio dio, required LocalStorage storage})
    : _dio = dio,
      _storage = storage;

  /// Authenticates a user and persists the JWT token + user data.
  /// Returns the [AuthResponse] on success.
  /// Throws a descriptive [String] error on failure.
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      final authResponse = AuthResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _storage.saveToken(authResponse.token);
      await _storage.saveUser(authResponse.user.toJson());
      return authResponse;
    } on DioException catch (e) {
      throw _extractErrorMessage(
        e,
        'Login failed. Please check your credentials.',
      );
    }
  }

  /// Registers a new user and persists the JWT token + user data.
  /// Returns the [AuthResponse] on success.
  /// Throws a descriptive [String] error on failure.
  Future<AuthResponse> register({
    required String email,
    required String password,
    String displayName = '',
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
          'display_name': displayName,
        },
      );
      final authResponse = AuthResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _storage.saveToken(authResponse.token);
      await _storage.saveUser(authResponse.user.toJson());
      return authResponse;
    } on DioException catch (e) {
      throw _extractErrorMessage(e, 'Registration failed. Please try again.');
    }
  }

  /// Clears all locally stored auth data.
  Future<void> logout() async {
    await _storage.deleteToken();
    await _storage.deleteUser();
  }

  /// Returns `true` if a token is present in local storage.
  Future<bool> isAuthenticated() async {
    final token = await _storage.getToken();
    return token != null;
  }

  /// Loads the cached user from local storage, if available.
  Future<UserModel?> getCachedUser() async {
    final json = await _storage.getUser();
    if (json == null) return null;
    return UserModel.fromJson(json);
  }

  /// Extracts a user-friendly error message from a DioException.
  String _extractErrorMessage(DioException e, String fallback) {
    final message = e.message;
    if (message != null && message.isNotEmpty) {
      return message;
    }
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data.containsKey('error')) {
      return data['error'] as String;
    }
    return fallback;
  }
}
