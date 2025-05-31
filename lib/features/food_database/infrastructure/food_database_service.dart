import 'dart:convert';
import 'package:result_type/result_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/food_record_model.dart';
import '../domain/i_food_database_service.dart';

class FoodDatabaseService implements IFoodDatabaseService {
  static const String _storageKey = 'food_database';
  static const String _recentFoodsKey = 'recent_foods';
  
  List<FoodRecordModel> _foods = [];
  List<String> _recentFoodIds = [];
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load foods
      final foodsJson = prefs.getString(_storageKey);
      if (foodsJson != null) {
        final List<dynamic> foodsList = json.decode(foodsJson);
        _foods = foodsList.map((json) => FoodRecordModel.fromJson(json)).toList();
      } else {
        // Initialize with sample Danish foods
        _foods = _getSampleFoods();
        await _saveFoods();
      }
      
      // Load recent foods
      final recentJson = prefs.getString(_recentFoodsKey);
      if (recentJson != null) {
        final List<dynamic> recentList = json.decode(recentJson);
        _recentFoodIds = recentList.cast<String>();
      }
      
      _isInitialized = true;
      print('🍽️ FoodDatabaseService: Initialized with ${_foods.length} foods');
    } catch (e) {
      print('🍽️ FoodDatabaseService: Error initializing: $e');
      _foods = _getSampleFoods();
      _isInitialized = true;
    }
  }

  List<FoodRecordModel> _getSampleFoods() {
    return [
      // Breakfast items
      FoodRecordModel(
        id: 'havregryn',
        name: 'Havregryn',
        description: 'Almindelige havregryn, tørre',
        caloriesPer100g: 389,
        proteinPer100g: 16.9,
        carbsPer100g: 66.3,
        fatPer100g: 6.9,
        category: FoodCategory.breakfast,
        servingSizes: [
          const ServingSize(name: '1 dl', grams: 35.0, isDefault: true),
          const ServingSize(name: '1 kop', grams: 80.0, isDefault: false),
        ],
        createdAt: DateTime.now(),
      ),
      
      FoodRecordModel(
        id: 'skummetmaelk',
        name: 'Skummetmælk',
        description: 'Skummetmælk, 0.5% fedt',
        caloriesPer100g: 35,
        proteinPer100g: 3.4,
        carbsPer100g: 4.8,
        fatPer100g: 0.5,
        category: FoodCategory.drink,
        servingSizes: [
          const ServingSize(name: '1 glas', grams: 200.0, isDefault: true),
          const ServingSize(name: '1 dl', grams: 100.0, isDefault: false),
        ],
        createdAt: DateTime.now(),
      ),

      FoodRecordModel(
        id: 'rugbroed',
        name: 'Rugbrød',
        description: 'Dansk rugbrød, mørkt',
        caloriesPer100g: 259,
        proteinPer100g: 4.2,
        carbsPer100g: 48.3,
        fatPer100g: 3.3,
        category: FoodCategory.breakfast,
        servingSizes: [
          const ServingSize(name: '1 skive', grams: 37.0, isDefault: true),
          const ServingSize(name: '1 tynd skive', grams: 25.0, isDefault: false),
        ],
        createdAt: DateTime.now(),
      ),

      // Lunch items
      FoodRecordModel(
        id: 'kyllingebryst',
        name: 'Kyllingebryst',
        description: 'Grillet kyllingebryst uden skind',
        caloriesPer100g: 165,
        proteinPer100g: 31.0,
        carbsPer100g: 0.0,
        fatPer100g: 3.6,
        category: FoodCategory.lunch,
        servingSizes: [
          const ServingSize(name: '1 bryst', grams: 150.0, isDefault: true),
          const ServingSize(name: '1 portion', grams: 120.0, isDefault: false),
        ],
        createdAt: DateTime.now(),
      ),

      FoodRecordModel(
        id: 'ris',
        name: 'Ris',
        description: 'Kogt hvide ris',
        caloriesPer100g: 130,
        proteinPer100g: 2.7,
        carbsPer100g: 28.0,
        fatPer100g: 0.3,
        category: FoodCategory.lunch,
        servingSizes: [
          const ServingSize(name: '1 dl', grams: 80.0, isDefault: true),
          const ServingSize(name: '1 portion', grams: 150.0, isDefault: false),
        ],
        createdAt: DateTime.now(),
      ),

      FoodRecordModel(
        id: 'broccoli',
        name: 'Broccoli',
        description: 'Kogt broccoli',
        caloriesPer100g: 35,
        proteinPer100g: 2.8,
        carbsPer100g: 7.0,
        fatPer100g: 0.4,
        category: FoodCategory.lunch,
        servingSizes: [
          const ServingSize(name: '1 portion', grams: 100.0, isDefault: true),
          const ServingSize(name: '1 lille portion', grams: 75.0, isDefault: false),
        ],
        createdAt: DateTime.now(),
      ),

      // Dinner items
      FoodRecordModel(
        id: 'laks',
        name: 'Laks',
        description: 'Grillet laks',
        caloriesPer100g: 208,
        proteinPer100g: 25.4,
        carbsPer100g: 0.0,
        fatPer100g: 12.4,
        category: FoodCategory.dinner,
        servingSizes: [
          const ServingSize(name: '1 portion', grams: 125.0, isDefault: true),
          const ServingSize(name: '1 lille portion', grams: 100.0, isDefault: false),
        ],
        createdAt: DateTime.now(),
      ),

      FoodRecordModel(
        id: 'kartofler',
        name: 'Kartofler',
        description: 'Kogte kartofler',
        caloriesPer100g: 77,
        proteinPer100g: 2.0,
        carbsPer100g: 17.0,
        fatPer100g: 0.1,
        category: FoodCategory.dinner,
        servingSizes: [
          const ServingSize(name: '1 stor kartoffel', grams: 150.0, isDefault: true),
          const ServingSize(name: '1 lille kartoffel', grams: 100.0, isDefault: false),
          const ServingSize(name: '3 små kartofler', grams: 200.0, isDefault: false),
        ],
        createdAt: DateTime.now(),
      ),

      // Snacks
      FoodRecordModel(
        id: 'banan',
        name: 'Banan',
        description: 'Frisk banan',
        caloriesPer100g: 89,
        proteinPer100g: 1.1,
        carbsPer100g: 23.0,
        fatPer100g: 0.3,
        category: FoodCategory.snack,
        servingSizes: [
          const ServingSize(name: '1 banan', grams: 120.0, isDefault: true),
          const ServingSize(name: '1 lille banan', grams: 90.0, isDefault: false),
        ],
        createdAt: DateTime.now(),
      ),

      FoodRecordModel(
        id: 'aeble',
        name: 'Æble',
        description: 'Frisk æble med skræl',
        caloriesPer100g: 52,
        proteinPer100g: 0.3,
        carbsPer100g: 14.0,
        fatPer100g: 0.2,
        category: FoodCategory.snack,
        servingSizes: [
          const ServingSize(name: '1 æble', grams: 150.0, isDefault: true),
          const ServingSize(name: '1 lille æble', grams: 100.0, isDefault: false),
        ],
        createdAt: DateTime.now(),
      ),

      // Drinks
      FoodRecordModel(
        id: 'kaffe',
        name: 'Kaffe',
        description: 'Sort kaffe uden tilsætninger',
        caloriesPer100g: 2,
        proteinPer100g: 0.3,
        carbsPer100g: 0.0,
        fatPer100g: 0.0,
        category: FoodCategory.drink,
        servingSizes: [
          const ServingSize(name: '1 kop', grams: 200.0, isDefault: true),
          const ServingSize(name: '1 espresso', grams: 30.0, isDefault: false),
        ],
        createdAt: DateTime.now(),
      ),

      FoodRecordModel(
        id: 'vand',
        name: 'Vand',
        description: 'Almindeligt vand',
        caloriesPer100g: 0,
        proteinPer100g: 0.0,
        carbsPer100g: 0.0,
        fatPer100g: 0.0,
        category: FoodCategory.drink,
        servingSizes: [
          const ServingSize(name: '1 glas', grams: 200.0, isDefault: true),
          const ServingSize(name: '1 flaske', grams: 500.0, isDefault: false),
        ],
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<void> _saveFoods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final foodsJson = json.encode(_foods.map((food) => food.toJson()).toList());
      await prefs.setString(_storageKey, foodsJson);
    } catch (e) {
      print('🍽️ FoodDatabaseService: Error saving foods: $e');
    }
  }

  Future<void> _saveRecentFoods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentJson = json.encode(_recentFoodIds);
      await prefs.setString(_recentFoodsKey, recentJson);
    } catch (e) {
      print('🍽️ FoodDatabaseService: Error saving recent foods: $e');
    }
  }

  @override
  Future<Result<List<FoodRecordModel>, FoodDatabaseError>> getAllFoods() async {
    try {
      await _ensureInitialized();
      return Success(_foods);
    } catch (e) {
      print('🍽️ FoodDatabaseService: Error getting all foods: $e');
      return Failure(FoodDatabaseError.storage);
    }
  }

  @override
  Future<Result<List<FoodRecordModel>, FoodDatabaseError>> searchFoods(String query) async {
    try {
      await _ensureInitialized();
      
      if (query.trim().isEmpty) {
        return Success(_foods);
      }
      
      final lowerQuery = query.toLowerCase();
      final results = _foods.where((food) {
        return food.name.toLowerCase().contains(lowerQuery) ||
               food.description.toLowerCase().contains(lowerQuery);
      }).toList();
      
      return Success(results);
    } catch (e) {
      print('🍽️ FoodDatabaseService: Error searching foods: $e');
      return Failure(FoodDatabaseError.storage);
    }
  }

  @override
  Future<Result<List<FoodRecordModel>, FoodDatabaseError>> getFoodsByCategory(FoodCategory category) async {
    try {
      await _ensureInitialized();
      
      final results = _foods.where((food) => food.category == category).toList();
      return Success(results);
    } catch (e) {
      print('🍽️ FoodDatabaseService: Error getting foods by category: $e');
      return Failure(FoodDatabaseError.storage);
    }
  }

  @override
  Future<Result<FoodRecordModel, FoodDatabaseError>> getFoodById(String id) async {
    try {
      await _ensureInitialized();
      
      final food = _foods.firstWhere(
        (food) => food.id == id,
        orElse: () => throw Exception('Food not found'),
      );
      
      return Success(food);
    } catch (e) {
      print('🍽️ FoodDatabaseService: Food not found: $id');
      return Failure(FoodDatabaseError.notFound);
    }
  }

  @override
  Future<Result<FoodRecordModel, FoodDatabaseError>> addFood(FoodRecordModel food) async {
    try {
      await _ensureInitialized();
      
      // Check if food with same name already exists
      final existingFood = _foods.where((f) => f.name.toLowerCase() == food.name.toLowerCase()).firstOrNull;
      if (existingFood != null) {
        return Failure(FoodDatabaseError.alreadyExists);
      }
      
      // Generate ID if not provided
      final newFood = food.id.isEmpty 
          ? food.copyWith(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              createdAt: DateTime.now(),
            )
          : food.copyWith(createdAt: DateTime.now());
      
      _foods.add(newFood);
      await _saveFoods();
      
      print('🍽️ FoodDatabaseService: Added food: ${newFood.name}');
      return Success(newFood);
    } catch (e) {
      print('🍽️ FoodDatabaseService: Error adding food: $e');
      return Failure(FoodDatabaseError.storage);
    }
  }

  @override
  Future<Result<FoodRecordModel, FoodDatabaseError>> updateFood(FoodRecordModel food) async {
    try {
      await _ensureInitialized();
      
      final index = _foods.indexWhere((f) => f.id == food.id);
      if (index == -1) {
        return Failure(FoodDatabaseError.notFound);
      }
      
      _foods[index] = food;
      await _saveFoods();
      
      print('🍽️ FoodDatabaseService: Updated food: ${food.name}');
      return Success(food);
    } catch (e) {
      print('🍽️ FoodDatabaseService: Error updating food: $e');
      return Failure(FoodDatabaseError.storage);
    }
  }

  @override
  Future<Result<void, FoodDatabaseError>> deleteFood(String id) async {
    try {
      await _ensureInitialized();
      
      final index = _foods.indexWhere((f) => f.id == id);
      if (index == -1) {
        return Failure(FoodDatabaseError.notFound);
      }
      
      final removedFood = _foods.removeAt(index);
      
      // Remove from recent foods if present
      _recentFoodIds.remove(id);
      
      await _saveFoods();
      await _saveRecentFoods();
      
      print('🍽️ FoodDatabaseService: Deleted food: ${removedFood.name}');
      return Success(null);
    } catch (e) {
      print('🍽️ FoodDatabaseService: Error deleting food: $e');
      return Failure(FoodDatabaseError.storage);
    }
  }

  @override
  Future<Result<List<FoodRecordModel>, FoodDatabaseError>> getRecentFoods({int limit = 10}) async {
    try {
      await _ensureInitialized();
      
      final recentFoods = <FoodRecordModel>[];
      
      for (final id in _recentFoodIds.take(limit)) {
        final food = _foods.where((f) => f.id == id).firstOrNull;
        if (food != null) {
          recentFoods.add(food);
        }
      }
      
      return Success(recentFoods);
    } catch (e) {
      print('🍽️ FoodDatabaseService: Error getting recent foods: $e');
      return Failure(FoodDatabaseError.storage);
    }
  }

  @override
  Future<Result<void, FoodDatabaseError>> addToRecentFoods(String foodId) async {
    try {
      await _ensureInitialized();
      
      // Remove if already exists
      _recentFoodIds.remove(foodId);
      
      // Add to beginning
      _recentFoodIds.insert(0, foodId);
      
      // Keep only last 20 items
      if (_recentFoodIds.length > 20) {
        _recentFoodIds = _recentFoodIds.take(20).toList();
      }
      
      await _saveRecentFoods();
      return Success(null);
    } catch (e) {
      print('🍽️ FoodDatabaseService: Error adding to recent foods: $e');
      return Failure(FoodDatabaseError.storage);
    }
  }

  @override
  Future<Result<List<FoodRecordModel>, FoodDatabaseError>> findMatches(String foodName, {double threshold = 0.6}) async {
    try {
      await _ensureInitialized();
      
      final lowerFoodName = foodName.toLowerCase();
      final matches = <FoodRecordModel>[];
      
      for (final food in _foods) {
        final lowerName = food.name.toLowerCase();
        final lowerDescription = food.description.toLowerCase();
        
        // Simple fuzzy matching - check if food name contains the search term or vice versa
        if (lowerName.contains(lowerFoodName) || lowerFoodName.contains(lowerName) ||
            lowerDescription.contains(lowerFoodName)) {
          matches.add(food);
        }
      }
      
      // Sort by name length (closer matches first)
      matches.sort((a, b) => a.name.length.compareTo(b.name.length));
      
      return Success(matches);
    } catch (e) {
      print('🍽️ FoodDatabaseService: Error finding matches: $e');
      return Failure(FoodDatabaseError.storage);
    }
  }

  @override
  Future<Result<void, FoodDatabaseError>> seedDatabase() async {
    try {
      await _ensureInitialized();
      
      // Only seed if database is empty
      if (_foods.isEmpty) {
        _foods = _getSampleFoods();
        await _saveFoods();
        print('🍽️ FoodDatabaseService: Seeded database with ${_foods.length} foods');
      } else {
        print('🍽️ FoodDatabaseService: Database already has ${_foods.length} foods, skipping seed');
      }
      
      return Success(null);
    } catch (e) {
      print('🍽️ FoodDatabaseService: Error seeding database: $e');
      return Failure(FoodDatabaseError.storage);
    }
  }
} 