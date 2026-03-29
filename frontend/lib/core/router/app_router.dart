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

      // Still checking stored token — don't redirect yet
      if (authState.status == AuthStatus.initial) {
        return null;
      }

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
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const LoginScreen(),
              transitionsBuilder: _fadeTransition,
            ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const RegisterScreen(),
              transitionsBuilder: _fadeTransition,
            ),
      ),
      GoRoute(
        path: '/habits',
        name: 'habits',
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HabitsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
        routes: [
          GoRoute(
            path: ':id',
            name: 'habit-detail',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return CustomTransitionPage(
                key: state.pageKey,
                child: HabitDetailScreen(habitId: id),
                transitionsBuilder: _slideTransition,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/statistics',
        name: 'statistics',
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const StatisticsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
              transitionsBuilder: _fadeTransition,
            ),
      ),
    ],
  );
});

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}

Widget _slideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final offsetAnimation = Tween<Offset>(
    begin: const Offset(1, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
  return SlideTransition(position: offsetAnimation, child: child);
}
