import 'package:flutter_test/flutter_test.dart';
import 'package:habitpal_frontend/features/auth/data/auth_repository.dart';
import 'package:habitpal_frontend/features/auth/domain/auth_provider.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late AuthNotifier notifier;

  setUp(() {
    mockRepository = MockAuthRepository();
    notifier = AuthNotifier(mockRepository);
  });

  group('AuthNotifier', () {
    group('initial state', () {
      test('has initial status', () {
        expect(notifier.state.status, AuthStatus.initial);
      });

      test('has no error message', () {
        expect(notifier.state.errorMessage, isNull);
      });

      test('has no user', () {
        expect(notifier.state.user, isNull);
      });

      test('has no token', () {
        expect(notifier.state.token, isNull);
      });
    });

    group('login', () {
      final testUser = UserModel(
        id: 'user-1',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final testAuthResponse = AuthResponse(
        token: 'jwt-token-123',
        user: testUser,
      );

      test('sets authenticated state on success', () async {
        when(() => mockRepository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => testAuthResponse);

        await notifier.login(email: 'test@example.com', password: 'password');

        expect(notifier.state.status, AuthStatus.authenticated);
        expect(notifier.state.user?.email, 'test@example.com');
        expect(notifier.state.token, 'jwt-token-123');
        expect(notifier.state.errorMessage, isNull);
      });

      test('sets error state on failure', () async {
        when(() => mockRepository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Invalid credentials'));

        await notifier.login(email: 'test@example.com', password: 'wrong');

        expect(notifier.state.status, AuthStatus.error);
        expect(notifier.state.errorMessage, isNotNull);
        expect(notifier.state.user, isNull);
      });

      test('transitions through loading state', () async {
        final states = <AuthStatus>[];
        notifier.addListener((state) {
          states.add(state.status);
        });

        when(() => mockRepository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => testAuthResponse);

        await notifier.login(email: 'test@example.com', password: 'password');

        expect(states, contains(AuthStatus.loading));
        expect(states.last, AuthStatus.authenticated);
      });
    });

    group('register', () {
      final testUser = UserModel(
        id: 'user-2',
        email: 'new@example.com',
        displayName: 'New User',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final testAuthResponse = AuthResponse(
        token: 'jwt-token-456',
        user: testUser,
      );

      test('sets authenticated state on success', () async {
        when(() => mockRepository.register(
              email: any(named: 'email'),
              password: any(named: 'password'),
              displayName: any(named: 'displayName'),
            )).thenAnswer((_) async => testAuthResponse);

        await notifier.register(
          email: 'new@example.com',
          password: 'password',
          displayName: 'New User',
        );

        expect(notifier.state.status, AuthStatus.authenticated);
        expect(notifier.state.user?.email, 'new@example.com');
        expect(notifier.state.token, 'jwt-token-456');
      });

      test('sets error state on failure', () async {
        when(() => mockRepository.register(
              email: any(named: 'email'),
              password: any(named: 'password'),
              displayName: any(named: 'displayName'),
            )).thenThrow(Exception('Email already exists'));

        await notifier.register(
          email: 'existing@example.com',
          password: 'password',
        );

        expect(notifier.state.status, AuthStatus.error);
        expect(notifier.state.errorMessage, isNotNull);
      });
    });

    group('logout', () {
      test('sets unauthenticated state and clears user and token', () async {
        when(() => mockRepository.logout()).thenAnswer((_) async {});

        // First login
        final testUser = UserModel(
          id: 'user-1',
          email: 'test@example.com',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );
        when(() => mockRepository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => AuthResponse(
              token: 'token',
              user: testUser,
            ));

        await notifier.login(email: 'test@example.com', password: 'password');
        expect(notifier.state.status, AuthStatus.authenticated);

        // Then logout
        await notifier.logout();

        expect(notifier.state.status, AuthStatus.unauthenticated);
        expect(notifier.state.user, isNull);
        expect(notifier.state.token, isNull);
      });

      test('calls repository.logout', () async {
        when(() => mockRepository.logout()).thenAnswer((_) async {});

        await notifier.logout();

        verify(() => mockRepository.logout()).called(1);
      });
    });
  });
}
