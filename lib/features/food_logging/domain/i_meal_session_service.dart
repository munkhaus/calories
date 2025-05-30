import 'package:result_type/result_type.dart';
import 'meal_session_model.dart';

/// Error types for meal session operations
enum MealSessionError {
  notFound,
  validation,
  imageCapture,
  imageSave,
  database,
  userCancelled,
  permissionDenied,
  cameraUnavailable,
  maxImagesReached,
  unknown,
}

/// Interface for meal session service operations
abstract class IMealSessionService {
  /// Start a new meal session
  /// 
  /// Returns [Result.failure] with [MealSessionError.validation] if validation fails.
  Future<Result<MealSessionModel, MealSessionError>> startMealSession();

  /// Add image to existing meal session
  /// 
  /// Returns [Result.failure] with [MealSessionError.notFound] if session doesn't exist.
  /// Returns [Result.failure] with [MealSessionError.maxImagesReached] if too many images.
  /// Returns [Result.failure] with [MealSessionError.imageCapture] if camera fails.
  Future<Result<MealSessionModel, MealSessionError>> addImageToSession(String sessionId);

  /// Add image from gallery to existing meal session
  /// 
  /// Returns [Result.failure] with [MealSessionError.notFound] if session doesn't exist.
  /// Returns [Result.failure] with [MealSessionError.userCancelled] if user cancels.
  Future<Result<MealSessionModel, MealSessionError>> addImageFromGalleryToSession(String sessionId);

  /// Get all active meal sessions
  /// 
  /// Returns [Result.failure] with [MealSessionError.database] if database error occurs.
  Future<Result<List<MealSessionModel>, MealSessionError>> getMealSessions();

  /// Get meal session by ID
  /// 
  /// Returns [Result.failure] with [MealSessionError.notFound] if session doesn't exist.
  Future<Result<MealSessionModel, MealSessionError>> getMealSessionById(String id);

  /// Process meal session (analyze all images and create food log)
  /// 
  /// Returns [Result.failure] with [MealSessionError.validation] if processing fails.
  Future<Result<bool, MealSessionError>> processMealSession(String id);

  /// Delete meal session and all its images
  /// 
  /// Returns [Result.failure] with [MealSessionError.notFound] if session doesn't exist.
  Future<Result<bool, MealSessionError>> deleteMealSession(String id);

  /// Remove specific image from meal session
  /// 
  /// Returns [Result.failure] with [MealSessionError.notFound] if session or image doesn't exist.
  Future<Result<MealSessionModel, MealSessionError>> removeImageFromSession(String sessionId, String imagePath);

  /// Add notes to meal session
  /// 
  /// Returns [Result.failure] with [MealSessionError.notFound] if session doesn't exist.
  Future<Result<MealSessionModel, MealSessionError>> addNotes(String id, String notes);
} 