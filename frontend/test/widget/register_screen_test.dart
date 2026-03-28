import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitpal_frontend/features/auth/data/auth_repository.dart';
import 'package:habitpal_frontend/features/auth/domain/auth_provider.dart';
import 'package:habitpal_frontend/features/auth/presentation/register_screen.dart';

void main() {
  Widget createTestWidget({List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: [
        authStateProvider.overrideWith(
          (ref) => AuthNotifier(_FakeAuthRepository()),
        ),
        ...overrides,
      ],
      child: const MaterialApp(
        home: RegisterScreen(),
      ),
    );
  }

  group('RegisterScreen', () {
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

    testWidgets('renders confirm password field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        findsOneWidget,
      );
    });

    testWidgets('renders register button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilledButton, 'Register'), findsOneWidget);
    });

    testWidgets('renders login navigation link', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(TextButton, 'Already have an account? Login'),
        findsOneWidget,
      );
    });

    testWidgets('shows error on password mismatch', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'different',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Register'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('shows error when email is empty on submit', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Register'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows error when password is too short', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        '12345',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        '12345',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Register'));
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
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

    testWidgets('renders Create Account title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
    });
  });
}

class _LoadingAuthNotifier extends AuthNotifier {
  _LoadingAuthNotifier() : super(_FakeAuthRepository()) {
    state = const AuthState(status: AuthStatus.loading);
  }
}

/// Minimal fake to satisfy the AuthNotifier constructor.
class _FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
