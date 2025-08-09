// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:calories/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calories/core/di/service_locator.dart';
import 'package:calories/goals/domain/i_goal_service.dart';
import 'package:calories/log/domain/i_log_service.dart';
import 'package:calories/core/domain/models/food_entry.dart';
import 'package:calories/log/domain/quick_item.dart';

class _FakeGoalService implements IGoalService {
  @override
  Future<void> saveGoal(goal) async {}
  @override
  getGoal() => null;
}

class _FakeLogService implements ILogService {
  @override
  Future<void> addEntry(FoodEntry entry) async {}
  @override
  List<FoodEntry> getEntriesByDate(String _) => <FoodEntry>[];
  @override
  Future<void> deleteEntry(String id) async {}
  @override
  FoodEntry? getEntryById(String id) => null;
  @override
  List<QuickItem> getRecents() => <QuickItem>[];
  @override
  List<QuickItem> getFavorites() => <QuickItem>[];
  @override
  Future<void> toggleFavorite(QuickItem item) async {}
}

void main() {
  testWidgets('App renders and shows Today tab', (WidgetTester tester) async {
    if (!getIt.isRegistered<IGoalService>()) {
      getIt.registerSingleton<IGoalService>(_FakeGoalService());
    }
    if (!getIt.isRegistered<ILogService>()) {
      getIt.registerSingleton<ILogService>(_FakeLogService());
    }

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
