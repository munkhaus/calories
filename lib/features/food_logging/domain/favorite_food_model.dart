import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_food_log_model.dart';
import '../../food_database/domain/online_food_models.dart';

part 'favorite_food_model.freezed.dart';
part 'favorite_food_model.g.dart';

/// Type of food favorite
enum FoodType {
  meal('Ret'),
  ingredient('Fødevare');

  const FoodType(this.displayName);
  final String displayName;

  String get emoji {
    switch (this) {
      case FoodType.meal:
        return '🍽️';
      case FoodType.ingredient:
        return '🥕';
    }
  }

  String get description {
    switch (this) {
      case FoodType.meal:
        return 'Komplekse retter og måltider';
      case FoodType.ingredient:
        return 'Enkle fødevarer og ingredienser';
    }
  }
}

/// Source of the favorite food data
enum FoodSource {
  userCreated('Bruger'),
  onlineDatabase('Online'),
  imported('Importeret'),
  barcode('Stregkode');

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
      case FoodSource.barcode:
        return '📦';
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

  /// Create from OnlineServingSize (from LLM response)
  factory FavoriteServingSize.fromOnlineServingInfo(OnlineServingSize serving) {
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
  static const String manualProvider = 'manual'; // For manually created favorites

  const factory FavoriteFoodModel({
    @Default('') String id,
    @Default('') String foodName,
    @Default('') String description,
    @Default(MealType.none) MealType preferredMealType,
    
    // Food type classification
    @Default(FoodType.meal) FoodType foodType,
    
    // Nutrition per 100g
    @Default(0) int caloriesPer100g,
    @Default(0.0) double proteinPer100g,
    @Default(0.0) double fatPer100g,
    @Default(0.0) double carbsPer100g,
    @Default(0.0) double fiberPer100g,
    @Default(0.0) double sugarPer100g,
    
    // Default serving information (user's preferred portion)
    @Default(1.0) double defaultQuantity, // This is now effectively defaultServingGrams if unit is 'gram'
    @Default('gram') String defaultServingUnit, // Defaulting to 'gram' more strongly
    @Default(100.0) double defaultServingGrams,
    
    // Total calories for the default serving (calculated)
    @Default(0) int totalCaloriesForServing, // Renamed from 'calories'
    
    // Available serving sizes
    @Default([]) List<FavoriteServingSize> servingSizes,
    
    // Source and metadata
    @Default(FoodSource.userCreated) FoodSource source,
    @Default(FavoriteFoodModel.manualProvider) String sourceProvider, // Default to manual
    @Default(false) bool isAiGenerated,
    String? aiSearchQuery,
    String? barcodeData, // Store barcode if from barcode scan
    @Default([]) List<String> tags,
    @Default('') String ingredients,
    
    // Usage tracking
    required DateTime createdAt,
    required DateTime lastUsed,
    @Default(0) int usageCount,
  }) = _FavoriteFoodModel;

  factory FavoriteFoodModel.fromJson(Map<String, dynamic> json) => 
      _$FavoriteFoodModelFromJson(json);

  /// Create favorite from UserFoodLog (usually meals)
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
      foodType: FoodType.meal, // User food logs are typically meals
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

  /// Create ingredient-type favorite from barcode data
  factory FavoriteFoodModel.fromBarcodeData({
    required String barcode,
    required String foodName,
    required int caloriesPer100g,
    String? brand,
    String? description,
    double? proteinPer100g,
    double? fatPer100g,
    double? carbsPer100g,
    double? fiberPer100g,
    double? sugarPer100g,
    List<String>? ingredients,
  }) {
    return FavoriteFoodModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      foodName: foodName,
      description: description ?? (brand != null ? '$brand - $foodName' : ''),
      foodType: FoodType.ingredient, // Barcode scanned items are ingredients
      caloriesPer100g: caloriesPer100g,
      proteinPer100g: proteinPer100g ?? 0.0,
      fatPer100g: fatPer100g ?? 0.0,
      carbsPer100g: carbsPer100g ?? 0.0,
      fiberPer100g: fiberPer100g ?? 0.0,
      sugarPer100g: sugarPer100g ?? 0.0,
      defaultQuantity: 100.0, // Default to 100g for ingredients
      defaultServingUnit: 'gram',
      defaultServingGrams: 100.0,
      totalCaloriesForServing: caloriesPer100g, // 100g = calories per 100g
      source: FoodSource.barcode,
      sourceProvider: 'barcode',
      barcodeData: barcode,
      ingredients: ingredients?.join(', ') ?? '',
      tags: brand != null ? [brand] : [],
      servingSizes: [
        FavoriteServingSize(
          name: '100 gram',
          grams: 100.0,
          isDefault: true,
        ),
      ],
      createdAt: DateTime.now(),
      lastUsed: DateTime.now(),
      usageCount: 1,
    );
  }

