import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_food_log_model.dart';
import '../../food_database/domain/online_food_models.dart';

part 'favorite_food_model.freezed.dart';
part 'favorite_food_model.g.dart';

/// Source of the favorite food data
enum FoodSource {
  userCreated('Bruger'),
  onlineDatabase('Online'),
  imported('Importeret');

  const FoodSource(this.displayName);
  final String displayName;

  String get emoji {
    switch (this) {
      case FoodSource.userCreated:
        return '👤';
      case FoodSource.onlineDatabase:
        return '🌐';
      case FoodSource.imported:
        return '📥';
    }
  }
}

/// Serving size information for favorites
@freezed
class FavoriteServingSize with _$FavoriteServingSize {
  const factory FavoriteServingSize({
    @Default('') String name,
    @Default(100.0) double grams,
    @Default(false) bool isDefault,
  }) = _FavoriteServingSize;

  factory FavoriteServingSize.fromJson(Map<String, dynamic> json) => 
      _$FavoriteServingSizeFromJson(json);

  /// Create from OnlineFoodDetails ServingInfo
  factory FavoriteServingSize.fromServingInfo(ServingInfo serving) {
    return FavoriteServingSize(
      name: serving.name,
      grams: serving.grams,
      isDefault: serving.isDefault,
    );
  }
}

/// Model for favorite food items that can be quickly selected for logging
/// Now enhanced to store comprehensive food data
@freezed
class FavoriteFoodModel with _$FavoriteFoodModel {
  const FavoriteFoodModel._();

  const factory FavoriteFoodModel({
    @Default('') String id,
    @Default('') String foodName,
    @Default('') String description,
    @Default(MealType.none) MealType preferredMealType,
    
    // Nutrition per 100g
    @Default(0) int caloriesPer100g,
    @Default(0.0) double proteinPer100g,
    @Default(0.0) double fatPer100g,
    @Default(0.0) double carbsPer100g,
    @Default(0.0) double fiberPer100g,
    @Default(0.0) double sugarPer100g,
    
    // Default serving information (user's preferred portion)
    @Default(1.0) double defaultQuantity,
    @Default('portion') String defaultServingUnit,
    @Default(100.0) double defaultServingGrams,
    
    // Available serving sizes
    @Default([]) List<FavoriteServingSize> servingSizes,
    
    // Source and metadata
    @Default(FoodSource.userCreated) FoodSource source,
    @Default('') String sourceProvider,
    @Default([]) List<String> tags,
    @Default('') String ingredients,
    
    // Usage tracking
    required DateTime createdAt,
    required DateTime lastUsed,
    @Default(0) int usageCount,
  }) = _FavoriteFoodModel;

  factory FavoriteFoodModel.fromJson(Map<String, dynamic> json) => 
      _$FavoriteFoodModelFromJson(json);

