import 'package:result_type/result_type.dart';
import 'favorite_food_model.dart';

/// Error types for favorite food operations
enum FavoriteFoodError {
  notFound,
  validation,
  database,
  alreadyExists,
  unknown,
}

/// Interface for favorite food service operations
abstract class IFavoriteFoodService {
  /// Get all favorite foods, sorted by most recently used
  /// 
  /// Returns [Result.failure] with [FavoriteFoodError.database] if database error occurs.
  Future<Result<List<FavoriteFoodModel>, FavoriteFoodError>> getFavorites();

  /// Add a food to favorites
  /// 
  /// Returns [Result.failure] with [FavoriteFoodError.validation] if validation fails.
  /// Returns [Result.failure] with [FavoriteFoodError.alreadyExists] if favorite already exists.
  Future<Result<FavoriteFoodModel, FavoriteFoodError>> addToFavorites(FavoriteFoodModel favorite);

  /// Remove a food from favorites
  /// 
  /// Returns [Result.failure] with [FavoriteFoodError.notFound] if favorite doesn't exist.
  Future<Result<bool, FavoriteFoodError>> removeFromFavorites(String id);

  /// Update a favorite (when used again)
  /// 
  /// Returns [Result.failure] with [FavoriteFoodError.notFound] if favorite doesn't exist.
  Future<Result<FavoriteFoodModel, FavoriteFoodError>> updateFavorite(FavoriteFoodModel favorite);

  /// Check if a food is already in favorites
  Future<bool> isFavorite(String foodName, int calories);

  /// Get most used favorites (top 10)
  Future<Result<List<FavoriteFoodModel>, FavoriteFoodError>> getMostUsedFavorites({int limit = 10});
} 