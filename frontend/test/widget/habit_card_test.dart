import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';
import 'package:habitpal_frontend/features/habits/presentation/widgets/habit_card.dart';

void main() {
  Widget createTestWidget({
    required HabitModel habit,
    VoidCallback? onTap,
    VoidCallback? onComplete,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: HabitCard(
          habit: habit,
          onTap: onTap,
          onComplete: onComplete,
        ),
      ),
    );
  }

  group('HabitCard', () {
    testWidgets('renders habit name', (tester) async {
      final habit = HabitModel(
        id: 'h1',
        name: 'Morning Run',
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createTestWidget(habit: habit));
      await tester.pumpAndSettle();

      expect(find.text('Morning Run'), findsOneWidget);
    });

    testWidgets('renders habit description when not empty', (tester) async {
      final habit = HabitModel(
        id: 'h1',
        name: 'Morning Run',
        description: 'Run for 30 minutes',
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createTestWidget(habit: habit));
      await tester.pumpAndSettle();

      expect(find.text('Run for 30 minutes'), findsOneWidget);
    });

    testWidgets('does not render description when empty', (tester) async {
      final habit = HabitModel(
        id: 'h1',
        name: 'Morning Run',
        description: '',
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createTestWidget(habit: habit));
      await tester.pumpAndSettle();

      // Only the name should be present, no extra Text widgets for description
      expect(find.text('Morning Run'), findsOneWidget);
    });

    testWidgets('renders streak counter when streak is greater than zero',
        (tester) async {
      final habit = HabitModel(
        id: 'h1',
        name: 'Morning Run',
        createdAt: DateTime(2024, 1, 1),
        streak: const StreakModel(currentStreak: 5),
      );

      await tester.pumpWidget(createTestWidget(habit: habit));
      await tester.pumpAndSettle();

      expect(find.text('5'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('does not render streak when streak is zero', (tester) async {
      final habit = HabitModel(
        id: 'h1',
        name: 'Morning Run',
        createdAt: DateTime(2024, 1, 1),
        streak: const StreakModel(currentStreak: 0),
      );

      await tester.pumpWidget(createTestWidget(habit: habit));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.local_fire_department), findsNothing);
    });

    testWidgets('onTap callback fires when card is tapped', (tester) async {
      var tapped = false;
      final habit = HabitModel(
        id: 'h1',
        name: 'Morning Run',
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(
        createTestWidget(
          habit: habit,
          onTap: () => tapped = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell).first);
      expect(tapped, true);
    });

    testWidgets('onComplete callback fires when complete button is tapped',
        (tester) async {
      var completed = false;
      final habit = HabitModel(
        id: 'h1',
        name: 'Morning Run',
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(
        createTestWidget(
          habit: habit,
          onComplete: () => completed = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.check_circle_outline));
      expect(completed, true);
    });

    testWidgets('renders chevron icon', (tester) async {
      final habit = HabitModel(
        id: 'h1',
        name: 'Morning Run',
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createTestWidget(habit: habit));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });
}
