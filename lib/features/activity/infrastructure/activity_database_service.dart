import '../domain/activity_item_model.dart';
import '../domain/user_activity_log_model.dart';
import '../../../core/infrastructure/storage_service.dart';

/// Simple in-memory database service for activity data
class ActivityDatabaseService {
  static final List<ActivityItemModel> _activities = <ActivityItemModel>[];
  static List<UserActivityLogModel> _activityLogs = <UserActivityLogModel>[];
  static bool _isInitialized = false;

  /// Initialize the database with sample data
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _insertSampleActivities();
    
    // Load persisted activity logs
    _activityLogs = await StorageService.loadList(
      StorageService.activityLogsKey,
      UserActivityLogModel.fromJson,
    );
    
    _isInitialized = true;
    print('🏃 ActivityDatabaseService: Loaded ${_activityLogs.length} activity logs from storage');
  }
  
  /// Save activity logs to persistent storage
  static Future<void> _saveActivityLogs() async {
    final success = await StorageService.saveList(
      StorageService.activityLogsKey,
      _activityLogs,
      (log) => log.toJson(),
    );
    
    if (success) {
      print('🏃 ActivityDatabaseService: Saved ${_activityLogs.length} activity logs to storage');
    } else {
      print('❌ ActivityDatabaseService: Failed to save activity logs');
    }
  }

  /// Insert sample activities data
  static Future<void> _insertSampleActivities() async {
    final sampleActivities = [
      ActivityItemModel(
        activityId: 1,
        name: 'Gåtur',
        category: 'Cardio',
        caloriesPerMinute: 3.5,
        caloriesPerKgPerKm: 0.5,
        supportsDuration: true,
        supportsDistance: true,
        iconName: 'walk',
        description: 'Afslappet gåtur',
      ),
      ActivityItemModel(
        activityId: 2,
        name: 'Løb',
        category: 'Cardio',
        caloriesPerMinute: 10.0,
        caloriesPerKgPerKm: 1.0,
        supportsDuration: true,
        supportsDistance: true,
        iconName: 'run',
        description: 'Løbetræning',
      ),
      ActivityItemModel(
        activityId: 3,
        name: 'Cykling',
        category: 'Cardio',
        caloriesPerMinute: 8.0,
        caloriesPerKgPerKm: 0.3,
        supportsDuration: true,
        supportsDistance: true,
        iconName: 'bike',
        description: 'Cykeltur eller spinning',
      ),
      ActivityItemModel(
        activityId: 4,
        name: 'Svømning',
        category: 'Cardio',
        caloriesPerMinute: 11.0,
        caloriesPerKgPerKm: 0.0,
        supportsDuration: true,
        supportsDistance: false,
        iconName: 'swim',
        description: 'Svømmetræning',
      ),
      ActivityItemModel(
        activityId: 5,
        name: 'Styrketræning',
        category: 'Strength',
        caloriesPerMinute: 6.0,
        caloriesPerKgPerKm: 0.0,
        supportsDuration: true,
        supportsDistance: false,
        iconName: 'dumbbell',
        description: 'Vægtløftning og styrkeøvelser',
      ),
      ActivityItemModel(
        activityId: 6,
        name: 'Yoga',
        category: 'Flexibility',
        caloriesPerMinute: 3.0,
        caloriesPerKgPerKm: 0.0,
        supportsDuration: true,
        supportsDistance: false,
        iconName: 'yoga',
        description: 'Yoga og stretching',
      ),
      ActivityItemModel(
        activityId: 7,
        name: 'Tennis',
        category: 'Sport',
        caloriesPerMinute: 8.5,
        caloriesPerKgPerKm: 0.0,
        supportsDuration: true,
        supportsDistance: false,
        iconName: 'tennis',
        description: 'Tennisspil',
      ),
      ActivityItemModel(
        activityId: 8,
        name: 'Fodbold',
        category: 'Sport',
        caloriesPerMinute: 9.0,
        caloriesPerKgPerKm: 0.0,
        supportsDuration: true,
        supportsDistance: false,
        iconName: 'soccer',
        description: 'Fodboldspil',
      ),
    ];

    _activities.clear();
    _activities.addAll(sampleActivities);
  }

  // Activity Item Operations
  static Future<List<ActivityItemModel>> getAvailableActivities() async {
    await initialize();
    return List.from(_activities);
  }

  static Future<List<ActivityItemModel>> searchActivities(String query) async {
    await initialize();
    
    if (query.isEmpty) return [];
    
    return _activities.where((activity) =>
      activity.name.toLowerCase().contains(query.toLowerCase()) ||
      activity.category.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  static Future<ActivityItemModel?> getActivityById(int id) async {
    await initialize();
    
    try {
      return _activities.firstWhere((a) => a.activityId == id);
    } catch (e) {
      return null;
    }
  }

  static Future<List<ActivityItemModel>> getCommonActivities() async {
    await initialize();
    
    // Create a map to count activity usage
    final usageCount = <int, int>{};
    
    for (final log in _activityLogs) {
      // Find matching activity by name
      final activity = _activities.where((a) => a.name == log.activityName).firstOrNull;
      if (activity != null) {
        usageCount[activity.activityId] = (usageCount[activity.activityId] ?? 0) + 1;
      }
    }
    
    // Sort activities by usage count, then by name
    final sortedActivities = List<ActivityItemModel>.from(_activities);
    sortedActivities.sort((a, b) {
      final aCount = usageCount[a.activityId] ?? 0;
      final bCount = usageCount[b.activityId] ?? 0;
      
      if (aCount != bCount) {
        return bCount.compareTo(aCount); // Most used first
      }
      return a.name.compareTo(b.name); // Then alphabetical
    });
    
    return sortedActivities.take(8).toList();
  }

  // Activity Log Operations
  static Future<int> logActivity(UserActivityLogModel activity) async {
    await initialize();
    
    final newId = _getNextId();
    final now = DateTime.now().toIso8601String();
    
    final logWithId = activity.copyWith(
      logEntryId: newId,
      loggedAt: now,
      createdAt: now,
      updatedAt: now,
    );
    
    _activityLogs.add(logWithId);
    await _saveActivityLogs(); // Save to persistent storage
    return newId;
  }
  
  static int _getNextId() {
    if (_activityLogs.isEmpty) return 1;
    
    final maxId = _activityLogs
        .map((log) => log.logEntryId)
        .reduce((max, id) => id > max ? id : max);
    
    return maxId + 1;
  }

  static Future<List<UserActivityLogModel>> getActivityLogsForDate(
    int userId, 
    DateTime date,
  ) async {
    await initialize();
    
    final dateString = date.toIso8601String().split('T')[0]; // YYYY-MM-DD format
    
    return _activityLogs.where((log) {
      final logDate = DateTime.parse(log.loggedAt).toIso8601String().split('T')[0];
      return log.userId == userId && logDate == dateString;
    }).toList()..sort((a, b) => b.loggedAt.compareTo(a.loggedAt)); // Most recent first
  }

  static Future<int> getTodaysCaloriesBurned(int userId) async {
    await initialize();
    
    final today = DateTime.now();
    final logs = await getActivityLogsForDate(userId, today);
    
    // Calculate calories from logged activities
    final activityCalories = logs.fold<int>(0, (sum, log) => sum + log.caloriesBurned);
    
    // Calculate BMR calories based on time of day - need user profile for this
    // For now, return just activity calories until we can get user profile
    return activityCalories;
  }

  /// Get calories burned for specific date (activities only)
  static Future<int> getCaloriesBurnedForDate(int userId, DateTime date) async {
    await initialize();
    
    final logs = await getActivityLogsForDate(userId, date);
    
    // Calculate calories from logged activities
    final activityCalories = logs.fold<int>(0, (sum, log) => sum + log.caloriesBurned);
    
    return activityCalories;
  }

  /// Calculate BMR calories burned based on time of day
  static int calculateBmrCaloriesForTimeOfDay(double dailyBmr) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final minutesSinceStartOfDay = now.difference(startOfDay).inMinutes;
    final percentOfDayPassed = minutesSinceStartOfDay / (24 * 60); // 24 hours * 60 minutes
    
    final bmrCalories = (dailyBmr * percentOfDayPassed).round();
    
    return bmrCalories;
  }

  /// Calculate BMR calories burned based on specific date and time
  static int calculateBmrCaloriesForDate(double dailyBmr, DateTime date) {
    final now = DateTime.now();
    final targetDate = DateTime(date.year, date.month, date.day);
    
    // If it's today, calculate based on current time
    if (targetDate.year == now.year && targetDate.month == now.month && targetDate.day == now.day) {
      return calculateBmrCaloriesForTimeOfDay(dailyBmr);
    }
    
    // If it's a past date, return full BMR for that day
    if (targetDate.isBefore(DateTime(now.year, now.month, now.day))) {
      return dailyBmr.round();
    }
    
    // If it's a future date, return 0
    return 0;
  }

  /// Get total calories burned including BMR and activities
  static Future<int> getTotalCaloriesBurnedWithBmr(int userId, double dailyBmr) async {
    await initialize();
    
    final today = DateTime.now();
    final logs = await getActivityLogsForDate(userId, today);
    
    // Calculate calories from logged activities
    final activityCalories = logs.fold<int>(0, (sum, log) => sum + log.caloriesBurned);
    
    // Calculate BMR calories based on time of day
    final bmrCalories = calculateBmrCaloriesForTimeOfDay(dailyBmr);
    
    return activityCalories + bmrCalories;
  }

  /// Get total calories burned including BMR and activities for specific date
  static Future<int> getTotalCaloriesBurnedWithBmrForDate(int userId, double dailyBmr, DateTime date) async {
    await initialize();
    
    final logs = await getActivityLogsForDate(userId, date);
    
    // Calculate calories from logged activities
    final activityCalories = logs.fold<int>(0, (sum, log) => sum + log.caloriesBurned);
    
    // Calculate BMR calories based on date
    final bmrCalories = calculateBmrCaloriesForDate(dailyBmr, date);
    
    return activityCalories + bmrCalories;
  }

  static Future<bool> deleteActivityLog(int logEntryId) async {
    await initialize();
    
    final index = _activityLogs.indexWhere((log) => log.logEntryId == logEntryId);
    if (index >= 0) {
      _activityLogs.removeAt(index);
      await _saveActivityLogs(); // Save to persistent storage
      return true;
    }
    return false;
  }

  static Future<bool> updateActivityLog(UserActivityLogModel activity) async {
    await initialize();
    
    final index = _activityLogs.indexWhere((log) => log.logEntryId == activity.logEntryId);
    if (index >= 0) {
      final updatedActivity = activity.copyWith(
        updatedAt: DateTime.now().toIso8601String(),
      );
      _activityLogs[index] = updatedActivity;
      await _saveActivityLogs(); // Save to persistent storage
      return true;
    }
    return false;
  }

  // Helper methods for development and testing
  static void clearAllData() {
    _activityLogs.clear();
    _saveActivityLogs(); // Save empty list to storage
    _isInitialized = false;
  }

  static List<UserActivityLogModel> get activityLogs => List.unmodifiable(_activityLogs);
  static List<ActivityItemModel> get activities => List.unmodifiable(_activities);
} 