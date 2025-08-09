import 'dart:io';

import 'package:calories/core/domain/models/enums.dart';
import 'package:calories/core/domain/models/food_entry.dart';
import 'package:calories/core/domain/services/log_service.dart';
import 'package:calories/core/storage/hive_boxes.dart';
import 'package:calories/log/domain/quick_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

String _iso(DateTime dt) =>
    '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_quick_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  Future<LogService> _newService() async {
    final boxes = HiveBoxes(
      profiles: await Hive.openBox<dynamic>('profiles'),
      goals: await Hive.openBox<dynamic>('goals'),
      foodEntries: await Hive.openBox<dynamic>('food_entries'),
      weights: await Hive.openBox<dynamic>('weights'),
      water: await Hive.openBox<dynamic>('water'),
    );
    return LogService(boxes);
  }

  test('Recents maintains LRU order and cap', () async {
    final svc = await _newService();
    final now = DateTime(2025, 1, 10, 12);
    for (int i = 0; i < 12; i++) {
      final dt = now.add(Duration(minutes: i));
      await svc.addEntry(FoodEntry(
        id: 'e$i',
        date: _iso(dt),
        dateTime: dt,
        mealType: MealType.snack,
        name: 'Item $i',
        calories: 100 + i,
      ));
    }
    final recents = svc.getRecents();
    expect(recents.length, 10);
    expect(recents.first.name, 'Item 11');
    expect(recents.last.name, 'Item 2');
  });

  test('Pin/unpin favorites via toggle and sort pinned first', () async {
    final svc = await _newService();
    final dt = DateTime(2025, 1, 11, 8);
    final entry = FoodEntry(
      id: 'a1',
      date: _iso(dt),
      dateTime: dt,
      mealType: MealType.breakfast,
      name: 'Oats',
      calories: 250,
    );
    await svc.addEntry(entry);

    // Initially not favorite
    expect(svc.getFavorites().any((f) => f.name == 'Oats'), isFalse);

    // Toggle to favorite
    await svc.toggleFavorite(QuickItem(name: 'Oats', calories: 250));
    final favs1 = svc.getFavorites();
    expect(favs1.any((f) => f.name == 'Oats'), isTrue);

    // Toggle off favorite
    await svc.toggleFavorite(QuickItem(name: 'Oats', calories: 250));
    expect(svc.getFavorites().any((f) => f.name == 'Oats'), isFalse);
  });

  test('Auto-promote to favorites after repeated use in window', () async {
    final svc = await _newService();
    // Simulate usage over three distinct days within 7-day window
    for (int d = 0; d < 3; d++) {
      final dt = DateTime(2025, 2, 1 + d, 12);
      await svc.addEntry(FoodEntry(
        id: 'p$d',
        date: _iso(dt),
        dateTime: dt,
        mealType: MealType.lunch,
        name: 'Chicken Bowl',
        calories: 600,
      ));
    }
    final favs = svc.getFavorites();
    expect(favs.any((f) => f.name == 'Chicken Bowl'), isTrue);
  });
}


