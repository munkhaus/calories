import 'dart:io';
import 'dart:typed_data';
import 'package:result_type/result_type.dart';
import '../domain/i_pending_food_service.dart';
import '../domain/pending_food_model.dart';
import 'camera_service.dart';
import '../../../core/infrastructure/storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'gemini_service.dart';

/// Implementation of pending food service with in-memory storage
class PendingFoodService implements IPendingFoodService {
  // Static list to simulate database storage
  static List<PendingFoodModel> _pendingFoods = [];
  static bool _isInitialized = false;
  
  // Gemini service for AI analysis
  final GeminiService _geminiService = GeminiService();
  
  /// Initialize service and load persisted data
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _pendingFoods = await StorageService.loadList(
        StorageService.pendingFoodsKey,
        PendingFoodModel.fromJson,
      );
      
      _isInitialized = true;
      print('🍎 PendingFoodService: Service initialized, current items: ${_pendingFoods.length}');
      
      // Only save if we loaded data successfully or if the list was already empty
      // This prevents accidentally overwriting data with an empty list
      if (_pendingFoods.isNotEmpty) {
        print('🍎 PendingFoodService: Loaded ${_pendingFoods.length} pending foods from storage');
      } else {
        print('🍎 PendingFoodService: No pending foods found in storage (empty start)');
      }
    } catch (e) {
      print('❌ PendingFoodService: Error during initialization: $e');
      _pendingFoods = [];
      _isInitialized = true;
    }
  }
  
  /// Save pending foods to persistent storage
  static Future<void> _savePendingFoods() async {
    final success = await StorageService.saveList(
      StorageService.pendingFoodsKey,
      _pendingFoods,
      (food) => food.toJson(),
    );
    
    if (success) {
      print('🍎 PendingFoodService: Saved ${_pendingFoods.length} pending foods to storage');
    } else {
      print('❌ PendingFoodService: Failed to save pending foods');
    }
  }
  
  /// Initialize with empty list (ONLY for testing or explicit data clearing)
  static void initializeEmpty() {
    _pendingFoods = [];
    _isInitialized = true;
    print('🍎 PendingFoodService: Service initialized with empty data (testing mode)');
    
    _savePendingFoods(); // Save empty list to storage
  }
  
  /// Clear all pending foods (for testing or explicit user action)
  static Future<void> clearAll() async {
    _pendingFoods.clear();
    await _savePendingFoods();
    print('🍎 PendingFoodService: Cleared all pending foods');
  }

  @override
  Future<Result<List<PendingFoodModel>, PendingFoodError>> getPendingFoods() async {
    await initialize();
    
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Filter out processed items and sort by capture time (newest first)
      final unprocessedFoods = _pendingFoods
          .where((food) => !food.isProcessed)
          .toList()
        ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
      
      print('🍎 PendingFoodService: getPendingFoods() returning ${unprocessedFoods.length} unprocessed items');
      print('🍎 PendingFoodService: Total items in storage: ${_pendingFoods.length}');
      
      return Success(unprocessedFoods);
    } catch (e) {
      print('🍎 PendingFoodService: Error getting pending foods: $e');
      return Failure(PendingFoodError.database);
    }
  }

  @override
  Future<Result<PendingFoodModel, PendingFoodError>> getPendingFoodById(String id) async {
    await initialize();
    
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      final food = _pendingFoods.firstWhere(
        (food) => food.id == id,
        orElse: () => throw Exception('Food not found'),
      );
      
      return Success(food);
    } catch (e) {
      print('🍎 PendingFoodService: Error getting food by id: $e');
      return Failure(PendingFoodError.notFound);
    }
  }

  /// Get the most recently captured pending food
  @override
  Future<Result<PendingFoodModel?, PendingFoodError>> getMostRecentPendingFood() async {
    await initialize();
    
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      if (_pendingFoods.isEmpty) {
        return Success(null);
      }
      
      // Sort by capturedAt and return the most recent
      final sortedFoods = List<PendingFoodModel>.from(_pendingFoods)
        ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
      
      return Success(sortedFoods.first);
    } catch (e) {
      print('🍎 PendingFoodService: Error getting most recent food: $e');
      return Failure(PendingFoodError.database);
    }
  }

  @override
  Future<Result<PendingFoodModel, PendingFoodError>> captureFood() async {
    await initialize();
    
    try {
      // Capture image using camera service
      final result = await CameraService.capturePhoto();
      
      if (result.isFailure) {
        // Map camera errors to pending food errors
        switch (result.failure) {
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
      
      final imagePath = result.success;
      
      // Create initial pending food item
      final pendingFood = PendingFoodModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePaths: [imagePath],
        capturedAt: DateTime.now(),
      );
      
      // Add to list immediately so user sees it
      _pendingFoods.add(pendingFood);
      await _savePendingFoods();
      
      print('🍎 PendingFoodService: Added new pending food with ID ${pendingFood.id}');
      
      // Start AI analysis in background (don't wait for it)
      _performBackgroundAiAnalysis(pendingFood);
      
      return Success(pendingFood);
    } catch (e) {
      print('🍎 PendingFoodService: Error capturing food: $e');
      return Failure(PendingFoodError.unknown);
    }
  }
  
  @override
  Future<Result<PendingFoodModel, PendingFoodError>> pickFromGallery() async {
    await initialize();
    
    try {
      // Pick image from gallery using camera service
      final result = await CameraService.pickFromGallery();
      
      if (result.isFailure) {
        // Map camera errors to pending food errors
        switch (result.failure) {
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
      
      final imagePath = result.success;
      
      // Create initial pending food item
      final pendingFood = PendingFoodModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePaths: [imagePath],
        capturedAt: DateTime.now(),
      );
      
      // Add to list immediately so user sees it
      _pendingFoods.add(pendingFood);
      await _savePendingFoods();
      
      print('🍎 PendingFoodService: Added new pending food from gallery with ID ${pendingFood.id}');
      
      // Start AI analysis in background (don't wait for it)
      _performBackgroundAiAnalysis(pendingFood);
      
      return Success(pendingFood);
    } catch (e) {
      print('🍎 PendingFoodService: Error capturing from gallery: $e');
      return Failure(PendingFoodError.unknown);
    }
  }
  
  /// Perform AI analysis in background and update the pending food
  Future<void> _performBackgroundAiAnalysis(PendingFoodModel pendingFood) async {
    try {
      print('🤖 PendingFoodService: Starting background AI analysis for ${pendingFood.id}');
      
      // Perform AI analysis
      Result<FoodAnalysisResult, GeminiError> analysisResult;
      if (pendingFood.imageCount > 1) {
        analysisResult = await _geminiService.analyzeMultipleFoodImages(pendingFood.imagePaths);
      } else {
        analysisResult = await _geminiService.analyzeFoodImage(pendingFood.primaryImagePath);
      }
      
      if (analysisResult.isSuccess) {
        print('🤖 PendingFoodService: AI analysis successful, updating pending food');
        
        // Find and update the pending food with AI results
        final index = _pendingFoods.indexWhere((food) => food.id == pendingFood.id);
        if (index != -1) {
          final updatedFood = _pendingFoods[index].copyWith(
            aiResult: analysisResult.success,
          );
          _pendingFoods[index] = updatedFood;
          
          // Save updated list
          await _savePendingFoods();
          
          print('🤖 PendingFoodService: Updated pending food ${pendingFood.id} with AI analysis: ${analysisResult.success.foodName}');
        } else {
          print('🤖 PendingFoodService: Warning: Could not find pending food ${pendingFood.id} to update with AI results');
        }
      } else {
        print('🤖 PendingFoodService: AI analysis failed: ${analysisResult.failure}');
      }
    } catch (e) {
      print('🤖 PendingFoodService: Error during background AI analysis: $e');
      // Don't fail the whole operation if AI analysis fails
    }
  }

  Future<Result<String, PendingFoodError>> captureFromGallery() async {
    // Use pickFromGallery and return just the ID for compatibility
    final result = await pickFromGallery();
    if (result.isSuccess) {
      return Success(result.success.id);
    } else {
      return Failure(result.failure);
    }
  }

  @override
  Future<Result<bool, PendingFoodError>> deletePendingFood(String id) async {
    await initialize();
    
    try {
      // Find and remove the item
      final index = _pendingFoods.indexWhere((food) => food.id == id);
      
      if (index == -1) {
        return Failure(PendingFoodError.notFound);
      }
      
      // Delete associated images
      final food = _pendingFoods[index];
      for (final imagePath in food.imagePaths) {
        if (imagePath.isNotEmpty && !imagePath.startsWith('mock_')) {
          await CameraService.deleteImage(imagePath);
        }
      }
      
      // Remove from list
      _pendingFoods.removeAt(index);
      
      await _savePendingFoods(); // Save to persistent storage
      
      print('🍎 PendingFoodService: Deleted pending food with ID $id');
      return Success(true);
    } catch (e) {
      print('🍎 PendingFoodService: Error deleting food: $e');
      return Failure(PendingFoodError.unknown);
    }
  }

  @override
  Future<Result<bool, PendingFoodError>> markAsProcessed(String id) async {
    await initialize();
    
    try {
      // Find the item
      final index = _pendingFoods.indexWhere((food) => food.id == id);
      
      if (index == -1) {
        return Failure(PendingFoodError.notFound);
      }
      
      // Delete associated images before removing the item
      final food = _pendingFoods[index];
      for (final imagePath in food.imagePaths) {
        if (imagePath.isNotEmpty && !imagePath.startsWith('mock_')) {
          await CameraService.deleteImage(imagePath);
        }
      }
      
      // Remove from list (instead of just marking as processed)
      _pendingFoods.removeAt(index);
      
      await _savePendingFoods(); // Save to persistent storage
      
      print('🍎 PendingFoodService: Deleted processed food $id and its ${food.imagePaths.length} images');
      return Success(true);
    } catch (e) {
      print('🍎 PendingFoodService: Error marking as processed: $e');
      return Failure(PendingFoodError.unknown);
    }
  }

  @override
  Future<Result<int, PendingFoodError>> getUnprocessedCount() async {
    await initialize();
    
    try {
      final count = _pendingFoods.where((food) => !food.isProcessed).length;
      return Success(count);
    } catch (e) {
      print('🍎 PendingFoodService: Error getting unprocessed count: $e');
      return Failure(PendingFoodError.database);
    }
  }
  
  @override
  Future<Result<PendingFoodModel, PendingFoodError>> addNotes(String id, String notes) async {
    await initialize();
    
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
      
      await _savePendingFoods(); // Save to persistent storage

      print('🍎 PendingFoodService: Added notes to item $id');
      return Success(updatedItem);
    } catch (e) {
      print('🍎 PendingFoodService: Error adding notes: $e');
      return Failure(PendingFoodError.notFound);
    }
  }

  /// Add a new pending food element directly
  @override
  Future<Result<PendingFoodModel, PendingFoodError>> addPendingFood(PendingFoodModel pendingFood) async {
    await initialize();
    
    try {
      // Add to list
      _pendingFoods.add(pendingFood);
      
      await _savePendingFoods(); // Save to persistent storage
      
      print('🍎 PendingFoodService: Added new pending food with ID ${pendingFood.id} and ${pendingFood.imagePaths.length} images');
      return Success(pendingFood);
    } catch (e) {
      print('🍎 PendingFoodService: Error adding pending food: $e');
      return Failure(PendingFoodError.unknown);
    }
  }

  /// Add an additional image to an existing pending food
  @override
  Future<Result<PendingFoodModel, PendingFoodError>> addImageToPendingFood(String pendingFoodId) async {
    await initialize();
    
    try {
      // Find the existing pending food
      final existingIndex = _pendingFoods.indexWhere((food) => food.id == pendingFoodId);
      if (existingIndex == -1) {
        return Failure(PendingFoodError.notFound);
      }
      
      // Capture new image
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image == null) {
        return Failure(PendingFoodError.userCancelled);
      }
      
      // Update the existing pending food with additional image path
      final existingFood = _pendingFoods[existingIndex];
      final updatedImagePaths = List<String>.from(existingFood.imagePaths)..add(image.path);
      final updatedFood = existingFood.copyWith(
        imagePaths: updatedImagePaths,
        capturedAt: DateTime.now(), // Update capture time
      );
      
      _pendingFoods[existingIndex] = updatedFood;
      await _savePendingFoods();
      
      print('🍎 PendingFoodService: Added image to pending food ${pendingFoodId}, now has ${updatedFood.imageCount} images');
      return Success(updatedFood);
    } catch (e) {
      print('🍎 PendingFoodService: Error adding image to pending food: $e');
      return Failure(PendingFoodError.imageCapture);
    }
  }

  // Helper methods for testing/development
  static List<PendingFoodModel> get allItems => List.unmodifiable(_pendingFoods);
  
  /// Add test pending food for debugging
  Future<Result<PendingFoodModel, PendingFoodError>> addTestPendingFood() async {
    await initialize();
    
    try {
      // Create test pending food with mock image
      final testFood = PendingFoodModel(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        imagePaths: ['mock_test_image_${DateTime.now().millisecondsSinceEpoch}.jpg'],
        capturedAt: DateTime.now(),
        notes: 'Test pending food for debugging',
      );
      
      // Add to list
      _pendingFoods.add(testFood);
      
      await _savePendingFoods();
      
      print('🍎 PendingFoodService: Added test pending food with ID ${testFood.id}');
      return Success(testFood);
    } catch (e) {
      print('🍎 PendingFoodService: Error adding test pending food: $e');
      return Failure(PendingFoodError.unknown);
    }
  }
  
  /// Clear all pending foods (for debugging)
  Future<Result<bool, PendingFoodError>> clearAllPendingFoods() async {
    await initialize();
    
    try {
      // Clean up all image files before clearing list
      for (final item in _pendingFoods) {
        for (final imagePath in item.imagePaths) {
          if (imagePath.isNotEmpty && !imagePath.startsWith('mock_')) {
            await CameraService.deleteImage(imagePath);
          }
        }
      }
      
      _pendingFoods.clear();
      await _savePendingFoods();
      
      print('🍎 PendingFoodService: Cleared all pending foods');
      return Success(true);
    } catch (e) {
      print('🍎 PendingFoodService: Error clearing pending foods: $e');
      return Failure(PendingFoodError.unknown);
    }
  }
} 