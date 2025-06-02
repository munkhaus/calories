import 'package:flutter_test/flutter_test.dart';
import 'package:calories/features/onboarding/domain/user_profile_model.dart';

/// Test class to verify all calorie calculations are correct
class CalorieCalculationTester {
  
  /// Test BMR calculation using Mifflin-St Jeor Equation
  static double calculateBMR({
    required Gender gender,
    required double weightKg,
    required double heightCm,
    required int age,
  }) {
    if (gender == Gender.male) {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
  }
  
  /// Test TDEE calculation with work and leisure activity
  static double calculateTDEE({
    required double bmr,
    required WorkActivityLevel workLevel,
    required LeisureActivityLevel? leisureLevel,
    required bool isWorkDay,
    required bool isLeisureEnabled,
  }) {
    // Work activity multiplier
    double workMultiplier = 1.2; // Default sedentary baseline
    
    if (isWorkDay) {
      workMultiplier = switch (workLevel) {
        WorkActivityLevel.sedentary => 1.2,
        WorkActivityLevel.light => 1.375,
        WorkActivityLevel.moderate => 1.55,
        WorkActivityLevel.heavy => 1.725,
        WorkActivityLevel.veryHeavy => 1.9,
      };
    }
    
    // Leisure activity addition
    double leisureAddition = 0.0;
    if (isLeisureEnabled && leisureLevel != null) {
      leisureAddition = switch (leisureLevel) {
        LeisureActivityLevel.sedentary => 0.0,
        LeisureActivityLevel.lightlyActive => 0.155,
        LeisureActivityLevel.moderatelyActive => 0.35,
        LeisureActivityLevel.veryActive => 0.525,
        LeisureActivityLevel.extraActive => 0.7,
      };
    }
    
    return (bmr * workMultiplier) + (bmr * leisureAddition);
  }
  
  /// Test target calories calculation based on goal
  static double calculateTargetCalories({
    required double tdee,
    required GoalType goalType,
    required double weeklyGoalKg,
  }) {
    double targetCalories = tdee;
    
    if (goalType == GoalType.weightLoss) {
      // Weight loss: create caloric deficit
      final weeklyDeficitKcal = weeklyGoalKg * 7700.0; // 1 kg fat ≈ 7700 kcal
      final dailyDeficitKcal = weeklyDeficitKcal / 7.0;
      targetCalories = tdee - dailyDeficitKcal;
    } else if (goalType == GoalType.weightGain || goalType == GoalType.muscleGain) {
      // Weight gain: create caloric surplus
      final weeklySurplusKcal = weeklyGoalKg * 7700.0;
      final dailySurplusKcal = weeklySurplusKcal / 7.0;
      targetCalories = tdee + dailySurplusKcal;
    }
    // WeightMaintenance: no change needed
    
    return targetCalories.clamp(800.0, 4000.0);
  }
  
  /// Test calories burned so far today based on time
  static double calculateCaloriesBurnedSoFar({
    required double tdee,
    required DateTime currentTime,
  }) {
    final secondsInDay = 24 * 60 * 60;
    final secondsSoFar = (currentTime.hour * 3600) + 
                        (currentTime.minute * 60) + 
                        currentTime.second;
    final percentOfDayPassed = secondsSoFar / secondsInDay;
    return tdee * percentOfDayPassed;
  }
}

void main() {
  group('Calorie Calculation Tests', () {
    
    test('BMR calculation - Male example', () {
      // Test case: 30-year-old male, 80kg, 180cm
      final bmr = CalorieCalculationTester.calculateBMR(
        gender: Gender.male,
        weightKg: 80.0,
        heightCm: 180.0,
        age: 30,
      );
      
      // Expected: (10 * 80) + (6.25 * 180) - (5 * 30) + 5 = 800 + 1125 - 150 + 5 = 1780
      expect(bmr, closeTo(1780.0, 0.1));
      print('Male BMR (80kg, 180cm, 30 år): ${bmr.round()} kcal ✓');
    });
    
    test('BMR calculation - Female example', () {
      // Test case: 25-year-old female, 65kg, 165cm
      final bmr = CalorieCalculationTester.calculateBMR(
        gender: Gender.female,
        weightKg: 65.0,
        heightCm: 165.0,
        age: 25,
      );
      
      // Expected: (10 * 65) + (6.25 * 165) - (5 * 25) - 161 = 650 + 1031.25 - 125 - 161 = 1395.25
      expect(bmr, closeTo(1395.25, 0.1));
      print('Female BMR (65kg, 165cm, 25 år): ${bmr.round()} kcal ✓');
    });
    
    test('TDEE calculation - Work day with leisure activity', () {
      final bmr = 1780.0; // From male example above
      
      final tdee = CalorieCalculationTester.calculateTDEE(
        bmr: bmr,
        workLevel: WorkActivityLevel.moderate, // 1.55 multiplier
        leisureLevel: LeisureActivityLevel.moderatelyActive, // 0.35 addition
        isWorkDay: true,
        isLeisureEnabled: true,
      );
      
      // Expected: (1780 * 1.55) + (1780 * 0.35) = 2759 + 623 = 3382
      final expectedTdee = (bmr * 1.55) + (bmr * 0.35);
      expect(tdee, closeTo(expectedTdee, 0.1));
      print('TDEE arbejdsdag med fritidsaktivitet: ${tdee.round()} kcal ✓');
    });
    
    test('TDEE calculation - Non-work day without leisure', () {
      final bmr = 1780.0;
      
      final tdee = CalorieCalculationTester.calculateTDEE(
        bmr: bmr,
        workLevel: WorkActivityLevel.moderate, // Should not apply
        leisureLevel: LeisureActivityLevel.moderatelyActive, // Should not apply
        isWorkDay: false,
        isLeisureEnabled: false,
      );
      
      // Expected: BMR * 1.2 (sedentary baseline) + 0 = 1780 * 1.2 = 2136
      final expectedTdee = bmr * 1.2;
      expect(tdee, closeTo(expectedTdee, 0.1));
      print('TDEE fridag uden fritidsaktivitet: ${tdee.round()} kcal ✓');
    });
    
    test('Target calories - Weight loss 0.5kg/week', () {
      final tdee = 2500.0;
      
      final targetCalories = CalorieCalculationTester.calculateTargetCalories(
        tdee: tdee,
        goalType: GoalType.weightLoss,
        weeklyGoalKg: 0.5,
      );
      
      // Expected: 0.5kg/uge = 0.5 * 7700 = 3850 kcal/uge deficit
      // Daily deficit: 3850 / 7 = 550 kcal
      // Target: 2500 - 550 = 1950 kcal
      final expectedTarget = tdee - (0.5 * 7700 / 7);
      expect(targetCalories, closeTo(expectedTarget, 0.1));
      print('Målkalorier vægttab 0.5kg/uge: ${targetCalories.round()} kcal (deficit: ${(tdee - targetCalories).round()} kcal) ✓');
    });
    
    test('Target calories - Weight gain 0.3kg/week', () {
      final tdee = 2500.0;
      
      final targetCalories = CalorieCalculationTester.calculateTargetCalories(
        tdee: tdee,
        goalType: GoalType.weightGain,
        weeklyGoalKg: 0.3,
      );
      
      // Expected: 0.3kg/uge = 0.3 * 7700 = 2310 kcal/uge surplus
      // Daily surplus: 2310 / 7 = 330 kcal
      // Target: 2500 + 330 = 2830 kcal
      final expectedTarget = tdee + (0.3 * 7700 / 7);
      expect(targetCalories, closeTo(expectedTarget, 0.1));
      print('Målkalorier vægtøgning 0.3kg/uge: ${targetCalories.round()} kcal (surplus: ${(targetCalories - tdee).round()} kcal) ✓');
    });
    
    test('Target calories - Weight maintenance', () {
      final tdee = 2500.0;
      
      final targetCalories = CalorieCalculationTester.calculateTargetCalories(
        tdee: tdee,
        goalType: GoalType.weightMaintenance,
        weeklyGoalKg: 0.0,
      );
      
      // Expected: No change from TDEE
      expect(targetCalories, closeTo(tdee, 0.1));
      print('Målkalorier vægtvedligeholdelse: ${targetCalories.round()} kcal (ingen justering) ✓');
    });
    
    test('Calories burned so far - Midday example', () {
      final tdee = 2400.0;
      final currentTime = DateTime(2025, 1, 1, 12, 0, 0); // Midday
      
      final caloriesBurned = CalorieCalculationTester.calculateCaloriesBurnedSoFar(
        tdee: tdee,
        currentTime: currentTime,
      );
      
      // Expected: 50% of day passed, so 50% of TDEE = 1200 kcal
      final expectedBurned = tdee * 0.5;
      expect(caloriesBurned, closeTo(expectedBurned, 0.1));
      print('Kalorier forbrændt kl. 12:00: ${caloriesBurned.round()} kcal (50% af TDEE) ✓');
    });
    
    test('Calories burned so far - Evening example', () {
      final tdee = 2400.0;
      final currentTime = DateTime(2025, 1, 1, 18, 0, 0); // 6 PM
      
      final caloriesBurned = CalorieCalculationTester.calculateCaloriesBurnedSoFar(
        tdee: tdee,
        currentTime: currentTime,
      );
      
      // Expected: 18/24 = 75% of day passed, so 75% of TDEE = 1800 kcal
      final expectedBurned = tdee * 0.75;
      expect(caloriesBurned, closeTo(expectedBurned, 0.1));
      print('Kalorier forbrændt kl. 18:00: ${caloriesBurned.round()} kcal (75% af TDEE) ✓');
    });
    
    test('Complete scenario - Real user example', () {
      print('\n=== KOMPLET SCENARIO TEST ===');
      print('Bruger: 28-årig mand, 75kg, 175cm');
      print('Mål: Vægttab 0.7kg/uge');
      print('Aktivitet: Moderat arbejde + let fritidsaktivitet');
      print('Tid: Arbejdsdag kl. 14:00');
      
      // Calculate BMR
      final bmr = CalorieCalculationTester.calculateBMR(
        gender: Gender.male,
        weightKg: 75.0,
        heightCm: 175.0,
        age: 28,
      );
      print('BMR: ${bmr.round()} kcal');
      
      // Calculate TDEE
      final tdee = CalorieCalculationTester.calculateTDEE(
        bmr: bmr,
        workLevel: WorkActivityLevel.moderate,
        leisureLevel: LeisureActivityLevel.lightlyActive,
        isWorkDay: true,
        isLeisureEnabled: true,
      );
      print('TDEE: ${tdee.round()} kcal');
      
      // Calculate target calories
      final targetCalories = CalorieCalculationTester.calculateTargetCalories(
        tdee: tdee,
        goalType: GoalType.weightLoss,
        weeklyGoalKg: 0.7,
      );
      print('Målkalorier: ${targetCalories.round()} kcal');
      print('Dagligt underskud: ${(tdee - targetCalories).round()} kcal');
      
      // Calculate calories burned so far (2 PM)
      final currentTime = DateTime(2025, 1, 1, 14, 0, 0);
      final caloriesBurned = CalorieCalculationTester.calculateCaloriesBurnedSoFar(
        tdee: tdee,
        currentTime: currentTime,
      );
      print('Forbrændt kl. 14:00: ${caloriesBurned.round()} kcal');
      
      // Verify calculations make sense
      expect(bmr, greaterThan(1500)); // Reasonable BMR
      expect(bmr, lessThan(2000)); // Not too high
      expect(tdee, greaterThan(bmr)); // TDEE should be higher than BMR
      expect(targetCalories, lessThan(tdee)); // Weight loss target should be lower
      expect(caloriesBurned, lessThan(tdee)); // Can't burn more than daily total
      expect(caloriesBurned, greaterThan(tdee * 0.3)); // Should have burned something by 2 PM
      
      print('✓ Alle beregninger ser rimelige ud!');
    });
  });
} 