  /// Create favorite from OnlineFoodDetails (can be meals or ingredients)
  factory FavoriteFoodModel.fromOnlineFoodDetails(OnlineFoodDetails details, {
    MealType? preferredMealType,
    double? preferredQuantityGrams, // Quantity is now grams
    FoodType? foodType, // Allow explicit food type specification
  }) {
    final nutrition = details.nutrition;
    final basicInfo = details.basicInfo;

    final OnlineServingSize defaultServingOnline = details.servingSizes.firstWhere(
      (s) => s.isDefault,
      orElse: () => details.servingSizes.isNotEmpty 
          ? details.servingSizes.first 
          : const OnlineServingSize(name: '100 gram', grams: 100.0, isDefault: true),
    );
    
    final double currentPortionGrams = preferredQuantityGrams ?? defaultServingOnline.grams;
    
    // Ensure calories are finite and calculate total calories, defaulting to 0
    final int calculatedTotalCalories = nutrition.calories.isFinite && currentPortionGrams.isFinite
        ? (nutrition.calories / 100.0 * currentPortionGrams).round()
        : 0;

    return FavoriteFoodModel(
      id: basicInfo.id.isNotEmpty ? basicInfo.id : DateTime.now().millisecondsSinceEpoch.toString(),
      foodName: basicInfo.name,
      description: basicInfo.description,
      preferredMealType: preferredMealType ?? _inferMealTypeFromTags(basicInfo.tags),
      foodType: foodType ?? _inferFoodTypeFromName(basicInfo.name), // Infer type from name if not specified
      caloriesPer100g: nutrition.calories.round(),
      proteinPer100g: nutrition.protein,
      fatPer100g: nutrition.fat,
      carbsPer100g: nutrition.carbs,
      fiberPer100g: nutrition.fiber,
      sugarPer100g: nutrition.sugar,
      
      defaultQuantity: currentPortionGrams, // This is the portion in grams
      defaultServingUnit: 'gram', // Always gram now
      defaultServingGrams: currentPortionGrams,
      totalCaloriesForServing: calculatedTotalCalories, // Use renamed field

      servingSizes: details.servingSizes.map((s) => FavoriteServingSize.fromOnlineServingInfo(s)).toList(),
      
      source: FoodSource.onlineDatabase, // Explicitly set source
      sourceProvider: basicInfo.provider,
      isAiGenerated: true, // Mark as AI generated
      aiSearchQuery: null, // Could use original query if passed through

      tags: extractTagsFromFoodTags(basicInfo.tags),
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
    
    double totalGrams;
    
    // For ingredients with gram serving unit, quantity IS the grams
    if (foodType == FoodType.ingredient && useServingUnit.toLowerCase() == 'gram') {
      totalGrams = useQuantity;
    } else {
      // For meals or other serving units, use the traditional calculation
      final servingInfo = servingSizes.firstWhere(
        (s) => s.name.toLowerCase() == useServingUnit.toLowerCase(),
        orElse: () => FavoriteServingSize(name: useServingUnit, grams: defaultServingGrams),
      );
      totalGrams = servingInfo.grams * useQuantity;
    }
    
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

  /// Calculated calories for default serving - NOW USES THE STORED 'totalCaloriesForServing' field
  int get defaultServingCalories {
    return totalCaloriesForServing; // Use the renamed field
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
      if (lower.contains('aftensmad') || lower.contains('dinner') || lower.contains('middag')) return MealType.aftensmad;
      if (lower.contains('snack') || lower.contains('mellemmåltid')) return MealType.snack;
    }
    // Check food types if custom tags didn't yield a result
    for (final foodType in tags.foodTypes) {
        final lower = foodType.displayName.toLowerCase(); // Access displayName
        if (lower == 'breakfast') return MealType.morgenmad;
        if (lower == 'lunch') return MealType.frokost;
        if (lower == 'dinner') return MealType.aftensmad;
        if (lower == 'snack') return MealType.snack;
    }
    return MealType.none;
  }

  static FoodType _inferFoodTypeFromName(String foodName) {
    final lower = foodName.toLowerCase();
    
    // Keywords that suggest this is a complex meal/dish
    final mealKeywords = [
      'ret', 'måltid', 'ragu', 'steg', 'gryde', 'suppe', 'salat',
      'sandwich', 'burger', 'pizza', 'pasta', 'lasagne', 'risotto',
      'curry', 'stir-fry', 'casserole', 'pie', 'stew', 'soup',
      'dinner', 'lunch', 'breakfast', 'meal', 'dish',
      'med', 'og', 'i', // Danish prepositions indicating complex dishes
    ];
    
    // Keywords that suggest this is a simple ingredient/food item
    final ingredientKeywords = [
      'æble', 'banan', 'tomat', 'løg', 'gulerød', 'kartoffel',
      'kylling', 'oksekød', 'laks', 'torsk', 'ris', 'pasta',
      'brød', 'smør', 'ost', 'mælk', 'æg', 'mel', 'sukker',
      'apple', 'banana', 'tomato', 'onion', 'carrot', 'potato',
      'chicken', 'beef', 'salmon', 'cod', 'rice', 'bread',
      'butter', 'cheese', 'milk', 'egg', 'flour', 'sugar',
    ];
    
    // Check for complex meal indicators first
    for (final keyword in mealKeywords) {
      if (lower.contains(keyword)) {
        return FoodType.meal;
      }
    }
    
    // Check for simple ingredient indicators
    for (final keyword in ingredientKeywords) {
      if (lower == keyword || lower.startsWith('$keyword ') || lower.endsWith(' $keyword')) {
        return FoodType.ingredient;
      }
    }
    
    // Default to ingredient for single words, meal for multiple words
    return lower.split(' ').length == 1 ? FoodType.ingredient : FoodType.meal;
  }

  static List<String> extractTagsFromFoodTags(FoodTags foodTags) {
    final tags = <String>{}; // Use a Set to avoid duplicates
    tags.addAll(foodTags.foodTypes.map((e) => e.displayName));
    tags.addAll(foodTags.cuisineStyles.map((e) => e.displayName));
    tags.addAll(foodTags.dietaryTags.map((e) => e.displayName));
    tags.addAll(foodTags.preparationTypes.map((e) => e.displayName));
    tags.addAll(foodTags.customTags);
    return tags.toList();
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