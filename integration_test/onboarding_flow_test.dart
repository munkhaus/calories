import 'package:calories/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Onboarding completes and lands on Today', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Expect Onboarding title
    expect(find.text('Onboarding'), findsOneWidget);

    // Walk through wizard with minimal valid inputs
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.enterText(find.bySemanticsLabel('Age (years)'), '30');
    await tester.enterText(find.bySemanticsLabel('Height (cm)'), '180');
    await tester.enterText(find.bySemanticsLabel('Weight (kg)'), '80');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.bySemanticsLabel('Daily pace (kcal/day, e.g., 500)'),
      '500',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    // Expect Today screen list
    expect(find.textContaining('Today:'), findsOneWidget);
  });
}
