import '../domain/food_item_model.dart';
import '../domain/user_food_log_model.dart';

class FoodLoggingService {
  // Mock data for demonstration - in real app this would use SQLite
  static final List<FoodItemModel> _mockFoodItems = [
    FoodItemModel(
      foodId: 1,
      name: 'Bananer',
      brand: '',
      caloriesPer100g: 89.0,
      proteinPer100g: 1.1,
      fatPer100g: 0.3,
      carbsPer100g: 22.8,
      servingUnit: 'stk',
      servingSize: 120.0,
    ),
    FoodItemModel(
      foodId: 2,
      name: 'Æbler',
      brand: '',
      caloriesPer100g: 52.0,
      proteinPer100g: 0.3,
      fatPer100g: 0.2,
      carbsPer100g: 13.8,
      servingUnit: 'stk',
      servingSize: 150.0,
    ),
    FoodItemModel(
      foodId: 3,
      name: 'Havregryn',
      brand: '',
      caloriesPer100g: 389.0,
      proteinPer100g: 16.9,
      fatPer100g: 6.9,
      carbsPer100g: 66.3,
      servingUnit: 'g',
      servingSize: 40.0,
    ),
    FoodItemModel(
      foodId: 4,
      name: 'Kyllingbryst',
      brand: '',
      caloriesPer100g: 165.0,
      proteinPer100g: 31.0,
      fatPer100g: 3.6,
      carbsPer100g: 0.0,
      servingUnit: 'g',
      servingSize: 150.0,
    ),
    FoodItemModel(
      foodId: 5,
      name: 'Fuldkornsspaghetti',
      brand: '',
      caloriesPer100g: 371.0,
      proteinPer100g: 13.0,
      fatPer100g: 2.5,
      carbsPer100g: 72.0,
      servingUnit: 'g',
      servingSize: 80.0,
    ),
    FoodItemModel(
      foodId: 6,
      name: 'Laks',
      brand: '',
      caloriesPer100g: 208.0,
      proteinPer100g: 22.0,
      fatPer100g: 13.0,
      carbsPer100g: 0.0,
      servingUnit: 'g',
      servingSize: 150.0,
    ),
    FoodItemModel(
      foodId: 7,
      name: 'Ris',
      brand: '',
      caloriesPer100g: 130.0,
      proteinPer100g: 2.7,
      fatPer100g: 0.3,
      carbsPer100g: 28.0,
      servingUnit: 'g',
      servingSize: 75.0,
    ),
    FoodItemModel(
      foodId: 8,
      name: 'Broccoli',
      brand: '',
      caloriesPer100g: 34.0,
      proteinPer100g: 2.8,
      fatPer100g: 0.4,
      carbsPer100g: 7.0,
      servingUnit: 'g',
      servingSize: 150.0,
    ),
  ];

  static final List<UserFoodLogModel> _foodLogs = <UserFoodLogModel>[];

  // Food Item Operations
  static Future<List<FoodItemModel>> searchFoodItems(String query) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (query.isEmpty) return [];
    
    return _mockFoodItems.where((food) => 
      food.name.toLowerCase().contains(query.toLowerCase()) ||
      food.brand.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  static Future<FoodItemModel?> getFoodItemById(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    try {
      return _mockFoodItems.firstWhere((food) => food.foodId == id);
    } catch (e) {
      return null;
    }
  }

  static Future<List<FoodItemModel>> getRecentFoodItems({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Get recently used food items from logs
    final recentIds = _foodLogs
        .map((log) => log.foodItemId)
        .where((id) => id != null)
        .take(limit)
        .toSet();
    
    return _mockFoodItems
        .where((food) => recentIds.contains(food.foodId))
        .toList();
  }

  static Future<List<FoodItemModel>> getPopularFoodItems({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Return first few items as "popular"
    return _mockFoodItems.take(limit).toList();
  }

  // Food Log Operations
  static Future<int> logFood(UserFoodLogModel foodLog) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final newId = _foodLogs.length + 1;
    final logWithId = foodLog.copyWith(
      logEntryId: newId,
      loggedAt: DateTime.now().toIso8601String(),
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    
    _foodLogs.add(logWithId);
    return newId;
  }

  static Future<List<UserFoodLogModel>> getFoodLogsForDate(
    int userId, 
    DateTime date,
  ) async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    final dateString = date.toIso8601String().split('T')[0];
    
    return _foodLogs.where((log) {
      final logDate = DateTime.parse(log.loggedAt).toIso8601String().split('T')[0];
      return log.userId == userId && logDate == dateString;
    }).toList();
  }

  static Future<List<UserFoodLogModel>> getFoodLogsForMeal(
    int userId,
    DateTime date,
    MealType mealType,
  ) async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    final dateString = date.toIso8601String().split('T')[0];
    
    return _foodLogs.where((log) {
      final logDate = DateTime.parse(log.loggedAt).toIso8601String().split('T')[0];
      return log.userId == userId && 
             logDate == dateString && 
             log.mealType == mealType;
    }).toList();
  }

  static Future<Map<String, double>> getDailyNutritionSummary(
    int userId,
    DateTime date,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final logs = await getFoodLogsForDate(userId, date);
    
    double totalCalories = 0;
    double totalProtein = 0;
    double totalFat = 0;
    double totalCarbs = 0;
    
    for (final log in logs) {
      totalCalories += log.calories;
      totalProtein += log.protein;
      totalFat += log.fat;
      totalCarbs += log.carbs;
    }
    
    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'fat': totalFat,
      'carbs': totalCarbs,
    };
  }

  static Future<bool> deleteFoodLog(int logEntryId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final index = _foodLogs.indexWhere((log) => log.logEntryId == logEntryId);
    if (index >= 0) {
      _foodLogs.removeAt(index);
      return true;
    }
    return false;
  }

  static Future<bool> updateFoodLog(UserFoodLogModel foodLog) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final index = _foodLogs.indexWhere((log) => log.logEntryId == foodLog.logEntryId);
    if (index >= 0) {
      _foodLogs[index] = foodLog.copyWith(
        updatedAt: DateTime.now().toIso8601String(),
      );
      return true;
    }
    return false;
  }

  // Get today's logged meals
  static Future<List<UserFoodLogModel>> getTodaysMeals() async {
    // Simulate delay for demo
    await Future.delayed(Duration(milliseconds: 500));
    
    // Filter logged meals for today
    final today = DateTime.now();
    final todayFormatted = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    return _foodLogs.where((meal) => 
      meal.loggedAt.startsWith(todayFormatted)
    ).toList();
  }

  // Clear all data (for demo/testing)
  static void clearAllData() {
    _foodLogs.clear();
  }

  static Future<void> deleteFood(int logEntryId) async {
    _foodLogs.removeWhere((meal) => meal.logEntryId == logEntryId);
  }

  static Future<void> updateFood(UserFoodLogModel updatedFoodLog) async {
    final index = _foodLogs.indexWhere((meal) => meal.logEntryId == updatedFoodLog.logEntryId);
    if (index != -1) {
      _foodLogs[index] = updatedFoodLog;
    }
  }
} 