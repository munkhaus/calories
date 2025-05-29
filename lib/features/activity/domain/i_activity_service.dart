import 'package:result_type/result_type.dart';
import 'user_activity_log_model.dart';
import 'activity_item_model.dart';

/// Error types for activity operations
enum ActivityError {
  notFound,
  validation,
  database,
  unknown,
}

/// Interface for activity service operations
abstract class IActivityService {
  /// Get available activities for selection
  /// 
  /// Returns [Result.failure] with [ActivityError.database] if database error occurs.
  Future<Result<List<ActivityItemModel>, ActivityError>> getAvailableActivities();

  /// Search activities by name
  /// 
  /// Returns [Result.failure] with [ActivityError.database] if database error occurs.
  Future<Result<List<ActivityItemModel>, ActivityError>> searchActivities(String query);

  /// Get activity by ID
  /// 
  /// Returns [Result.failure] with [ActivityError.notFound] if activity doesn't exist.
  Future<Result<ActivityItemModel, ActivityError>> getActivityById(int id);

  /// Log an activity
  /// 
  /// Returns [Result.failure] with [ActivityError.validation] if validation fails.
  Future<Result<UserActivityLogModel, ActivityError>> logActivity(UserActivityLogModel activity);

  /// Get activity logs for a specific date
  /// 
  /// Returns [Result.failure] with [ActivityError.database] if database error occurs.
  Future<Result<List<UserActivityLogModel>, ActivityError>> getActivityLogsForDate(
    int userId, 
    DateTime date
  );

  /// Get today's total calories burned from activities only
  Future<Result<int, ActivityError>> getTodaysCaloriesBurned(int userId);

  /// Get today's total calories burned including BMR based on time of day
  Future<Result<int, ActivityError>> getTotalCaloriesBurnedWithBmr(int userId, double dailyBmr);

  /// Delete an activity log entry
  /// 
  /// Returns [Result.failure] with [ActivityError.notFound] if entry doesn't exist.
  Future<Result<bool, ActivityError>> deleteActivityLog(int logEntryId);

  /// Update an activity log entry
  /// 
  /// Returns [Result.failure] with [ActivityError.notFound] if entry doesn't exist.
  /// Returns [Result.failure] with [ActivityError.validation] if validation fails.
  Future<Result<UserActivityLogModel, ActivityError>> updateActivityLog(UserActivityLogModel activity);

  /// Get common/popular activities
  Future<Result<List<ActivityItemModel>, ActivityError>> getCommonActivities();

  /// Calculate calories for activity
  /// 
  /// Returns calculated calories based on activity, duration/distance, and user weight
  Future<Result<int, ActivityError>> calculateCalories({
    required int activityId,
    required double value,
    required bool isDuration,
    required double userWeightKg,
  });
} 