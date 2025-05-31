import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_food_log_model.dart';
import '../infrastructure/food_logging_service.dart';

class FoodLoggingState {
  final List<UserFoodLogModel> mealsForDate;
  final bool isLoading;
  final String? error;
  final DateTime lastUpdate;
  final DateTime selectedDate;

  const FoodLoggingState({
    this.mealsForDate = const [],
    this.isLoading = false,
    this.error,
    required this.lastUpdate,
    required this.selectedDate,
  });

  FoodLoggingState copyWith({
    List<UserFoodLogModel>? mealsForDate,
    bool? isLoading,
    String? error,
    DateTime? lastUpdate,
    DateTime? selectedDate,
  }) {
    return FoodLoggingState(
      mealsForDate: mealsForDate ?? this.mealsForDate,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class FoodLoggingNotifier extends StateNotifier<FoodLoggingState> {
  bool _isDisposed = false;
  
  FoodLoggingNotifier() : super(FoodLoggingState(
    lastUpdate: DateTime.now(),
    selectedDate: DateTime.now(),
  )) {
    loadMealsForDate(state.selectedDate);
  }
  
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Indlæser måltider for en specifik dato
  Future<void> loadMealsForDate(DateTime date) async {
    if (_isDisposed) return; // Don't proceed if disposed
    
    // Standardisér datoen til midnat
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    state = state.copyWith(
      isLoading: true, 
      error: null,
      selectedDate: normalizedDate,
    );
    
    try {
      const userId = 1; // TODO: Get actual user ID
      final meals = await FoodLoggingService.getFoodLogsForDate(userId, normalizedDate);
      if (!_isDisposed) {
        state = state.copyWith(
          mealsForDate: meals,
          isLoading: false,
          lastUpdate: DateTime.now(),
        );
      }
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
          lastUpdate: DateTime.now(),
        );
      }
    }
  }

  /// Indlæser måltider for i dag (legacy method for bagudkompatibilitet)
  Future<void> loadTodaysMeals() async {
    await loadMealsForDate(DateTime.now());
  }

  Future<void> logFood(UserFoodLogModel foodLog) async {
    if (_isDisposed) return; // Don't proceed if disposed
    
    try {
      await FoodLoggingService.logFood(foodLog);
      // Reload meals after logging for the selected date
      await loadMealsForDate(state.selectedDate);
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(error: e.toString());
      }
    }
  }

  Future<void> deleteFood(int logEntryId) async {
    if (_isDisposed) return; // Don't proceed if disposed
    
    try {
      await FoodLoggingService.deleteFood(logEntryId);
      // Reload meals after deleting for the selected date
      await loadMealsForDate(state.selectedDate);
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(error: e.toString());
      }
    }
  }

  Future<void> updateFood(UserFoodLogModel foodLog) async {
    if (_isDisposed) return; // Don't proceed if disposed
    
    try {
      await FoodLoggingService.updateFood(foodLog);
      // Reload meals after updating for the selected date
      await loadMealsForDate(state.selectedDate);
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(error: e.toString());
      }
    }
  }

  Future<void> refresh() async {
    await loadMealsForDate(state.selectedDate);
  }

  void clearError() {
    if (_isDisposed) return; // Don't proceed if disposed
    state = state.copyWith(error: null);
  }

  /// Henter total kalorier for den valgte dato
  int get totalCaloriesForSelectedDate {
    return state.mealsForDate.fold(0, (sum, meal) => sum + meal.calories);
  }

  /// Henter måltider for valgt dato fordelt på måltidstyper
  Map<MealType, List<UserFoodLogModel>> get mealsByType {
    final Map<MealType, List<UserFoodLogModel>> result = {};
    
    for (final mealType in MealType.values) {
      result[mealType] = state.mealsForDate
          .where((meal) => meal.mealType == mealType)
          .toList();
    }
    
    return result;
  }
}

// Provider
final foodLoggingProvider = StateNotifierProvider<FoodLoggingNotifier, FoodLoggingState>((ref) {
  return FoodLoggingNotifier();
});

// Helper providers - opdateret til at arbejde med valgt dato
final mealsForSelectedDateProvider = Provider<List<UserFoodLogModel>>((ref) {
  return ref.watch(foodLoggingProvider).mealsForDate;
});

// Legacy provider for bagudkompatibilitet
final todaysMealsProvider = Provider<List<UserFoodLogModel>>((ref) {
  return ref.watch(foodLoggingProvider).mealsForDate;
});

final isLoadingMealsProvider = Provider<bool>((ref) {
  return ref.watch(foodLoggingProvider).isLoading;
});

final mealsErrorProvider = Provider<String?>((ref) {
  return ref.watch(foodLoggingProvider).error;
});

// Provider for total calories for the selected date
final totalCaloriesForSelectedDateProvider = Provider<double>((ref) {
  final meals = ref.watch(mealsForSelectedDateProvider);
  return meals.fold(0.0, (sum, meal) => sum + meal.calories);
});

// Legacy provider for total calories (today)
final totalCaloriesProvider = Provider<double>((ref) {
  return ref.watch(totalCaloriesForSelectedDateProvider);
});

// Provider for selected date in food logging
final selectedFoodDateProvider = Provider<DateTime>((ref) {
  return ref.watch(foodLoggingProvider).selectedDate;
});

// Daily nutrition calculation providers
final dailyNutritionProvider = Provider<Map<String, double>>((ref) {
  final meals = ref.watch(todaysMealsProvider);
  
  double totalCalories = 0;
  double totalProtein = 0;
  double totalFat = 0;
  double totalCarbs = 0;
  
  for (final meal in meals) {
    totalCalories += meal.calories;
    totalProtein += meal.protein;
    totalFat += meal.fat;
    totalCarbs += meal.carbs;
  }
  
  return {
    'calories': totalCalories,
    'protein': totalProtein,
    'fat': totalFat,
    'carbs': totalCarbs,
  };
});

final totalProteinProvider = Provider<double>((ref) {
  return ref.watch(dailyNutritionProvider)['protein'] ?? 0.0;
});

final totalFatProvider = Provider<double>((ref) {
  return ref.watch(dailyNutritionProvider)['fat'] ?? 0.0;
});

final totalCarbsProvider = Provider<double>((ref) {
  return ref.watch(dailyNutritionProvider)['carbs'] ?? 0.0;
}); 