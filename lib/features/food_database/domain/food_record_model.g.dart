// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServingSizeImpl _$$ServingSizeImplFromJson(Map<String, dynamic> json) =>
    _$ServingSizeImpl(
      name: json['name'] as String? ?? '',
      grams: (json['grams'] as num?)?.toDouble() ?? 100.0,
      isDefault: json['isDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$$ServingSizeImplToJson(_$ServingSizeImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'grams': instance.grams,
      'isDefault': instance.isDefault,
    };

_$FoodRecordModelImpl _$$FoodRecordModelImplFromJson(
  Map<String, dynamic> json,
) => _$FoodRecordModelImpl(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  description: json['description'] as String? ?? '',
  caloriesPer100g: (json['caloriesPer100g'] as num?)?.toInt() ?? 0,
  proteinPer100g: (json['proteinPer100g'] as num?)?.toDouble() ?? 0.0,
  carbsPer100g: (json['carbsPer100g'] as num?)?.toDouble() ?? 0.0,
  fatPer100g: (json['fatPer100g'] as num?)?.toDouble() ?? 0.0,
  category:
      $enumDecodeNullable(_$FoodCategoryEnumMap, json['category']) ??
      FoodCategory.other,
  servingSizes:
      (json['servingSizes'] as List<dynamic>?)
          ?.map((e) => ServingSize.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  source:
      $enumDecodeNullable(_$FoodSourceEnumMap, json['source']) ??
      FoodSource.userCreated,
  sourceProvider: json['sourceProvider'] as String? ?? '',
  isCustom: json['isCustom'] as bool? ?? false,
  createdBy: json['createdBy'] as String? ?? '',
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$FoodRecordModelImplToJson(
  _$FoodRecordModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'caloriesPer100g': instance.caloriesPer100g,
  'proteinPer100g': instance.proteinPer100g,
  'carbsPer100g': instance.carbsPer100g,
  'fatPer100g': instance.fatPer100g,
  'category': _$FoodCategoryEnumMap[instance.category]!,
  'servingSizes': instance.servingSizes,
  'source': _$FoodSourceEnumMap[instance.source]!,
  'sourceProvider': instance.sourceProvider,
  'isCustom': instance.isCustom,
  'createdBy': instance.createdBy,
  'tags': instance.tags,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$FoodCategoryEnumMap = {
  FoodCategory.breakfast: 'breakfast',
  FoodCategory.lunch: 'lunch',
  FoodCategory.dinner: 'dinner',
  FoodCategory.snack: 'snack',
  FoodCategory.drink: 'drink',
  FoodCategory.dessert: 'dessert',
  FoodCategory.other: 'other',
};

const _$FoodSourceEnumMap = {
  FoodSource.userCreated: 'userCreated',
  FoodSource.onlineDatabase: 'onlineDatabase',
  FoodSource.imported: 'imported',
};
