import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../activity/application/activity_state.dart';
import '../domain/food_record_model.dart';
import '../domain/i_food_database_service.dart';
import '../infrastructure/food_database_service.dart';
import 'food_database_state.dart';
import 'providers.dart'; // Import shared providers

class FoodDatabaseCubit extends StateNotifier<FoodDatabaseState> {
  final IFoodDatabaseService _service;

  FoodDatabaseCubit({
    IFoodDatabaseService? service,
  })  : _service = service ?? FoodDatabaseService(),
        super(FoodDatabaseState.initial()) {
    // Set up callback to refresh when data changes
    if (_service is FoodDatabaseService) {
      (_service as FoodDatabaseService).setOnDataChanged(() {
        refresh();
      });
    }
  }

  Future<void> initialize() async {
    state = state.copyWith(
      foodsDataState: const DataState.loading(),
      errorMessage: '',
    );

    final result = await _service.getAllFoods();
    if (result.isSuccess) {
      print('🍽️ FoodDatabaseCubit: Loaded ${result.success.length} foods');
      state = state.copyWith(
        foodsDataState: DataState.success(result.success),
      );
    } else {
      print('🍽️ FoodDatabaseCubit: Error loading foods: ${result.failure}');
      state = state.copyWith(
        foodsDataState: const DataState.error(),
        errorMessage: result.failure.message,
      );
    }
  }

  Future<void> refresh() async {
    await initialize();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSelectedCategory(FoodCategory? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      selectedCategory: null,
    );
  }

  void startAddingFood() {
    state = state.copyWith(
      isAddingFood: true,
      editingFood: null,
    );
  }

  void startEditingFood(FoodRecordModel food) {
    state = state.copyWith(
      editingFood: food,
      isAddingFood: false,
    );
  }

  void cancelEditing() {
    state = state.copyWith(
      editingFood: null,
      isAddingFood: false,
    );
  }

  Future<bool> saveFood(FoodRecordModel food) async {
    try {
      if (state.isAddingFood) {
        // Adding new food
        final result = await _service.addFood(food);
        if (result.isSuccess) {
          print('🍽️ FoodDatabaseCubit: Added food: ${result.success.name}');
          
          // Update local state
          final updatedFoods = [...state.foods, result.success];
          state = state.copyWith(
            foodsDataState: DataState.success(updatedFoods),
            isAddingFood: false,
            errorMessage: '',
          );
          return true;
        } else {
          print('🍽️ FoodDatabaseCubit: Error adding food: ${result.failure}');
          state = state.copyWith(errorMessage: result.failure.message);
          return false;
        }
      } else {
        // Updating existing food
        final result = await _service.updateFood(food);
        if (result.isSuccess) {
          print('🍽️ FoodDatabaseCubit: Updated food: ${result.success.name}');
          
          // Update local state
          final updatedFoods = state.foods.map((f) => 
            f.id == result.success.id ? result.success : f
          ).toList();
          
          state = state.copyWith(
            foodsDataState: DataState.success(updatedFoods),
            editingFood: null,
            errorMessage: '',
          );
          return true;
        } else {
          print('🍽️ FoodDatabaseCubit: Error updating food: ${result.failure}');
          state = state.copyWith(errorMessage: result.failure.message);
          return false;
        }
      }
    } catch (e) {
      print('🍽️ FoodDatabaseCubit: Unexpected error saving food: $e');
      state = state.copyWith(errorMessage: 'Uventet fejl ved lagring');
      return false;
    }
  }

  Future<bool> deleteFood(FoodRecordModel food) async {
    try {
      final result = await _service.deleteFood(food.id);
      if (result.isSuccess) {
        print('🍽️ FoodDatabaseCubit: Deleted food: ${food.name}');
        
        // Update local state
        final updatedFoods = state.foods.where((f) => f.id != food.id).toList();
        state = state.copyWith(
          foodsDataState: DataState.success(updatedFoods),
          errorMessage: '',
        );
        return true;
      } else {
        print('🍽️ FoodDatabaseCubit: Error deleting food: ${result.failure}');
        state = state.copyWith(errorMessage: result.failure.message);
        return false;
      }
    } catch (e) {
      print('🍽️ FoodDatabaseCubit: Unexpected error deleting food: $e');
      state = state.copyWith(errorMessage: 'Uventet fejl ved sletning af mad');
      return false;
    }
  }

  Future<bool> clearAllFoods() async {
    try {
      state = state.copyWith(
        foodsDataState: const DataState.loading(),
        errorMessage: '',
      );

      final result = await _service.clearAllFoods();
      if (result.isSuccess) {
        print('🍽️ FoodDatabaseCubit: Cleared all foods from database');
        
        // Update local state to empty list
        state = state.copyWith(
          foodsDataState: const DataState.success([]),
          errorMessage: '',
        );
        return true;
      } else {
        print('🍽️ FoodDatabaseCubit: Error clearing all foods: ${result.failure}');
        state = state.copyWith(
          foodsDataState: const DataState.error(),
          errorMessage: result.failure.message,
        );
        return false;
      }
    } catch (e) {
      print('🍽️ FoodDatabaseCubit: Unexpected error clearing all foods: $e');
      state = state.copyWith(
        foodsDataState: const DataState.error(),
        errorMessage: 'Uventet fejl ved sletning af alle fødevarer',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: '');
  }

  Future<void> searchFoods(String query) async {
    try {
      final result = await _service.searchFoods(query);
      if (result.isSuccess) {
        print('🍽️ FoodDatabaseCubit: Search completed for: "$query" - found ${result.success.length} results');
        state = state.copyWith(
          foodsDataState: DataState.success(result.success),
          searchQuery: query,
          errorMessage: '',
        );
      } else {
        print('🍽️ FoodDatabaseCubit: Error searching foods: ${result.failure}');
        state = state.copyWith(errorMessage: result.failure.message);
      }
    } catch (e) {
      print('🍽️ FoodDatabaseCubit: Unexpected error searching foods: $e');
      state = state.copyWith(errorMessage: 'Uventet fejl ved søgning');
    }
  }
}

// Provider for the food database cubit - uses shared service
final foodDatabaseProvider = StateNotifierProvider<FoodDatabaseCubit, FoodDatabaseState>(
  (ref) {
    final service = ref.read(foodDatabaseServiceProvider);
    return FoodDatabaseCubit(service: service);
  },
); 