// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_food_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FavoriteServingSizeImpl _$$FavoriteServingSizeImplFromJson(
  Map<String, dynamic> json,
) => _$FavoriteServingSizeImpl(
  name: json['name'] as String? ?? '',
  grams: (json['grams'] as num?)?.toDouble() ?? 100.0,
  isDefault: json['isDefault'] as bool? ?? false,
);

Map<String, dynamic> _$$FavoriteServingSizeImplToJson(
  _$FavoriteServingSizeImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'grams': instance.grams,
  'isDefault': instance.isDefault,
};

_$FavoriteFoodModelImpl _$$FavoriteFoodModelImplFromJson(
  Map<String, dynamic> json,
) => _$FavoriteFoodModelImpl(
  id: json['id'] as String? ?? '',
  foodName: json['foodName'] as String? ?? '',
  description: json['description'] as String? ?? '',
  preferredMealType:
      $enumDecodeNullable(_$MealTypeEnumMap, json['preferredMealType']) ??
      MealType.none,
  caloriesPer100g: (json['caloriesPer100g'] as num?)?.toInt() ?? 0,
  proteinPer100g: (json['proteinPer100g'] as num?)?.toDouble() ?? 0.0,
  fatPer100g: (json['fatPer100g'] as num?)?.toDouble() ?? 0.0,
  carbsPer100g: (json['carbsPer100g'] as num?)?.toDouble() ?? 0.0,
  fiberPer100g: (json['fiberPer100g'] as num?)?.toDouble() ?? 0.0,
  sugarPer100g: (json['sugarPer100g'] as num?)?.toDouble() ?? 0.0,
  defaultQuantity: (json['defaultQuantity'] as num?)?.toDouble() ?? 1.0,
  defaultServingUnit: json['defaultServingUnit'] as String? ?? 'gram',
  defaultServingGrams:
      (json['defaultServingGrams'] as num?)?.toDouble() ?? 100.0,
  totalCaloriesForServing:
      (json['totalCaloriesForServing'] as num?)?.toInt() ?? 0,
  servingSizes:
      (json['servingSizes'] as List<dynamic>?)
          ?.map((e) => FavoriteServingSize.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  source:
      $enumDecodeNullable(_$FoodSourceEnumMap, json['source']) ??
      FoodSource.userCreated,
  sourceProvider:
      json['sourceProvider'] as String? ?? FavoriteFoodModel.manualProvider,
  isAiGenerated: json['isAiGenerated'] as bool? ?? false,
  aiSearchQuery: json['aiSearchQuery'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  ingredients: json['ingredients'] as String? ?? '',
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastUsed: DateTime.parse(json['lastUsed'] as String),
  usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$FavoriteFoodModelImplToJson(
  _$FavoriteFoodModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'foodName': instance.foodName,
  'description': instance.description,
  'preferredMealType': _$MealTypeEnumMap[instance.preferredMealType]!,
  'caloriesPer100g': instance.caloriesPer100g,
  'proteinPer100g': instance.proteinPer100g,
  'fatPer100g': instance.fatPer100g,
  'carbsPer100g': instance.carbsPer100g,
  'fiberPer100g': instance.fiberPer100g,
  'sugarPer100g': instance.sugarPer100g,
  'defaultQuantity': instance.defaultQuantity,
  'defaultServingUnit': instance.defaultServingUnit,
  'defaultServingGrams': instance.defaultServingGrams,
  'totalCaloriesForServing': instance.totalCaloriesForServing,
  'servingSizes': instance.servingSizes,
  'source': _$FoodSourceEnumMap[instance.source]!,
  'sourceProvider': instance.sourceProvider,
  'isAiGenerated': instance.isAiGenerated,
  'aiSearchQuery': instance.aiSearchQuery,
  'tags': instance.tags,
  'ingredients': instance.ingredients,
  'createdAt': instance.createdAt.toIso8601String(),
  'lastUsed': instance.lastUsed.toIso8601String(),
  'usageCount': instance.usageCount,
};

const _$MealTypeEnumMap = {
  MealType.none: 'none',
  MealType.morgenmad: 'morgenmad',
  MealType.frokost: 'frokost',
  MealType.aftensmad: 'aftensmad',
  MealType.snack: 'snack',
};

const _$FoodSourceEnumMap = {
  FoodSource.userCreated: 'userCreated',
  FoodSource.onlineDatabase: 'onlineDatabase',
  FoodSource.imported: 'imported',
};
