import 'package:flutter_test/flutter_test.dart';
import 'package:your_project_name/features/activity/application/activity_state.dart'; // Replace your_project_name
import 'package:your_project_name/core/domain/data_state.dart'; // Replace your_project_name
import 'package:your_project_name/features/activity/domain/activity_log.dart'; // Replace your_project_name
import 'package:your_project_name/features/activity/domain/activity.dart'; // Replace your_project_name

void main() {
  group('ActivityState', () {
    final mockActivity = Activity(
      id: '1',
      name: 'Running',
      metValue: 3.5,
    );
    final mockActivityLog = ActivityLog(
      id: 'log1',
      activity: mockActivity,
      duration: Duration(minutes: 30),
      caloriesBurned: 150,
      loggedAt: DateTime.now(),
    );

    group('initial factory', () {
      test('should return an initial ActivityState', () {
        final initialState = ActivityState.initial();

        expect(initialState.commonActivitiesState, equals(DataState.idle()));
        expect(initialState.searchResultsState, equals(DataState.idle()));
        expect(initialState.todaysActivitiesState, equals(DataState.idle()));
        expect(initialState.todaysCaloriesState, equals(DataState.idle()));
        expect(initialState.isLoggingActivity, isFalse);
        expect(initialState.searchQuery, isEmpty);
        expect(initialState.selectedDate, isNotNull); // Or specific date check
      });
    });

    group('copyWith', () {
      final initialState = ActivityState.initial();

      test('should update commonActivitiesState', () {
        final newState = initialState.copyWith(commonActivitiesState: DataState.loading());
        expect(newState.commonActivitiesState, equals(DataState.loading()));
        expect(newState.searchResultsState, equals(initialState.searchResultsState));
        // ... test other properties remain unchanged
      });

      test('should update searchResultsState', () {
        final newState = initialState.copyWith(searchResultsState: DataState.success([mockActivity]));
        expect(newState.searchResultsState, equals(DataState.success([mockActivity])));
        expect(newState.commonActivitiesState, equals(initialState.commonActivitiesState));
      });

      test('should update todaysActivitiesState', () {
        final newState = initialState.copyWith(todaysActivitiesState: DataState.success([mockActivityLog]));
        expect(newState.todaysActivitiesState, equals(DataState.success([mockActivityLog])));
      });

      test('should update todaysCaloriesState', () {
        final newState = initialState.copyWith(todaysCaloriesState: DataState.success(500.0));
        expect(newState.todaysCaloriesState, equals(DataState.success(500.0)));
      });

      test('should update isLoggingActivity', () {
        final newState = initialState.copyWith(isLoggingActivity: true);
        expect(newState.isLoggingActivity, isTrue);
      });

      test('should update searchQuery', () {
        final newState = initialState.copyWith(searchQuery: 'run');
        expect(newState.searchQuery, equals('run'));
      });

      test('should update selectedDate', () {
        final newDate = DateTime.now().subtract(Duration(days: 1));
        final newState = initialState.copyWith(selectedDate: newDate);
        expect(newState.selectedDate, equals(newDate));
      });

      test('should update multiple properties', () {
        final newDate = DateTime.now().subtract(Duration(days: 5));
        final newState = initialState.copyWith(
          commonActivitiesState: DataState.error('Error'),
          todaysCaloriesState: DataState.loading(),
          searchQuery: 'walk',
          selectedDate: newDate,
          isLoggingActivity: true,
        );
        expect(newState.commonActivitiesState, equals(DataState.error('Error')));
        expect(newState.todaysCaloriesState, equals(DataState.loading()));
        expect(newState.searchQuery, equals('walk'));
        expect(newState.selectedDate, equals(newDate));
        expect(newState.isLoggingActivity, isTrue);
      });
    });

    group('Getters', () {
      // isLoadingActivities
      test('isLoadingActivities should be true if commonActivitiesState is loading', () {
        final state = ActivityState.initial().copyWith(commonActivitiesState: DataState.loading());
        expect(state.isLoadingActivities, isTrue);
      });
      test('isLoadingActivities should be false if commonActivitiesState is not loading', () {
        final state = ActivityState.initial().copyWith(commonActivitiesState: DataState.success([]));
        expect(state.isLoadingActivities, isFalse);
      });

      // isSearching
      test('isSearching should be true if searchResultsState is loading', () {
        final state = ActivityState.initial().copyWith(searchResultsState: DataState.loading());
        expect(state.isSearching, isTrue);
      });
      test('isSearching should be false if searchResultsState is not loading', () {
        final state = ActivityState.initial().copyWith(searchResultsState: DataState.idle());
        expect(state.isSearching, isFalse);
      });

      // hasSearchResults
      test('hasSearchResults should be true if searchResultsState is success and has data', () {
        final state = ActivityState.initial().copyWith(searchResultsState: DataState.success([mockActivity]));
        expect(state.hasSearchResults, isTrue);
      });
      test('hasSearchResults should be false if searchResultsState is success but empty', () {
        final state = ActivityState.initial().copyWith(searchResultsState: DataState.success([]));
        expect(state.hasSearchResults, isFalse);
      });
       test('hasSearchResults should be false if searchResultsState is not success', () {
        final state = ActivityState.initial().copyWith(searchResultsState: DataState.loading());
        expect(state.hasSearchResults, isFalse);
      });

      // isLoadingTodaysData
      test('isLoadingTodaysData should be true if todaysActivitiesState is loading', () {
        final state = ActivityState.initial().copyWith(todaysActivitiesState: DataState.loading());
        expect(state.isLoadingTodaysData, isTrue);
      });
      test('isLoadingTodaysData should be true if todaysCaloriesState is loading', () {
        final state = ActivityState.initial().copyWith(todaysCaloriesState: DataState.loading());
        expect(state.isLoadingTodaysData, isTrue);
      });
      test('isLoadingTodaysData should be false if both states are not loading', () {
        final state = ActivityState.initial().copyWith(
          todaysActivitiesState: DataState.success([]),
          todaysCaloriesState: DataState.success(0.0)
        );
        expect(state.isLoadingTodaysData, isFalse);
      });

      // commonActivities
      test('commonActivities should return data if state is success', () {
        final state = ActivityState.initial().copyWith(commonActivitiesState: DataState.success([mockActivity]));
        expect(state.commonActivities, equals([mockActivity]));
      });
      test('commonActivities should return empty list if state is not success', () {
        final state = ActivityState.initial().copyWith(commonActivitiesState: DataState.loading());
        expect(state.commonActivities, isEmpty);
      });

      // searchResults
      test('searchResults should return data if state is success', () {
        final state = ActivityState.initial().copyWith(searchResultsState: DataState.success([mockActivity]));
        expect(state.searchResults, equals([mockActivity]));
      });
      test('searchResults should return empty list if state is not success', () {
        final state = ActivityState.initial().copyWith(searchResultsState: DataState.error('Error'));
        expect(state.searchResults, isEmpty);
      });

      // todaysActivities
      test('todaysActivities should return data if state is success', () {
        final state = ActivityState.initial().copyWith(todaysActivitiesState: DataState.success([mockActivityLog]));
        expect(state.todaysActivities, equals([mockActivityLog]));
      });
      test('todaysActivities should return empty list if state is not success', () {
        final state = ActivityState.initial().copyWith(todaysActivitiesState: DataState.idle());
        expect(state.todaysActivities, isEmpty);
      });

      // todaysCaloriesBurned
      test('todaysCaloriesBurned should return data if state is success', () {
        final state = ActivityState.initial().copyWith(todaysCaloriesState: DataState.success(250.5));
        expect(state.todaysCaloriesBurned, equals(250.5));
      });
      test('todaysCaloriesBurned should return 0.0 if state is not success', () {
        final state = ActivityState.initial().copyWith(todaysCaloriesState: DataState.loading());
        expect(state.todaysCaloriesBurned, equals(0.0));
      });
    });
  });
}
