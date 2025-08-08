import 'package:calories/core/domain/models/food_entry.dart';
import 'package:calories/core/domain/models/goal.dart';
import 'package:calories/core/domain/models/user_profile.dart';
import 'package:calories/core/domain/models/enums.dart';
import 'package:calories/core/domain/services/goal_service.dart';
import 'package:calories/core/domain/services/log_service.dart';
import 'package:calories/core/domain/services/profile_service.dart';
import 'package:calories/core/storage/hive_boxes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  setUpAll(() async {
    await Hive.initFlutter();
  });

  test('ProfileService save/load roundtrip', () async {
    final profiles = await Hive.openBox<dynamic>('profiles');
    final boxes = HiveBoxes(
      profiles: profiles,
      goals: await Hive.openBox<dynamic>('goals'),
      foodEntries: await Hive.openBox<dynamic>('food_entries'),
      weights: await Hive.openBox<dynamic>('weights'),
      water: await Hive.openBox<dynamic>('water'),
    );
    final svc = ProfileService(boxes);
    final profile = UserProfile(
      id: 'u1',
      metricUnits: true,
      ageYears: 28,
      sex: Sex.female,
      heightCm: 165,
      weightKg: 62,
      activityLevel: ActivityLevel.light,
    );
    await svc.saveProfile(profile);
    final loaded = svc.getProfile();
    expect(loaded?.sex, profile.sex);
    expect(loaded?.heightCm, profile.heightCm);
  });

  test('LogService add/query/delete by date', () async {
    final boxes = HiveBoxes(
      profiles: await Hive.openBox<dynamic>('profiles'),
      goals: await Hive.openBox<dynamic>('goals'),
      foodEntries: await Hive.openBox<dynamic>('food_entries'),
      weights: await Hive.openBox<dynamic>('weights'),
      water: await Hive.openBox<dynamic>('water'),
    );
    final svc = LogService(boxes);
    final today = DateTime.now();
    final dateStr =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final e1 = FoodEntry(
      id: 'e1',
      date: dateStr,
      dateTime: today,
      mealType: MealType.lunch,
      name: 'Chicken',
      calories: 400,
    );
    final e2 = FoodEntry(
      id: 'e2',
      date: dateStr,
      dateTime: today,
      mealType: MealType.dinner,
      name: 'Rice',
      calories: 300,
    );
    await svc.addEntry(e1);
    await svc.addEntry(e2);
    final entries = svc.getEntriesByDate(dateStr);
    expect(entries.length, 2);
    await svc.deleteEntry('e1');
    final entries2 = svc.getEntriesByDate(dateStr);
    expect(entries2.length, 1);
  });

  test('GoalService save/load roundtrip', () async {
    final boxes = HiveBoxes(
      profiles: await Hive.openBox<dynamic>('profiles'),
      goals: await Hive.openBox<dynamic>('goals'),
      foodEntries: await Hive.openBox<dynamic>('food_entries'),
      weights: await Hive.openBox<dynamic>('weights'),
      water: await Hive.openBox<dynamic>('water'),
    );
    final svc = GoalService(boxes);
    final goal = Goal(
      id: 'g1',
      startDate: DateTime(2025, 1, 1),
      mode: GoalMode.maintain,
      targetCalories: 2200,
    );
    await svc.saveGoal(goal);
    final loaded = svc.getGoal();
    expect(loaded?.targetCalories, 2200);
  });
}
