import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitpal_frontend/features/auth/domain/auth_provider.dart';
import 'package:habitpal_frontend/features/auth/presentation/login_screen.dart';
import 'package:habitpal_frontend/features/auth/presentation/register_screen.dart';
import 'package:habitpal_frontend/features/habits/presentation/habit_detail_screen.dart';
import 'package:habitpal_frontend/features/habits/presentation/habits_screen.dart';
import 'package:habitpal_frontend/features/profile/presentation/profile_screen.dart';
import 'package:habitpal_frontend/features/statistics/presentation/statistics_screen.dart';

/// A [ChangeNotifier] that listens to auth state changes and triggers
/// GoRouter's redirect evaluation.
class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier(Ref ref) {
    ref.listen<AuthState>(authStateProvider, (_, __) {
      notifyListeners();
    });
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authChangeNotifier = AuthChangeNotifier(ref);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authChangeNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authStateProvider);
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isOnLogin = state.matchedLocation == '/login';
      final isOnRegister = state.matchedLocation == '/register';
      final isOnAuthPage = isOnLogin || isOnRegister;

      // Not authenticated and trying to access a protected route
      if (!isAuthenticated && !isOnAuthPage) {
        return '/login';
      }

      // Authenticated but on an auth page — redirect to habits
      if (isAuthenticated && isOnAuthPage) {
        return '/habits';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/habits',
        name: 'habits',
        builder: (context, state) => const HabitsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'habit-detail',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return HabitDetailScreen(habitId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/statistics',
        name: 'statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
