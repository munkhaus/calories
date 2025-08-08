import 'dart:convert';

import 'package:calories/core/domain/models/goal.dart';
import 'package:calories/core/storage/hive_boxes.dart';
import 'package:calories/goals/domain/i_goal_service.dart';

class GoalService implements IGoalService {
  GoalService(this._boxes);

  static const String _currentKey = 'current';
  final HiveBoxes _boxes;

  @override
  Goal? getGoal() {
    final dynamic raw = _boxes.goals.get(_currentKey);
    if (raw is String) {
      return Goal.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<void> saveGoal(Goal goal) async {
    await _boxes.goals.put(_currentKey, jsonEncode(goal.toJson()));
  }
}
