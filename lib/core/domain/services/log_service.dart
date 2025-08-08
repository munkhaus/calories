import 'dart:convert';

import 'package:calories/core/domain/models/food_entry.dart';
import 'package:calories/core/storage/hive_boxes.dart';
import 'package:calories/log/domain/quick_item.dart';
import 'package:calories/log/domain/i_log_service.dart';

class LogService implements ILogService {
  LogService(this._boxes);

  final HiveBoxes _boxes;

  static const String _recentsKey = 'recents';
  static const String _favoritesKey = 'favorites';

  @override
  Future<void> addEntry(FoodEntry entry) async {
    await _boxes.foodEntries.put(entry.id, jsonEncode(entry.toJson()));
    final String indexKey = 'date_index_${entry.date}';
    final List<dynamic> current =
        (_boxes.foodEntries.get(indexKey) as List<dynamic>?) ?? <dynamic>[];
    if (!current.contains(entry.id)) {
      current.add(entry.id);
      await _boxes.foodEntries.put(indexKey, current);
    }

    // Update recents (simple LRU by name)
    final List<dynamic> recentsRaw =
        (_boxes.foodEntries.get(_recentsKey) as List<dynamic>?) ?? <dynamic>[];
    recentsRaw.removeWhere((e) => (e as Map)['name'] == entry.name);
    recentsRaw.insert(0, {'name': entry.name, 'calories': entry.calories});
    while (recentsRaw.length > 10) recentsRaw.removeLast();
    await _boxes.foodEntries.put(_recentsKey, recentsRaw);
  }

  @override
  List<FoodEntry> getEntriesByDate(String yyyyMmDd) {
    final String indexKey = 'date_index_$yyyyMmDd';
    final List<dynamic> ids =
        (_boxes.foodEntries.get(indexKey) as List<dynamic>?) ?? <dynamic>[];
    return ids
        .map((dynamic id) => _boxes.foodEntries.get(id))
        .whereType<String>()
        .map(
          (String raw) =>
              FoodEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> deleteEntry(String id) async {
    // Remove from entries and all date indices containing it
    final dynamic raw = _boxes.foodEntries.get(id);
    if (raw is String) {
      final FoodEntry entry = FoodEntry.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      final String indexKey = 'date_index_${entry.date}';
      final List<dynamic> ids =
          (_boxes.foodEntries.get(indexKey) as List<dynamic>?) ?? <dynamic>[];
      ids.remove(id);
      await _boxes.foodEntries.put(indexKey, ids);
    }
    await _boxes.foodEntries.delete(id);
  }

  List<QuickItem> getRecents() {
    final List<dynamic> recentsRaw =
        (_boxes.foodEntries.get(_recentsKey) as List<dynamic>?) ?? <dynamic>[];
    return recentsRaw
        .whereType<Map>()
        .map(
          (m) => QuickItem(
            name: (m['name'] as String?) ?? 'Item',
            calories: (m['calories'] as int?) ?? 0,
          ),
        )
        .toList();
  }

  List<QuickItem> getFavorites() {
    final List<dynamic> favsRaw =
        (_boxes.foodEntries.get(_favoritesKey) as List<dynamic>?) ??
        <dynamic>[];
    return favsRaw
        .whereType<Map>()
        .map(
          (m) => QuickItem(
            name: (m['name'] as String?) ?? 'Item',
            calories: (m['calories'] as int?) ?? 0,
            pinned: true,
          ),
        )
        .toList();
  }

  Future<void> toggleFavorite(QuickItem item) async {
    final List<dynamic> favsRaw =
        (_boxes.foodEntries.get(_favoritesKey) as List<dynamic>?) ??
        <dynamic>[];
    final int idx = favsRaw.indexWhere((e) => (e as Map)['name'] == item.name);
    if (idx >= 0) {
      favsRaw.removeAt(idx);
    } else {
      favsRaw.insert(0, {'name': item.name, 'calories': item.calories});
    }
    await _boxes.foodEntries.put(_favoritesKey, favsRaw);
  }
}
