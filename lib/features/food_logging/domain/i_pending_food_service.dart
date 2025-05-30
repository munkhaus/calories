import 'package:result_type/result_type.dart';
import 'pending_food_model.dart';

/// Error types for pending food operations
enum PendingFoodError {
  notFound,
  validation,
  imageCapture,
  imageSave,
  database,
  unknown,
}

/// Interface for pending food service operations
abstract class IPendingFoodService {
  /// Capture photo and create pending food item
  /// 
  /// Returns [Result.failure] with [PendingFoodError.imageCapture] if camera fails.
  /// Returns [Result.failure] with [PendingFoodError.imageSave] if saving fails.
  Future<Result<PendingFoodModel, PendingFoodError>> captureFood();

  /// Get all pending food items
  /// 
  /// Returns [Result.failure] with [PendingFoodError.database] if database error occurs.
  Future<Result<List<PendingFoodModel>, PendingFoodError>> getPendingFoods();

  /// Get pending food by ID
  /// 
  /// Returns [Result.failure] with [PendingFoodError.notFound] if item doesn't exist.
  Future<Result<PendingFoodModel, PendingFoodError>> getPendingFoodById(String id);

  /// Mark pending food as processed (categorized)
  /// 
  /// Returns [Result.failure] with [PendingFoodError.validation] if validation fails.
  Future<Result<bool, PendingFoodError>> markAsProcessed(String id);

  /// Delete pending food item
  /// 
  /// Returns [Result.failure] with [PendingFoodError.notFound] if item doesn't exist.
  Future<Result<bool, PendingFoodError>> deletePendingFood(String id);

  /// Add notes to pending food item
  /// 
  /// Returns [Result.failure] with [PendingFoodError.validation] if validation fails.
  Future<Result<PendingFoodModel, PendingFoodError>> addNotes(String id, String notes);
} 