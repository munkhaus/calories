import 'package:result_type/result_type.dart';
import 'favorite_activity_model.dart';

/// Error types for favorite activity operations
enum FavoriteActivityError {
  notFound,
  validation,
  database,
  alreadyExists,
  unknown,
}

/// Interface for favorite activity service operations
abstract class IFavoriteActivityService {
  /// Get all favorite activities, sorted by most recently used
  /// 
  /// Returns [Result.failure] with [FavoriteActivityError.database] if database error occurs.
  Future<Result<List<FavoriteActivityModel>, FavoriteActivityError>> getFavorites();

  /// Add an activity to favorites
  /// 
  /// Returns [Result.failure] with [FavoriteActivityError.validation] if validation fails.
  /// Returns [Result.failure] with [FavoriteActivityError.alreadyExists] if favorite already exists.
  Future<Result<FavoriteActivityModel, FavoriteActivityError>> addToFavorites(FavoriteActivityModel favorite);

  /// Remove an activity from favorites
  /// 
  /// Returns [Result.failure] with [FavoriteActivityError.notFound] if favorite doesn't exist.
  Future<Result<bool, FavoriteActivityError>> removeFromFavorites(String favoriteId);

  /// Update a favorite activity
  /// 
  /// Returns [Result.failure] with [FavoriteActivityError.notFound] if favorite doesn't exist.
  /// Returns [Result.failure] with [FavoriteActivityError.validation] if validation fails.
  Future<Result<FavoriteActivityModel, FavoriteActivityError>> updateFavorite(FavoriteActivityModel favorite);

  /// Get a specific favorite by ID
  /// 
  /// Returns [Result.failure] with [FavoriteActivityError.notFound] if favorite doesn't exist.
  Future<Result<FavoriteActivityModel, FavoriteActivityError>> getFavoriteById(String favoriteId);

  /// Get most used favorites (top 5)
  /// 
  /// Returns [Result.failure] with [FavoriteActivityError.database] if database error occurs.
  Future<Result<List<FavoriteActivityModel>, FavoriteActivityError>> getMostUsedFavorites();

  /// Search favorites by activity name
  /// 
  /// Returns [Result.failure] with [FavoriteActivityError.database] if database error occurs.
  Future<Result<List<FavoriteActivityModel>, FavoriteActivityError>> searchFavorites(String query);

  /// Clear all favorites
  /// 
  /// Returns [Result.failure] with [FavoriteActivityError.database] if database error occurs.
  Future<Result<bool, FavoriteActivityError>> clearAllFavorites();
} 