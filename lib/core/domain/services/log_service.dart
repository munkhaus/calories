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
  static const int _recentsLimit = 10;
  static const int _promotionThreshold = 3; // uses in window to auto-fav
  static const int _promotionWindowDays = 7;

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

    // Update recents (LRU with usage window for promotion)
    final DateTime usedAt = entry.dateTime;
    final List<dynamic> recentsRaw =
        (_boxes.foodEntries.get(_recentsKey) as List<dynamic>?) ?? <dynamic>[];
    // Normalize maps
    final List<Map<String, dynamic>> recents = recentsRaw
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m as Map))
        .toList();

    final int rIdx =
        recents.indexWhere((m) => (m['name'] as String?) == entry.name);
    if (rIdx >= 0) {
      final Map<String, dynamic> existing = recents[rIdx];
      final List<dynamic> usedDatesRaw =
          (existing['usedDates'] as List<dynamic>?) ?? <dynamic>[];
      final List<String> usedDates = usedDatesRaw.whereType<String>().toList();
      final String today = entry.date; // yyyy-mm-dd
      usedDates.add(today);
      // keep only last window and unique days
      final DateTime windowStart =
          usedAt.subtract(Duration(days: _promotionWindowDays - 1));
      final Set<String> uniqueDates = usedDates
          .where((d) => DateTime.parse('${d}T00:00:00')
              .isAfter(windowStart.subtract(const Duration(seconds: 1))))
          .toSet();
      existing['usedDates'] = uniqueDates.toList();
      existing['lastUsedAt'] = usedAt.toIso8601String();
      existing['calories'] = entry.calories;
      recents
        ..removeAt(rIdx)
        ..insert(0, existing);
    } else {
      recents.insert(0, <String, dynamic>{
        'name': entry.name,
        'calories': entry.calories,
        'lastUsedAt': usedAt.toIso8601String(),
        'usedDates': <String>[entry.date],
      });
    }
    while (recents.length > _recentsLimit) {
      recents.removeLast();
    }
    await _boxes.foodEntries.put(_recentsKey, recents);

    // Auto-promotion to favorites if used enough in window
    final List<QuickItem> favs = getFavorites();
    final bool alreadyFav = favs.any((f) => f.name == entry.name);
    if (!alreadyFav) {
      final Map<String, dynamic>? r =
          recents.firstWhere((m) => m['name'] == entry.name, orElse: () => {});
      final int recentCount =
          ((r?['usedDates'] as List<dynamic>?) ?? <dynamic>[]).length;
      if (recentCount >= _promotionThreshold) {
        final List<dynamic> favsRaw =
            (_boxes.foodEntries.get(_favoritesKey) as List<dynamic>?) ??
            <dynamic>[];
        favsRaw.insert(0, <String, dynamic>{
          'name': entry.name,
          'calories': entry.calories,
          'pinned': true,
          'timesUsed': 1,
          'lastUsedAt': usedAt.toIso8601String(),
        });
        await _boxes.foodEntries.put(_favoritesKey, favsRaw);
      }
    } else {
      // Update usage metrics for existing favorite
      final List<dynamic> favsRaw =
          (_boxes.foodEntries.get(_favoritesKey) as List<dynamic>?) ??
          <dynamic>[];
      final int fIdx = favsRaw.indexWhere(
        (e) => (e as Map)['name'] == entry.name,
      );
      if (fIdx >= 0) {
        final Map f = Map<String, dynamic>.from(favsRaw[fIdx] as Map);
        final int timesUsed = (f['timesUsed'] as int? ?? 0) + 1;
        f['timesUsed'] = timesUsed;
        f['lastUsedAt'] = usedAt.toIso8601String();
        f['calories'] = entry.calories;
        favsRaw
          ..removeAt(fIdx)
          ..insert(0, f);
        await _boxes.foodEntries.put(_favoritesKey, favsRaw);
      }
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

  @override
  List<QuickItem> getRecents() {
    final List<dynamic> recentsRaw =
        (_boxes.foodEntries.get(_recentsKey) as List<dynamic>?) ?? <dynamic>[];
    final List<Map<String, dynamic>> recents = recentsRaw
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m as Map))
        .toList();
    recents.sort((a, b) =>
        (b['lastUsedAt'] as String? ?? '').compareTo(a['lastUsedAt'] as String? ?? ''));
    return recents
        .map(
          (m) => QuickItem(
            name: (m['name'] as String?) ?? 'Item',
            calories: (m['calories'] as int?) ?? 0,
          ),
        )
        .toList();
  }

  @override
  List<QuickItem> getFavorites() {
    final List<dynamic> favsRaw =
        (_boxes.foodEntries.get(_favoritesKey) as List<dynamic>?) ??
        <dynamic>[];
    final List<Map<String, dynamic>> favs = favsRaw
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m as Map))
        .toList();
    favs.sort((a, b) {
      final bool ap = (a['pinned'] as bool?) ?? true;
      final bool bp = (b['pinned'] as bool?) ?? true;
      if (ap != bp) return bp ? 1 : -1; // pinned first
      return (b['lastUsedAt'] as String? ?? '')
          .compareTo(a['lastUsedAt'] as String? ?? '');
    });
    return favs
        .map(
          (m) => QuickItem(
            name: (m['name'] as String?) ?? 'Item',
            calories: (m['calories'] as int?) ?? 0,
            pinned: (m['pinned'] as bool?) ?? true,
          ),
        )
        .toList();
  }

  @override
  Future<void> toggleFavorite(QuickItem item) async {
    final List<dynamic> favsRaw =
        (_boxes.foodEntries.get(_favoritesKey) as List<dynamic>?) ??
        <dynamic>[];
    final int idx = favsRaw.indexWhere((e) => (e as Map)['name'] == item.name);
    if (idx >= 0) {
      favsRaw.removeAt(idx);
    } else {
      favsRaw.insert(0, <String, dynamic>{
        'name': item.name,
        'calories': item.calories,
        'pinned': true,
        'timesUsed': 0,
        'lastUsedAt': DateTime.now().toIso8601String(),
      });
    }
    await _boxes.foodEntries.put(_favoritesKey, favsRaw);
  }
}
