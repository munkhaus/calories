import '../domain/activity_item_model.dart';
import '../domain/user_activity_log_model.dart';

/// Data state wrapper for async operations
class DataState<T> {
  final T? data;
  final bool isLoading;
  final String? error;

  const DataState._({
    this.data,
    this.isLoading = false,
    this.error,
  });

  const DataState.idle() : this._();
  
  const DataState.loading() : this._(isLoading: true);
  
  const DataState.success(T data) : this._(data: data);
  
  const DataState.error([String? error]) : this._(error: error ?? 'Unknown error');

  bool get isIdle => !isLoading && error == null && data == null;
  bool get isSuccess => data != null && error == null;
  bool get hasError => error != null;
}

/// Activity feature state
class ActivityState {
  final DataState<List<ActivityItemModel>> availableActivitiesState;
  final DataState<List<ActivityItemModel>> commonActivitiesState;
  final DataState<List<ActivityItemModel>> searchResultsState;
  final DataState<List<UserActivityLogModel>> todaysActivitiesState;
  final DataState<int> todaysCaloriesState;
  final String searchQuery;
  final bool isLoggingActivity;

  const ActivityState({
    this.availableActivitiesState = const DataState.idle(),
    this.commonActivitiesState = const DataState.idle(),
    this.searchResultsState = const DataState.idle(),
    this.todaysActivitiesState = const DataState.idle(),
    this.todaysCaloriesState = const DataState.idle(),
    this.searchQuery = '',
    this.isLoggingActivity = false,
  });

  ActivityState copyWith({
    DataState<List<ActivityItemModel>>? availableActivitiesState,
    DataState<List<ActivityItemModel>>? commonActivitiesState,
    DataState<List<ActivityItemModel>>? searchResultsState,
    DataState<List<UserActivityLogModel>>? todaysActivitiesState,
    DataState<int>? todaysCaloriesState,
    String? searchQuery,
    bool? isLoggingActivity,
  }) {
    return ActivityState(
      availableActivitiesState: availableActivitiesState ?? this.availableActivitiesState,
      commonActivitiesState: commonActivitiesState ?? this.commonActivitiesState,
      searchResultsState: searchResultsState ?? this.searchResultsState,
      todaysActivitiesState: todaysActivitiesState ?? this.todaysActivitiesState,
      todaysCaloriesState: todaysCaloriesState ?? this.todaysCaloriesState,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoggingActivity: isLoggingActivity ?? this.isLoggingActivity,
    );
  }

  /// Helper getters for common state checks
  bool get isLoadingActivities => availableActivitiesState.isLoading || commonActivitiesState.isLoading;
  bool get isSearching => searchResultsState.isLoading;
  bool get hasSearchResults => searchResultsState.isSuccess && searchResultsState.data!.isNotEmpty;
  bool get isLoadingTodaysData => todaysActivitiesState.isLoading || todaysCaloriesState.isLoading;

  /// Get common activities or empty list
  List<ActivityItemModel> get commonActivities => commonActivitiesState.data ?? [];
  
  /// Get search results or empty list
  List<ActivityItemModel> get searchResults => searchResultsState.data ?? [];
  
  /// Get today's activities or empty list
  List<UserActivityLogModel> get todaysActivities => todaysActivitiesState.data ?? [];
  
  /// Get today's calories burned or 0
  int get todaysCaloriesBurned => todaysCaloriesState.data ?? 0;

  /// Factory method for initial state
  factory ActivityState.initial() => const ActivityState();
} 