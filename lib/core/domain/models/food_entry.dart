import 'package:json_annotation/json_annotation.dart';
import 'enums.dart';

part 'food_entry.g.dart';

@JsonSerializable()
class FoodEntry {
  const FoodEntry({
    required this.id,
    required this.date, // yyyy-mm-dd
    required this.dateTime,
    required this.mealType,
    required this.name,
    required this.calories,
    this.carbsG = 0,
    this.proteinG = 0,
    this.fatG = 0,
    this.portionValue,
    this.portionUnit,
    this.source = 'manual',
  });

  final String id;
  final String date; // yyyy-mm-dd
  final DateTime dateTime;
  final MealType mealType;
  final String name;
  final int calories;
  final int carbsG;
  final int proteinG;
  final int fatG;
  final double? portionValue;
  final String? portionUnit;
  final String source;

  factory FoodEntry.fromJson(Map<String, dynamic> json) =>
      _$FoodEntryFromJson(json);
  Map<String, dynamic> toJson() => _$FoodEntryToJson(this);
}
