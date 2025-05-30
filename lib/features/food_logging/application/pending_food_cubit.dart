import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../activity/application/activity_state.dart';
import '../domain/i_pending_food_service.dart';
import '../infrastructure/pending_food_service.dart';
import 'pending_food_state.dart';

/// Cubit for managing pending food items
class PendingFoodCubit extends StateNotifier<PendingFoodState> {
  final IPendingFoodService _service;

  PendingFoodCubit({
    IPendingFoodService? service,
  })  : _service = service ?? PendingFoodService(),
        super(PendingFoodState.initial());

  /// Initialize pending foods by loading them
  Future<void> initialize() async {
    await loadPendingFoods();
  }

  /// Capture new food photo
  Future<void> captureFood() async {
    state = state.copyWith(
      captureState: const DataState.loading(),
      isCapturing: true,
    );

    final result = await _service.captureFood();

    if (result.isSuccess) {
      state = state.copyWith(
        captureState: DataState.success(result.success),
        isCapturing: false,
      );
      
      // Reload pending foods to include the new item
      await loadPendingFoods();
    } else {
      state = state.copyWith(
        captureState: const DataState.error('Kunne ikke tage billede'),
        isCapturing: false,
      );
    }
  }

  /// Load all pending food items
  Future<void> loadPendingFoods() async {
    state = state.copyWith(
      pendingFoodsState: const DataState.loading(),
    );

    final result = await _service.getPendingFoods();

    if (result.isSuccess) {
      state = state.copyWith(
        pendingFoodsState: DataState.success(result.success),
      );
    } else {
      state = state.copyWith(
        pendingFoodsState: const DataState.error('Kunne ikke indlæse afventende mad'),
      );
    }
  }

  /// Mark pending food as processed (categorized)
  Future<bool> markAsProcessed(String id) async {
    final result = await _service.markAsProcessed(id);
    
    if (result.isSuccess) {
      // Reload pending foods to update the list
      await loadPendingFoods();
      return true;
    }
    
    return false;
  }

  /// Delete pending food item
  Future<bool> deletePendingFood(String id) async {
    final result = await _service.deletePendingFood(id);
    
    if (result.isSuccess) {
      // Reload pending foods to update the list
      await loadPendingFoods();
      return true;
    }
    
    return false;
  }

  /// Add notes to pending food item
  Future<bool> addNotes(String id, String notes) async {
    final result = await _service.addNotes(id, notes);
    
    if (result.isSuccess) {
      // Reload pending foods to update the list
      await loadPendingFoods();
      return true;
    }
    
    return false;
  }

  /// Retry loading pending foods after error
  Future<void> retryLoadPendingFoods() async {
    await loadPendingFoods();
  }

  /// Retry capturing food after error
  Future<void> retryCaptureFood() async {
    await captureFood();
  }

  /// Clear capture state
  void clearCaptureState() {
    state = state.copyWith(
      captureState: const DataState.idle(),
    );
  }
}

/// Provider for pending food cubit
final pendingFoodProvider = StateNotifierProvider<PendingFoodCubit, PendingFoodState>((ref) {
  return PendingFoodCubit();
});

/// Helper providers
final pendingFoodsCountProvider = Provider<int>((ref) {
  return ref.watch(pendingFoodProvider).pendingFoodsCount;
});

final hasPendingFoodsProvider = Provider<bool>((ref) {
  return ref.watch(pendingFoodProvider).hasPendingFoods;
});

final pendingFoodsListProvider = Provider<List<dynamic>>((ref) {
  return ref.watch(pendingFoodProvider).pendingFoods;
}); 