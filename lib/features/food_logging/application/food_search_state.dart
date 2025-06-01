import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/favorite_food_model.dart';
import '../../food_database/domain/online_food_models.dart';

part 'food_search_state.freezed.dart';

@freezed
class FoodSearchState with _$FoodSearchState {
  const FoodSearchState._();

  const factory FoodSearchState({
    // Loading states
    @Default(false) bool isLoading,
    @Default(false) bool isSearchingFavorites,
    @Default(false) bool isSearchingOnline,
    @Default(false) bool isLoadingDetails,
    
    // Search data
    @Default('') String searchQuery,
    @Default([]) List<FavoriteFoodModel> favoriteResults,
    @Default([]) List<OnlineFoodResult> onlineResults,
    @Default([]) List<FavoriteFoodModel> recentFavorites,
    @Default([]) List<FavoriteFoodModel> quickSuggestions,
    
    // Selected items
    FavoriteFoodModel? selectedFood,
    OnlineFoodDetails? selectedOnlineFoodDetails,
    
    // Service availability
    @Default(false) bool isOnlineServiceAvailable,
    
    // Error handling
    @Default(false) bool hasError,
    @Default('') String errorMessage,
  }) = _FoodSearchState;

  // Helper getters
  bool get isSearching => isSearchingFavorites || isSearchingOnline;
  bool get hasSearchResults => favoriteResults.isNotEmpty || onlineResults.isNotEmpty;
  bool get hasFavoriteResults => favoriteResults.isNotEmpty;
  bool get hasOnlineResults => onlineResults.isNotEmpty;
  bool get hasRecentFavorites => recentFavorites.isNotEmpty;
  bool get hasQuickSuggestions => quickSuggestions.isNotEmpty;
  bool get showEmptyState => searchQuery.isNotEmpty && !isSearching && !hasSearchResults;

  factory FoodSearchState.initial() => const FoodSearchState();
} 