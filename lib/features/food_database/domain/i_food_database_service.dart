import 'package:result_type/result_type.dart';
import 'food_record_model.dart';

enum FoodDatabaseError {
  notFound,
  alreadyExists,
  validation,
  storage,
  unknown;

  String get message {
    switch (this) {
      case FoodDatabaseError.notFound:
        return 'Mad ikke fundet';
      case FoodDatabaseError.alreadyExists:
        return 'Mad findes allerede';
      case FoodDatabaseError.validation:
        return 'Ugyldig data';
      case FoodDatabaseError.storage:
        return 'Fejl ved lagring';
      case FoodDatabaseError.unknown:
        return 'Ukendt fejl';
    }
  }
}

abstract class IFoodDatabaseService {
  /// Get all food records
  Future<Result<List<FoodRecordModel>, FoodDatabaseError>> getAllFoods();

  /// Search food records by name or description
  Future<Result<List<FoodRecordModel>, FoodDatabaseError>> searchFoods(String query);

  /// Get foods by category
  Future<Result<List<FoodRecordModel>, FoodDatabaseError>> getFoodsByCategory(FoodCategory category);

  /// Get a specific food record by ID
  Future<Result<FoodRecordModel, FoodDatabaseError>> getFoodById(String id);

  /// Add a new food record
  Future<Result<FoodRecordModel, FoodDatabaseError>> addFood(FoodRecordModel food);

  /// Update an existing food record
  Future<Result<FoodRecordModel, FoodDatabaseError>> updateFood(FoodRecordModel food);

  /// Delete a food record
  Future<Result<void, FoodDatabaseError>> deleteFood(String id);

  /// Clear all food records from the database
  Future<Result<void, FoodDatabaseError>> clearAllFoods();

  /// Get recent foods (last used)
  Future<Result<List<FoodRecordModel>, FoodDatabaseError>> getRecentFoods({int limit = 10});

  /// Find best match for AI-suggested food name
  Future<Result<List<FoodRecordModel>, FoodDatabaseError>> findMatches(String foodName, {double threshold = 0.6});

  /// Seed initial database with common foods
  Future<Result<void, FoodDatabaseError>> seedDatabase();
} 