import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_food_log_model.dart';
import '../infrastructure/food_logging_service.dart';

class FoodLoggingState {
  final List<UserFoodLogModel> todaysMeals;
  final bool isLoading;
  final String? error;
  final DateTime lastUpdate;

  const FoodLoggingState({
    this.todaysMeals = const [],
    this.isLoading = false,
    this.error,
    required this.lastUpdate,
  });

  FoodLoggingState copyWith({
    List<UserFoodLogModel>? todaysMeals,
    bool? isLoading,
    String? error,
    DateTime? lastUpdate,
  }) {
    return FoodLoggingState(
      todaysMeals: todaysMeals ?? this.todaysMeals,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

class FoodLoggingNotifier extends StateNotifier<FoodLoggingState> {
  FoodLoggingNotifier() : super(FoodLoggingState(lastUpdate: DateTime.now())) {
    loadTodaysMeals();
  }

  Future<void> loadTodaysMeals() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final meals = await FoodLoggingService.getTodaysMeals();
      state = state.copyWith(
        todaysMeals: meals,
        isLoading: false,
        lastUpdate: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        lastUpdate: DateTime.now(),
      );
    }
  }

  Future<void> logFood(UserFoodLogModel foodLog) async {
    try {
      await FoodLoggingService.logFood(foodLog);
      // Reload meals after logging
      await loadTodaysMeals();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteFood(int logEntryId) async {
    try {
      await FoodLoggingService.deleteFood(logEntryId);
      // Reload meals after deleting
      await loadTodaysMeals();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateFood(UserFoodLogModel foodLog) async {
    try {
      await FoodLoggingService.updateFood(foodLog);
      // Reload meals after updating
      await loadTodaysMeals();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refresh() async {
    await loadTodaysMeals();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final foodLoggingProvider = StateNotifierProvider<FoodLoggingNotifier, FoodLoggingState>((ref) {
  return FoodLoggingNotifier();
});

// Helper providers
final todaysMealsProvider = Provider<List<UserFoodLogModel>>((ref) {
  return ref.watch(foodLoggingProvider).todaysMeals;
});

final isLoadingMealsProvider = Provider<bool>((ref) {
  return ref.watch(foodLoggingProvider).isLoading;
});

final mealsErrorProvider = Provider<String?>((ref) {
  return ref.watch(foodLoggingProvider).error;
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

final totalCaloriesProvider = Provider<double>((ref) {
  return ref.watch(dailyNutritionProvider)['calories'] ?? 0.0;
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