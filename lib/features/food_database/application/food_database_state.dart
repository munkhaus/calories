import 'package:freezed_annotation/freezed_annotation.dart';
import '../../activity/application/activity_state.dart';
import '../domain/food_record_model.dart';

part 'food_database_state.freezed.dart';

@freezed
class FoodDatabaseState with _$FoodDatabaseState {
  const FoodDatabaseState._();

  const factory FoodDatabaseState({
    required DataState<List<FoodRecordModel>> foodsDataState,
    @Default('') String searchQuery,
    @Default(null) FoodCategory? selectedCategory,
    @Default(null) FoodRecordModel? editingFood,
    @Default(false) bool isAddingFood,
    @Default('') String errorMessage,
  }) = _FoodDatabaseState;

  // Helper getters
  bool get isLoading => foodsDataState.isLoading;
  bool get hasError => foodsDataState.hasError;
  bool get isSuccess => foodsDataState.isSuccess;
  List<FoodRecordModel> get foods => foodsDataState.data ?? [];
  
  bool get isEditing => editingFood != null || isAddingFood;
  
  // Filtered foods based on search and category
  List<FoodRecordModel> get filteredFoods {
    var result = foods;
    
    // Filter by category
    if (selectedCategory != null) {
      result = result.where((food) => food.category == selectedCategory).toList();
    }
    
    // Filter by search query
    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((food) => 
        food.name.toLowerCase().contains(query) ||
        food.description.toLowerCase().contains(query)
      ).toList();
    }
    
    // Sort by name
    result.sort((a, b) => a.name.compareTo(b.name));
    
    return result;
  }

  factory FoodDatabaseState.initial() => const FoodDatabaseState(
    foodsDataState: DataState.idle(),
  );
} 