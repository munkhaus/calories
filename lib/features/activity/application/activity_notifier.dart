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
  
  // Static list to keep track of all instances for global updates
  static final List<ActivityNotifier> _instances = [];

  ActivityNotifier({
    IActivityService? service,
    this.onActivityChanged, // Add callback parameter
  }) : _service = service ?? ActivityService() {
    _instances.add(this);
  }
  
  bool _isDisposed = false;

  void _updateState(ActivityState newState) {
    if (_isDisposed) return; // Don't update if disposed
    _state = newState;
    notifyListeners();
  }
  
  bool get mounted => !_isDisposed;
  
  @override
  void dispose() {
    _isDisposed = true;
    _instances.remove(this);
    super.dispose();
  }
  
  /// Refresh all ActivityNotifier instances (call this when logging from other screens)
  static Future<void> refreshAllInstances() async {
    for (final instance in _instances) {
      await instance._refreshData();
    }
  }
  
  /// Refresh this instance's data
  Future<void> _refreshData() async {
    if (!mounted) return;
    
    if (_currentBmr != null) {
      await Future.wait([
        loadActivitiesForDate(_selectedDate),
        loadTotalCaloriesWithBmrForDate(_currentBmr!, _selectedDate),
      ]);
    } else {
      await Future.wait([
        loadActivitiesForDate(_selectedDate),
        loadCaloriesBurnedForDate(_selectedDate),
      ]);
    }
    
    if (onActivityChanged != null) {
      onActivityChanged!();
    }
  }

  ActivityState get state => _state;
  DateTime get selectedDate => _selectedDate;
  
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

  /// Initialize with BMR calculation
  Future<void> initializeWithBmr(double bmr) async {
    print('🔥 ActivityNotifier: Initializing with BMR: $bmr');
    
    // Explicit initialization of the database service
    await _service.getAvailableActivities(); // This will trigger database initialization
    
    _currentBmr = bmr;
    _selectedDate = DateTime.now();
    
    // Load activity data
    await Future.wait([
      loadTodaysActivities(),
      loadTotalCaloriesWithBmr(bmr),
    ]);
    
    print('🔥 ActivityNotifier: Initialization complete');
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
    if (!mounted) return; // Don't proceed if disposed
    
    final normalizedDate = DateTime(date.year, date.month, date.day);
    print('🔥 ActivityNotifier: Loading activities for date: $normalizedDate');
    
    if (!mounted) return; // Check again before state update
    
    _updateState(_state.copyWith(
      todaysActivitiesState: const DataState.loading(),
    ));

    try {
      final result = await _service.getActivityLogsForDate(1, normalizedDate); // TODO: Get real user ID
      print('🔥 ActivityNotifier: Service result - isSuccess: ${result.isSuccess}');
      
      if (!mounted) return; // Don't proceed if disposed during async operation
      
      if (result.isSuccess) {
        print('🔥 ActivityNotifier: Found ${result.success.length} activities for $normalizedDate');
        _updateState(_state.copyWith(
          todaysActivitiesState: DataState.success(result.success),
        ));
      } else {
        print('🔥 ActivityNotifier: Failed to load activities - ${result.failure}');
        _updateState(_state.copyWith(
          todaysActivitiesState: const DataState.error('Kunne ikke indlæse aktiviteter'),
        ));
      }
    } catch (e) {
      print('🔥 ActivityNotifier: Exception loading activities: $e');
      if (!mounted) return; // Don't proceed if disposed during error handling
      
      _updateState(_state.copyWith(
        todaysActivitiesState: DataState.error(e.toString()),
      ));
    }
  }

  /// Load today's activity logs (deprecated - use loadActivitiesForDate)
  Future<void> loadTodaysActivities() async {
    if (!mounted) return; // Don't proceed if disposed
    
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

  /// Log activity and refresh data
  Future<void> logActivity(UserActivityLogModel activity) async {
    if (!mounted) return; // Don't proceed if disposed
    
    _updateState(_state.copyWith(
      isLoggingActivity: true,
    ));

    try {
      final result = await _service.logActivity(activity);
      
      if (!mounted) return; // Don't proceed if disposed during async operation
      
      if (result.isSuccess) {
        // Set the selected date to the activity's date
        final activityDate = DateTime.parse(activity.loggedAt);
        final activityDateNormalized = DateTime(activityDate.year, activityDate.month, activityDate.day);
        _selectedDate = activityDateNormalized;
        
        // Force reload of all activity data for the activity's date
        await Future.wait([
          loadActivitiesForDate(activityDateNormalized),
          _currentBmr != null 
            ? loadTotalCaloriesWithBmrForDate(_currentBmr!, activityDateNormalized)
            : loadCaloriesBurnedForDate(activityDateNormalized),
        ]);
        
        // Notify listeners of changes
        if (onActivityChanged != null) {
          onActivityChanged!();
        }
        
        // Update to completed state
        _updateState(_state.copyWith(
          isLoggingActivity: false,
        ));
      } else {
        if (!mounted) return; // Check again before error update
        
        _updateState(_state.copyWith(
          isLoggingActivity: false,
          todaysActivitiesState: const DataState.error('Kunne ikke tilføje aktivitet'),
        ));
      }
    } catch (e) {
      if (!mounted) return; // Don't proceed if disposed during error handling
      
      _updateState(_state.copyWith(
        isLoggingActivity: false,
        todaysActivitiesState: DataState.error(e.toString()),
      ));
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

  /// Refresh all data for current selected date
  Future<void> refresh() async {
    if (!mounted) return;
    await _refreshData();
  }

  void updateSelectedDate(DateTime date) {
    if (!mounted) return; // Don't proceed if disposed
    
    _selectedDate = date;
    loadActivitiesForDate(date);
  }
} 