import 'package:result_type/result_type.dart';
import '../domain/i_activity_service.dart';
import '../domain/activity_item_model.dart';
import '../domain/user_activity_log_model.dart';
import 'activity_database_service.dart';

/// Implementation of activity service using database storage
class ActivityService implements IActivityService {
  @override
  Future<Result<List<ActivityItemModel>, ActivityError>> getAvailableActivities() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final activities = await ActivityDatabaseService.getAvailableActivities();
      return Success(activities);
    } catch (e) {
      return Failure(ActivityError.database);
    }
  }

  @override
  Future<Result<List<ActivityItemModel>, ActivityError>> searchActivities(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final results = await ActivityDatabaseService.searchActivities(query);
      return Success(results);
    } catch (e) {
      return Failure(ActivityError.database);
    }
  }

  @override
  Future<Result<ActivityItemModel, ActivityError>> getActivityById(int id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final activity = await ActivityDatabaseService.getActivityById(id);
      
      if (activity != null) {
        return Success(activity);
      } else {
        return Failure(ActivityError.notFound);
      }
    } catch (e) {
      return Failure(ActivityError.database);
    }
  }

  @override
  Future<Result<List<ActivityItemModel>, ActivityError>> getCommonActivities() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final activities = await ActivityDatabaseService.getCommonActivities();
      return Success(activities);
    } catch (e) {
      return Failure(ActivityError.database);
    }
  }

  @override
  Future<Result<UserActivityLogModel, ActivityError>> logActivity(UserActivityLogModel activity) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final logEntryId = await ActivityDatabaseService.logActivity(activity);
      final loggedActivity = activity.copyWith(logEntryId: logEntryId);
      
      return Success(loggedActivity);
    } catch (e) {
      return Failure(ActivityError.validation);
    }
  }

  @override
  Future<Result<List<UserActivityLogModel>, ActivityError>> getActivityLogsForDate(
    int userId, 
    DateTime date,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      final logs = await ActivityDatabaseService.getActivityLogsForDate(userId, date);
      return Success(logs);
    } catch (e) {
      return Failure(ActivityError.database);
    }
  }

  @override
  Future<Result<int, ActivityError>> getTodaysCaloriesBurned(int userId) async {
    try {
      final calories = await ActivityDatabaseService.getTodaysCaloriesBurned(userId);
      return Success(calories);
    } catch (e) {
      return Failure(ActivityError.database);
    }
  }

  @override
  Future<Result<int, ActivityError>> getCaloriesBurnedForDate(int userId, DateTime date) async {
    try {
      final calories = await ActivityDatabaseService.getCaloriesBurnedForDate(userId, date);
      return Success(calories);
    } catch (e) {
      return Failure(ActivityError.database);
    }
  }

  @override
  Future<Result<int, ActivityError>> getTotalCaloriesBurnedWithBmr(int userId, double dailyBmr) async {
    try {
      final calories = await ActivityDatabaseService.getTotalCaloriesBurnedWithBmr(userId, dailyBmr);
      return Success(calories);
    } catch (e) {
      return Failure(ActivityError.database);
    }
  }

  @override
  Future<Result<int, ActivityError>> getTotalCaloriesBurnedWithBmrForDate(int userId, double dailyBmr, DateTime date) async {
    try {
      final calories = await ActivityDatabaseService.getTotalCaloriesBurnedWithBmrForDate(userId, dailyBmr, date);
      return Success(calories);
    } catch (e) {
      return Failure(ActivityError.database);
    }
  }

  @override
  Future<Result<bool, ActivityError>> deleteActivityLog(int logEntryId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final success = await ActivityDatabaseService.deleteActivityLog(logEntryId);
      
      if (success) {
        return Success(true);
      } else {
        return Failure(ActivityError.notFound);
      }
    } catch (e) {
      return Failure(ActivityError.database);
    }
  }

  @override
  Future<Result<UserActivityLogModel, ActivityError>> updateActivityLog(UserActivityLogModel activity) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final success = await ActivityDatabaseService.updateActivityLog(activity);
      
      if (success) {
        return Success(activity);
      } else {
        return Failure(ActivityError.notFound);
      }
    } catch (e) {
      return Failure(ActivityError.validation);
    }
  }

  @override
  Future<Result<int, ActivityError>> calculateCalories({
    required int activityId,
    required double value,
    required bool isDuration,
    required double userWeightKg,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      final activityResult = await getActivityById(activityId);
      if (activityResult.isFailure) {
        return Failure(ActivityError.notFound);
      }
      
      final activity = activityResult.success;
      final calories = activity.calculateCalories(
        value: value,
        isDuration: isDuration,
        userWeightKg: userWeightKg,
      );
      
      return Success(calories);
    } catch (e) {
      return Failure(ActivityError.validation);
    }
  }

  // Helper methods for testing and development
  static void clearAllData() {
    ActivityDatabaseService.clearAllData();
  }

  static List<UserActivityLogModel> get activityLogs => ActivityDatabaseService.activityLogs;
} 