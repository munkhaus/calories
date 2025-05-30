import 'user_food_log_model.dart';

/// Model for favorite food items that can be quickly selected for logging
class FavoriteFoodModel {
  final String id;
  final String foodName;
  final MealType mealType;
  final int calories;
  final double protein;
  final double fat;
  final double carbs;
  final double quantity;
  final String servingUnit;
  final DateTime createdAt;
  final DateTime lastUsed;
  final int usageCount;

  const FavoriteFoodModel({
    this.id = '',
    this.foodName = '',
    this.mealType = MealType.morgenmad,
    this.calories = 0,
    this.protein = 0.0,
    this.fat = 0.0,
    this.carbs = 0.0,
    this.quantity = 1.0,
    this.servingUnit = 'portion',
    required this.createdAt,
    required this.lastUsed,
    this.usageCount = 0,
  });

  /// Create from JSON
  factory FavoriteFoodModel.fromJson(Map<String, dynamic> json) {
    return FavoriteFoodModel(
      id: json['id'] ?? '',
      foodName: json['foodName'] ?? '',
      mealType: _mealTypeFromString(json['mealType'] ?? 'morgenmad'),
      calories: json['calories'] ?? 0,
      protein: (json['protein'] ?? 0.0).toDouble(),
      fat: (json['fat'] ?? 0.0).toDouble(),
      carbs: (json['carbs'] ?? 0.0).toDouble(),
      quantity: (json['quantity'] ?? 1.0).toDouble(),
      servingUnit: json['servingUnit'] ?? 'portion',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      lastUsed: DateTime.tryParse(json['lastUsed'] ?? '') ?? DateTime.now(),
      usageCount: json['usageCount'] ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodName': foodName,
      'mealType': _mealTypeToString(mealType),
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'quantity': quantity,
      'servingUnit': servingUnit,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed.toIso8601String(),
      'usageCount': usageCount,
    };
  }

  /// Copy with new values
  FavoriteFoodModel copyWith({
    String? id,
    String? foodName,
    MealType? mealType,
    int? calories,
    double? protein,
    double? fat,
    double? carbs,
    double? quantity,
    String? servingUnit,
    DateTime? createdAt,
    DateTime? lastUsed,
    int? usageCount,
  }) {
    return FavoriteFoodModel(
      id: id ?? this.id,
      foodName: foodName ?? this.foodName,
      mealType: mealType ?? this.mealType,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      quantity: quantity ?? this.quantity,
      servingUnit: servingUnit ?? this.servingUnit,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  /// Create favorite from UserFoodLogModel
  factory FavoriteFoodModel.fromUserFoodLog(UserFoodLogModel foodLog) {
    return FavoriteFoodModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      foodName: foodLog.foodName,
      mealType: foodLog.mealType,
      calories: foodLog.calories,
      protein: foodLog.protein,
      fat: foodLog.fat,
      carbs: foodLog.carbs,
      quantity: foodLog.quantity,
      servingUnit: foodLog.servingUnit,
      createdAt: DateTime.now(),
      lastUsed: DateTime.now(),
      usageCount: 1,
    );
  }

  /// Convert to UserFoodLogModel for logging
  UserFoodLogModel toUserFoodLog() {
    return UserFoodLogModel(
      userId: 1, // TODO: Get real user ID
      foodName: foodName,
      mealType: mealType,
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
      quantity: quantity,
      servingUnit: servingUnit,
      loggedAt: DateTime.now().toIso8601String(),
    );
  }

  /// Update usage statistics
  FavoriteFoodModel withUpdatedUsage() {
    return copyWith(
      lastUsed: DateTime.now(),
      usageCount: usageCount + 1,
    );
  }

  static MealType _mealTypeFromString(String value) {
    switch (value.toLowerCase()) {
      case 'none':
        return MealType.none;
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
      case MealType.none:
        return 'none';
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteFoodModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Display name for meal type
  String get mealTypeDisplayName {
    switch (mealType) {
      case MealType.none:
        return 'Ingen kategori';
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

  /// Short display text for the favorite
  String get displayText => '$foodName (${calories} kcal)';
} 