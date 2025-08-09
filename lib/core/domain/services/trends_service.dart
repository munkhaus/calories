import 'dart:convert';

import 'package:calories/core/domain/models/daily_totals.dart';
import 'package:calories/core/domain/models/food_entry.dart';
import 'package:calories/core/storage/hive_boxes.dart';
import 'package:calories/goals/domain/i_goal_service.dart';
import 'package:calories/trends/domain/i_trends_service.dart';

class TrendsService implements ITrendsService {
  TrendsService(this._boxes, this._goals);

  final HiveBoxes _boxes;
  final IGoalService _goals;

  @override
  List<DailyTotals> getDailyTotals({required int days}) {
    final DateTime now = DateTime.now();
    final Map<String, int> totals = <String, int>{};
    // Walk all date indices in range and sum kcal
    for (int i = 0; i < days; i++) {
      final DateTime day = now.subtract(Duration(days: i));
      final String key = _iso(day);
      totals[key] = 0;
      final List<dynamic> ids =
          (_boxes.foodEntries.get('date_index_$key') as List<dynamic>?) ??
              <dynamic>[];
      for (final dynamic id in ids) {
        final dynamic raw = _boxes.foodEntries.get(id);
        if (raw is String) {
          final FoodEntry e =
              FoodEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>);
          totals[key] = (totals[key] ?? 0) + e.calories;
        }
      }
    }
    final int? target = _goals.getGoal()?.targetCalories;
    final List<DailyTotals> list = totals.entries
        .map((e) => DailyTotals(
              date: e.key,
              calorieTotal: e.value,
              deltaFromGoal: target != null ? e.value - target : 0,
            ))
        .toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  @override
  double getAdherencePercent({required int days, int tolerancePercent = 10}) {
    final List<DailyTotals> list = getDailyTotals(days: days);
    final int? target = _goals.getGoal()?.targetCalories;
    if (target == null || list.isEmpty) return 0;
    final double tol = target * (tolerancePercent / 100.0);
    int ok = 0;
    for (final DailyTotals d in list) {
      if ((d.calorieTotal - target).abs() <= tol) ok++;
    }
    return ok * 100.0 / list.length;
  }

  @override
  int getAdherenceStreak({int tolerancePercent = 10}) {
    final int? target = _goals.getGoal()?.targetCalories;
    if (target == null) return 0;
    final double tol = target * (tolerancePercent / 100.0);
    int streak = 0;
    final DateTime now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final String key = _iso(now.subtract(Duration(days: i)));
      final List<dynamic> ids =
          (_boxes.foodEntries.get('date_index_$key') as List<dynamic>?) ??
              <dynamic>[];
      int sum = 0;
      for (final dynamic id in ids) {
        final dynamic raw = _boxes.foodEntries.get(id);
        if (raw is String) {
          final FoodEntry e =
              FoodEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>);
          sum += e.calories;
        }
      }
      if ((sum - target).abs() <= tol) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  String _iso(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}


