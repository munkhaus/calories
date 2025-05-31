import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../food_logging/application/food_logging_notifier.dart';
import '../../activity/application/activity_notifier.dart';
import '../../activity/infrastructure/activity_service.dart';
import '../application/selected_date_provider.dart';
import '../../onboarding/application/onboarding_notifier.dart';

/// Provider for ActivityNotifier
final activityNotifierProvider = ChangeNotifierProvider<ActivityNotifier>((ref) {
  return ActivityNotifier();
});

/// Provider der lytter til ændringer i valgt dato og opdaterer food logging
final dateAwareFoodProvider = Provider<void>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final foodNotifier = ref.read(foodLoggingProvider.notifier);
  
  // Indlæs måltider for den valgte dato når datoen ændres
  WidgetsBinding.instance.addPostFrameCallback((_) {
    foodNotifier.loadMealsForDate(selectedDate);
  });
  
  return;
});

/// Provider der lytter til ændringer i valgt dato og opdaterer activity loading
final dateAwareActivityProvider = Provider<void>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final activityNotifier = ref.read(activityNotifierProvider.notifier);
  
  // Get user profile for BMR calculation
  final userProfile = ref.read(onboardingProvider).userProfile;
  
  // Indlæs aktiviteter for den valgte dato når datoen ændres
  WidgetsBinding.instance.addPostFrameCallback((_) {
    activityNotifier.setSelectedDate(selectedDate);
    
    // Also load calories with BMR if user profile is complete
    if (userProfile.isCompleteForCalculations) {
      activityNotifier.loadTotalCaloriesWithBmrForDate(userProfile.bmr, selectedDate);
    } else {
      activityNotifier.loadCaloriesBurnedForDate(selectedDate);
    }
  });
  
  return;
});

/// Provider der leverer kalorier for den valgte dato
final caloriesForSelectedDateProvider = Provider<double>((ref) {
  // Trigger food loading for selected date
  ref.watch(dateAwareFoodProvider);
  
  // Return calories for the currently selected date
  return ref.watch(totalCaloriesForSelectedDateProvider);
});

/// Provider der leverer aktiviteter for den valgte dato
final activitiesForSelectedDateProvider = Provider<List<dynamic>>((ref) {
  // Trigger activity loading for selected date
  ref.watch(dateAwareActivityProvider);
  
  // Get activities from activity notifier state
  final activityNotifier = ref.watch(activityNotifierProvider);
  final activityState = activityNotifier.state;
  
  if (activityState.todaysActivitiesState.isSuccess) {
    return activityState.todaysActivitiesState.data!;
  }
  
  return [];
});

// Global activity refresh counter for forcing provider updates
final activityRefreshCounterProvider = StateProvider<int>((ref) => 0);

/// Provider der leverer aktivitetskalorier for den valgte dato
final activityCaloriesForSelectedDateProvider = Provider<int>((ref) {
  // Watch the refresh counter to force updates
  final refreshCounter = ref.watch(activityRefreshCounterProvider);
  
  // Trigger activity loading for selected date
  ref.watch(dateAwareActivityProvider);
  
  // Get the selected date
  final selectedDate = ref.watch(selectedDateProvider);
  
  // Get calories from activity notifier state
  final activityNotifier = ref.watch(activityNotifierProvider);
  final activityState = activityNotifier.state;
  
  print('🔥 activityCaloriesForSelectedDateProvider: refreshCounter: $refreshCounter');
  print('🔥 activityCaloriesForSelectedDateProvider: selectedDate: $selectedDate');
  print('🔥 activityCaloriesForSelectedDateProvider: activityNotifier selectedDate: ${activityNotifier.selectedDate}');
  print('🔥 activityCaloriesForSelectedDateProvider: State isSuccess: ${activityState.todaysCaloriesState.isSuccess}');
  print('🔥 activityCaloriesForSelectedDateProvider: State hasError: ${activityState.todaysCaloriesState.hasError}');
  print('🔥 activityCaloriesForSelectedDateProvider: State isLoading: ${activityState.todaysCaloriesState.isLoading}');
  print('🔥 activityCaloriesForSelectedDateProvider: State data: ${activityState.todaysCaloriesState.data}');
  print('🔥 activityCaloriesForSelectedDateProvider: Activity logs count: ${activityState.todaysActivities?.length ?? 0}');
  if (activityState.todaysActivities != null) {
    for (final activity in activityState.todaysActivities!) {
      print('🔥 activityCaloriesForSelectedDateProvider: Activity: ${activity.activityName} - ${activity.caloriesBurned} kcal');
    }
  }
  
  if (activityState.todaysCaloriesState.isSuccess) {
    final calories = activityState.todaysCaloriesState.data!;
    print('🔥 activityCaloriesForSelectedDateProvider: Returning $calories calories');
    return calories;
  }
  
  print('🔥 activityCaloriesForSelectedDateProvider: Returning 0 calories (default)');
  return 0;
});

/// Function to refresh activity calories - call this when activities are logged
void refreshActivityCalories(WidgetRef ref) {
  // Increment counter to force provider updates
  final counter = ref.read(activityRefreshCounterProvider.notifier);
  counter.state = counter.state + 1;
  
  // Get the current selected date and reload activities for that date
  final selectedDate = ref.read(selectedDateProvider);
  final activityNotifier = ref.read(activityNotifierProvider);
  
  // Reload activities and calories for the selected date
  Future.microtask(() async {
    await activityNotifier.loadActivitiesForDate(selectedDate);
    await activityNotifier.loadCaloriesBurnedForDate(selectedDate);
  });
} 