import 'models/enums.dart';
import 'models/user_profile.dart';
import 'models/goal.dart';

class CalorieCalculator {
  const CalorieCalculator();

  double computeBmr({
    required Sex sex,
    required double weightKg,
    required double heightCm,
    required int ageYears,
  }) {
    final double base = (10 * weightKg) + (6.25 * heightCm) - (5 * ageYears);
    return sex == Sex.male ? base + 5 : base - 161;
  }

  double activityMultiplier(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.active:
        return 1.725;
      case ActivityLevel.veryActive:
        return 1.9;
    }
  }

  double computeTdee({
    required double bmr,
    required ActivityLevel activityLevel,
  }) {
    return bmr * activityMultiplier(activityLevel);
  }

  int computeTargetCalories({
    required UserProfile profile,
    required Goal goal,
  }) {
    final double bmr = computeBmr(
      sex: profile.sex,
      weightKg: profile.weightKg,
      heightCm: profile.heightCm,
      ageYears: profile.ageYears,
    );
    final double tdee = computeTdee(
      bmr: bmr,
      activityLevel: profile.activityLevel,
    );
    final double adjusted = tdee + goal.paceKcalPerDay.toDouble();
    return adjusted.round();
  }
}
