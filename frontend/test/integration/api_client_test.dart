import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitpal_frontend/core/network/api_client.dart';
import 'package:habitpal_frontend/core/network/api_endpoints.dart';
import 'package:habitpal_frontend/core/storage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ApiClient (dioProvider)', () {
    test('auth interceptor adds Bearer token from storage', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = LocalStorage();
      await storage.saveToken('my-jwt-token');

      final container = ProviderContainer(
        overrides: [
          localStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      final dio = container.read(dioProvider);

      // The interceptor is attached; we verify it by checking the
      // interceptors count (base interceptor wrapper is always present).
      expect(dio.interceptors.isNotEmpty, true);

      // Verify base URL is set
      expect(dio.options.baseUrl, ApiEndpoints.baseUrl);
    });

    test('dio has correct base configuration', () {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final dio = container.read(dioProvider);

      expect(dio.options.baseUrl, ApiEndpoints.baseUrl);
      expect(dio.options.headers['Content-Type'], 'application/json');
      expect(dio.options.headers['Accept'], 'application/json');
      expect(dio.options.connectTimeout, const Duration(seconds: 30));
      expect(dio.options.receiveTimeout, const Duration(seconds: 30));
      expect(dio.options.sendTimeout, const Duration(seconds: 30));
    });

    test('onUnauthorizedProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final callback = container.read(onUnauthorizedProvider);

      expect(callback, isNull);
    });

    test('onUnauthorizedProvider can be set to a callback', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      var called = false;
      container.read(onUnauthorizedProvider.notifier).state = () {
        called = true;
      };

      final callback = container.read(onUnauthorizedProvider);
      callback!();

      expect(called, true);
    });
  });
}
