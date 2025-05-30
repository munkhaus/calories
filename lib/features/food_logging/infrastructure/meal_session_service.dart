import 'package:result_type/result_type.dart';
import '../domain/i_meal_session_service.dart';
import '../domain/meal_session_model.dart';
import 'camera_service.dart';

/// Implementation of meal session service for multi-photo meals
class MealSessionService implements IMealSessionService {
  // Static list to simulate database storage
  static final List<MealSessionModel> _mealSessions = [];
  static const int maxImagesPerSession = 5; // Limit to 5 images per meal

  /// Constructor
  MealSessionService() {
    print('🍎 MealSessionService: Service initialized');
  }

  @override
  Future<Result<MealSessionModel, MealSessionError>> startMealSession() async {
    try {
      // Create new meal session
      final session = MealSessionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePaths: [],
        startedAt: DateTime.now(),
        notes: '',
        isProcessed: false,
        estimatedCalories: 0,
        mealName: '',
      );

      // Add to list
      _mealSessions.add(session);
      print('🍎 MealSessionService: Started new meal session ${session.id}');

      return Success(session);
    } catch (e) {
      return Failure(MealSessionError.unknown);
    }
  }

  @override
  Future<Result<MealSessionModel, MealSessionError>> addImageToSession(String sessionId) async {
    try {
      // Find session
      final sessionIndex = _mealSessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex == -1) {
        return Failure(MealSessionError.notFound);
      }

      final session = _mealSessions[sessionIndex];

      // Check if max images reached
      if (session.imagePaths.length >= maxImagesPerSession) {
        return Failure(MealSessionError.maxImagesReached);
      }

      // Use real camera service
      final cameraResult = await CameraService.capturePhoto();
      
      if (cameraResult.isFailure) {
        // Map camera errors to meal session errors
        switch (cameraResult.failure) {
          case CameraError.userCancelled:
            return Failure(MealSessionError.userCancelled);
          case CameraError.permissionDenied:
            return Failure(MealSessionError.permissionDenied);
          case CameraError.cameraNotAvailable:
            return Failure(MealSessionError.cameraUnavailable);
          case CameraError.imageSaveFailed:
            return Failure(MealSessionError.imageSave);
          case CameraError.unknown:
          default:
            return Failure(MealSessionError.unknown);
        }
      }

      // Add image to session
      final updatedSession = session.addImage(cameraResult.success);
      _mealSessions[sessionIndex] = updatedSession;

      print('🍎 MealSessionService: Added image to session ${sessionId}, total images: ${updatedSession.imageCount}');

      return Success(updatedSession);
    } catch (e) {
      return Failure(MealSessionError.unknown);
    }
  }

  @override
  Future<Result<MealSessionModel, MealSessionError>> addImageFromGalleryToSession(String sessionId) async {
    try {
      // Find session
      final sessionIndex = _mealSessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex == -1) {
        return Failure(MealSessionError.notFound);
      }

      final session = _mealSessions[sessionIndex];

      // Check if max images reached
      if (session.imagePaths.length >= maxImagesPerSession) {
        return Failure(MealSessionError.maxImagesReached);
      }

      // Use camera service gallery picker
      final cameraResult = await CameraService.pickFromGallery();
      
      if (cameraResult.isFailure) {
        // Map camera errors to meal session errors
        switch (cameraResult.failure) {
          case CameraError.userCancelled:
            return Failure(MealSessionError.userCancelled);
          case CameraError.permissionDenied:
            return Failure(MealSessionError.permissionDenied);
          case CameraError.imageSaveFailed:
            return Failure(MealSessionError.imageSave);
          case CameraError.unknown:
          default:
            return Failure(MealSessionError.unknown);
        }
      }

      // Add image to session
      final updatedSession = session.addImage(cameraResult.success);
      _mealSessions[sessionIndex] = updatedSession;

      print('🍎 MealSessionService: Added gallery image to session ${sessionId}, total images: ${updatedSession.imageCount}');

      return Success(updatedSession);
    } catch (e) {
      return Failure(MealSessionError.unknown);
    }
  }

  @override
  Future<Result<List<MealSessionModel>, MealSessionError>> getMealSessions() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Return only unprocessed sessions
      final unprocessedSessions = _mealSessions.where((s) => !s.isProcessed).toList();
      
      print('🍎 MealSessionService: Found ${unprocessedSessions.length} unprocessed meal sessions');
      
      return Success(unprocessedSessions);
    } catch (e) {
      return Failure(MealSessionError.database);
    }
  }

  @override
  Future<Result<MealSessionModel, MealSessionError>> getMealSessionById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      final session = _mealSessions.firstWhere(
        (s) => s.id == id,
        orElse: () => throw Exception('Not found'),
      );
      
      return Success(session);
    } catch (e) {
      return Failure(MealSessionError.notFound);
    }
  }

  @override
  Future<Result<bool, MealSessionError>> processMealSession(String id) async {
    try {
      final sessionIndex = _mealSessions.indexWhere((s) => s.id == id);
      if (sessionIndex == -1) {
        return Failure(MealSessionError.notFound);
      }

      // Mark session as processed
      final session = _mealSessions[sessionIndex];
      final processedSession = session.copyWith(isProcessed: true);
      _mealSessions[sessionIndex] = processedSession;

      // Delete all images in the session after processing
      for (final imagePath in session.imagePaths) {
        await CameraService.deleteImage(imagePath);
      }

      print('🍎 MealSessionService: Processed meal session ${id} and deleted ${session.imagePaths.length} images');

      return Success(true);
    } catch (e) {
      return Failure(MealSessionError.validation);
    }
  }

  /// Remove specific image from session
  Future<Result<MealSessionModel, MealSessionError>> removeImageFromSession(String sessionId, String imagePath) async {
    try {
      final sessionIndex = _mealSessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex == -1) {
        return Failure(MealSessionError.notFound);
      }

      final session = _mealSessions[sessionIndex];
      final updatedSession = session.removeImage(imagePath);
      _mealSessions[sessionIndex] = updatedSession;

      // Delete the actual image file
      await CameraService.deleteImage(imagePath);

      print('🍎 MealSessionService: Removed image from session ${sessionId}, remaining images: ${updatedSession.imageCount}');

      return Success(updatedSession);
    } catch (e) {
      return Failure(MealSessionError.unknown);
    }
  }

  /// Delete entire meal session
  Future<Result<bool, MealSessionError>> deleteMealSession(String id) async {
    try {
      final sessionIndex = _mealSessions.indexWhere((s) => s.id == id);
      if (sessionIndex == -1) {
        return Failure(MealSessionError.notFound);
      }

      final session = _mealSessions[sessionIndex];
      
      // Delete all image files
      for (final imagePath in session.imagePaths) {
        await CameraService.deleteImage(imagePath);
      }

      _mealSessions.removeAt(sessionIndex);

      print('🍎 MealSessionService: Deleted meal session ${id} and ${session.imagePaths.length} images');

      return Success(true);
    } catch (e) {
      return Failure(MealSessionError.unknown);
    }
  }

  @override
  Future<Result<MealSessionModel, MealSessionError>> addNotes(String sessionId, String notes) async {
    try {
      final sessionIndex = _mealSessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex == -1) {
        return Failure(MealSessionError.notFound);
      }

      final session = _mealSessions[sessionIndex];
      final updatedSession = session.copyWith(notes: notes);
      _mealSessions[sessionIndex] = updatedSession;

      print('🍎 MealSessionService: Added notes to session ${sessionId}');

      return Success(updatedSession);
    } catch (e) {
      return Failure(MealSessionError.unknown);
    }
  }

  // Helper methods for testing/development
  static void clearAll() {
    // Clean up all image files before clearing list
    for (final session in _mealSessions) {
      for (final imagePath in session.imagePaths) {
        CameraService.deleteImage(imagePath);
      }
    }
    _mealSessions.clear();
  }

  static List<MealSessionModel> get allSessions => List.unmodifiable(_mealSessions);
} 