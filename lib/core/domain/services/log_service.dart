import 'dart:convert';

import 'package:calories/core/domain/models/food_entry.dart';
import 'package:calories/core/storage/hive_boxes.dart';
import 'package:calories/log/domain/i_log_service.dart';

class LogService implements ILogService {
  LogService(this._boxes);

  final HiveBoxes _boxes;

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
}
