enum MealType {
  morgenmad,
  frokost,
  aftensmad,
  snack,
}

enum FoodItemSourceType {
  foodItem,
  custom,
  recipe,
  quickLog,
}

class UserFoodLogModel {
  final int logEntryId;
  final int userId;
  final int? foodItemId;
  final int? customFoodId;
  final int? recipeId;
  final String foodName;
  final String loggedAt;
  final MealType mealType;
  final double quantity;
  final String servingUnit;
  final int calories;
  final double protein;
  final double fat;
  final double carbs;
  final FoodItemSourceType foodItemSourceType;
  final String createdAt;
  final String updatedAt;

  const UserFoodLogModel({
    this.logEntryId = 0,
    this.userId = 0,
    this.foodItemId,
    this.customFoodId,
    this.recipeId,
    this.foodName = '',
    this.loggedAt = '',
    this.mealType = MealType.morgenmad,
    this.quantity = 0.0,
    this.servingUnit = '',
    this.calories = 0,
    this.protein = 0.0,
    this.fat = 0.0,
    this.carbs = 0.0,
    this.foodItemSourceType = FoodItemSourceType.foodItem,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory UserFoodLogModel.fromJson(Map<String, dynamic> json) {
    return UserFoodLogModel(
      logEntryId: json['log_entry_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      foodItemId: json['food_item_id'],
      customFoodId: json['custom_food_id'],
      recipeId: json['recipe_id'],
      foodName: json['food_name'] ?? '',
      loggedAt: json['logged_at'] ?? '',
      mealType: _mealTypeFromString(json['meal_type'] ?? 'morgenmad'),
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      servingUnit: json['serving_unit'] ?? '',
      calories: json['calories'] ?? 0,
      protein: (json['protein'] ?? 0.0).toDouble(),
      fat: (json['fat'] ?? 0.0).toDouble(),
      carbs: (json['carbs'] ?? 0.0).toDouble(),
      foodItemSourceType: _sourceTypeFromString(json['food_item_source_type'] ?? 'foodItem'),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'log_entry_id': logEntryId,
      'user_id': userId,
      'food_item_id': foodItemId,
      'custom_food_id': customFoodId,
      'recipe_id': recipeId,
      'food_name': foodName,
      'logged_at': loggedAt,
      'meal_type': _mealTypeToString(mealType),
      'quantity': quantity,
      'serving_unit': servingUnit,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'food_item_source_type': _sourceTypeToString(foodItemSourceType),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static MealType _mealTypeFromString(String value) {
    switch (value.toLowerCase()) {
      case 'frokost':
        return MealType.frokost;
      case 'aftensmad':
        return MealType.aftensmad;
      case 'snack':
        return MealType.snack;
      default:
        return MealType.morgenmad;
    }
  }

  static String _mealTypeToString(MealType type) {
    switch (type) {
      case MealType.morgenmad:
        return 'morgenmad';
      case MealType.frokost:
        return 'frokost';
      case MealType.aftensmad:
        return 'aftensmad';
      case MealType.snack:
        return 'snack';
    }
  }

  static FoodItemSourceType _sourceTypeFromString(String value) {
    switch (value.toLowerCase()) {
      case 'custom':
        return FoodItemSourceType.custom;
      case 'recipe':
        return FoodItemSourceType.recipe;
      case 'quicklog':
        return FoodItemSourceType.quickLog;
      default:
        return FoodItemSourceType.foodItem;
    }
  }

  static String _sourceTypeToString(FoodItemSourceType type) {
    switch (type) {
      case FoodItemSourceType.foodItem:
        return 'food_item';
      case FoodItemSourceType.custom:
        return 'custom';
      case FoodItemSourceType.recipe:
        return 'recipe';
      case FoodItemSourceType.quickLog:
        return 'quickLog';
    }
  }

  UserFoodLogModel copyWith({
    int? logEntryId,
    int? userId,
    int? foodItemId,
    int? customFoodId,
    int? recipeId,
    String? foodName,
    String? loggedAt,
    MealType? mealType,
    double? quantity,
    String? servingUnit,
    int? calories,
    double? protein,
    double? fat,
    double? carbs,
    FoodItemSourceType? foodItemSourceType,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserFoodLogModel(
      logEntryId: logEntryId ?? this.logEntryId,
      userId: userId ?? this.userId,
      foodItemId: foodItemId ?? this.foodItemId,
      customFoodId: customFoodId ?? this.customFoodId,
      recipeId: recipeId ?? this.recipeId,
      foodName: foodName ?? this.foodName,
      loggedAt: loggedAt ?? this.loggedAt,
      mealType: mealType ?? this.mealType,
      quantity: quantity ?? this.quantity,
      servingUnit: servingUnit ?? this.servingUnit,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      foodItemSourceType: foodItemSourceType ?? this.foodItemSourceType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserFoodLogModel && other.logEntryId == logEntryId;
  }

  @override
  int get hashCode => logEntryId.hashCode;

  String get mealTypeDisplayName {
    switch (mealType) {
      case MealType.morgenmad:
        return 'Morgenmad';
      case MealType.frokost:
        return 'Frokost';
      case MealType.aftensmad:
        return 'Aftensmad';
      case MealType.snack:
        return 'Snack';
    }
  }

  static String mealTypeToString(MealType type) {
    switch (type) {
      case MealType.morgenmad:
        return 'morgenmad';
      case MealType.frokost:
        return 'frokost';
      case MealType.aftensmad:
        return 'aftensmad';
      case MealType.snack:
        return 'snack';
    }
  }
}

// Extension for display names
extension MealTypeExtension on MealType {
  String get mealTypeDisplayName {
    switch (this) {
      case MealType.morgenmad:
        return 'Morgenmad';
      case MealType.frokost:
        return 'Frokost';
      case MealType.aftensmad:
        return 'Aftensmad';
      case MealType.snack:
        return 'Snack';
    }
  }
} 