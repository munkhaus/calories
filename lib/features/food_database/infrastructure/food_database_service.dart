import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:result_type/result_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/food_record_model.dart';
import '../domain/i_food_database_service.dart';
import '../domain/online_food_models.dart';

class FoodDatabaseService implements IFoodDatabaseService {
  static FoodDatabaseService? _instance;
  
  // Singleton pattern
  factory FoodDatabaseService() {
    _instance ??= FoodDatabaseService._internal();
    return _instance!;
  }
  
  FoodDatabaseService._internal();

  static const String _storageKey = 'food_database';
  static const String _recentFoodsKey = 'recent_foods';
  
  List<FoodRecordModel> _foods = [];
  List<String> _recentFoodIds = [];
  bool _isInitialized = false;
  
  // Callback for when foods are added/updated/deleted
  VoidCallback? _onDataChanged;

  /// Set callback to be called when data changes
  void setOnDataChanged(VoidCallback? callback) {
    _onDataChanged = callback;
  }
  
  /// Notify that data has changed
  void _notifyDataChanged() {
    _onDataChanged?.call();
  }

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
    // Return empty list - no automatic sample foods
    // Users can add their own foods or search online
    return [];
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
      
      final results = _performAdvancedSearch(query);
      return Success(results);
    } catch (e) {
      print('🍽️ FoodDatabaseService: Error searching foods: $e');
      return Failure(FoodDatabaseError.storage);
    }
  }

  List<FoodRecordModel> _performAdvancedSearch(String query) {
    final lowerQuery = query.toLowerCase().trim();
    final queryTerms = lowerQuery.split(' ').where((term) => term.isNotEmpty).toList();
    
    final scoredResults = <FoodRecordModel, double>{};
    
    for (final food in _foods) {
      final score = _calculateFoodScore(food, queryTerms, lowerQuery);
      if (score > 0) {
        scoredResults[food] = score;
      }
    }
    
    // Sort by score (highest first)
    final sortedResults = scoredResults.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedResults.map((entry) => entry.key).toList();
  }

  double _calculateFoodScore(FoodRecordModel food, List<String> queryTerms, String fullQuery) {
    double score = 0.0;
    final foodName = food.name.toLowerCase();
    final foodDescription = food.description.toLowerCase();
    final foodType = FoodImageHelper.getFoodType(food.name);
    final categoryName = _getCategoryDisplayName(food.category).toLowerCase();
    
    // Tags for this food item
    final foodTags = _generateFoodTags(food);
    
    // 1. Exact name match (highest priority)
    if (foodName == fullQuery) {
      score += 100.0;
    }
    
    // 2. Name starts with query
    else if (foodName.startsWith(fullQuery)) {
      score += 80.0;
    }
    
    // 3. Name contains full query
    else if (foodName.contains(fullQuery)) {
      score += 60.0;
    }
    
    // 4. Check individual terms against name and description
    for (final term in queryTerms) {
      if (foodName.contains(term)) {
        score += 40.0;
      }
      if (foodDescription.contains(term)) {
        score += 20.0;
      }
    }
    
    // 5. Tag-based scoring
    for (final term in queryTerms) {
      // Check food type tags
      if (foodType.displayName.toLowerCase().contains(term)) {
        score += 50.0;
      }
      
      // Check category tags
      if (categoryName.contains(term)) {
        score += 45.0;
      }
      
      // Check custom food tags
      for (final tag in foodTags) {
        if (tag.toLowerCase().contains(term)) {
          score += 35.0;
        }
      }
    }
    
    // 6. Meal time matching
    for (final term in queryTerms) {
      if (_isMealTimeKeyword(term)) {
        final mealCategory = _getMealCategoryFromKeyword(term);
        if (mealCategory == food.category) {
          score += 30.0;
        }
      }
    }
    
    // 7. Fuzzy matching bonus for partial matches
    for (final term in queryTerms) {
      if (term.length >= 3) {
        if (_fuzzyMatch(foodName, term)) {
          score += 15.0;
        }
        if (_fuzzyMatch(foodDescription, term)) {
          score += 10.0;
        }
      }
    }
    
    return score;
  }

  List<String> _generateFoodTags(FoodRecordModel food) {
    final tags = <String>[];
    final name = food.name.toLowerCase();
    
    // Ingredient-based tags
    if (name.contains('æble')) tags.addAll(['frugt', 'vitamin', 'fiber']);
    if (name.contains('banan')) tags.addAll(['frugt', 'kalium', 'energi']);
    if (name.contains('brød')) tags.addAll(['kulhydrat', 'fiber', 'morgenmad']);
    if (name.contains('ris')) tags.addAll(['kulhydrat', 'basis', 'frokost', 'aftensmad']);
    if (name.contains('pasta')) tags.addAll(['kulhydrat', 'italiensk', 'aftensmad']);
    if (name.contains('kylling')) tags.addAll(['protein', 'magert', 'frokost', 'aftensmad']);
    if (name.contains('laks')) tags.addAll(['protein', 'omega3', 'fisk', 'aftensmad']);
    if (name.contains('yoghurt')) tags.addAll(['protein', 'probiotika', 'morgenmad', 'snack']);
    if (name.contains('ost')) tags.addAll(['protein', 'calcium', 'fedt']);
    if (name.contains('salat')) tags.addAll(['grøntsager', 'fiber', 'vitaminer', 'frokost']);
    if (name.contains('kartoffel')) tags.addAll(['kulhydrat', 'kalium', 'aftensmad']);
    if (name.contains('tomat')) tags.addAll(['grøntsager', 'lycopin', 'vitamin']);
    if (name.contains('gulerod')) tags.addAll(['grøntsager', 'betacaroten', 'fiber']);
    
    // Preparation method tags
    if (name.contains('grillet')) tags.add('grillet');
    if (name.contains('kogt')) tags.add('kogt');
    if (name.contains('bagt')) tags.add('bagt');
    if (name.contains('stegt')) tags.add('stegt');
    
    // Meal timing tags
    if (name.contains('morgenmad') || name.contains('müsli') || name.contains('havre')) {
      tags.add('morgenmad');
    }
    
    return tags;
  }

  String _getCategoryDisplayName(FoodCategory category) {
    switch (category) {
      case FoodCategory.breakfast:
        return 'Morgenmad';
      case FoodCategory.lunch:
        return 'Frokost';
      case FoodCategory.dinner:
        return 'Aftensmad';
      case FoodCategory.snack:
        return 'Snack';
      case FoodCategory.dessert:
        return 'Dessert';
      case FoodCategory.drink:
        return 'Drikkevare';
      case FoodCategory.other:
        return 'Andet';
    }
  }

  bool _isMealTimeKeyword(String term) {
    final mealKeywords = [
      'morgenmad', 'morgen', 'breakfast',
      'frokost', 'lunch', 'middag',
      'aftensmad', 'aften', 'dinner',
      'snack', 'mellemmåltid'
    ];
    return mealKeywords.contains(term);
  }

  FoodCategory? _getMealCategoryFromKeyword(String term) {
    switch (term) {
      case 'morgenmad':
      case 'morgen':
      case 'breakfast':
        return FoodCategory.breakfast;
      case 'frokost':
      case 'lunch':
      case 'middag':
        return FoodCategory.lunch;
      case 'aftensmad':
      case 'aften':
      case 'dinner':
        return FoodCategory.dinner;
      case 'snack':
      case 'mellemmåltid':
        return FoodCategory.snack;
      default:
        return null;
    }
  }

  bool _fuzzyMatch(String text, String pattern) {
    if (pattern.length > text.length) return false;
    
    int textIndex = 0;
    for (int i = 0; i < pattern.length; i++) {
      while (textIndex < text.length && text[textIndex] != pattern[i]) {
        textIndex++;
      }
      if (textIndex >= text.length) return false;
      textIndex++;
    }
    return true;
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
      
      // Check if food with same name already exists (case insensitive)
      final existingByName = _foods.where((f) => f.name.toLowerCase() == food.name.toLowerCase()).toList();
      if (existingByName.isNotEmpty) {
        return Failure(FoodDatabaseError.alreadyExists);
      }
      
      // Check if food with same ID already exists
      final existingById = _foods.where((f) => f.id == food.id).toList();
      if (existingById.isNotEmpty) {
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
      _notifyDataChanged(); // Notify UI of changes
      
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
      _notifyDataChanged(); // Notify UI of changes
      
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
      
      _foods.removeWhere((food) => food.id == id);
      await _saveFoods();
      _notifyDataChanged(); // Notify UI of changes
      
      return Success(null);
    } catch (e) {
      print('🍽️ FoodDatabaseService: Error deleting food: $e');
      return Failure(FoodDatabaseError.storage);
    }
  }

  @override
  Future<Result<void, FoodDatabaseError>> clearAllFoods() async {
    try {
      await _ensureInitialized();
      
      final foodCount = _foods.length;
      _foods.clear();
      _recentFoodIds.clear();
      
      await _saveFoods();
      await _saveRecentFoods();
      _notifyDataChanged(); // Notify UI of changes
      
      print('🍽️ FoodDatabaseService: Cleared all $foodCount foods from database');
      return Success(null);
    } catch (e) {
      print('🍽️ FoodDatabaseService: Error clearing all foods: $e');
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