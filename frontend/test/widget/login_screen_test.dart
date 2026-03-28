import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitpal_frontend/features/auth/data/auth_repository.dart';
import 'package:habitpal_frontend/features/auth/domain/auth_provider.dart';
import 'package:habitpal_frontend/features/auth/presentation/login_screen.dart';

void main() {
  Widget createTestWidget({List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: [
        // Override auth provider to avoid Riverpod initialization conflict
        // where AuthNotifier modifies onUnauthorizedProvider during build
        authStateProvider.overrideWith(
          (ref) => AuthNotifier(_FakeAuthRepository()),
        ),
        ...overrides,
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders email field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    });

    testWidgets('renders password field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    });

    testWidgets('renders login button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
    });

    testWidgets('renders register navigation link', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(TextButton, "Don't have an account? Register"),
        findsOneWidget,
      );
    });

    testWidgets('shows validation error when email is empty on submit',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows validation error when password is empty on submit',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Fill in email but not password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('shows loading indicator when auth status is loading',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => _LoadingAuthNotifier(),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when auth status is error',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => _ErrorAuthNotifier('Invalid credentials'),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('login button is disabled during loading', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => _LoadingAuthNotifier(),
            ),
          ],
        ),
      );
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('renders HabitPal title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('HabitPal'), findsOneWidget);
    });
  });
}

class _LoadingAuthNotifier extends AuthNotifier {
  _LoadingAuthNotifier() : super(_FakeAuthRepository()) {
    state = const AuthState(status: AuthStatus.loading);
  }
}

class _ErrorAuthNotifier extends AuthNotifier {
  _ErrorAuthNotifier(String message) : super(_FakeAuthRepository()) {
    state = AuthState(
      status: AuthStatus.error,
      errorMessage: message,
    );
  }
}

/// Minimal fake to satisfy the AuthNotifier constructor.
class _FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
