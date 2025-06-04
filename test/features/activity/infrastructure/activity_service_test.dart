import 'package:flutter_test/flutter_test.dart';
import 'package:your_project_name/features/activity/domain/models/activity_item_model.dart'; // Placeholder
import 'package:your_project_name/features/activity/domain/models/user_activity_log_model.dart'; // Placeholder
import 'package:your_project_name/features/activity/domain/contracts/i_activity_service.dart'; // For ActivityError placeholder
import 'package:your_project_name/features/activity/infrastructure/activity_service.dart'; // Placeholder
import 'package:your_project_name/core/domain/result.dart'; // Placeholder
// Other necessary placeholder enums and models will be defined below

// --- Placeholder for ActivityDatabaseService ---
// This simulates the static service that ActivityService interacts with.
// In a real test, these static methods would point to your actual database service.
class ActivityDatabaseService {
  static List<ActivityItemModel> _activities = [];
  static List<UserActivityLogModel> _logs = [];
  static int _nextLogId = 1;

  static Future<void> initialize() async {
    _activities = [
      ActivityItemModel(id: '1', name: 'Gåtur', metValue: 3.5, emoji: '🚶', supportsDuration: true, metFormulaType: METFormulaType.durationBased, parentId: 'cat1', sortOrder: 1, activityCategory: ActivityCategory.gang),
      ActivityItemModel(id: '2', name: 'Løb', metValue: 7.0, emoji: '🏃', supportsDuration: true, supportsDistance: true, metFormulaType: METFormulaType.durationBased, parentId: 'cat1', sortOrder: 2, activityCategory: ActivityCategory.loeb),
      ActivityItemModel(id: '3', name: 'Cykling', metValue: 5.5, emoji: '🚴', supportsDuration: true, supportsDistance: true, metFormulaType: METFormulaType.durationBased, parentId: 'cat1', sortOrder: 3, activityCategory: ActivityCategory.cykling),
      ActivityItemModel(id: '4', name: 'Yoga Session', metValue: 2.5, emoji: '🧘', supportsDuration: true, metFormulaType: METFormulaType.durationBased, parentId: 'cat2', sortOrder: 1, activityCategory: ActivityCategory.yoga),
    ];
    // Add some sample logs for today for user '1'
    final today = DateTime.now();
    _logs = [
      UserActivityLogModel(logEntryId: (_nextLogId++).toString(), userId: '1', activityId: '1', activityName: 'Morgen gåtur', caloriesBurned: 150, loggedAt: today, durationMinutes: 30, inputType: ActivityInputType.duration, intensity: ActivityIntensity.moderate),
      UserActivityLogModel(logEntryId: (_nextLogId++).toString(), userId: '1', activityId: '2', activityName: 'Aftenløb', caloriesBurned: 300, loggedAt: today, durationMinutes: 30, inputType: ActivityInputType.duration, intensity: ActivityIntensity.vigorous),
    ];
  }

  static Future<void> clearAllData() async {
    _activities.clear();
    _logs.clear();
    _nextLogId = 1;
  }

  static Future<List<ActivityItemModel>> getActivitiesDB() async => List.from(_activities);

