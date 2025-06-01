import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/i_online_food_service.dart';
import '../domain/online_food_models.dart';
import '../domain/i_food_database_service.dart';
import '../domain/food_record_model.dart';
import '../infrastructure/llm_food_service.dart';
import '../infrastructure/food_database_service.dart';
import 'online_food_state.dart';
import 'providers.dart'; // Import shared providers

// Provider for LLM service (only provider)
final llmFoodServiceProvider = Provider<IOnlineFoodService>((ref) {
  return LLMFoodService();
});

// Shared provider for FoodDatabaseService
final foodDatabaseServiceProvider = Provider<IFoodDatabaseService>((ref) {
  return FoodDatabaseService();
});

// Online food cubit provider - uses shared database service
final onlineFoodProvider = StateNotifierProvider<OnlineFoodCubit, OnlineFoodState>((ref) {
  final llmService = ref.read(llmFoodServiceProvider);
  final foodDatabaseService = ref.read(foodDatabaseServiceProvider);
  return OnlineFoodCubit(llmService, foodDatabaseService);
});

class OnlineFoodCubit extends StateNotifier<OnlineFoodState> {
  final IOnlineFoodService _foodService;
  final IFoodDatabaseService _foodDatabaseService;

  OnlineFoodCubit(this._foodService, this._foodDatabaseService) 
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
    final bool allSelected = currentSelected.length == allFoodIds.length &&
                            allFoodIds.every((id) => currentSelected.contains(id));
    
    if (allSelected) {
      print('🌐 OnlineFoodCubit: All were selected, deselecting all');
      state = state.copyWith(
        selectedFoodIds: [],
        isSelectionMode: true, // Keep selection mode active
      );
    } else {
      print('🌐 OnlineFoodCubit: Not all selected, selecting all');
      state = state.copyWith(
        selectedFoodIds: allFoodIds,
        isSelectionMode: true,
      );
    }
    
