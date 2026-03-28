import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitpal_frontend/shared/widgets/empty_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('renders icon and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              message: 'No items yet',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('No items yet'), findsOneWidget);
    });

    testWidgets('renders action button when actionLabel and onAction provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              message: 'No items yet',
              actionLabel: 'Add Item',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.text('Add Item'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('does not render action button when actionLabel is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              message: 'No items yet',
            ),
          ),
        ),
      );

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('action callback fires on button tap', (tester) async {
      var actionFired = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              message: 'No items yet',
              actionLabel: 'Add Item',
              onAction: () => actionFired = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FilledButton));
      expect(actionFired, true);
    });

    testWidgets('does not render action button when onAction is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              message: 'No items yet',
              actionLabel: 'Add Item',
            ),
          ),
        ),
      );

      expect(find.byType(FilledButton), findsNothing);
    });
  });
}