  static Future<List<ActivityItemModel>> searchActivitiesDB(String query) async {
    if (query.isEmpty) return [];
    return _activities.where((a) => a.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  static Future<ActivityItemModel?> getActivityByIdDB(String id) async {
    try {
      return _activities.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<UserActivityLogModel> logActivityDB(UserActivityLogModel log) async {
    final newLog = log.copyWith(
      logEntryId: (_nextLogId++).toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _logs.add(newLog);
    return newLog;
  }

  static Future<List<UserActivityLogModel>> getActivityLogsForDateDB(String userId, DateTime date) async {
    return _logs.where((log) =>
        log.userId == userId &&
        log.loggedAt.year == date.year &&
        log.loggedAt.month == date.month &&
        log.loggedAt.day == date.day).toList();
  }

  static Future<bool> deleteActivityLogDB(String logEntryId) async {
    final initialLength = _logs.length;
    _logs.removeWhere((log) => log.logEntryId == logEntryId);
    return _logs.length < initialLength;
  }

  static Future<UserActivityLogModel?> updateActivityLogDB(UserActivityLogModel logUpdate) async {
    final index = _logs.indexWhere((log) => log.logEntryId == logUpdate.logEntryId);
    if (index != -1) {
      _logs[index] = logUpdate.copyWith(updatedAt: DateTime.now());
      return _logs[index];
    }
    return null;
  }
   static Future<List<UserActivityLogModel>> getCommonActivitiesDB(String userId, int limit) async {
    // Simplified: return most recent logs as "common" for testing
    var userLogs = _logs.where((log) => log.userId == userId).toList();
    userLogs.sort((a,b) => b.loggedAt.compareTo(a.loggedAt)); // most recent first

    // Create ActivityItemModels from these logs (very simplified)
    return userLogs.take(limit).map((log) =>
        _activities.firstWhere((act) => act.id == log.activityId, orElse: () => ActivityItemModel(id: log.activityId, name: log.activityName))
    ).toList();
  }
}
// --- End of Placeholder ActivityDatabaseService ---


void main() {
  late ActivityService activityService;

  setUpAll(() async {
    // Initialize the mock database service with sample data
    await ActivityDatabaseService.initialize();
  });

  tearDownAll(() async {
    // Clear data after all tests
    await ActivityDatabaseService.clearAllData();
  });

  setUp(() {
      activityService = ActivityService();
      // Note: If ActivityDatabaseService had instance methods, you'd mock it here.
      // Since it's static, tests will use the static implementation.
  });


  group('ActivityService', () {
    group('getAvailableActivities()', () {
      test('should return Success with a non-empty list of activities', () async {
        final result = await activityService.getAvailableActivities();
        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), isNotEmpty);
        expect(result.getOrNull()!.length, ActivityDatabaseService._activities.length);
      });
    });

    group('searchActivities()', () {
      test('with matching query, returns Success with results', () async {
        final result = await activityService.searchActivities('Løb');
        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), isNotEmpty);
        expect(result.getOrNull()!.first.name, 'Løb');
      });

      test('with non-matching query, returns Success with empty list', () async {
        final result = await activityService.searchActivities('Unobtainable');
        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), isEmpty);
      });

      test('with empty query, returns Success with empty list (as per DB service logic)', () async {
        final result = await activityService.searchActivities('');
        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), isEmpty);
      });
    });

    group('getActivityById()', () {
      test('with existing ID, returns Success with ActivityItemModel', () async {
        final result = await activityService.getActivityById('1'); // 'Gåtur'
        expect(result.isSuccess, isTrue);
        expect(result.getOrNull()?.name, 'Gåtur');
      });

      test('with non-existing ID, returns Failure(notFound)', () async {
        final result = await activityService.getActivityById('999');
        expect(result.isFailure, isTrue);
        expect(result.getErrorOrNull(), ActivityError.notFound);
      });
    });

    group('getCommonActivities()', () {
      test('should return Success (content depends on logs)', () async {
        // This test assumes ActivityDatabaseService.initialize() adds some logs
        // that would result in common activities.
        final result = await activityService.getCommonActivities(userId: '1');
        expect(result.isSuccess, isTrue);
        // Further checks would depend on the exact logic of getCommonActivitiesDB
        expect(result.getOrNull(), isNotNull);
      });
    });

    group('logActivity()', () {
      test('should log activity and return Success with updated model', () async {
        final logToCreate = UserActivityLogModel(
          userId: '1',
          activityId: '3', // Cykling
          activityName: 'Test Cykling',
          caloriesBurned: 250,
          durationMinutes: 45,
          inputType: ActivityInputType.duration,
          intensity: ActivityIntensity.moderate,
          loggedAt: DateTime.now(), // This will be overridden by DB service
        );
        final result = await activityService.logActivity(logToCreate);
        expect(result.isSuccess, isTrue);
        final loggedActivity = result.getOrNull();
        expect(loggedActivity, isNotNull);
        expect(loggedActivity!.logEntryId, isNotNull);
        expect(loggedActivity.logEntryId!.isNotEmpty, isTrue);
        expect(loggedActivity.createdAt, isNotNull);
        expect(loggedActivity.activityName, 'Test Cykling');
      });
    });

    group('getActivityLogsForDate()', () {
      test('for a date with logs, returns Success with non-empty list', () async {
        final result = await activityService.getActivityLogsForDate(userId: '1', date: DateTime.now());
        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), isNotEmpty);
        expect(result.getOrNull()!.length, 2); // Based on initialize()
      });

      test('for a date with no logs, returns Success with empty list', () async {
        final futureDate = DateTime.now().add(Duration(days: 5));
        final result = await activityService.getActivityLogsForDate(userId: '1', date: futureDate);
        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), isEmpty);
      });
    });

    group('Calorie calculation methods', () {
      // These are simplified as they mostly pass through to DB service or specific calorie logic.
      // The actual calculation correctness is tested with ActivityDatabaseService/CalorieCalculator.
      test('getTodaysCaloriesBurned returns Success', () async {
        final result = await activityService.getTodaysCaloriesBurned(userId: '1');
        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), 450); // 150 + 300 from sample logs
      });

      test('getCaloriesBurnedForDate returns Success', () async {
        final result = await activityService.getCaloriesBurnedForDate(userId: '1', date: DateTime.now());
        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), 450);
      });

      test('getTotalCaloriesBurnedWithBmr returns Success', () async {
        final result = await activityService.getTotalCaloriesBurnedWithBmr(userId: '1', bmr: 1500);
        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), 1500 + 450); // BMR + logged calories
      });

      test('getTotalCaloriesBurnedWithBmrForDate returns Success', () async {
        final result = await activityService.getTotalCaloriesBurnedWithBmrForDate(userId: '1', bmr: 1500, date: DateTime.now());
        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), 1500 + 450);
      });
    });

    group('deleteActivityLog()', () {
      String? logIdToDelete;
      setUp(() async {
        // Log a new activity to ensure a deletable ID for each test in this group
        final log = UserActivityLogModel(userId: 'testUser', activityId: '1', activityName: 'Deletable', caloriesBurned: 10, loggedAt: DateTime.now(), inputType: ActivityInputType.duration, intensity: ActivityIntensity.light);
        final addResult = await activityService.logActivity(log);
        logIdToDelete = addResult.getOrNull()?.logEntryId;
        expect(logIdToDelete, isNotNull, reason: "Failed to create log for deletion test setup");
      });

      test('with existing ID, returns Success(true)', () async {
        final result = await activityService.deleteActivityLog(logIdToDelete!);
        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), isTrue);
      });

      test('deleting same ID again, returns Failure(notFound)', () async {
        await activityService.deleteActivityLog(logIdToDelete!); // First delete
        final result = await activityService.deleteActivityLog(logIdToDelete!); // Second delete
        expect(result.isFailure, isTrue);
        expect(result.getErrorOrNull(), ActivityError.notFound);
      });

      test('with non-existent ID, returns Failure(notFound)', () async {
        final result = await activityService.deleteActivityLog('99999');
        expect(result.isFailure, isTrue);
        expect(result.getErrorOrNull(), ActivityError.notFound);
      });
    });

    group('updateActivityLog()', () {
      UserActivityLogModel? originalLog;
       setUp(() async {
        final log = UserActivityLogModel(userId: 'updateUser', activityId: '4', activityName: 'Yoga Initial', caloriesBurned: 100, loggedAt: DateTime.now(), inputType: ActivityInputType.duration, intensity: ActivityIntensity.light, notes: "Initial notes");
        final addResult = await activityService.logActivity(log);
        originalLog = addResult.getOrNull();
        expect(originalLog, isNotNull, reason: "Failed to create log for update test setup");
      });

      test('with existing log, returns Success with updated fields', () async {
        final logToUpdate = originalLog!.copyWith(notes: "Updated notes", caloriesBurned: 120);
        final result = await activityService.updateActivityLog(logToUpdate);

        expect(result.isSuccess, isTrue);
        final updatedLog = result.getOrNull();
        expect(updatedLog, isNotNull);
        expect(updatedLog!.notes, "Updated notes");
        expect(updatedLog.caloriesBurned, 120);
        expect(updatedLog.updatedAt, isNotNull);
        expect(updatedLog.updatedAt!.isAfter(originalLog!.createdAt!), isTrue);
      });

      test('with non-existent log, returns Failure(notFound)', () async {
        final nonExistentLog = UserActivityLogModel(logEntryId: 'non-id-123', userId: 'u', activityId: 'a', activityName: 'n', caloriesBurned: 1, loggedAt: DateTime.now(), inputType: ActivityInputType.duration, intensity: ActivityIntensity.light);
        final result = await activityService.updateActivityLog(nonExistentLog);
        expect(result.isFailure, isTrue);
        expect(result.getErrorOrNull(), ActivityError.notFound);
      });
    });

    group('calculateCalories()', () {
      test('with existing activityId, returns Success with calculated calories', () async {
        // Activity '2' (Løb) has MET 7.0. 7.0 * 75kg * (30/60 hr) = 262.5 -> 263
        final result = await activityService.calculateCalories(activityId: '2', value: 30, isDuration: true, userWeightKg: 75);
        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), 263);
      });

      test('with non-existent activityId, returns Failure(notFound)', () async {
        final result = await activityService.calculateCalories(activityId: 'non-existent-99', value: 30, isDuration: true, userWeightKg: 70);
        expect(result.isFailure, isTrue);
        expect(result.getErrorOrNull(), ActivityError.notFound);
      });
    });
  });
}


