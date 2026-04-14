import 'package:flutter_test/flutter_test.dart';
import 'package:habitpal_frontend/core/storage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorage();
  });

  group('LocalStorage', () {
    group('token', () {
      test('saveToken and getToken store and retrieve a token', () async {
        await storage.saveToken('my-jwt-token');

        final token = await storage.getToken();

        expect(token, 'my-jwt-token');
      });

      test('getToken returns null when no token is saved', () async {
        final token = await storage.getToken();

        expect(token, isNull);
      });

      test('deleteToken removes the stored token', () async {
        await storage.saveToken('my-jwt-token');
        await storage.deleteToken();

        final token = await storage.getToken();

        expect(token, isNull);
      });

      test('saveToken overwrites previous token', () async {
        await storage.saveToken('first-token');
        await storage.saveToken('second-token');

        final token = await storage.getToken();

        expect(token, 'second-token');
      });
    });

    group('user', () {
      test('saveUser and getUser store and retrieve user JSON', () async {
        final userJson = {
          'id': 'user-1',
          'email': 'test@example.com',
          'display_name': 'Test User',
        };

        await storage.saveUser(userJson);

        final result = await storage.getUser();

        expect(result, isNotNull);
        expect(result!['id'], 'user-1');
        expect(result['email'], 'test@example.com');
        expect(result['display_name'], 'Test User');
      });

      test('getUser returns null when no user is saved', () async {
        final result = await storage.getUser();

        expect(result, isNull);
      });

      test('deleteUser removes the stored user', () async {
        await storage.saveUser({'id': 'user-1'});
        await storage.deleteUser();

        final result = await storage.getUser();

        expect(result, isNull);
      });
    });

    group('dark mode', () {
      test('isDarkMode returns false by default', () async {
        final result = await storage.isDarkMode();

        expect(result, false);
      });

      test('setDarkMode and isDarkMode store and retrieve the value', () async {
        await storage.setDarkMode(true);

        final result = await storage.isDarkMode();

        expect(result, true);
      });

      test('setDarkMode can toggle back to false', () async {
        await storage.setDarkMode(true);
        await storage.setDarkMode(false);

        final result = await storage.isDarkMode();

        expect(result, false);
      });
    });

    group('locale', () {
      test('getLocale returns en by default', () async {
        final result = await storage.getLocale();

        expect(result, 'en');
      });

      test('setLocale and getLocale store and retrieve the value', () async {
        await storage.setLocale('ru');

        final result = await storage.getLocale();

        expect(result, 'ru');
      });
    });

    group('onboarding', () {
      test('needsOnboardingForUser is true for new user id', () async {
        expect(await storage.needsOnboardingForUser('u1'), true);
      });

      test('setOnboardingCompletedForUser clears need for same user', () async {
        await storage.setOnboardingCompletedForUser('u1');
        expect(await storage.needsOnboardingForUser('u1'), false);
      });

      test('different user id needs onboarding again', () async {
        await storage.setOnboardingCompletedForUser('u1');
        expect(await storage.needsOnboardingForUser('u2'), true);
      });

      test('saveOnboardingChoices persists goal and reminder', () async {
        await storage.saveOnboardingChoices(
          goalId: 'health',
          reminderId: 'morning',
        );
        expect(await storage.getOnboardingGoal(), 'health');
        expect(await storage.getOnboardingReminder(), 'morning');
      });
    });

    group('clearAll', () {
      test('removes all stored data', () async {
        await storage.saveToken('token');
        await storage.saveUser({'id': 'user-1'});
        await storage.setDarkMode(true);
        await storage.setLocale('ru');

        await storage.clearAll();

        expect(await storage.getToken(), isNull);
        expect(await storage.getUser(), isNull);
        expect(await storage.isDarkMode(), false);
        expect(await storage.getLocale(), 'en');
      });
    });
  });
}