    print('🌐 OnlineFoodCubit: After toggle - selected: ${state.selectedFoodIds.length}');
  }

  /// Select all foods
  void selectAllFoods() {
    final allFoodIds = state.searchResults.map((food) => food.id).toList();
    print('🌐 OnlineFoodCubit: selectAllFoods() called');
    print('🌐 OnlineFoodCubit: Current search results: ${state.searchResults.length}');
    print('🌐 OnlineFoodCubit: Current selected: ${state.selectedFoodIds.length}');
    print('🌐 OnlineFoodCubit: About to select all IDs: $allFoodIds');
    
    state = state.copyWith(
      selectedFoodIds: allFoodIds,
      isSelectionMode: true,
    );
    
    print('🌐 OnlineFoodCubit: After selectAll - selected: ${state.selectedFoodIds.length}');
    print('🌐 OnlineFoodCubit: Selection mode: ${state.isSelectionMode}');
  }

  /// Add single food to database
  Future<void> addFoodToDatabase(OnlineFoodResult food) async {
    print('🌐 OnlineFoodCubit: Adding "${food.name}" to database');
    
    state = state.copyWith(isAddingToDatabase: true);

    try {
      // Get detailed food information
      final detailsResult = await _foodService.getFoodDetails(food.id);
      
      if (detailsResult.isSuccess) {
        final details = detailsResult.success;
        
        // Convert to FoodRecordModel
        final foodRecord = FoodRecordModel(
          id: details.basicInfo.id,
          name: details.basicInfo.name,
          description: details.basicInfo.description,
          caloriesPer100g: details.nutrition.calories.round(),
          proteinPer100g: details.nutrition.protein,
          carbsPer100g: details.nutrition.carbs,
          fatPer100g: details.nutrition.fat,
          category: FoodCategory.other,
          servingSizes: details.servingSizes.map((serving) => ServingSize(
            name: serving.name,
            grams: serving.grams,
            isDefault: serving.isDefault,
          )).toList(),
          source: FoodSource.onlineDatabase,
          sourceProvider: details.basicInfo.provider,
          createdAt: DateTime.now(),
        );

        // Add to database
        final addResult = await _foodDatabaseService.addFood(foodRecord);
        
        if (addResult.isSuccess) {
          print('🌐 OnlineFoodCubit: Successfully added "${food.name}" to database');
          state = state.copyWith(
            isAddingToDatabase: false,
            hasError: false,
          );
        } else if (addResult.failure == FoodDatabaseError.alreadyExists) {
          print('🌐 OnlineFoodCubit: "${food.name}" already exists in database');
          state = state.copyWith(
            isAddingToDatabase: false,
            hasError: false, // Not an error, just info
            errorMessage: '✅ "${food.name}" er allerede i din database fra tidligere',
          );
        } else {
          print('🌐 OnlineFoodCubit: Failed to add "${food.name}" to database: ${addResult.failure}');
          
          // Get specific error message based on failure type
          String errorMessage;
          switch (addResult.failure) {
            case FoodDatabaseError.storage:
              errorMessage = 'Kunne ikke gemme fødevaren lige nu. Prøv igen.';
              break;
            case FoodDatabaseError.notFound:
              errorMessage = 'Fødevaren blev ikke fundet. Prøv at søge igen.';
              break;
            default:
              errorMessage = 'Noget gik galt. Prøv igen om lidt.';
          }
          
          state = state.copyWith(
            isAddingToDatabase: false,
            hasError: true,
            errorMessage: errorMessage,
          );
        }
      } else {
        print('🌐 OnlineFoodCubit: Failed to get details for "${food.name}"');
        state = state.copyWith(
          isAddingToDatabase: false,
          hasError: true,
          errorMessage: 'Kunne ikke hente fødevaredetaljer',
        );
      }
    } catch (e) {
      print('🌐 OnlineFoodCubit: Add food error: $e');
      state = state.copyWith(
        isAddingToDatabase: false,
        hasError: true,
        errorMessage: 'Uventet fejl ved tilføjelse',
      );
    }
  }

  /// Add multiple selected foods to database
  Future<void> addSelectedFoodsToDatabase() async {
    if (state.selectedFoodIds.isEmpty) return;

    final selectedIds = state.selectedFoodIds;
    final selectedFoods = state.searchResults
        .where((food) => selectedIds.contains(food.id))
        .toList();

    print('🌐 OnlineFoodCubit: Adding ${selectedFoods.length} foods to database');
    
    state = state.copyWith(isAddingToDatabase: true);

    int successCount = 0;
    int failureCount = 0;
    int alreadyExistsCount = 0;
    final List<String> failedFoodNames = [];

    for (final food in selectedFoods) {
      try {
        // Get detailed food information
        final detailsResult = await _foodService.getFoodDetails(food.id);
        
        if (detailsResult.isSuccess) {
          final details = detailsResult.success;
          
          // Convert to FoodRecordModel
          final foodRecord = FoodRecordModel(
            id: details.basicInfo.id,
            name: details.basicInfo.name,
            description: details.basicInfo.description,
            caloriesPer100g: details.nutrition.calories.round(),
            proteinPer100g: details.nutrition.protein,
            carbsPer100g: details.nutrition.carbs,
            fatPer100g: details.nutrition.fat,
            category: FoodCategory.other,
            servingSizes: details.servingSizes.map((serving) => ServingSize(
              name: serving.name,
              grams: serving.grams,
              isDefault: serving.isDefault,
            )).toList(),
            source: FoodSource.onlineDatabase,
            sourceProvider: details.basicInfo.provider,
            createdAt: DateTime.now(),
          );

          // Add to database
          final addResult = await _foodDatabaseService.addFood(foodRecord);
          
          if (addResult.isSuccess) {
            successCount++;
            print('🌐 OnlineFoodCubit: Successfully added "${food.name}" to database');
          } else if (addResult.failure == FoodDatabaseError.alreadyExists) {
            alreadyExistsCount++;
            print('🌐 OnlineFoodCubit: "${food.name}" already exists in database');
          } else {
            failureCount++;
            failedFoodNames.add(food.name);
            print('🌐 OnlineFoodCubit: Failed to add "${food.name}" to database: ${addResult.failure}');
          }
        } else {
          failureCount++;
          failedFoodNames.add(food.name);
          print('🌐 OnlineFoodCubit: Failed to get details for "${food.name}"');
        }
      } catch (e) {
        failureCount++;
        failedFoodNames.add(food.name);
        print('🌐 OnlineFoodCubit: Exception adding "${food.name}": $e');
      }
    }

    print('🌐 OnlineFoodCubit: Bulk add complete. $successCount new, $alreadyExistsCount existed, $failureCount failed');
    
    // Generate appropriate user-friendly message
    String errorMessage = '';
    bool hasError = false;
    
    if (successCount > 0 && alreadyExistsCount > 0 && failureCount == 0) {
      // Mixed success and already exists
      errorMessage = '$successCount nye tilføjet, $alreadyExistsCount fandtes allerede ✅';
    } else if (successCount == 0 && alreadyExistsCount > 0 && failureCount == 0) {
      // All already exist
      errorMessage = 'Alle ${alreadyExistsCount} fødevarer findes allerede i din database ✅';
    } else if (successCount > 0 && failureCount > 0) {
      // Mixed success and failure
      hasError = true;
      errorMessage = '$successCount tilføjet, $failureCount fejlede';
    } else if (successCount == 0 && failureCount > 0) {
      // All failed
      hasError = true;
      errorMessage = 'Kunne ikke tilføje fødevarerne. Prøv igen.';
    }
    
    state = state.copyWith(
      isAddingToDatabase: false,
      isSelectionMode: hasError, // Keep selection mode only if there were real errors
      selectedFoodIds: hasError ? state.selectedFoodIds : [], // Keep selections only if there were real errors
      hasError: hasError,
      errorMessage: errorMessage,
    );
  }

  /// Dismiss error
  void dismissError() {
    state = state.copyWith(
      hasError: false,
      errorMessage: '',
    );
  }
} 