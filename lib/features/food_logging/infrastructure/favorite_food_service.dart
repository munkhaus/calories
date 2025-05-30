import 'package:result_type/result_type.dart';
import '../domain/i_favorite_food_service.dart';
import '../domain/favorite_food_model.dart';
import '../domain/user_food_log_model.dart';

/// Implementation of favorite food service with in-memory storage
class FavoriteFoodService implements IFavoriteFoodService {
  // Static list to simulate database storage
  static final List<FavoriteFoodModel> _favorites = [];

  @override
  Future<Result<List<FavoriteFoodModel>, FavoriteFoodError>> getFavorites() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Sort by most recently used first
      final sortedFavorites = List<FavoriteFoodModel>.from(_favorites)
        ..sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
      
      print('⭐ FavoriteFoodService: getFavorites() returning ${sortedFavorites.length} items');
      return Success(sortedFavorites);
    } catch (e) {
      print('⭐ FavoriteFoodService: getFavorites() error: $e');
      return Failure(FavoriteFoodError.database);
    }
  }

  @override
  Future<Result<FavoriteFoodModel, FavoriteFoodError>> addToFavorites(FavoriteFoodModel favorite) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Validate input
      if (favorite.foodName.trim().isEmpty) {
        return Failure(FavoriteFoodError.validation);
      }
      
      // Check if already exists (same name and similar calories)
      final exists = await isFavorite(favorite.foodName, favorite.calories);
      if (exists) {
        return Failure(FavoriteFoodError.alreadyExists);
      }
      
      // Add to favorites
      _favorites.add(favorite);
      
      print('⭐ FavoriteFoodService: Added favorite: ${favorite.foodName}');
      return Success(favorite);
    } catch (e) {
      print('⭐ FavoriteFoodService: addToFavorites() error: $e');
      return Failure(FavoriteFoodError.unknown);
    }
  }

  @override
  Future<Result<bool, FavoriteFoodError>> removeFromFavorites(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final index = _favorites.indexWhere((favorite) => favorite.id == id);
      if (index == -1) {
        return Failure(FavoriteFoodError.notFound);
      }
      
      final removed = _favorites.removeAt(index);
      print('⭐ FavoriteFoodService: Removed favorite: ${removed.foodName}');
      return Success(true);
    } catch (e) {
      print('⭐ FavoriteFoodService: removeFromFavorites() error: $e');
      return Failure(FavoriteFoodError.unknown);
    }
  }

  @override
  Future<Result<FavoriteFoodModel, FavoriteFoodError>> updateFavorite(FavoriteFoodModel favorite) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final index = _favorites.indexWhere((item) => item.id == favorite.id);
      if (index == -1) {
        return Failure(FavoriteFoodError.notFound);
      }
      
      _favorites[index] = favorite;
      print('⭐ FavoriteFoodService: Updated favorite: ${favorite.foodName}');
      return Success(favorite);
    } catch (e) {
      print('⭐ FavoriteFoodService: updateFavorite() error: $e');
      return Failure(FavoriteFoodError.unknown);
    }
  }

  @override
  Future<bool> isFavorite(String foodName, int calories) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Check if similar favorite exists (same name, calories within 10% range)
      final exists = _favorites.any((favorite) =>
          favorite.foodName.toLowerCase() == foodName.toLowerCase() &&
          (favorite.calories - calories).abs() <= (calories * 0.1));
      
      return exists;
    } catch (e) {
      print('⭐ FavoriteFoodService: isFavorite() error: $e');
      return false;
    }
  }

  @override
  Future<Result<List<FavoriteFoodModel>, FavoriteFoodError>> getMostUsedFavorites({int limit = 10}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
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

  /// Clear all favorites (for testing)
  static void clearAllFavorites() {
    _favorites.clear();
    print('⭐ FavoriteFoodService: Cleared all favorites');
  }

  /// Add test favorites for demonstration
  static void addTestFavorites() {
    final testFavorites = [
      FavoriteFoodModel(
        id: 'test_1',
        foodName: 'Spaghetti Bolognese',
        mealType: MealType.aftensmad,
        calories: 580,
        protein: 25.0,
        fat: 18.0,
        carbs: 75.0,
        quantity: 1.0,
        servingUnit: 'portion',
        createdAt: DateTime.now().subtract(Duration(days: 10)),
        lastUsed: DateTime.now().subtract(Duration(days: 2)),
        usageCount: 8,
      ),
      FavoriteFoodModel(
        id: 'test_2',
        foodName: 'Grøntsagssalat med kylling',
        mealType: MealType.frokost,
        calories: 320,
        protein: 30.0,
        fat: 12.0,
        carbs: 15.0,
        quantity: 1.0,
        servingUnit: 'portion',
        createdAt: DateTime.now().subtract(Duration(days: 15)),
        lastUsed: DateTime.now().subtract(Duration(days: 1)),
        usageCount: 12,
      ),
      FavoriteFoodModel(
        id: 'test_3',
        foodName: 'Havregrød med blåbær',
        mealType: MealType.morgenmad,
        calories: 280,
        protein: 8.0,
        fat: 6.0,
        carbs: 45.0,
        quantity: 1.0,
        servingUnit: 'skål',
        createdAt: DateTime.now().subtract(Duration(days: 20)),
        lastUsed: DateTime.now().subtract(Duration(days: 3)),
        usageCount: 15,
      ),
      FavoriteFoodModel(
        id: 'test_4',
        foodName: 'Protein shake',
        mealType: MealType.snack,
        calories: 150,
        protein: 25.0,
        fat: 2.0,
        carbs: 8.0,
        quantity: 1.0,
        servingUnit: 'glas',
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        lastUsed: DateTime.now(),
        usageCount: 22,
      ),
    ];
    
    _favorites.addAll(testFavorites);
    print('⭐ FavoriteFoodService: Added ${testFavorites.length} test favorites');
  }

  /// Get favorite count (for testing/debugging)
  static int get favoriteCount => _favorites.length;
} 