// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodEntry _$FoodEntryFromJson(Map<String, dynamic> json) => FoodEntry(
  id: json['id'] as String,
  date: json['date'] as String,
  dateTime: DateTime.parse(json['dateTime'] as String),
  mealType: $enumDecode(_$MealTypeEnumMap, json['mealType']),
  name: json['name'] as String,
  calories: (json['calories'] as num).toInt(),
  carbsG: (json['carbsG'] as num?)?.toInt() ?? 0,
  proteinG: (json['proteinG'] as num?)?.toInt() ?? 0,
  fatG: (json['fatG'] as num?)?.toInt() ?? 0,
  portionValue: (json['portionValue'] as num?)?.toDouble(),
  portionUnit: json['portionUnit'] as String?,
  source: json['source'] as String? ?? 'manual',
);

Map<String, dynamic> _$FoodEntryToJson(FoodEntry instance) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date,
  'dateTime': instance.dateTime.toIso8601String(),
  'mealType': _$MealTypeEnumMap[instance.mealType]!,
  'name': instance.name,
  'calories': instance.calories,
  'carbsG': instance.carbsG,
  'proteinG': instance.proteinG,
  'fatG': instance.fatG,
  'portionValue': instance.portionValue,
  'portionUnit': instance.portionUnit,
  'source': instance.source,
};

const _$MealTypeEnumMap = {
  MealType.breakfast: 'breakfast',
  MealType.lunch: 'lunch',
  MealType.dinner: 'dinner',
  MealType.snack: 'snack',
};