// --- Minimal Placeholder Definitions ---
// (These would typically be imported from your actual project structure)

// Enums (simplified)
enum ActivityInputType { duration, distance, reps }
enum ActivityIntensity { light, moderate, vigorous, varied }
enum ActivityCategory { gang, loeb, cykling, svoemning, styrketraening, fitnessMaskiner, gymnastik, sport, dans, yoga, hjemmeaktiviteter, udendoersaktiviteter, vinteraktiviteter, vandaktiviteter, andet }
enum ActivityIntensityLevel { lav, moderat, hoej } // For MET data
enum METFormulaType { durationBased, distanceBased, unknown } // For ActivityItemModel

// ActivityError (as part of IActivityService or a general error enum)
enum ActivityError {
  unknown,
  notFound,
  databaseError,
  invalidData,
  // ... other specific errors
}

// ActivityItemModel (simplified)
class ActivityItemModel {
  final String id;
  final String name;
  final double metValue;
  final String? emoji;
  final bool supportsDuration;
  final bool supportsDistance;
  final METFormulaType metFormulaType;
  final String? parentId;
  final int sortOrder;
  final ActivityCategory? activityCategory; // For getDefaultSpeed context

  ActivityItemModel({
    required this.id,
    required this.name,
    this.metValue = 0.0,
    this.emoji,
    this.supportsDuration = true,
    this.supportsDistance = false,
    this.metFormulaType = METFormulaType.unknown,
    this.parentId,
    this.sortOrder = 0,
    this.activityCategory,
  });

