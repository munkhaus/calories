import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/i_favorite_food_service.dart';
import '../domain/favorite_food_model.dart';
import '../domain/user_food_log_model.dart';
import '../../food_database/domain/i_online_food_service.dart';
import '../../food_database/domain/online_food_models.dart';
import '../infrastructure/favorite_food_service.dart';
import '../../food_database/infrastructure/llm_food_service.dart';
import 'food_search_state.dart';
import 'food_logging_notifier.dart';

// Providers
final favoriteFoodServiceProvider = Provider<IFavoriteFoodService>((ref) {
  return FavoriteFoodService();
});

final onlineFoodServiceProvider = Provider<IOnlineFoodService>((ref) {
  return LLMFoodService();
});

final foodSearchProvider = StateNotifierProvider<FoodSearchCubit, FoodSearchState>((ref) {
  final favoriteService = ref.read(favoriteFoodServiceProvider);
  final onlineService = ref.read(onlineFoodServiceProvider);
  final foodLoggingNotifier = ref.read(foodLoggingProvider.notifier);
  return FoodSearchCubit(favoriteService, onlineService, foodLoggingNotifier);
});

/// Comprehensive food search cubit that combines favorites and online search
class FoodSearchCubit extends StateNotifier<FoodSearchState> {
  final IFavoriteFoodService _favoriteService;
  final IOnlineFoodService _onlineService;
  final FoodLoggingNotifier _foodLoggingNotifier;

  FoodSearchCubit(this._favoriteService, this._onlineService, this._foodLoggingNotifier) 
      : super(FoodSearchState.initial());

  /// Initialize services
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Initialize online service
      await _onlineService.initialize();
      
      // Load recent favorites for quick access
      final recentResult = await _favoriteService.getRecentFavorites(limit: 10);
      final quickSuggestionsResult = await _favoriteService.getQuickSuggestions(limit: 5);
      
      state = state.copyWith(
        isLoading: false,
        recentFavorites: recentResult.isSuccess ? recentResult.success : [],
        quickSuggestions: quickSuggestionsResult.isSuccess ? quickSuggestionsResult.success : [],
        isOnlineServiceAvailable: true,
      );
      
