import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitpal_frontend/core/network/api_endpoints.dart';
import 'package:habitpal_frontend/core/storage/local_storage.dart';

/// Callback provider that the auth layer sets to handle forced logouts
/// (e.g., on 401 responses). This avoids a circular dependency between
/// the network layer and the auth layer.
final onUnauthorizedProvider = StateProvider<void Function()?>((ref) => null);

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Auth interceptor: attach JWT token to every request
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final storage = ref.read(localStorageProvider);
        final token = await storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) {
        // On 401 from a protected endpoint, trigger forced logout
        if (error.response?.statusCode == 401) {
          final path = error.requestOptions.path;
          final isAuthEndpoint =
              path == ApiEndpoints.login || path == ApiEndpoints.register;
          if (!isAuthEndpoint) {
            final onUnauthorized = ref.read(onUnauthorizedProvider);
            if (onUnauthorized != null) {
              onUnauthorized();
            }
          }
        }

        // Convert server error messages to DioException messages
        final responseData = error.response?.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('error')) {
          final serverMessage = responseData['error'] as String;
          handler.next(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: serverMessage,
              message: serverMessage,
            ),
          );
          return;
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});
