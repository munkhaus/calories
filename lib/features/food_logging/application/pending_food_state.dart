import '../../activity/application/activity_state.dart';
import '../domain/pending_food_model.dart';

/// State for pending food management
class PendingFoodState {
  final DataState<List<PendingFoodModel>> pendingFoodsState;
  final DataState<PendingFoodModel> captureState;
  final bool isCapturing;

  const PendingFoodState._({
    required this.pendingFoodsState,
    required this.captureState,
    required this.isCapturing,
  });

  /// Initial state factory
  factory PendingFoodState.initial() => const PendingFoodState._(
    pendingFoodsState: DataState.idle(),
    captureState: DataState.idle(),
    isCapturing: false,
  );

  /// Copy with new values
  PendingFoodState copyWith({
    DataState<List<PendingFoodModel>>? pendingFoodsState,
    DataState<PendingFoodModel>? captureState,
    bool? isCapturing,
  }) {
    return PendingFoodState._(
      pendingFoodsState: pendingFoodsState ?? this.pendingFoodsState,
      captureState: captureState ?? this.captureState,
      isCapturing: isCapturing ?? this.isCapturing,
    );
  }

  // Helper getters for derived states
  bool get isLoadingPendingFoods => pendingFoodsState.isLoading;
  bool get hasPendingFoodsError => pendingFoodsState.hasError;
  
  // Only count unprocessed pending foods
  List<PendingFoodModel> get pendingFoods => pendingFoodsState.isSuccess 
      ? pendingFoodsState.data!.where((food) => !food.isProcessed).toList()
      : [];
  
  bool get hasPendingFoods => pendingFoods.isNotEmpty;
  int get pendingFoodsCount => pendingFoods.length;
  
  bool get isCaptureLoading => captureState.isLoading;
  bool get hasCaptureError => captureState.hasError;
  bool get hasCaptureSuccess => captureState.isSuccess;
} 