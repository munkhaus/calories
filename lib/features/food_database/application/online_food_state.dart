import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/online_food_models.dart';

part 'online_food_state.freezed.dart';

@freezed
class OnlineFoodState with _$OnlineFoodState {
  const OnlineFoodState._();

  const factory OnlineFoodState({
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingDetails,
    @Default(false) bool isAddingToDatabase,
    @Default(false) bool isServiceAvailable,
    @Default([]) List<OnlineFoodResult> searchResults,
    OnlineFoodDetails? selectedFoodDetails,
    @Default('') String searchQuery,
    @Default('') String errorMessage,
    @Default(false) bool hasError,
    
    // Multi-selection features
    @Default(false) bool isSelectionMode,
    @Default([]) List<String> selectedFoodIds,
    @Default(0) int addedCount,
  }) = _OnlineFoodState;

  // Helper getters
  bool get hasResults => searchResults.isNotEmpty;
  bool get hasSearched => searchQuery.isNotEmpty;
  bool get isIdle => !isLoading && !hasError;
  bool get hasSelectedItems => selectedFoodIds.isNotEmpty;
  int get selectedCount => selectedFoodIds.length;

  factory OnlineFoodState.initial() => const OnlineFoodState();
} 