  /// Create favorite from UserFoodLogModel
  factory FavoriteFoodModel.fromUserFoodLog(UserFoodLogModel foodLog) {
    // Calculate per 100g values from the logged portion
    final totalGrams = foodLog.quantity * 100; // Assume 100g default if no serving info
    final caloriesPer100g = totalGrams > 0 ? (foodLog.calories * 100 / totalGrams).round() : 0;
    final proteinPer100g = totalGrams > 0 ? (foodLog.protein * 100 / totalGrams) : 0.0;
    final fatPer100g = totalGrams > 0 ? (foodLog.fat * 100 / totalGrams) : 0.0;
    final carbsPer100g = totalGrams > 0 ? (foodLog.carbs * 100 / totalGrams) : 0.0;

    return FavoriteFoodModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      foodName: foodLog.foodName,
      preferredMealType: foodLog.mealType,
      caloriesPer100g: caloriesPer100g,
      proteinPer100g: proteinPer100g,
      fatPer100g: fatPer100g,
      carbsPer100g: carbsPer100g,
      defaultQuantity: foodLog.quantity,
      defaultServingUnit: foodLog.servingUnit,
      source: FoodSource.userCreated,
      createdAt: DateTime.now(),
      lastUsed: DateTime.now(),
      usageCount: 1,
      servingSizes: [
        FavoriteServingSize(
          name: foodLog.servingUnit,
          grams: 100.0,
          isDefault: true,
        ),
      ],
    );
  }

  /// Create favorite from OnlineFoodDetails
  factory FavoriteFoodModel.fromOnlineFoodDetails(OnlineFoodDetails details, {
    MealType? preferredMealType,
    double? preferredQuantity,
    String? preferredServingUnit,
  }) {
    final nutrition = details.nutrition;
    final defaultServing = details.servingSizes.firstWhere(
      (s) => s.isDefault,
      orElse: () => details.servingSizes.isNotEmpty 
          ? details.servingSizes.first 
          : const ServingInfo(name: 'portion', grams: 100.0, isDefault: true),
    );

    return FavoriteFoodModel(
      id: details.basicInfo.id,
      foodName: details.basicInfo.name,
      description: details.basicInfo.description,
      preferredMealType: preferredMealType ?? _inferMealTypeFromTags(details.basicInfo.tags),
      caloriesPer100g: nutrition.calories.round(),
      proteinPer100g: nutrition.protein,
      fatPer100g: nutrition.fat,
      carbsPer100g: nutrition.carbs,
      fiberPer100g: nutrition.fiber,
      sugarPer100g: nutrition.sugar,
      defaultQuantity: preferredQuantity ?? 1.0,
      defaultServingUnit: preferredServingUnit ?? defaultServing.name,
      defaultServingGrams: defaultServing.grams,
      servingSizes: details.servingSizes.map((s) => FavoriteServingSize.fromServingInfo(s)).toList(),
      source: FoodSource.onlineDatabase,
      sourceProvider: details.basicInfo.provider,
      tags: _extractTagsFromFoodTags(details.basicInfo.tags),
      ingredients: details.ingredients,
      createdAt: DateTime.now(),
      lastUsed: DateTime.now(),
      usageCount: 1,
    );
  }

  /// Convert to UserFoodLogModel for logging
  UserFoodLogModel toUserFoodLog({
    double? quantity,
    String? servingUnit,
    MealType? mealType,
  }) {
    final useQuantity = quantity ?? defaultQuantity;
    final useServingUnit = servingUnit ?? defaultServingUnit;
    final useMealType = mealType ?? preferredMealType;
    
    // Find serving size info
    final servingInfo = servingSizes.firstWhere(
      (s) => s.name.toLowerCase() == useServingUnit.toLowerCase(),
      orElse: () => FavoriteServingSize(name: useServingUnit, grams: defaultServingGrams),
    );
    
    final totalGrams = servingInfo.grams * useQuantity;
    final factor = totalGrams / 100; // Convert from per 100g to actual serving
    
    return UserFoodLogModel(
      userId: 1, // TODO: Get real user ID
      foodName: foodName,
      mealType: useMealType,
      calories: (caloriesPer100g * factor).round(),
      protein: proteinPer100g * factor,
      fat: fatPer100g * factor,
      carbs: carbsPer100g * factor,
      quantity: useQuantity,
      servingUnit: useServingUnit,
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

  /// Display text for this favorite
  String get displayText => '$foodName (${caloriesPer100g} kcal/100g)';

  /// Calculated calories for default serving
  int get defaultServingCalories {
    final totalGrams = defaultServingGrams * defaultQuantity;
    return (caloriesPer100g * totalGrams / 100).round();
  }

  /// Get emoji representation based on food name and tags
  String get emoji {
    return FoodImageHelper.getFoodEmoji(foodName);
  }

  // Helper methods
  static MealType _inferMealTypeFromTags(FoodTags tags) {
    // Analyze meal tags to suggest preferred meal type
    for (final tag in tags.customTags) {
      final lower = tag.toLowerCase();
      if (lower.contains('morgenmad') || lower.contains('breakfast')) return MealType.morgenmad;
      if (lower.contains('frokost') || lower.contains('lunch')) return MealType.frokost;
      if (lower.contains('aftensmad') || lower.contains('dinner')) return MealType.aftensmad;
      if (lower.contains('snack') || lower.contains('mellemmåltid')) return MealType.snack;
    }
    return MealType.none;
  }

  static List<String> _extractTagsFromFoodTags(FoodTags tags) {
    final allTags = <String>[];
    allTags.addAll(tags.foodTypes.map((t) => t.displayName));
    allTags.addAll(tags.cuisineStyles.map((t) => t.displayName));
    allTags.addAll(tags.dietaryTags.map((t) => t.displayName));
    allTags.addAll(tags.preparationTypes.map((t) => t.displayName));
    allTags.addAll(tags.customTags);
    return allTags;
  }

  /// Display name for meal type
  String get mealTypeDisplayName {
    switch (preferredMealType) {
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
} 