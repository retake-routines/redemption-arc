import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitpal_frontend/core/network/api_endpoints.dart';
import 'package:habitpal_frontend/core/storage/local_storage.dart';
import 'package:habitpal_frontend/features/auth/data/auth_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late LocalStorage storage;
  late AuthRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockDio = MockDio();
    storage = LocalStorage();
    repository = AuthRepository(dio: mockDio, storage: storage);
  });

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  group('AuthRepository', () {
    group('login', () {
      test('calls POST /auth/login with correct body', () async {
        when(
          () => mockDio.post(
            ApiEndpoints.login,
            data: {'email': 'test@example.com', 'password': 'password123'},
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ApiEndpoints.login),
            statusCode: 200,
            data: {
              'token': 'jwt-token-123',
              'user': {
                'id': 'user-1',
                'email': 'test@example.com',
                'display_name': 'Test User',
                'created_at': '2024-01-01T00:00:00.000Z',
                'updated_at': '2024-01-01T00:00:00.000Z',
              },
            },
          ),
        );

        await repository.login(
          email: 'test@example.com',
          password: 'password123',
        );

        verify(
          () => mockDio.post(
            ApiEndpoints.login,
            data: {'email': 'test@example.com', 'password': 'password123'},
          ),
        ).called(1);
      });

      test('parses AuthResponse correctly', () async {
        when(
          () => mockDio.post(ApiEndpoints.login, data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ApiEndpoints.login),
            statusCode: 200,
            data: {
              'token': 'jwt-token-123',
              'user': {
                'id': 'user-1',
                'email': 'test@example.com',
                'display_name': 'Test User',
                'created_at': '2024-01-01T00:00:00.000Z',
                'updated_at': '2024-01-01T00:00:00.000Z',
              },
            },
          ),
        );

        final result = await repository.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result.token, 'jwt-token-123');
        expect(result.user.id, 'user-1');
        expect(result.user.email, 'test@example.com');
        expect(result.user.displayName, 'Test User');
      });

      test('persists token and user to storage on success', () async {
        when(
          () => mockDio.post(ApiEndpoints.login, data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ApiEndpoints.login),
            statusCode: 200,
            data: {
              'token': 'jwt-token-123',
              'user': {
                'id': 'user-1',
                'email': 'test@example.com',
                'display_name': 'Test User',
                'created_at': '2024-01-01T00:00:00.000Z',
                'updated_at': '2024-01-01T00:00:00.000Z',
              },
            },
          ),
        );

        await repository.login(
          email: 'test@example.com',
          password: 'password123',
        );

        final savedToken = await storage.getToken();
        final savedUser = await storage.getUser();

        expect(savedToken, 'jwt-token-123');
        expect(savedUser, isNotNull);
        expect(savedUser!['email'], 'test@example.com');
      });

      test('throws on DioException with server error message', () async {
        when(
          () => mockDio.post(ApiEndpoints.login, data: any(named: 'data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ApiEndpoints.login),
            response: Response(
              requestOptions: RequestOptions(path: ApiEndpoints.login),
              statusCode: 401,
              data: {'error': 'Invalid credentials'},
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        expect(
          () => repository.login(email: 'test@example.com', password: 'wrong'),
          throwsA(isA<String>()),
        );
      });
    });

    group('register', () {
      test('calls POST /auth/register with correct body', () async {
        when(
          () => mockDio.post(
            ApiEndpoints.register,
            data: {
              'email': 'new@example.com',
              'password': 'password123',
              'display_name': 'New User',
            },
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ApiEndpoints.register),
            statusCode: 201,
            data: {
              'token': 'jwt-token-456',
              'user': {
                'id': 'user-2',
                'email': 'new@example.com',
                'display_name': 'New User',
                'created_at': '2024-01-01T00:00:00.000Z',
                'updated_at': '2024-01-01T00:00:00.000Z',
              },
            },
          ),
        );

        await repository.register(
          email: 'new@example.com',
          password: 'password123',
          displayName: 'New User',
        );

        verify(
          () => mockDio.post(
            ApiEndpoints.register,
            data: {
              'email': 'new@example.com',
              'password': 'password123',
              'display_name': 'New User',
            },
          ),
        ).called(1);
      });

      test('parses AuthResponse correctly', () async {
        when(
          () => mockDio.post(ApiEndpoints.register, data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ApiEndpoints.register),
            statusCode: 201,
            data: {
              'token': 'jwt-token-456',
              'user': {
                'id': 'user-2',
                'email': 'new@example.com',
                'display_name': 'New User',
                'created_at': '2024-01-01T00:00:00.000Z',
                'updated_at': '2024-01-01T00:00:00.000Z',
              },
            },
          ),
        );

        final result = await repository.register(
          email: 'new@example.com',
          password: 'password123',
          displayName: 'New User',
        );

        expect(result.token, 'jwt-token-456');
        expect(result.user.email, 'new@example.com');
      });
    });

    group('logout', () {
      test('clears token and user from storage', () async {
        // First save some data
        await storage.saveToken('some-token');
        await storage.saveUser({'id': 'user-1'});

        await repository.logout();

        expect(await storage.getToken(), isNull);
        expect(await storage.getUser(), isNull);
      });
    });

    group('isAuthenticated', () {
      test('returns true when token is present', () async {
        await storage.saveToken('some-token');

        final result = await repository.isAuthenticated();

        expect(result, true);
      });

      test('returns false when no token is present', () async {
        final result = await repository.isAuthenticated();

        expect(result, false);
      });
    });

    group('getCachedUser', () {
      test('returns UserModel when user data is stored', () async {
        await storage.saveUser({
          'id': 'user-1',
          'email': 'test@example.com',
          'display_name': 'Test User',
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
        });

        final user = await repository.getCachedUser();

        expect(user, isNotNull);
        expect(user!.id, 'user-1');
        expect(user.email, 'test@example.com');
      });

      test('returns null when no user data is stored', () async {
        final user = await repository.getCachedUser();

        expect(user, isNull);
      });
    });
  });
}