  // Simplified calorie calculation for testing calculateCalories in service
  int calculateCalories({required double inputValue, required double userWeightKg, bool? isDuration}) {
    if (metValue <= 0) return 0;
    // Assuming duration based for simplicity here
    final durationHours = inputValue / 60.0; // Assuming inputValue is minutes
    return (metValue * userWeightKg * durationHours).round();
  }
}

// UserActivityLogModel (simplified)
class UserActivityLogModel {
  final String? logEntryId;
  final String userId;
  final String activityId;
  final String activityName;
  final int caloriesBurned;
  final DateTime loggedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? durationMinutes;
  final ActivityInputType inputType;
  final ActivityIntensity intensity;
  final String? notes;


  UserActivityLogModel({
    this.logEntryId,
    required this.userId,
    required this.activityId,
    required this.activityName,
    required this.caloriesBurned,
    required this.loggedAt,
    this.createdAt,
    this.updatedAt,
    this.durationMinutes,
    required this.inputType,
    required this.intensity,
    this.notes,
  });

  UserActivityLogModel copyWith({
    String? logEntryId,
    String? userId,
    String? activityId,
    String? activityName,
    int? caloriesBurned,
    DateTime? loggedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? durationMinutes,
    ActivityInputType? inputType,
    ActivityIntensity? intensity,
    String? notes,
  }) {
    return UserActivityLogModel(
      logEntryId: logEntryId ?? this.logEntryId,
      userId: userId ?? this.userId,
      activityId: activityId ?? this.activityId,
      activityName: activityName ?? this.activityName,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      loggedAt: loggedAt ?? this.loggedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      inputType: inputType ?? this.inputType,
      intensity: intensity ?? this.intensity,
      notes: notes ?? this.notes,
    );
  }
}


// ActivityService (Placeholder Implementation that uses the static DB service)
class ActivityService implements IActivityService {
  @override
  Future<Result<List<ActivityItemModel>, ActivityError>> getAvailableActivities() async {
    try {
      final activities = await ActivityDatabaseService.getActivitiesDB();
      return Result.success(activities);
    } catch (e) {
      return Result.failure(ActivityError.databaseError);
    }
  }

  @override
  Future<Result<List<ActivityItemModel>, ActivityError>> searchActivities(String query) async {
    try {
      final activities = await ActivityDatabaseService.searchActivitiesDB(query);
      return Result.success(activities);
    } catch (e) {
      return Result.failure(ActivityError.databaseError);
    }
  }

  @override
  Future<Result<ActivityItemModel, ActivityError>> getActivityById(String id) async {
    try {
      final activity = await ActivityDatabaseService.getActivityByIdDB(id);
      if (activity != null) {
        return Result.success(activity);
      }
      return Result.failure(ActivityError.notFound);
    } catch (e) {
      return Result.failure(ActivityError.databaseError);
    }
  }

