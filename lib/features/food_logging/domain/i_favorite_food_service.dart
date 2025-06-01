import 'package:result_type/result_type.dart';
import 'favorite_food_model.dart';
import 'user_food_log_model.dart';
import '../../food_database/domain/online_food_models.dart';

/// Error types for favorite food operations
enum FavoriteFoodError {
  notFound,
  validation,
  database,
  alreadyExists,
  unknown,
}

extension FavoriteFoodErrorExtension on FavoriteFoodError {
  String get message {
    switch (this) {
      case FavoriteFoodError.notFound:
        return 'Mad ikke fundet';
      case FavoriteFoodError.alreadyExists:
        return 'Mad findes allerede i favoritter';
      case FavoriteFoodError.validation:
        return 'Ugyldig data';
      case FavoriteFoodError.database:
        return 'Fejl ved lagring';
      case FavoriteFoodError.unknown:
        return 'Ukendt fejl';
    }
  }
}

/// Interface for comprehensive favorite food service operations
/// Now serves as the primary food storage and search system
abstract class IFavoriteFoodService {
  /// Get all favorite foods
  /// 
  /// Returns [Result.failure] with [FavoriteFoodError.database] if database error occurs.
  Future<Result<List<FavoriteFoodModel>, FavoriteFoodError>> getAllFavorites();

  /// Search favorite foods by name, description or tags
  /// 
  /// Returns [Result.failure] with [FavoriteFoodError.database] if database error occurs.
  Future<Result<List<FavoriteFoodModel>, FavoriteFoodError>> searchFavorites(String query);

  /// Get favorites sorted by most recently used
  /// 
  /// Returns [Result.failure] with [FavoriteFoodError.database] if database error occurs.
  Future<Result<List<FavoriteFoodModel>, FavoriteFoodError>> getRecentFavorites({int limit = 20});

  /// Get most used favorites (by usage count)
  /// 
  /// Returns [Result.failure] with [FavoriteFoodError.database] if database error occurs.
  Future<Result<List<FavoriteFoodModel>, FavoriteFoodError>> getMostUsedFavorites({int limit = 10});

  /// Get favorites by preferred meal type
  /// 
  /// Returns [Result.failure] with [FavoriteFoodError.database] if database error occurs.
  Future<Result<List<FavoriteFoodModel>, FavoriteFoodError>> getFavoritesByMealType(MealType mealType);

  /// Get a specific favorite by ID
  /// 
  /// Returns [Result.failure] with [FavoriteFoodError.notFound] if favorite doesn't exist.
  Future<Result<FavoriteFoodModel, FavoriteFoodError>> getFavoriteById(String id);

  /// Add a food to favorites
  /// 
  /// Returns [Result.failure] with [FavoriteFoodError.validation] if validation fails.
  /// Returns [Result.failure] with [FavoriteFoodError.alreadyExists] if favorite already exists.
  Future<Result<FavoriteFoodModel, FavoriteFoodError>> addToFavorites(FavoriteFoodModel favorite);

  /// Add food from online details to favorites
  /// 
  /// Returns [Result.failure] with [FavoriteFoodError.validation] if validation fails.
  /// Returns [Result.failure] with [FavoriteFoodError.alreadyExists] if favorite already exists.
  Future<Result<FavoriteFoodModel, FavoriteFoodError>> addOnlineFoodToFavorites(
    OnlineFoodDetails details, {
    MealType? preferredMealType,
    double? preferredQuantity,
    String? preferredServingUnit,
  });

  /// Update a favorite (when used again or edited)
  /// 
  /// Returns [Result.failure] with [FavoriteFoodError.notFound] if favorite doesn't exist.
  Future<Result<FavoriteFoodModel, FavoriteFoodError>> updateFavorite(FavoriteFoodModel favorite);

  /// Update usage statistics for a favorite
  /// 
  /// Returns [Result.failure] with [FavoriteFoodError.notFound] if favorite doesn't exist.
  Future<Result<FavoriteFoodModel, FavoriteFoodError>> incrementFavoriteUsage(String id);

  /// Remove a food from favorites
  /// 
  /// Returns [Result.failure] with [FavoriteFoodError.notFound] if favorite doesn't exist.
  Future<Result<bool, FavoriteFoodError>> removeFromFavorites(String id);

  /// Check if a food is already in favorites (by name and calories)
  Future<bool> isFavorite(String foodName, int caloriesPer100g);

  /// Check if a food exists by ID
  Future<bool> favoriteExists(String id);

  /// Find similar favorites (fuzzy matching)
  /// 
  /// Returns [Result.failure] with [FavoriteFoodError.database] if database error occurs.
  Future<Result<List<FavoriteFoodModel>, FavoriteFoodError>> findSimilarFavorites(String foodName, {double threshold = 0.6});

  /// Clear all favorites (for testing/reset)
  Future<Result<void, FavoriteFoodError>> clearAllFavorites();

  /// Get quick suggestions based on time of day and history
  Future<Result<List<FavoriteFoodModel>, FavoriteFoodError>> getQuickSuggestions({int limit = 5});
} 