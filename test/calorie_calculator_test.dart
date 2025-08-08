import 'package:calories/core/domain/calorie_calculator.dart';
import 'package:calories/core/domain/models/enums.dart';
import 'package:calories/core/domain/models/goal.dart';
import 'package:calories/core/domain/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Calorie calculator returns plausible values', () {
    final calculator = CalorieCalculator();
    final profile = UserProfile(
      id: 'u1',
      metricUnits: true,
      ageYears: 30,
      sex: Sex.male,
      heightCm: 180,
      weightKg: 80,
      activityLevel: ActivityLevel.moderate,
    );
    final goal = Goal(
      id: 'g1',
      startDate: DateTime(2025, 1, 1),
      mode: GoalMode.lose,
      targetCalories: 0,
      paceKcalPerDay: -500,
    );

    final bmr = calculator.computeBmr(
      sex: profile.sex,
      weightKg: profile.weightKg,
      heightCm: profile.heightCm,
      ageYears: profile.ageYears,
    );
    expect(bmr, greaterThan(1500));
    expect(bmr, lessThan(2000));

    final tdee = calculator.computeTdee(
      bmr: bmr,
      activityLevel: profile.activityLevel,
    );
    expect(tdee, greaterThan(2000));
    expect(tdee, lessThan(3200));

    final target = calculator.computeTargetCalories(
      profile: profile,
      goal: goal,
    );
    expect(target, lessThan(tdee));
  });
}
