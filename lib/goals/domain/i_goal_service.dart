import 'package:calories/core/domain/models/goal.dart';

abstract class IGoalService {
  Goal? getGoal();
  Future<void> saveGoal(Goal goal);
}
