import 'package:calories/core/di/service_locator.dart';
import 'package:calories/core/domain/models/food_entry.dart';
import 'package:calories/goals/domain/i_goal_service.dart';
import 'package:calories/log/domain/i_log_service.dart';
import 'package:calories/today/presentation/today_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_utils.dart';

class _FakeGoalService implements IGoalService {
  @override
  Future<void> saveGoal(goal) async {}

  @override
  getGoal() => null;
}

class _FakeLogService implements ILogService {
  final List<FoodEntry> entries;
  _FakeLogService(this.entries);

  @override
  Future<void> addEntry(FoodEntry entry) async {}

  @override
  Future<void> deleteEntry(String id) async {}

  @override
  List<FoodEntry> getEntriesByDate(String yyyyMmDd) => entries;
}

void main() {
  testWidgets('Today renders totals and list', (tester) async {
    await registerTestLocalStorage(onboardingCompleted: true);
    getIt.registerSingleton<IGoalService>(_FakeGoalService());
    getIt.registerSingleton<ILogService>(
      _FakeLogService([
        FoodEntry(
          id: '1',
          date: '2024-01-01',
          dateTime: DateTime(2024, 1, 1, 8),
          mealType: MealType.breakfast,
          name: 'Oats',
          calories: 300,
        ),
      ]),
    );

    await tester.pumpWidget(wrapWithMaterialApp(const TodayPage()));
    await tester.pump();

    expect(find.textContaining('Total kcal'), findsOneWidget);
    expect(find.text('Oats'), findsOneWidget);
  });
}
