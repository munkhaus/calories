import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/i_online_food_service.dart';
import '../domain/online_food_models.dart';
import '../../food_logging/domain/i_favorite_food_service.dart';
import '../../food_logging/domain/user_food_log_model.dart';
import '../../food_logging/domain/favorite_food_model.dart';
import '../infrastructure/llm_food_service.dart' as llm_service;
import '../../food_logging/infrastructure/favorite_food_service.dart';
import 'online_food_state.dart';

// Provider for FavoriteFoodService - now the primary food storage
final favoriteFoodServiceProvider = Provider<IFavoriteFoodService>((ref) {
  return FavoriteFoodService();
});

// Online food cubit provider - now uses favorite food service
final onlineFoodProvider = StateNotifierProvider<OnlineFoodCubit, OnlineFoodState>((ref) {
  final llmServiceInstance = ref.read(llm_service.llmFoodServiceProvider);
  final favoriteFoodService = ref.read(favoriteFoodServiceProvider);
  return OnlineFoodCubit(llmServiceInstance, favoriteFoodService);
});

class OnlineFoodCubit extends StateNotifier<OnlineFoodState> {
  final llm_service.LLMFoodService _foodService;
  final IFavoriteFoodService _favoriteFoodService;

  OnlineFoodCubit(this._foodService, this._favoriteFoodService) 
      : super(OnlineFoodState.initial());

  /// Initialize the service
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final result = await _foodService.initialize();
      
