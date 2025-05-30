import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../food_logging/application/food_logging_notifier.dart';
import '../../activity/application/activity_notifier.dart';
import '../../activity/infrastructure/activity_service.dart';
import '../application/selected_date_provider.dart';

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
  
  // Indlæs aktiviteter for den valgte dato når datoen ændres
  WidgetsBinding.instance.addPostFrameCallback((_) {
    activityNotifier.setSelectedDate(selectedDate);
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

/// Provider der leverer aktivitetskalorier for den valgte dato
final activityCaloriesForSelectedDateProvider = Provider<int>((ref) {
  // Trigger activity loading for selected date
  ref.watch(dateAwareActivityProvider);
  
  // Get calories from activity notifier state
  final activityNotifier = ref.watch(activityNotifierProvider);
  final activityState = activityNotifier.state;
  
  if (activityState.todaysCaloriesState.isSuccess) {
    return activityState.todaysCaloriesState.data!;
  }
  
  return 0;
}); 