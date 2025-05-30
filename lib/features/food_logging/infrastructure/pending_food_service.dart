import 'package:result_type/result_type.dart';
import '../domain/i_pending_food_service.dart';
import '../domain/pending_food_model.dart';
import 'camera_service.dart';

/// Implementation of pending food service with real camera integration
class PendingFoodService implements IPendingFoodService {
  static final List<PendingFoodModel> _pendingFoods = [];

  // Constructor that adds test data for debugging
  PendingFoodService() {
    // Add test data for debugging if list is empty
    if (_pendingFoods.isEmpty) {
      print('🍎 PendingFoodService: Adding test data for debugging');
      addTestData();
    }
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

      // Create pending food with real image path
      final pendingFood = PendingFoodModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: cameraResult.success,
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

      // Create pending food with real image path
      final pendingFood = PendingFoodModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: cameraResult.success,
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
      
      // Delete the actual image file
      if (item.imagePath.isNotEmpty && !item.imagePath.startsWith('mock_')) {
        await CameraService.deleteImage(item.imagePath);
      }

      _pendingFoods.removeAt(index);
      return Success(true);
    } catch (e) {
      return Failure(PendingFoodError.database);
    }
  }

  @override
  Future<Result<PendingFoodModel, PendingFoodError>> addNotes(String id, String notes) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      final index = _pendingFoods.indexWhere((item) => item.id == id);
      if (index == -1) {
        return Failure(PendingFoodError.notFound);
      }

      _pendingFoods[index] = _pendingFoods[index].copyWith(notes: notes);
      return Success(_pendingFoods[index]);
    } catch (e) {
      return Failure(PendingFoodError.validation);
    }
  }

  // Helper methods for testing/development
  static void clearAll() {
    // Clean up all image files before clearing list
    for (final item in _pendingFoods) {
      if (item.imagePath.isNotEmpty && !item.imagePath.startsWith('mock_')) {
        CameraService.deleteImage(item.imagePath);
      }
    }
    _pendingFoods.clear();
  }

  static List<PendingFoodModel> get allItems => List.unmodifiable(_pendingFoods);
  
  // Add some test data
  static void addTestData() {
    _pendingFoods.addAll([
      PendingFoodModel(
        id: '1',
        imagePath: 'test_burger.jpg',
        capturedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        notes: 'Burger med pommes',
      ),
      PendingFoodModel(
        id: '2',
        imagePath: 'test_salad.jpg',
        capturedAt: DateTime.now().subtract(const Duration(hours: 1)),
        notes: 'Grøn salat',
      ),
    ]);
  }
} 