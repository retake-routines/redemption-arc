import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitpal_frontend/core/network/api_client.dart';
import 'package:habitpal_frontend/features/auth/data/auth_repository.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final UserModel? user;
  final String? token;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.user,
    this.token,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    UserModel? user,
    String? token,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      user: user ?? this.user,
      token: token ?? this.token,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final authResponse = await _repository.login(
        email: email,
        password: password,
      );
      state = AuthState(
        status: AuthStatus.authenticated,
        user: authResponse.user,
        token: authResponse.token,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String displayName = '',
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final authResponse = await _repository.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = AuthState(
        status: AuthStatus.authenticated,
        user: authResponse.user,
        token: authResponse.token,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Checks local storage for an existing token and restores auth state.
  Future<void> checkAuthStatus() async {
    final isAuthed = await _repository.isAuthenticated();
    if (isAuthed) {
      final user = await _repository.getCachedUser();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }
}

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.read(authRepositoryProvider);
  final notifier = AuthNotifier(repository);

  // Defer setting the 401 callback to avoid modifying another provider
  // during initialization (Riverpod disallows this).
  Future.microtask(() {
    ref.read(onUnauthorizedProvider.notifier).state = notifier.logout;
  });

  return notifier;
});

/// Derived provider for quick boolean check of authentication status.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).status == AuthStatus.authenticated;
});
