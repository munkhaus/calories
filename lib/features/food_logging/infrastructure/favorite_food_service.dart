import 'package:result_type/result_type.dart';
import '../domain/i_favorite_food_service.dart';
import '../domain/favorite_food_model.dart';
import '../domain/user_food_log_model.dart';
import '../../food_database/domain/online_food_models.dart';
import '../../../core/infrastructure/storage_service.dart';

/// Implementation of comprehensive favorite food service 
/// Now serves as the primary food storage and search system
class FavoriteFoodService implements IFavoriteFoodService {
  // Static list to simulate database storage
  static List<FavoriteFoodModel> _favorites = [];
  static bool _isInitialized = false;
  
  /// Initialize service and load persisted data
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    _favorites = await StorageService.loadList(
      StorageService.favoriteFoodsKey,
      FavoriteFoodModel.fromJson,
    );
    
    _isInitialized = true;
    print('⭐ FavoriteFoodService: Loaded ${_favorites.length} favorites from storage');
  }
  
  /// Save favorites to persistent storage
  static Future<void> _saveFavorites() async {
    final success = await StorageService.saveList(
      StorageService.favoriteFoodsKey,
      _favorites,
      (favorite) => favorite.toJson(),
    );
    
    if (success) {
      print('⭐ FavoriteFoodService: Saved ${_favorites.length} favorites to storage');
    } else {
      print('❌ FavoriteFoodService: Failed to save favorites');
    }
  }

  @override
  Future<Result<List<FavoriteFoodModel>, FavoriteFoodError>> getAllFavorites() async {
    await initialize();
    
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Sort by name for consistency
      final sortedFavorites = List<FavoriteFoodModel>.from(_favorites)
        ..sort((a, b) => a.foodName.compareTo(b.foodName));
      
      print('⭐ FavoriteFoodService: getAllFavorites() returning ${sortedFavorites.length} items');
      return Success(sortedFavorites);
    } catch (e) {
      print('⭐ FavoriteFoodService: getAllFavorites() error: $e');
      return Failure(FavoriteFoodError.database);
    }
  }

  @override
  Future<Result<List<FavoriteFoodModel>, FavoriteFoodError>> searchFavorites(String query) async {
    await initialize();
    
    if (query.trim().isEmpty) {
      return getAllFavorites();
    }
    
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      final lowerQuery = query.toLowerCase();
      final queryTerms = lowerQuery.split(' ').where((term) => term.isNotEmpty).toList();
      
      final results = _favorites.where((favorite) {
        final name = favorite.foodName.toLowerCase();
        final description = favorite.description.toLowerCase();
        final tags = favorite.tags.map((tag) => tag.toLowerCase()).join(' ');
        
        // Check if all query terms match somewhere
        return queryTerms.every((term) =>
          name.contains(term) ||
          description.contains(term) ||
          tags.contains(term)
        );
      }).toList();
      
      // Sort by relevance (name matches first, then description, then tags)
      results.sort((a, b) {
        final aName = a.foodName.toLowerCase();
        final bName = b.foodName.toLowerCase();
        
        final aStartsWithQuery = aName.startsWith(lowerQuery);
        final bStartsWithQuery = bName.startsWith(lowerQuery);
        
        if (aStartsWithQuery && !bStartsWithQuery) return -1;
        if (!aStartsWithQuery && bStartsWithQuery) return 1;
        
        final aContainsQuery = aName.contains(lowerQuery);
        final bContainsQuery = bName.contains(lowerQuery);
        
        if (aContainsQuery && !bContainsQuery) return -1;
        if (!aContainsQuery && bContainsQuery) return 1;
        
        // Sort by usage count if relevance is equal
        return b.usageCount.compareTo(a.usageCount);
      });
      
      print('⭐ FavoriteFoodService: searchFavorites("$query") returning ${results.length} items');
      return Success(results);
    } catch (e) {
      print('⭐ FavoriteFoodService: searchFavorites() error: $e');
      return Failure(FavoriteFoodError.database);
    }
  }

  @override
  Future<Result<List<FavoriteFoodModel>, FavoriteFoodError>> getRecentFavorites({int limit = 20}) async {
    await initialize();
    
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Sort by most recently used first
      final sortedFavorites = List<FavoriteFoodModel>.from(_favorites)
        ..sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
      
      final result = sortedFavorites.take(limit).toList();
      print('⭐ FavoriteFoodService: getRecentFavorites() returning ${result.length} items');
      return Success(result);
    } catch (e) {
      print('⭐ FavoriteFoodService: getRecentFavorites() error: $e');
      return Failure(FavoriteFoodError.database);
    }
  }

  @override
  Future<Result<List<FavoriteFoodModel>, FavoriteFoodError>> getMostUsedFavorites({int limit = 10}) async {
    await initialize();
    
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Sort by usage count (descending) then by last used (descending)
      final mostUsed = List<FavoriteFoodModel>.from(_favorites)
        ..sort((a, b) {
          final usageComparison = b.usageCount.compareTo(a.usageCount);
          if (usageComparison != 0) return usageComparison;
          return b.lastUsed.compareTo(a.lastUsed);
        });
      
      final result = mostUsed.take(limit).toList();
      print('⭐ FavoriteFoodService: getMostUsedFavorites() returning ${result.length} items');
      return Success(result);
    } catch (e) {
      print('⭐ FavoriteFoodService: getMostUsedFavorites() error: $e');
      return Failure(FavoriteFoodError.database);
    }
  }

  @override
  Future<Result<List<FavoriteFoodModel>, FavoriteFoodError>> getFavoritesByMealType(MealType mealType) async {
    await initialize();
    
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      final filtered = _favorites.where((favorite) => 
        favorite.preferredMealType == mealType
      ).toList();
      
      // Sort by usage for this meal type
      filtered.sort((a, b) => b.usageCount.compareTo(a.usageCount));
      
      print('⭐ FavoriteFoodService: getFavoritesByMealType($mealType) returning ${filtered.length} items');
      return Success(filtered);
    } catch (e) {
      print('⭐ FavoriteFoodService: getFavoritesByMealType() error: $e');
      return Failure(FavoriteFoodError.database);
    }
  }

  @override
  Future<Result<FavoriteFoodModel, FavoriteFoodError>> getFavoriteById(String id) async {
    await initialize();
    
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      final favorite = _favorites.firstWhere(
        (f) => f.id == id,
        orElse: () => throw StateError('Not found'),
      );
      
      print('⭐ FavoriteFoodService: getFavoriteById($id) found: ${favorite.foodName}');
      return Success(favorite);
    } catch (e) {
      print('⭐ FavoriteFoodService: getFavoriteById($id) not found');
      return Failure(FavoriteFoodError.notFound);
    }
  }

  @override
  Future<Result<FavoriteFoodModel, FavoriteFoodError>> addToFavorites(FavoriteFoodModel favorite) async {
    await initialize();
    
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Validate input
      if (favorite.foodName.trim().isEmpty) {
        return Failure(FavoriteFoodError.validation);
      }
      
      // Check if already exists (same name and similar calories)
      final exists = await isFavorite(favorite.foodName, favorite.caloriesPer100g);
      if (exists) {
        return Failure(FavoriteFoodError.alreadyExists);
      }
      
      // Add to favorites
      _favorites.add(favorite);
      await _saveFavorites();
      
      print('⭐ FavoriteFoodService: Added favorite: ${favorite.foodName}');
      return Success(favorite);
    } catch (e) {
      print('⭐ FavoriteFoodService: addToFavorites() error: $e');
      return Failure(FavoriteFoodError.unknown);
    }
  }

  @override
  Future<Result<FavoriteFoodModel, FavoriteFoodError>> addOnlineFoodToFavorites(
    OnlineFoodDetails details, {
    MealType? preferredMealType,
    double? preferredQuantity,
    String? preferredServingUnit,
  }) async {
    try {
      final favorite = FavoriteFoodModel.fromOnlineFoodDetails(
        details,
        preferredMealType: preferredMealType,
        preferredQuantity: preferredQuantity,
        preferredServingUnit: preferredServingUnit,
      );
      
      return await addToFavorites(favorite);
    } catch (e) {
      print('⭐ FavoriteFoodService: addOnlineFoodToFavorites() error: $e');
      return Failure(FavoriteFoodError.validation);
    }
  }

  @override
  Future<Result<FavoriteFoodModel, FavoriteFoodError>> updateFavorite(FavoriteFoodModel favorite) async {
    await initialize();
    
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      final index = _favorites.indexWhere((f) => f.id == favorite.id);
      if (index == -1) {
        return Failure(FavoriteFoodError.notFound);
      }
      
      _favorites[index] = favorite;
      await _saveFavorites();
      
      print('⭐ FavoriteFoodService: Updated favorite: ${favorite.foodName}');
      return Success(favorite);
    } catch (e) {
      print('⭐ FavoriteFoodService: updateFavorite() error: $e');
      return Failure(FavoriteFoodError.unknown);
    }
  }

  @override
  Future<Result<FavoriteFoodModel, FavoriteFoodError>> incrementFavoriteUsage(String id) async {
    await initialize();
    
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      final index = _favorites.indexWhere((f) => f.id == id);
      if (index == -1) {
        return Failure(FavoriteFoodError.notFound);
      }
      
      final updated = _favorites[index].withUpdatedUsage();
      _favorites[index] = updated;
      await _saveFavorites();
      
      print('⭐ FavoriteFoodService: Incremented usage for: ${updated.foodName} (count: ${updated.usageCount})');
      return Success(updated);
    } catch (e) {
      print('⭐ FavoriteFoodService: incrementFavoriteUsage() error: $e');
      return Failure(FavoriteFoodError.unknown);
    }
  }

  @override
  Future<Result<bool, FavoriteFoodError>> removeFromFavorites(String id) async {
    await initialize();
    
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      final index = _favorites.indexWhere((f) => f.id == id);
      if (index == -1) {
        return Failure(FavoriteFoodError.notFound);
      }
      
      final removed = _favorites.removeAt(index);
      await _saveFavorites();
      
      print('⭐ FavoriteFoodService: Removed favorite: ${removed.foodName}');
      return Success(true);
    } catch (e) {
      print('⭐ FavoriteFoodService: removeFromFavorites() error: $e');
      return Failure(FavoriteFoodError.unknown);
    }
  }

  @override
  Future<bool> isFavorite(String foodName, int caloriesPer100g) async {
    await initialize();
    
    try {
      await Future.delayed(const Duration(milliseconds: 25));
      
      // Check if similar favorite exists (same name, calories within 10% range)
      final exists = _favorites.any((favorite) =>
          favorite.foodName.toLowerCase() == foodName.toLowerCase() &&
          (favorite.caloriesPer100g - caloriesPer100g).abs() <= (caloriesPer100g * 0.1));
      
      return exists;
    } catch (e) {
      print('⭐ FavoriteFoodService: isFavorite() error: $e');
      return false;
    }
  }

  @override
  Future<bool> favoriteExists(String id) async {
    await initialize();
    
    try {
      await Future.delayed(const Duration(milliseconds: 25));
      
      return _favorites.any((f) => f.id == id);
    } catch (e) {
      print('⭐ FavoriteFoodService: favoriteExists() error: $e');
      return false;
    }
  }

  @override
  Future<Result<List<FavoriteFoodModel>, FavoriteFoodError>> findSimilarFavorites(String foodName, {double threshold = 0.6}) async {
    await initialize();
    
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      final lowerFoodName = foodName.toLowerCase();
      final matches = <FavoriteFoodModel>[];
      
      for (final favorite in _favorites) {
        final lowerName = favorite.foodName.toLowerCase();
        final lowerDescription = favorite.description.toLowerCase();
        
        // Simple fuzzy matching - check if food name contains the search term or vice versa
        if (lowerName.contains(lowerFoodName) || 
            lowerFoodName.contains(lowerName) ||
            lowerDescription.contains(lowerFoodName)) {
          matches.add(favorite);
        }
      }
      
      // Sort by name length (closer matches first)
      matches.sort((a, b) => a.foodName.length.compareTo(b.foodName.length));
      
      print('⭐ FavoriteFoodService: findSimilarFavorites("$foodName") found ${matches.length} matches');
      return Success(matches);
    } catch (e) {
      print('⭐ FavoriteFoodService: findSimilarFavorites() error: $e');
      return Failure(FavoriteFoodError.database);
    }
  }

  @override
  Future<Result<void, FavoriteFoodError>> clearAllFavorites() async {
    await initialize();
    
    try {
      _favorites.clear();
      await _saveFavorites();
      
      print('⭐ FavoriteFoodService: Cleared all favorites');
      return Success(null);
    } catch (e) {
      print('⭐ FavoriteFoodService: clearAllFavorites() error: $e');
      return Failure(FavoriteFoodError.unknown);
    }
  }

  @override
  Future<Result<List<FavoriteFoodModel>, FavoriteFoodError>> getQuickSuggestions({int limit = 5}) async {
    await initialize();
    
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      final now = DateTime.now();
      final hour = now.hour;
      
      // Determine suggested meal type based on time of day
      MealType suggestedMealType;
      if (hour >= 6 && hour < 11) {
        suggestedMealType = MealType.morgenmad;
      } else if (hour >= 11 && hour < 14) {
        suggestedMealType = MealType.frokost;
      } else if (hour >= 17 && hour < 21) {
        suggestedMealType = MealType.aftensmad;
      } else {
        suggestedMealType = MealType.snack;
      }
      
      // Get favorites for this meal type
      var suggestions = _favorites.where((f) => 
        f.preferredMealType == suggestedMealType
      ).toList();
      
      // If not enough for this meal type, add some recent favorites
      if (suggestions.length < limit) {
        final recent = _favorites.where((f) => 
          f.preferredMealType != suggestedMealType
        ).toList()..sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
        
        suggestions.addAll(recent.take(limit - suggestions.length));
      }
      
      // Sort by usage count and take limit
      suggestions.sort((a, b) => b.usageCount.compareTo(a.usageCount));
      final result = suggestions.take(limit).toList();
      
      print('⭐ FavoriteFoodService: getQuickSuggestions() for $suggestedMealType returning ${result.length} items');
      return Success(result);
    } catch (e) {
      print('⭐ FavoriteFoodService: getQuickSuggestions() error: $e');
      return Failure(FavoriteFoodError.database);
    }
  }

  /// Static methods for testing and initialization
  
  /// Clear all favorites (for testing)
  static void clearAllFavoritesStatic() {
    _favorites.clear();
    _saveFavorites();
    print('⭐ FavoriteFoodService: Cleared all favorites (static)');
  }

  /// Add test favorites for demonstration
  static void addTestFavorites() async {
    await initialize();
    
    // Only add test favorites if there are no existing favorites
    if (_favorites.isNotEmpty) {
      print('⭐ FavoriteFoodService: Favorites already exist, skipping test data');
      return;
    }
    
    final testFavorites = [
      FavoriteFoodModel(
        id: 'test_1',
        foodName: 'Spaghetti Bolognese',
        description: 'Klassisk italiensk pastarett med kødsovs',
        preferredMealType: MealType.aftensmad,
        caloriesPer100g: 150,
        proteinPer100g: 8.0,
        fatPer100g: 5.0,
        carbsPer100g: 20.0,
        defaultQuantity: 1.0,
        defaultServingUnit: 'portion',
        defaultServingGrams: 350.0,
        source: FoodSource.userCreated,
        tags: ['Pasta', 'Italiensk', 'Kød'],
        createdAt: DateTime.now().subtract(Duration(days: 10)),
        lastUsed: DateTime.now().subtract(Duration(days: 2)),
        usageCount: 8,
        servingSizes: [
          FavoriteServingSize(name: 'portion', grams: 350.0, isDefault: true),
          FavoriteServingSize(name: 'lille portion', grams: 250.0),
          FavoriteServingSize(name: 'stor portion', grams: 450.0),
        ],
      ),
      FavoriteFoodModel(
        id: 'test_2',
        foodName: 'Grøntsagssalat med kylling',
        description: 'Frisk salat med grillet kylling og blandede grøntsager',
        preferredMealType: MealType.frokost,
        caloriesPer100g: 120,
        proteinPer100g: 15.0,
        fatPer100g: 4.0,
        carbsPer100g: 8.0,
        defaultQuantity: 1.0,
        defaultServingUnit: 'skål',
        defaultServingGrams: 200.0,
        source: FoodSource.userCreated,
        tags: ['Salat', 'Kylling', 'Sund'],
        createdAt: DateTime.now().subtract(Duration(days: 15)),
        lastUsed: DateTime.now().subtract(Duration(days: 1)),
        usageCount: 12,
        servingSizes: [
          FavoriteServingSize(name: 'skål', grams: 200.0, isDefault: true),
          FavoriteServingSize(name: 'lille skål', grams: 150.0),
          FavoriteServingSize(name: 'stor skål', grams: 300.0),
        ],
      ),
      FavoriteFoodModel(
        id: 'test_3',
        foodName: 'Havregrød med blåbær',
        description: 'Varm havregrød toppet med friske blåbær',
        preferredMealType: MealType.morgenmad,
        caloriesPer100g: 90,
        proteinPer100g: 3.0,
        fatPer100g: 2.0,
        carbsPer100g: 16.0,
        defaultQuantity: 1.0,
        defaultServingUnit: 'skål',
        defaultServingGrams: 250.0,
        source: FoodSource.userCreated,
        tags: ['Havregrød', 'Bær', 'Morgenmad'],
        createdAt: DateTime.now().subtract(Duration(days: 20)),
        lastUsed: DateTime.now().subtract(Duration(days: 3)),
        usageCount: 15,
        servingSizes: [
          FavoriteServingSize(name: 'skål', grams: 250.0, isDefault: true),
          FavoriteServingSize(name: 'lille skål', grams: 180.0),
          FavoriteServingSize(name: 'stor skål', grams: 350.0),
        ],
      ),
    ];
    
    _favorites.addAll(testFavorites);
    await _saveFavorites();
    
    print('⭐ FavoriteFoodService: Added ${testFavorites.length} test favorites');
  }
} 