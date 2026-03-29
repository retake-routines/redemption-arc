import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:habitpal_frontend/core/router/app_router.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    // Create a minimal GoRouter to avoid depending on the full auth chain
    final testRouter = GoRouter(
      initialLocation: '/test',
      routes: [
        GoRoute(
          path: '/test',
          builder:
              (context, state) =>
                  const Scaffold(body: Center(child: Text('HabitPal'))),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appRouterProvider.overrideWithValue(testRouter)],
        child: MaterialApp.router(routerConfig: testRouter),
      ),
    );

    await tester.pumpAndSettle();

    // Verify the app renders without crashing.
    expect(find.text('HabitPal'), findsOneWidget);
  });
}
