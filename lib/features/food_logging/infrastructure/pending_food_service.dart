import 'package:result_type/result_type.dart';
import '../domain/i_pending_food_service.dart';
import '../domain/pending_food_model.dart';
import 'camera_service.dart';

/// Implementation of pending food service with real camera integration
class PendingFoodService implements IPendingFoodService {
  // Static list to simulate database storage
  static final List<PendingFoodModel> _pendingFoods = [];

  // Constructor - no longer clears data automatically
  PendingFoodService() {
    print('🍎 PendingFoodService: Service initialized, current items: ${_pendingFoods.length}');
  }

  @override
  Future<Result<PendingFoodModel, PendingFoodError>> captureFood() async {
    try {
      // Use real camera service
      final cameraResult = await CameraService.capturePhoto();
      
      if (cameraResult.isFailure) {
        // Map camera errors to pending food errors
        switch (cameraResult.failure) {
          case CameraError.userCancelled:
            return Failure(PendingFoodError.userCancelled);
          case CameraError.permissionDenied:
            return Failure(PendingFoodError.permissionDenied);
          case CameraError.cameraNotAvailable:
            return Failure(PendingFoodError.cameraUnavailable);
          case CameraError.imageSaveFailed:
            return Failure(PendingFoodError.imageSave);
          case CameraError.unknown:
          default:
            return Failure(PendingFoodError.unknown);
        }
      }

      // Create pending food with real image path (now as a list)
      final pendingFood = PendingFoodModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePaths: [cameraResult.success], // Put single image in list
        capturedAt: DateTime.now(),
        notes: '',
      );

      // Add to list
      _pendingFoods.add(pendingFood);

      return Success(pendingFood);
    } catch (e) {
      return Failure(PendingFoodError.unknown);
    }
  }

  /// Alternative method to pick from gallery
  Future<Result<PendingFoodModel, PendingFoodError>> pickFromGallery() async {
    try {
      // Use camera service gallery picker
      final cameraResult = await CameraService.pickFromGallery();
      
      if (cameraResult.isFailure) {
        // Map camera errors to pending food errors
        switch (cameraResult.failure) {
          case CameraError.userCancelled:
            return Failure(PendingFoodError.userCancelled);
          case CameraError.permissionDenied:
            return Failure(PendingFoodError.permissionDenied);
          case CameraError.imageSaveFailed:
            return Failure(PendingFoodError.imageSave);
          case CameraError.unknown:
          default:
            return Failure(PendingFoodError.unknown);
        }
      }

      // Create pending food with real image path (now as a list)
      final pendingFood = PendingFoodModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePaths: [cameraResult.success], // Put single image in list
        capturedAt: DateTime.now(),
        notes: '',
      );

      // Add to list
      _pendingFoods.add(pendingFood);

      return Success(pendingFood);
    } catch (e) {
      return Failure(PendingFoodError.unknown);
    }
  }

  /// NEW: Add image to existing pending food
  Future<Result<PendingFoodModel, PendingFoodError>> addImageToPendingFood(String pendingFoodId) async {
    try {
      // Take photo first
      final cameraResult = await CameraService.capturePhoto();
      
      if (cameraResult.isFailure) {
        switch (cameraResult.failure) {
          case CameraError.userCancelled:
            return Failure(PendingFoodError.userCancelled);
          case CameraError.permissionDenied:
            return Failure(PendingFoodError.permissionDenied);
          case CameraError.cameraNotAvailable:
            return Failure(PendingFoodError.cameraUnavailable);
          case CameraError.imageSaveFailed:
            return Failure(PendingFoodError.imageSave);
          case CameraError.unknown:
          default:
            return Failure(PendingFoodError.unknown);
        }
      }

      // Find the pending food to add image to
      final index = _pendingFoods.indexWhere((item) => item.id == pendingFoodId);
      if (index == -1) {
        return Failure(PendingFoodError.notFound);
      }

      // Add the new image to the list
      final updatedImagePaths = List<String>.from(_pendingFoods[index].imagePaths);
      updatedImagePaths.add(cameraResult.success);

      // Update the pending food with new image list
      _pendingFoods[index] = _pendingFoods[index].copyWith(
        imagePaths: updatedImagePaths,
      );

      return Success(_pendingFoods[index]);
    } catch (e) {
      return Failure(PendingFoodError.unknown);
    }
  }

  /// NEW: Get the most recent unprocessed pending food (for adding more images to same meal)
  Future<Result<PendingFoodModel?, PendingFoodError>> getMostRecentPendingFood() async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      final unprocessed = _pendingFoods
          .where((item) => !item.isProcessed)
          .toList()
        ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
      
      return Success(unprocessed.isNotEmpty ? unprocessed.first : null);
    } catch (e) {
      return Failure(PendingFoodError.database);
    }
  }

  @override
  Future<Result<List<PendingFoodModel>, PendingFoodError>> getPendingFoods() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Return only unprocessed items, sorted by newest first
      final unprocessed = _pendingFoods
          .where((item) => !item.isProcessed)
          .toList()
        ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
      
      print('🍎 PendingFoodService: getPendingFoods() returning ${unprocessed.length} items');
      print('🍎 PendingFoodService: Total items in storage: ${_pendingFoods.length}');
      
      return Success(unprocessed);
    } catch (e) {
      print('🍎 PendingFoodService: getPendingFoods() error: $e');
      return Failure(PendingFoodError.database);
    }
  }

  @override
  Future<Result<PendingFoodModel, PendingFoodError>> getPendingFoodById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      final item = _pendingFoods.firstWhere(
        (item) => item.id == id,
        orElse: () => throw Exception('Not found'),
      );
      return Success(item);
    } catch (e) {
      return Failure(PendingFoodError.notFound);
    }
  }

  @override
  Future<Result<bool, PendingFoodError>> markAsProcessed(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final index = _pendingFoods.indexWhere((item) => item.id == id);
      if (index == -1) {
        return Failure(PendingFoodError.notFound);
      }

      _pendingFoods[index] = _pendingFoods[index].copyWith(isProcessed: true);
      return Success(true);
    } catch (e) {
      return Failure(PendingFoodError.validation);
    }
  }

  @override
  Future<Result<bool, PendingFoodError>> deletePendingFood(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final index = _pendingFoods.indexWhere((item) => item.id == id);
      if (index == -1) {
        return Failure(PendingFoodError.notFound);
      }

      final item = _pendingFoods[index];
      
      // Delete all image files
      for (final imagePath in item.imagePaths) {
        if (imagePath.isNotEmpty && !imagePath.startsWith('mock_')) {
          await CameraService.deleteImage(imagePath);
        }
      }

      _pendingFoods.removeAt(index);
      return Success(true);
    } catch (e) {
      return Failure(PendingFoodError.database);
    }
  }

  /// Add notes to pending food item
  Future<Result<PendingFoodModel, PendingFoodError>> addNotes(String id, String notes) async {
    try {
      // Find the item
      final item = _pendingFoods.firstWhere(
        (food) => food.id == id,
        orElse: () => throw Exception('Food not found'),
      );

      // Update notes
      final updatedItem = item.copyWith(notes: notes);
      
      // Replace in list
      final index = _pendingFoods.indexWhere((food) => food.id == id);
      _pendingFoods[index] = updatedItem;

      print('🍎 PendingFoodService: Added notes to item $id');
      return Success(updatedItem);
    } catch (e) {
      print('🍎 PendingFoodService: Error adding notes: $e');
      return Failure(PendingFoodError.notFound);
    }
  }

  /// Add a new pending food element directly
  Future<Result<PendingFoodModel, PendingFoodError>> addPendingFood(PendingFoodModel pendingFood) async {
    try {
      // Add to list
      _pendingFoods.add(pendingFood);
      print('🍎 PendingFoodService: Added new pending food with ID ${pendingFood.id} and ${pendingFood.imagePaths.length} images');
      return Success(pendingFood);
    } catch (e) {
      print('🍎 PendingFoodService: Error adding pending food: $e');
      return Failure(PendingFoodError.unknown);
    }
  }

  // Helper methods for testing/development
  static void clearAll() {
    // Clean up all image files before clearing list
    for (final item in _pendingFoods) {
      for (final imagePath in item.imagePaths) {
        if (imagePath.isNotEmpty && !imagePath.startsWith('mock_')) {
          CameraService.deleteImage(imagePath);
        }
      }
    }
    _pendingFoods.clear();
  }

  static List<PendingFoodModel> get allItems => List.unmodifiable(_pendingFoods);
} 