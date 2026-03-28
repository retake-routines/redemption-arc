import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:habitpal_frontend/app.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: HabitPalApp()),
    );

    // Verify the app renders without errors.
    expect(find.text('HabitPal'), findsOneWidget);
  });
}
