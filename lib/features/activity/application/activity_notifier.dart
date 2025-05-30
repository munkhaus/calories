import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/i_activity_service.dart';
import '../domain/user_activity_log_model.dart';
import '../infrastructure/activity_service.dart';
import 'activity_state.dart';
import 'activity_calories_notifier.dart';

class ActivityNotifier extends ChangeNotifier {
  final IActivityService _service;
  ActivityState _state = ActivityState.initial();
  double? _currentBmr; // Track if we're using BMR calculation
  DateTime _selectedDate = DateTime.now(); // Track selected date
  
  // Callback to refresh activity calories
  void Function()? onActivityChanged;

  ActivityNotifier({
    IActivityService? service,
    this.onActivityChanged, // Add callback parameter
  }) : _service = service ?? ActivityService();

  ActivityState get state => _state;
  DateTime get selectedDate => _selectedDate;

  void _updateState(ActivityState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Set the selected date and reload activities
  Future<void> setSelectedDate(DateTime date) async {
    _selectedDate = date;
    await loadActivitiesForDate(date);
  }

  /// Initialize the activity screen by loading common activities and selected date's data
  Future<void> initialize() async {
    _currentBmr = null; // Clear BMR tracking
    await Future.wait([
      loadCommonActivities(),
      loadActivitiesForDate(_selectedDate),
      loadCaloriesBurnedForDate(_selectedDate),
    ]);
  }

  /// Initialize with BMR for total calorie calculation
  Future<void> initializeWithBmr(double dailyBmr) async {
    _currentBmr = dailyBmr; // Track BMR for future refreshes
    await Future.wait([
      loadCommonActivities(),
      loadActivitiesForDate(_selectedDate),
      loadTotalCaloriesWithBmrForDate(dailyBmr, _selectedDate),
    ]);
  }

  /// Load common/popular activities
  Future<void> loadCommonActivities() async {
    _updateState(_state.copyWith(
      commonActivitiesState: const DataState.loading(),
    ));

    final result = await _service.getCommonActivities();
    
    if (result.isSuccess) {
      _updateState(_state.copyWith(
        commonActivitiesState: DataState.success(result.success),
      ));
    } else {
      _updateState(_state.copyWith(
        commonActivitiesState: const DataState.error('Kunne ikke indlæse aktiviteter'),
      ));
    }
  }

  /// Search for activities
  Future<void> searchActivities(String query) async {
    _updateState(_state.copyWith(
      searchQuery: query,
      searchResultsState: const DataState.loading(),
    ));

    if (query.isEmpty) {
      _updateState(_state.copyWith(
        searchResultsState: const DataState.idle(),
      ));
      return;
    }

    final result = await _service.searchActivities(query);
    
    if (result.isSuccess) {
      _updateState(_state.copyWith(
        searchResultsState: DataState.success(result.success),
      ));
    } else {
      _updateState(_state.copyWith(
        searchResultsState: const DataState.error('Kunne ikke søge aktiviteter'),
      ));
    }
  }

  /// Load activities for specific date
  Future<void> loadActivitiesForDate(DateTime date) async {
    _updateState(_state.copyWith(
      todaysActivitiesState: const DataState.loading(),
    ));

    final result = await _service.getActivityLogsForDate(1, date); // TODO: Get real user ID
    
    if (result.isSuccess) {
      _updateState(_state.copyWith(
        todaysActivitiesState: DataState.success(result.success),
      ));
    } else {
      _updateState(_state.copyWith(
        todaysActivitiesState: const DataState.error('Kunne ikke indlæse aktiviteter'),
      ));
    }
  }

  /// Load today's activity logs (deprecated - use loadActivitiesForDate)
  Future<void> loadTodaysActivities() async {
    await loadActivitiesForDate(DateTime.now());
  }

  /// Load calories burned for specific date (activities only)
  Future<void> loadCaloriesBurnedForDate(DateTime date) async {
    _updateState(_state.copyWith(
      todaysCaloriesState: const DataState.loading(),
    ));

    final result = await _service.getCaloriesBurnedForDate(1, date); // TODO: Get real user ID
    
    if (result.isSuccess) {
      _updateState(_state.copyWith(
        todaysCaloriesState: DataState.success(result.success),
      ));
    } else {
      _updateState(_state.copyWith(
        todaysCaloriesState: const DataState.error(),
      ));
    }
  }

  /// Load today's total calories burned (activities only) (deprecated - use loadCaloriesBurnedForDate)
  Future<void> loadTodaysCaloriesBurned() async {
    await loadCaloriesBurnedForDate(DateTime.now());
  }

  /// Load total calories burned including BMR for specific date
  Future<void> loadTotalCaloriesWithBmrForDate(double dailyBmr, DateTime date) async {
    _updateState(_state.copyWith(
      todaysCaloriesState: const DataState.loading(),
    ));

    final result = await _service.getTotalCaloriesBurnedWithBmrForDate(1, dailyBmr, date); // TODO: Get real user ID
    
    if (result.isSuccess) {
      _updateState(_state.copyWith(
        todaysCaloriesState: DataState.success(result.success),
      ));
    } else {
      _updateState(_state.copyWith(
        todaysCaloriesState: const DataState.error(),
      ));
    }
  }

  /// Load today's total calories burned including BMR (deprecated - use loadTotalCaloriesWithBmrForDate)
  Future<void> loadTotalCaloriesWithBmr(double dailyBmr) async {
    await loadTotalCaloriesWithBmrForDate(dailyBmr, DateTime.now());
  }

  /// Log an activity
  Future<bool> logActivity(UserActivityLogModel activity) async {
    _updateState(_state.copyWith(isLoggingActivity: true));

    final result = await _service.logActivity(activity);
    
    _updateState(_state.copyWith(isLoggingActivity: false));

    if (result.isSuccess) {
      // Refresh today's data after logging - use BMR if available
      await Future.wait([
        loadActivitiesForDate(_selectedDate),
        _currentBmr != null 
          ? loadTotalCaloriesWithBmr(_currentBmr!)
          : loadCaloriesBurnedForDate(_selectedDate),
      ]);
      
      // Refresh the activity calories provider if ref is available
      if (onActivityChanged != null) {
        onActivityChanged!();
      }
      
      return true;
    } else {
      return false;
    }
  }

  /// Calculate calories for an activity
  Future<int?> calculateCalories({
    required int activityId,
    required double value,
    required bool isDuration,
    required double userWeightKg,
  }) async {
    final result = await _service.calculateCalories(
      activityId: activityId,
      value: value,
      isDuration: isDuration,
      userWeightKg: userWeightKg,
    );

    return result.isSuccess ? result.success : null;
  }

  /// Delete an activity log
  Future<bool> deleteActivity(int logEntryId) async {
    final result = await _service.deleteActivityLog(logEntryId);
    
    if (result.isSuccess) {
      // Refresh today's data after deletion - use BMR if available
      await Future.wait([
        loadActivitiesForDate(_selectedDate),
        _currentBmr != null 
          ? loadTotalCaloriesWithBmr(_currentBmr!)
          : loadCaloriesBurnedForDate(_selectedDate),
      ]);
      
      // Refresh the activity calories provider if ref is available
      if (onActivityChanged != null) {
        onActivityChanged!();
      }
      
      return true;
    }
    return false;
  }

  /// Update an activity log
  Future<bool> updateActivity(UserActivityLogModel activity) async {
    final result = await _service.updateActivityLog(activity);
    
    if (result.isSuccess) {
      // Refresh today's data after update - use BMR if available
      await Future.wait([
        loadActivitiesForDate(_selectedDate),
        _currentBmr != null 
          ? loadTotalCaloriesWithBmr(_currentBmr!)
          : loadCaloriesBurnedForDate(_selectedDate),
      ]);
      
      // Refresh the activity calories provider if ref is available
      if (onActivityChanged != null) {
        onActivityChanged!();
      }
      
      return true;
    }
    return false;
  }

  /// Clear search results
  void clearSearch() {
    _updateState(_state.copyWith(
      searchQuery: '',
      searchResultsState: const DataState.idle(),
    ));
  }

  /// Refresh all data
  Future<void> refresh() async {
    if (_currentBmr != null) {
      await initializeWithBmr(_currentBmr!);
    } else {
      await initialize();
    }
  }
} 