import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/i_online_food_service.dart';
import '../domain/online_food_models.dart';
import '../domain/i_food_database_service.dart';
import '../domain/food_record_model.dart';
import '../infrastructure/llm_food_service.dart';
import '../infrastructure/food_database_service.dart';
import 'online_food_state.dart';

// Provider for LLM service (only provider)
final llmFoodServiceProvider = Provider<IOnlineFoodService>((ref) {
  return LLMFoodService();
});

// Online food cubit provider - only uses LLM
final onlineFoodProvider = StateNotifierProvider<OnlineFoodCubit, OnlineFoodState>((ref) {
  final llmService = ref.read(llmFoodServiceProvider);
  final foodDatabaseService = FoodDatabaseService();
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

  /// Select all foods
  void selectAllFoods() {
    final allFoodIds = state.searchResults.map((food) => food.id).toList();
    state = state.copyWith(
      selectedFoodIds: allFoodIds,
      isSelectionMode: true,
    );
    print('🌐 OnlineFoodCubit: Selected all ${allFoodIds.length} foods');
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
        } else {
          print('🌐 OnlineFoodCubit: Failed to add "${food.name}" to database');
          state = state.copyWith(
            isAddingToDatabase: false,
            hasError: true,
            errorMessage: 'Kunne ikke tilføje til database',
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
        errorMessage: 'Fejl ved tilføjelse',
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
          } else {
            failureCount++;
          }
        } else {
          failureCount++;
        }
      } catch (e) {
        failureCount++;
      }
    }

    print('🌐 OnlineFoodCubit: Bulk add complete. $successCount/$failureCount successful');
    
    state = state.copyWith(
      isAddingToDatabase: false,
      isSelectionMode: false,
      selectedFoodIds: [],
      hasError: failureCount > 0,
      errorMessage: failureCount > 0 ? 'Nogle fødevarer kunne ikke tilføjes' : '',
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