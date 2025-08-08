import 'package:json_annotation/json_annotation.dart';

part 'daily_totals.g.dart';

@JsonSerializable()
class DailyTotals {
  const DailyTotals({
    required this.date, // yyyy-mm-dd
    this.calorieTotal = 0,
    this.carbsG = 0,
    this.proteinG = 0,
    this.fatG = 0,
    this.deltaFromGoal = 0,
  });

  final String date; // yyyy-mm-dd
  final int calorieTotal;
  final int carbsG;
  final int proteinG;
  final int fatG;
  final int deltaFromGoal;

  factory DailyTotals.fromJson(Map<String, dynamic> json) =>
      _$DailyTotalsFromJson(json);
  Map<String, dynamic> toJson() => _$DailyTotalsToJson(this);
}