  @override
  Future<Result<List<ActivityItemModel>, ActivityError>> getCommonActivities({required String userId, int limit = 10}) async {
     try {
      final activities = await ActivityDatabaseService.getCommonActivitiesDB(userId, limit);
      return Result.success(activities);
    } catch (e) {
      return Result.failure(ActivityError.databaseError);
    }
  }

  @override
  Future<Result<UserActivityLogModel, ActivityError>> logActivity(UserActivityLogModel log) async {
    try {
      final savedLog = await ActivityDatabaseService.logActivityDB(log);
      return Result.success(savedLog);
    } catch (e) {
      return Result.failure(ActivityError.databaseError);
    }
  }

  @override
  Future<Result<List<UserActivityLogModel>, ActivityError>> getActivityLogsForDate({required String userId, required DateTime date}) async {
    try {
      final logs = await ActivityDatabaseService.getActivityLogsForDateDB(userId, date);
      return Result.success(logs);
    } catch (e) {
      return Result.failure(ActivityError.databaseError);
    }
  }

  @override
  Future<Result<int, ActivityError>> getTodaysCaloriesBurned({required String userId}) async {
    return getCaloriesBurnedForDate(userId: userId, date: DateTime.now());
  }

  @override
  Future<Result<int, ActivityError>> getCaloriesBurnedForDate({required String userId, required DateTime date}) async {
    try {
      final logs = await ActivityDatabaseService.getActivityLogsForDateDB(userId, date);
      final totalCalories = logs.fold(0, (sum, log) => sum + log.caloriesBurned);
      return Result.success(totalCalories);
    } catch (e) {
      return Result.failure(ActivityError.databaseError);
    }
  }

  @override
  Future<Result<int, ActivityError>> getTotalCaloriesBurnedWithBmr({required String userId, required int bmr}) async {
    final activityCaloriesResult = await getTodaysCaloriesBurned(userId: userId);
    if (activityCaloriesResult.isSuccess) {
      return Result.success(bmr + activityCaloriesResult.getOrNull()!);
    }
    return Result.failure(activityCaloriesResult.getErrorOrNull() ?? ActivityError.unknown);
  }

  @override
  Future<Result<int, ActivityError>> getTotalCaloriesBurnedWithBmrForDate({required String userId, required int bmr, required DateTime date}) async {
    final activityCaloriesResult = await getCaloriesBurnedForDate(userId: userId, date: date);
    if (activityCaloriesResult.isSuccess) {
      return Result.success(bmr + activityCaloriesResult.getOrNull()!);
    }
    return Result.failure(activityCaloriesResult.getErrorOrNull() ?? ActivityError.unknown);
  }

  @override
  Future<Result<bool, ActivityError>> deleteActivityLog(String logEntryId) async {
    try {
      final success = await ActivityDatabaseService.deleteActivityLogDB(logEntryId);
      return success ? Result.success(true) : Result.failure(ActivityError.notFound);
    } catch (e) {
      return Result.failure(ActivityError.databaseError);
    }
  }

  @override
  Future<Result<UserActivityLogModel, ActivityError>> updateActivityLog(UserActivityLogModel log) async {
    try {
      final updatedLog = await ActivityDatabaseService.updateActivityLogDB(log);
      if (updatedLog != null) {
        return Result.success(updatedLog);
      }
      return Result.failure(ActivityError.notFound);
    } catch (e) {
      return Result.failure(ActivityError.databaseError);
    }
  }

  @override
  Future<Result<int, ActivityError>> calculateCalories({required String activityId, required double value, required bool isDuration, required double userWeightKg}) async {
    final activityResult = await getActivityById(activityId);
    if (activityResult.isFailure) {
      return Result.failure(activityResult.getErrorOrNull() ?? ActivityError.notFound);
    }
    final activity = activityResult.getOrNull()!;
    // Assuming ActivityItemModel has a method to calculate calories
    final calories = activity.calculateCalories(inputValue: value, userWeightKg: userWeightKg, isDuration: isDuration);
    return Result.success(calories);
  }
}


// Result class (simplified placeholder - should be in a common core location)
class Result<S, E> {
  final S? _value;
  final E? _error;
  final bool isSuccess;

  Result.success(this._value) : _error = null, isSuccess = true;
  Result.failure(this._error) : _value = null, isSuccess = false;

  bool get isFailure => !isSuccess;
  S? getOrNull() => _value;
  E? getErrorOrNull() => _error;
}

// IActivityService for ActivityError enum (if not defined elsewhere)
abstract class IActivityService {
  // ... methods
}
