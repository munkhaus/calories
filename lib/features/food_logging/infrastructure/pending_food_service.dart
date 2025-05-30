import 'package:result_type/result_type.dart';
import '../domain/i_pending_food_service.dart';
import '../domain/pending_food_model.dart';

/// Mock implementation of pending food service (will be replaced with real camera integration)
class PendingFoodService implements IPendingFoodService {
  static final List<PendingFoodModel> _pendingFoods = [];

  @override
  Future<Result<PendingFoodModel, PendingFoodError>> captureFood() async {
    try {
      // Mock implementation - simulate camera capture
      await Future.delayed(const Duration(milliseconds: 500));

      // Create mock pending food
      final pendingFood = PendingFoodModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: 'mock_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        capturedAt: DateTime.now(),
        notes: 'Mock billede af mad',
      );

      // Add to list
      _pendingFoods.add(pendingFood);

      return Success(pendingFood);
    } catch (e) {
      return Failure(PendingFoodError.imageSave);
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
      
      return Success(unprocessed);
    } catch (e) {
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