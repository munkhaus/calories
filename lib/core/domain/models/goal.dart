import 'package:json_annotation/json_annotation.dart';
import 'enums.dart';

part 'goal.g.dart';

@JsonSerializable()
class Goal {
  const Goal({
    required this.id,
    required this.startDate,
    required this.mode,
    required this.targetCalories,
    this.carbPercent = 40,
    this.proteinPercent = 30,
    this.fatPercent = 30,
    this.paceKcalPerDay = 0,
  });

  final String id;
  final DateTime startDate;
  final GoalMode mode;
  final int targetCalories;
  final int carbPercent;
  final int proteinPercent;
  final int fatPercent;
  final int paceKcalPerDay; // negative for deficit, positive for gain

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
  Map<String, dynamic> toJson() => _$GoalToJson(this);
}
