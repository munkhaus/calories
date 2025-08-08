// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_totals.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyTotals _$DailyTotalsFromJson(Map<String, dynamic> json) => DailyTotals(
  date: json['date'] as String,
  calorieTotal: (json['calorieTotal'] as num?)?.toInt() ?? 0,
  carbsG: (json['carbsG'] as num?)?.toInt() ?? 0,
  proteinG: (json['proteinG'] as num?)?.toInt() ?? 0,
  fatG: (json['fatG'] as num?)?.toInt() ?? 0,
  deltaFromGoal: (json['deltaFromGoal'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$DailyTotalsToJson(DailyTotals instance) =>
    <String, dynamic>{
      'date': instance.date,
      'calorieTotal': instance.calorieTotal,
      'carbsG': instance.carbsG,
      'proteinG': instance.proteinG,
      'fatG': instance.fatG,
      'deltaFromGoal': instance.deltaFromGoal,
    };