      print('🔍 FoodSearchCubit: Initialized with ${state.recentFavorites.length} recent favorites');
    } catch (e) {
      print('🔍 FoodSearchCubit: Initialization error: $e');
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Fejl ved initialisering',
      );
    }
  }

  /// Clear search and reset to initial state
  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      favoriteResults: [],
      onlineResults: [],
      selectedFood: null,
      hasError: false,
      errorMessage: '',
      isSearchingFavorites: false,
      isSearchingOnline: false,
    );
  }

  /// Search both favorites and online based on query
  Future<void> searchFood(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    print('🔍 FoodSearchCubit: Searching for "$query"');
    
    state = state.copyWith(
      searchQuery: query,
      isSearchingFavorites: true,
      isSearchingOnline: true,
      hasError: false,
      favoriteResults: [],
      onlineResults: [],
    );

    // Search favorites first (faster)
    try {
      final favoriteResult = await _favoriteService.searchFavorites(query);
      if (favoriteResult.isSuccess) {
        state = state.copyWith(
          favoriteResults: favoriteResult.success,
          isSearchingFavorites: false,
        );
        print('🔍 FoodSearchCubit: Found ${favoriteResult.success.length} favorites for "$query"');
      } else {
        state = state.copyWith(
          favoriteResults: [],
          isSearchingFavorites: false,
        );
      }
    } catch (e) {
      print('🔍 FoodSearchCubit: Favorite search error: $e');
      state = state.copyWith(
        favoriteResults: [],
        isSearchingFavorites: false,
      );
    }

    // Search online if enabled
    if (state.isOnlineServiceAvailable) {
      try {
        final onlineResult = await _onlineService.searchFoods(query);
        if (onlineResult.isSuccess) {
          state = state.copyWith(
            onlineResults: onlineResult.success,
            isSearchingOnline: false,
          );
          print('🔍 FoodSearchCubit: Found ${onlineResult.success.length} online results for "$query"');
        } else {
          state = state.copyWith(
            onlineResults: [],
            isSearchingOnline: false,
          );
        }
      } catch (e) {
        print('🔍 FoodSearchCubit: Online search error: $e');
        state = state.copyWith(
          onlineResults: [],
          isSearchingOnline: false,
        );
      }
    } else {
      state = state.copyWith(isSearchingOnline: false);
    }
  }

  /// Get details for online food
  Future<void> getOnlineFoodDetails(String foodId) async {
    print('🔍 FoodSearchCubit: Getting details for online food "$foodId"');
    
    state = state.copyWith(isLoadingDetails: true);

    try {
      final result = await _onlineService.getFoodDetails(foodId);
      
      if (result.isSuccess) {
        state = state.copyWith(
          isLoadingDetails: false,
          selectedOnlineFoodDetails: result.success,
        );
        print('🔍 FoodSearchCubit: Got details for "$foodId"');
      } else {
        state = state.copyWith(
          isLoadingDetails: false,
          hasError: true,
          errorMessage: 'Kunne ikke hente detaljer',
        );
      }
    } catch (e) {
      print('🔍 FoodSearchCubit: Details error: $e');
      state = state.copyWith(
        isLoadingDetails: false,
        hasError: true,
        errorMessage: 'Fejl ved hentning af detaljer',
      );
    }
  }

  /// Add online food to favorites
  Future<void> addOnlineFoodToFavorites(
    OnlineFoodDetails details, {
    MealType? preferredMealType,
    double? preferredQuantity,
    String? preferredServingUnit,
  }) async {
    print('🔍 FoodSearchCubit: Adding "${details.basicInfo.name}" to favorites');
    
    try {
      final result = await _favoriteService.addOnlineFoodToFavorites(
        details,
        preferredMealType: preferredMealType,
        preferredQuantity: preferredQuantity,
        preferredServingUnit: preferredServingUnit,
      );
      
      if (result.isSuccess) {
        print('🔍 FoodSearchCubit: Successfully added "${details.basicInfo.name}" to favorites');
        
        // Refresh search results to show the new favorite
        if (state.searchQuery.isNotEmpty) {
          final updatedSearch = await _favoriteService.searchFavorites(state.searchQuery);
          if (updatedSearch.isSuccess) {
            state = state.copyWith(favoriteResults: updatedSearch.success);
          }
        }
        
        state = state.copyWith(
          hasError: false,
          errorMessage: '✅ ${details.basicInfo.name} tilføjet til favoritter',
        );
      } else {
        final isAlreadyExists = result.failure == FavoriteFoodError.alreadyExists;
        state = state.copyWith(
          hasError: !isAlreadyExists,
          errorMessage: isAlreadyExists 
              ? '✅ ${details.basicInfo.name} findes allerede i favoritter'
              : '❌ Kunne ikke tilføje ${details.basicInfo.name} til favoritter',
        );
      }
    } catch (e) {
      print('🔍 FoodSearchCubit: Add to favorites error: $e');
      state = state.copyWith(
        hasError: true,
        errorMessage: '❌ Fejl ved tilføjelse til favoritter',
      );
    }
  }

  /// Use a favorite food and increment usage
  Future<void> useFavoriteFood(FavoriteFoodModel favorite) async {
    print('🔍 FoodSearchCubit: Using favorite food "${favorite.foodName}"');
    
    try {
      await _favoriteService.incrementFavoriteUsage(favorite.id);
      print('🔍 FoodSearchCubit: Incremented usage for "${favorite.foodName}"');
    } catch (e) {
      print('🔍 FoodSearchCubit: Error incrementing usage: $e');
    }
  }

  /// Get favorites by meal type
  Future<void> loadFavoritesByMealType(MealType mealType) async {
    print('🔍 FoodSearchCubit: Loading favorites for meal type: $mealType');
    
    state = state.copyWith(isSearchingFavorites: true);
    
    try {
      final result = await _favoriteService.getFavoritesByMealType(mealType);
      
      if (result.isSuccess) {
        state = state.copyWith(
          favoriteResults: result.success,
          isSearchingFavorites: false,
          searchQuery: '', // Clear search query when filtering by meal type
        );
        print('🔍 FoodSearchCubit: Loaded ${result.success.length} favorites for $mealType');
      } else {
        state = state.copyWith(
          favoriteResults: [],
          isSearchingFavorites: false,
        );
      }
    } catch (e) {
      print('🔍 FoodSearchCubit: Error loading favorites by meal type: $e');
      state = state.copyWith(
        favoriteResults: [],
        isSearchingFavorites: false,
        hasError: true,
        errorMessage: 'Fejl ved indlæsning af favoritter',
      );
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    print('🔍 FoodSearchCubit: Refreshing data');
    await initialize();
  }

  /// Use online food immediately (get details, create food log)
  Future<void> useOnlineFoodNow(String foodId) async {
    print('🔍 FoodSearchCubit: Using online food now "$foodId"');
    
    try {
      // Get details first
      final result = await _onlineService.getFoodDetails(foodId);
      
      if (result.isSuccess) {
        final details = result.success;
        final defaultServing = details.servingSizes.firstWhere((s) => s.isDefault);
        
        // Create UserFoodLogModel from online food details
        final foodLog = UserFoodLogModel(
          userId: 1, // TODO: Get real user ID
          foodName: details.basicInfo.name,
          mealType: MealType.none, // User can change later
          quantity: defaultServing.grams,
          servingUnit: 'g',
          calories: (details.nutrition.calories * defaultServing.grams / 100).round(),
          protein: details.nutrition.protein * defaultServing.grams / 100,
          carbs: details.nutrition.carbs * defaultServing.grams / 100,
          fat: details.nutrition.fat * defaultServing.grams / 100,
        );
        
        // Log the food using the food logging provider
        await _foodLoggingNotifier.logFood(foodLog);
        
        print('🔍 FoodSearchCubit: Successfully logged "${details.basicInfo.name}"');
      } else {
        throw Exception('Kunne ikke hente mad detaljer');
      }
    } catch (e) {
      print('🔍 FoodSearchCubit: Error using online food now: $e');
      throw e;
    }
  }

  /// Save online food as favorite only
  Future<void> saveFavoriteFood(String foodId) async {
    print('🔍 FoodSearchCubit: Saving online food as favorite "$foodId"');
    
    try {
      // Get details first
      final result = await _onlineService.getFoodDetails(foodId);
      
      if (result.isSuccess) {
        final details = result.success;
        
        // Add to favorites
        await addOnlineFoodToFavorites(details);
        
        print('🔍 FoodSearchCubit: Successfully saved "${details.basicInfo.name}" as favorite');
      } else {
        throw Exception('Kunne ikke hente mad detaljer');
      }
    } catch (e) {
      print('🔍 FoodSearchCubit: Error saving favorite food: $e');
      throw e;
    }
  }

  /// Use online food now AND save as favorite
  Future<void> useOnlineFoodAndSave(String foodId) async {
    print('🔍 FoodSearchCubit: Using online food now and saving as favorite "$foodId"');
    
    try {
      // Get details first
      final result = await _onlineService.getFoodDetails(foodId);
      
      if (result.isSuccess) {
        final details = result.success;
        final defaultServing = details.servingSizes.firstWhere((s) => s.isDefault);
        
        // 1. Create UserFoodLogModel and log it
        final foodLog = UserFoodLogModel(
          userId: 1, // TODO: Get real user ID
          foodName: details.basicInfo.name,
          mealType: MealType.none, // User can change later
          quantity: defaultServing.grams,
          servingUnit: 'g',
          calories: (details.nutrition.calories * defaultServing.grams / 100).round(),
          protein: details.nutrition.protein * defaultServing.grams / 100,
          carbs: details.nutrition.carbs * defaultServing.grams / 100,
          fat: details.nutrition.fat * defaultServing.grams / 100,
        );
        
        await _foodLoggingNotifier.logFood(foodLog);
        
        // 2. Add to favorites
        await addOnlineFoodToFavorites(details);
        
        print('🔍 FoodSearchCubit: Successfully used and saved "${details.basicInfo.name}"');
      } else {
        throw Exception('Kunne ikke hente mad detaljer');
      }
    } catch (e) {
      print('🔍 FoodSearchCubit: Error using and saving food: $e');
      throw e;
    }
  }
} 