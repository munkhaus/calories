import 'dart:io';

import 'package:calories/core/domain/models/enums.dart';
import 'package:calories/core/domain/models/food_entry.dart';
import 'package:calories/core/domain/models/goal.dart';
import 'package:calories/core/domain/services/goal_service.dart';
import 'package:calories/core/domain/services/trends_service.dart';
import 'package:calories/core/storage/hive_boxes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

String _iso(DateTime dt) =>
    '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_trends_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  Future<(TrendsService, GoalService, HiveBoxes)> _setup() async {
    final boxes = HiveBoxes(
      profiles: await Hive.openBox<dynamic>('profiles'),
      goals: await Hive.openBox<dynamic>('goals'),
      foodEntries: await Hive.openBox<dynamic>('food_entries'),
      weights: await Hive.openBox<dynamic>('weights'),
      water: await Hive.openBox<dynamic>('water'),
    );
    await boxes.profiles.clear();
    await boxes.goals.clear();
    await boxes.foodEntries.clear();
    await boxes.weights.clear();
    await boxes.water.clear();
    final goalSvc = GoalService(boxes);
    final trends = TrendsService(boxes, goalSvc);
    return (trends, goalSvc, boxes);
  }

  test('Daily totals aggregates last 7 days with deltas', () async {
    final (trends, goalSvc, boxes) = await _setup();
    await goalSvc.saveGoal(
      // Target 2000 kcal
      Goal(id: 'g', startDate: DateTime(2025, 1, 1), mode: GoalMode.maintain, targetCalories: 2000),
    );
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final dt = now.subtract(Duration(days: i));
      final date = _iso(dt);
      final id = 'e$i';
      await boxes.foodEntries.put(
        id,
        // FoodEntry JSON
        '{"id":"$id","date":"$date","dateTime":"${dt.toIso8601String()}","mealType":"snack","name":"X","calories":${1900 + i * 10},"macros":null,"portion":null,"source":null}',
      );
      final indexKey = 'date_index_$date';
      final ids = (boxes.foodEntries.get(indexKey) as List<dynamic>?) ?? <dynamic>[];
      ids.add(id);
      await boxes.foodEntries.put(indexKey, ids);
    }
    final list = trends.getDailyTotals(days: 7);
    expect(list.length, 7);
    expect(list.last.deltaFromGoal, (1900 + 0 * 10) - 2000);
  });

  test('Adherence percent within tolerance', () async {
    final (trends, goalSvc, boxes) = await _setup();
    await goalSvc.saveGoal(
      Goal(id: 'g', startDate: DateTime(2025, 1, 1), mode: GoalMode.maintain, targetCalories: 2000),
    );
    final now = DateTime.now();
    // 5 in range (within ±10%), 2 out of range
    final calories = <int>[1950, 2000, 2050, 1980, 2100, 1900, 2500];
    for (int i = 0; i < calories.length; i++) {
      final dt = now.subtract(Duration(days: i));
      final date = _iso(dt);
      final id = 'e$i';
      await boxes.foodEntries.put(
        id,
        '{"id":"$id","date":"$date","dateTime":"${dt.toIso8601String()}","mealType":"snack","name":"X","calories":${calories[i]},"macros":null,"portion":null,"source":null}',
      );
      final indexKey = 'date_index_$date';
      final ids = (boxes.foodEntries.get(indexKey) as List<dynamic>?) ?? <dynamic>[];
      ids.add(id);
      await boxes.foodEntries.put(indexKey, ids);
    }
    final p = trends.getAdherencePercent(days: 7);
    expect(p, greaterThanOrEqualTo(60));
  });
}


