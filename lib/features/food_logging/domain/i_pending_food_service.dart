import 'package:result_type/result_type.dart';
import 'pending_food_model.dart';

/// Error types for pending food operations
enum PendingFoodError {
  notFound,
  validation,
  imageCapture,
  imageSave,
  database,
  userCancelled,
  permissionDenied,
  cameraUnavailable,
  unknown,
}

/// Interface for pending food service operations
abstract class IPendingFoodService {
  /// Capture photo and create pending food item
  /// 
  /// Returns [Result.failure] with [PendingFoodError.imageCapture] if camera fails.
  /// Returns [Result.failure] with [PendingFoodError.imageSave] if saving fails.
  /// Returns [Result.failure] with [PendingFoodError.userCancelled] if user cancels.
  /// Returns [Result.failure] with [PendingFoodError.permissionDenied] if camera permission denied.
  /// Returns [Result.failure] with [PendingFoodError.cameraUnavailable] if camera not available.
  Future<Result<PendingFoodModel, PendingFoodError>> captureFood();

  /// Pick image from gallery and create pending food item
  /// 
  /// Returns [Result.failure] with [PendingFoodError.userCancelled] if user cancels.
  /// Returns [Result.failure] with [PendingFoodError.permissionDenied] if gallery permission denied.
  /// Returns [Result.failure] with [PendingFoodError.imageSave] if saving fails.
  Future<Result<PendingFoodModel, PendingFoodError>> pickFromGallery();

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

  /// Add a new pending food element directly
  /// 
  /// Returns [Result.failure] with [PendingFoodError.validation] if validation fails.
  Future<Result<PendingFoodModel, PendingFoodError>> addPendingFood(PendingFoodModel pendingFood);

  /// Get the most recent pending food item
  /// 
  /// Returns [Result.failure] with [PendingFoodError.notFound] if no pending foods exist.
  Future<Result<PendingFoodModel?, PendingFoodError>> getMostRecentPendingFood();

  /// Add an image to an existing pending food
  /// 
  /// Returns [Result.failure] with [PendingFoodError.notFound] if pending food doesn't exist.
  /// Returns [Result.failure] with [PendingFoodError.userCancelled] if user cancels camera.
  /// Returns [Result.failure] with [PendingFoodError.imageCapture] if image capture fails.
  Future<Result<PendingFoodModel, PendingFoodError>> addImageToPendingFood(String pendingFoodId);

  /// Get the count of unprocessed pending foods
  /// 
  /// Returns [Result.failure] with [PendingFoodError.database] if database error occurs.
  Future<Result<int, PendingFoodError>> getUnprocessedCount();
} 