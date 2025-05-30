import '../../activity/application/activity_state.dart';
import '../domain/meal_session_model.dart';

/// State for meal session management
class MealSessionState {
  final DataState<List<MealSessionModel>> mealSessionsState;
  final DataState<MealSessionModel> currentSessionState;
  final bool isCapturing;

  const MealSessionState._({
    required this.mealSessionsState,
    required this.currentSessionState,
    required this.isCapturing,
  });

  /// Initial state factory
  factory MealSessionState.initial() => const MealSessionState._(
    mealSessionsState: DataState.idle(),
    currentSessionState: DataState.idle(),
    isCapturing: false,
  );

  /// Copy with new values
  MealSessionState copyWith({
    DataState<List<MealSessionModel>>? mealSessionsState,
    DataState<MealSessionModel>? currentSessionState,
    bool? isCapturing,
  }) {
    return MealSessionState._(
      mealSessionsState: mealSessionsState ?? this.mealSessionsState,
      currentSessionState: currentSessionState ?? this.currentSessionState,
      isCapturing: isCapturing ?? this.isCapturing,
    );
  }

  // Helper getters for derived states
  bool get isLoadingMealSessions => mealSessionsState.isLoading;
  bool get hasMealSessionsError => mealSessionsState.hasError;
  bool get hasMealSessions => mealSessionsState.isSuccess && mealSessionsState.data!.isNotEmpty;
  List<MealSessionModel> get mealSessions => mealSessionsState.isSuccess ? mealSessionsState.data! : [];
  int get mealSessionsCount => mealSessions.length;
  
  bool get isCurrentSessionLoading => currentSessionState.isLoading;
  bool get hasCurrentSessionError => currentSessionState.hasError;
  bool get hasCurrentSession => currentSessionState.isSuccess;
  MealSessionModel? get currentSession => currentSessionState.isSuccess ? currentSessionState.data : null;
} 