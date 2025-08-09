import 'package:calories/core/di/service_locator.dart';
import 'package:calories/core/domain/models/goal.dart';
import 'package:calories/goals/domain/i_goal_service.dart';
import 'package:calories/goals/presentation/goals_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Goals editor saves target', (tester) async {
    final _FakeGoals fake = _FakeGoals();
    if (getIt.isRegistered<IGoalService>()) {
      getIt.unregister<IGoalService>();
    }
    getIt.registerSingleton<IGoalService>(fake);

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: GoalsPage())));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '2100');
    await tester.tap(find.text('Save'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(fake.saved?.targetCalories, 2100);
  });
}

class _FakeGoals implements IGoalService {
  Goal? saved;

  @override
  Goal? getGoal() => saved;

  @override
  Future<void> saveGoal(Goal goal) async {
    saved = goal;
  }
}


