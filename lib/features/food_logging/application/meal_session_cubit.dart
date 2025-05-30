import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../activity/application/activity_state.dart';
import '../domain/i_meal_session_service.dart';
import '../domain/meal_session_model.dart';
import '../infrastructure/meal_session_service.dart';
import 'meal_session_state.dart';

/// Cubit for managing meal sessions (multi-photo meals)
class MealSessionCubit extends StateNotifier<MealSessionState> {
  final IMealSessionService _service;

  MealSessionCubit({
    IMealSessionService? service,
  })  : _service = service ?? MealSessionService(),
        super(MealSessionState.initial());

  /// Initialize meal sessions by loading them
  Future<void> initialize() async {
    print('🍎 MealSessionCubit: initialize() called');
    await loadMealSessions();
  }

  /// Start a new meal session
  Future<void> startMealSession() async {
    print('🍎 MealSessionCubit: startMealSession() called');
    state = state.copyWith(
      currentSessionState: const DataState.loading(),
    );

    final result = await _service.startMealSession();

    if (result.isSuccess) {
      print('🍎 MealSessionCubit: startMealSession() success');
      state = state.copyWith(
        currentSessionState: DataState.success(result.success),
      );
      
      // Reload meal sessions to include the new session
      await loadMealSessions();
    } else {
      print('🍎 MealSessionCubit: startMealSession() failed: ${result.failure}');
      state = state.copyWith(
        currentSessionState: const DataState.error('Kunne ikke starte måltidssession'),
      );
    }
  }

  /// Add image to current session via camera
  Future<void> addImageToSession(String sessionId) async {
    state = state.copyWith(
      isCapturing: true,
    );

    final result = await _service.addImageToSession(sessionId);

    if (result.isSuccess) {
      state = state.copyWith(
        currentSessionState: DataState.success(result.success),
        isCapturing: false,
      );
      
      // Reload meal sessions to reflect changes
      await loadMealSessions();
    } else {
      String errorMessage = 'Kunne ikke tilføje billede';
      
      switch (result.failure) {
        case MealSessionError.maxImagesReached:
          errorMessage = 'Maksimalt antal billeder nået (5)';
          break;
        case MealSessionError.userCancelled:
          errorMessage = 'Billede ikke taget';
          break;
        case MealSessionError.permissionDenied:
          errorMessage = 'Kamera adgang nægtet';
          break;
        case MealSessionError.cameraUnavailable:
          errorMessage = 'Kamera ikke tilgængeligt';
          break;
        default:
          break;
      }
      
      state = state.copyWith(
        currentSessionState: DataState.error(errorMessage),
        isCapturing: false,
      );
    }
  }

  /// Add image to current session via gallery
  Future<void> addImageFromGalleryToSession(String sessionId) async {
    state = state.copyWith(
      isCapturing: true,
    );

    final result = await _service.addImageFromGalleryToSession(sessionId);

    if (result.isSuccess) {
      state = state.copyWith(
        currentSessionState: DataState.success(result.success),
        isCapturing: false,
      );
      
      // Reload meal sessions to reflect changes
      await loadMealSessions();
    } else {
      String errorMessage = 'Kunne ikke tilføje billede fra galleri';
      
      switch (result.failure) {
        case MealSessionError.maxImagesReached:
          errorMessage = 'Maksimalt antal billeder nået (5)';
          break;
        case MealSessionError.userCancelled:
          errorMessage = 'Billede ikke valgt';
          break;
        default:
          break;
      }
      
      state = state.copyWith(
        currentSessionState: DataState.error(errorMessage),
        isCapturing: false,
      );
    }
  }

  /// Load all meal sessions
  Future<void> loadMealSessions() async {
    print('🍎 MealSessionCubit: loadMealSessions() called');
    state = state.copyWith(
      mealSessionsState: const DataState.loading(),
    );

    final result = await _service.getMealSessions();

    if (result.isSuccess) {
      print('🍎 MealSessionCubit: loadMealSessions() success - found ${result.success.length} sessions');
      state = state.copyWith(
        mealSessionsState: DataState.success(result.success),
      );
    } else {
      print('🍎 MealSessionCubit: loadMealSessions() failed: ${result.failure}');
      state = state.copyWith(
        mealSessionsState: const DataState.error('Kunne ikke indlæse måltidssessioner'),
      );
    }
  }

  /// Process meal session (analyze all images and create food log)
  Future<bool> processMealSession(String id) async {
    final result = await _service.processMealSession(id);
    
    if (result.isSuccess) {
      // Clear current session if it was the one processed
      if (state.currentSession?.id == id) {
        state = state.copyWith(
          currentSessionState: const DataState.idle(),
        );
      }
      
      // Reload meal sessions to update the list
      await loadMealSessions();
      return true;
    }
    
    return false;
  }

  /// Delete meal session
  Future<bool> deleteMealSession(String id) async {
    // Use the service method we created
    final service = _service as MealSessionService;
    final result = await service.deleteMealSession(id);
    
    if (result.isSuccess) {
      // Clear current session if it was the one deleted
      if (state.currentSession?.id == id) {
        state = state.copyWith(
          currentSessionState: const DataState.idle(),
        );
      }
      
      // Reload meal sessions to update the list
      await loadMealSessions();
      return true;
    }
    
    return false;
  }

  /// Remove specific image from session
  Future<bool> removeImageFromSession(String sessionId, String imagePath) async {
    final service = _service as MealSessionService;
    final result = await service.removeImageFromSession(sessionId, imagePath);
    
    if (result.isSuccess) {
      // Update current session if it's the one being modified
      if (state.currentSession?.id == sessionId) {
        state = state.copyWith(
          currentSessionState: DataState.success(result.success),
        );
      }
      
      // Reload meal sessions to update the list
      await loadMealSessions();
      return true;
    }
    
    return false;
  }

  /// Clear current session
  void clearCurrentSession() {
    state = state.copyWith(
      currentSessionState: const DataState.idle(),
    );
  }

  /// Retry loading meal sessions after error
  Future<void> retryLoadMealSessions() async {
    await loadMealSessions();
  }
}

/// Provider for meal session cubit
final mealSessionProvider = StateNotifierProvider<MealSessionCubit, MealSessionState>((ref) {
  return MealSessionCubit();
});

/// Helper providers
final mealSessionsCountProvider = Provider<int>((ref) {
  return ref.watch(mealSessionProvider).mealSessionsCount;
});

final hasMealSessionsProvider = Provider<bool>((ref) {
  return ref.watch(mealSessionProvider).hasMealSessions;
});

final currentMealSessionProvider = Provider<MealSessionModel?>((ref) {
  return ref.watch(mealSessionProvider).currentSession;
}); 