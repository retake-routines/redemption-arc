import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitpal_frontend/core/l10n/app_localizations.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';
import 'package:habitpal_frontend/features/habits/presentation/widgets/streak_counter.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('StreakCounter', () {
    testWidgets('renders current streak value', (tester) async {
      const streak = StreakModel(currentStreak: 5, longestStreak: 10);

      await tester.pumpWidget(_wrap(const StreakCounter(streak: streak)));
      await tester.pumpAndSettle();

      expect(find.text('5 days'), findsOneWidget);
    });

    testWidgets('renders longest streak value', (tester) async {
      const streak = StreakModel(currentStreak: 5, longestStreak: 10);

      await tester.pumpWidget(_wrap(const StreakCounter(streak: streak)));
      await tester.pumpAndSettle();

      expect(find.text('10 days'), findsOneWidget);
    });

    testWidgets('renders fire icon for current streak', (tester) async {
      const streak = StreakModel(currentStreak: 5, longestStreak: 10);

      await tester.pumpWidget(_wrap(const StreakCounter(streak: streak)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('renders trophy icon for longest streak', (tester) async {
      const streak = StreakModel(currentStreak: 5, longestStreak: 10);

      await tester.pumpWidget(_wrap(const StreakCounter(streak: streak)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets('renders Current Streak label', (tester) async {
      const streak = StreakModel(currentStreak: 0, longestStreak: 0);

      await tester.pumpWidget(_wrap(const StreakCounter(streak: streak)));
      await tester.pumpAndSettle();

      expect(find.text('Current Streak'), findsOneWidget);
    });

    testWidgets('renders Longest Streak label', (tester) async {
      const streak = StreakModel(currentStreak: 0, longestStreak: 0);

      await tester.pumpWidget(_wrap(const StreakCounter(streak: streak)));
      await tester.pumpAndSettle();

      expect(find.text('Longest Streak'), findsOneWidget);
    });

    testWidgets('renders zero streaks correctly', (tester) async {
      const streak = StreakModel(currentStreak: 0, longestStreak: 0);

      await tester.pumpWidget(_wrap(const StreakCounter(streak: streak)));
      await tester.pumpAndSettle();

      expect(find.text('0 days'), findsNWidgets(2));
    });

    testWidgets('renders singular day for value of 1', (tester) async {
      const streak = StreakModel(currentStreak: 1, longestStreak: 1);

      await tester.pumpWidget(_wrap(const StreakCounter(streak: streak)));
      await tester.pumpAndSettle();

      expect(find.text('1 day'), findsNWidgets(2));
    });
  });
}
