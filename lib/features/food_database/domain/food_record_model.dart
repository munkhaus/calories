import 'package:freezed_annotation/freezed_annotation.dart';

part 'food_record_model.freezed.dart';
part 'food_record_model.g.dart';

enum FoodCategory {
  breakfast,
  lunch,
  dinner,
  snack,
  drink,
  dessert,
  other;

  String get displayName {
    switch (this) {
      case FoodCategory.breakfast:
        return 'Morgenmad';
      case FoodCategory.lunch:
        return 'Frokost';
      case FoodCategory.dinner:
        return 'Aftensmad';
      case FoodCategory.snack:
        return 'Snack';
      case FoodCategory.drink:
        return 'Drikke';
      case FoodCategory.dessert:
        return 'Dessert';
      case FoodCategory.other:
        return 'Andet';
    }
  }

  String get emoji {
    switch (this) {
      case FoodCategory.breakfast:
        return '🌅';
      case FoodCategory.lunch:
        return '🌞';
      case FoodCategory.dinner:
        return '🌙';
      case FoodCategory.snack:
        return '🍪';
      case FoodCategory.drink:
        return '🥤';
      case FoodCategory.dessert:
        return '🍰';
      case FoodCategory.other:
        return '🍽️';
    }
  }
}

@freezed
class ServingSize with _$ServingSize {
  const factory ServingSize({
    @Default('') String name,
    @Default(100.0) double grams,
    @Default(false) bool isDefault,
  }) = _ServingSize;

  factory ServingSize.fromJson(Map<String, dynamic> json) => _$ServingSizeFromJson(json);
}

@freezed
class FoodRecordModel with _$FoodRecordModel {
  const FoodRecordModel._();

  const factory FoodRecordModel({
    @Default('') String id,
    @Default('') String name,
    @Default('') String description,
    @Default(0) int caloriesPer100g,
    @Default(0.0) double proteinPer100g,
    @Default(0.0) double carbsPer100g,
    @Default(0.0) double fatPer100g,
    @Default(FoodCategory.other) FoodCategory category,
    @Default([]) List<ServingSize> servingSizes,
    @Default(false) bool isCustom,
    @Default('') String createdBy,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _FoodRecordModel;

  factory FoodRecordModel.fromJson(Map<String, dynamic> json) => _$FoodRecordModelFromJson(json);

  // Factory for creating empty food record
  factory FoodRecordModel.empty() => FoodRecordModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    createdAt: DateTime.now(),
    servingSizes: [
      const ServingSize(
        name: '1 portion',
        grams: 100.0,
        isDefault: true,
      ),
    ],
  );

  // Calculate calories for specific serving
  int caloriesForServing(ServingSize serving, double quantity) {
    final totalGrams = serving.grams * quantity;
    return ((caloriesPer100g * totalGrams) / 100).round();
  }

  // Calculate nutrition for specific serving
  Map<String, double> nutritionForServing(ServingSize serving, double quantity) {
    final totalGrams = serving.grams * quantity;
    final multiplier = totalGrams / 100;
    
    return {
      'calories': (caloriesPer100g * multiplier),
      'protein': proteinPer100g * multiplier,
      'carbs': carbsPer100g * multiplier,
      'fat': fatPer100g * multiplier,
    };
  }

  // Get default serving size
  ServingSize get defaultServingSize {
    final defaultServing = servingSizes.where((s) => s.isDefault).firstOrNull;
    return defaultServing ?? servingSizes.firstOrNull ?? const ServingSize(name: '1 portion', grams: 100.0, isDefault: true);
  }

  // Search-friendly text
  String get searchText => '$name $description ${category.displayName}'.toLowerCase();
} 