      if (result.isSuccess) {
        print('🌐 OnlineFoodCubit: LLM service initialized successfully');
        state = state.copyWith(
          isLoading: false,
          isServiceAvailable: true,
          hasError: false,
        );
      } else {
        print('🌐 OnlineFoodCubit: LLM service initialization failed');
        state = state.copyWith(
          isLoading: false,
          isServiceAvailable: false,
          hasError: true,
          errorMessage: 'Service ikke tilgængelig',
        );
      }
    } catch (e) {
      print('🌐 OnlineFoodCubit: Initialization error: $e');
      state = state.copyWith(
        isLoading: false,
        isServiceAvailable: false,
        hasError: true,
        errorMessage: 'Fejl ved initialisering',
      );
    }
  }

  /// Clear search results and reset state
  void clearResults() {
    state = state.copyWith(
      searchResults: [],
      searchQuery: '',
      selectedFoodDetails: null,
      hasError: false,
      errorMessage: '',
      isSelectionMode: false,
      selectedFoodIds: [],
    );
  }

  /// Search for foods using LLM
  Future<void> searchFoods(String query, {SearchMode? searchMode}) async {
    if (query.trim().isEmpty) return;

    print('🌐 OnlineFoodCubit: Searching for "$query" with mode: $searchMode');
    
    state = state.copyWith(
      isLoading: true,
      searchQuery: query,
      hasError: false,
      searchResults: [],
      selectedFoodDetails: null,
    );

    try {
      final result = await _foodService.searchFoods(query);
      
      if (result.isSuccess) {
        var results = result.success;
        
        // Filter results based on search mode if specified
        if (searchMode != null) {
          results = results.where((food) => food.searchMode == searchMode).toList();
          print('🌐 OnlineFoodCubit: Filtered to ${results.length} results for mode: $searchMode');
        }
        
        print('🌐 OnlineFoodCubit: Found ${results.length} results');
        
        state = state.copyWith(
          isLoading: false,
          searchResults: results,
          hasError: false,
        );
      } else {
        print('🌐 OnlineFoodCubit: Search failed');
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: 'Søgning fejlede',
        );
      }
    } catch (e) {
      print('🌐 OnlineFoodCubit: Search error: $e');
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Fejl ved søgning',
      );
    }
  }

  /// Get detailed information for a food item
  Future<void> getFoodDetails(String foodId) async {
    print('🌐 OnlineFoodCubit: Getting details for "$foodId"');
    
    state = state.copyWith(isLoadingDetails: true);

    try {
      final result = await _foodService.getFoodDetails(foodId);
      
      if (result.isSuccess) {
        final details = result.success;
        print('🌐 OnlineFoodCubit: Got details for "$foodId"');
        
        state = state.copyWith(
          isLoadingDetails: false,
          selectedFoodDetails: details,
        );
      } else {
        print('🌐 OnlineFoodCubit: Failed to get details for "$foodId"');
        state = state.copyWith(
          isLoadingDetails: false,
          hasError: true,
          errorMessage: 'Kunne ikke hente detaljer',
        );
      }
    } catch (e) {
      print('🌐 OnlineFoodCubit: Details error: $e');
      state = state.copyWith(
        isLoadingDetails: false,
        hasError: true,
        errorMessage: 'Fejl ved hentning af detaljer',
      );
    }
  }

  /// Add a single food to favorites
  Future<void> addFoodToFavorites(String foodId, {
    MealType? preferredMealType,
    double? preferredQuantity,
    String? preferredServingUnit,
  }) async {
    print('🌐 OnlineFoodCubit: Adding "$foodId" to favorites');
    
    try {
      // Get details first
      await getFoodDetails(foodId);
      
      final details = state.selectedFoodDetails;
      if (details == null) {
        state = state.copyWith(
          hasError: true,
          errorMessage: 'Kunne ikke hente madvarens detaljer',
        );
        return;
      }
      
      // Add to favorites
      final result = await _favoriteFoodService.addOnlineFoodToFavorites(
        details,
        preferredMealType: preferredMealType,
        preferredQuantity: preferredQuantity,
        preferredServingUnit: preferredServingUnit,
      );
      
      if (result.isSuccess) {
        print('🌐 OnlineFoodCubit: Successfully added "${details.basicInfo.name}" to favorites');
        state = state.copyWith(
          hasError: false,
          errorMessage: '✅ ${details.basicInfo.name} tilføjet til favoritter',
        );
      } else {
        final isAlreadyExists = result.failure == FavoriteFoodError.alreadyExists;
        print('🌐 OnlineFoodCubit: "${details.basicInfo.name}" ${isAlreadyExists ? "already exists in" : "failed to add to"} favorites');
        
        state = state.copyWith(
          hasError: !isAlreadyExists,
          errorMessage: isAlreadyExists 
              ? '✅ ${details.basicInfo.name} findes allerede i favoritter'
              : '❌ Kunne ikke tilføje ${details.basicInfo.name} til favoritter',
        );
      }
    } catch (e) {
      print('🌐 OnlineFoodCubit: Add to favorites error: $e');
      state = state.copyWith(
        hasError: true,
        errorMessage: '❌ Fejl ved tilføjelse til favoritter',
      );
    }
  }

  /// Toggle selection mode
  void toggleSelectionMode() {
    state = state.copyWith(
      isSelectionMode: !state.isSelectionMode,
      selectedFoodIds: [], // Clear selections when toggling
    );
    print('🌐 OnlineFoodCubit: Selection mode: ${state.isSelectionMode}');
  }

  /// Toggle food selection
  void toggleFoodSelection(String foodId) {
    final selectedIds = List<String>.from(state.selectedFoodIds);
    
    if (selectedIds.contains(foodId)) {
      selectedIds.remove(foodId);
    } else {
      selectedIds.add(foodId);
    }
    
    state = state.copyWith(selectedFoodIds: selectedIds);
    print('🌐 OnlineFoodCubit: Selected foods: ${selectedIds.length}');
  }

  /// Toggle select all foods (select all if none/some selected, deselect all if all selected)
  void toggleSelectAllFoods() {
    final allFoodIds = state.searchResults.map((food) => food.id).toList();
    final currentSelected = state.selectedFoodIds;
    
    print('🌐 OnlineFoodCubit: toggleSelectAllFoods() called');
    print('🌐 OnlineFoodCubit: Total foods: ${allFoodIds.length}');
    print('🌐 OnlineFoodCubit: Currently selected: ${currentSelected.length}');
    
    // If all are selected, deselect all. Otherwise, select all.
    List<String> newSelection;
    if (currentSelected.length == allFoodIds.length && 
        allFoodIds.every((id) => currentSelected.contains(id))) {
      // All are selected, so deselect all
      newSelection = [];
      print('🌐 OnlineFoodCubit: Deselecting all foods');
    } else {
      // Not all are selected, so select all
      newSelection = allFoodIds;
      print('🌐 OnlineFoodCubit: Selecting all ${allFoodIds.length} foods');
    }
    
    state = state.copyWith(selectedFoodIds: newSelection);
    print('🌐 OnlineFoodCubit: New selection count: ${newSelection.length}');
  }

  /// Add selected foods to favorites
  Future<void> addSelectedFoodsToFavorites({
    MealType? preferredMealType,
    double? preferredQuantity,
    String? preferredServingUnit,
  }) async {
    if (state.selectedFoodIds.isEmpty) return;

    state = state.copyWith(isLoading: true, hasError: false, errorMessage: '');

      int successCount = 0;
    List<String> failedFoods = [];
      
    for (final foodId in state.selectedFoodIds) {
      try {
        // Get details first (important to get fresh details)
        final detailsResult = await _foodService.getFoodDetails(foodId);
        
        if (detailsResult.isSuccess) {
        final details = detailsResult.success;
          final favorite = FavoriteFoodModel.fromOnlineFoodDetails(
            details,
            preferredMealType: preferredMealType,
            preferredQuantityGrams: preferredQuantity,
          );
          
          final addResult = await _favoriteFoodService.addToFavorites(favorite);
        if (addResult.isSuccess) {
          successCount++;
          } else {
            failedFoods.add(details.basicInfo.name);
          }
        } else {
          failedFoods.add('Ukendt ($foodId)'); // Could not get details
        }
      } catch (e) {
        failedFoods.add('Ukendt ($foodId) - Fejl: $e');
        }
      }

    String message;
    if (successCount == state.selectedFoodIds.length) {
      message = '✅ Alle valgte madvarer tilføjet til favoritter!';
    } else if (successCount > 0) {
      message = '✅ $successCount madvarer tilføjet. ${failedFoods.length} fejlede: ${failedFoods.join(', ')}';
    } else {
      message = '❌ Kunne ikke tilføje nogen af de valgte madvarer. Fejlede: ${failedFoods.join(', ')}';
    }
      
      state = state.copyWith(
      isLoading: false,
      hasError: successCount < state.selectedFoodIds.length,
      errorMessage: message,
      selectedFoodIds: [], // Clear selection after attempt
        isSelectionMode: false, // Exit selection mode
      );
    print('🌐 OnlineFoodCubit: Added $successCount / ${state.selectedFoodIds.length} to favorites.');
  }

  /// Dismiss error
  void dismissError() {
    state = state.copyWith(
      hasError: false,
      errorMessage: '',
    );
  }
} 