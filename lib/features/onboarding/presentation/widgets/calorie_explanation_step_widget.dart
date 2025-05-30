import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../application/onboarding_notifier.dart';
import '../../domain/user_profile_model.dart';

/// Step for explaining how calorie calculations are made
class CalorieExplanationStepWidget extends ConsumerWidget {
  const CalorieExplanationStepWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final profile = state.userProfile;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dit daglige kaloriemål',
            style: TextStyle(
              fontSize: KSizes.fontSizeL,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: KSizes.margin2x),
          Text(
            'Sådan har vi beregnet dit personlige kaloriemål',
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: KSizes.margin6x),

          // Final result card
          _buildFinalResultCard(context, profile),
          SizedBox(height: KSizes.margin6x),

          // Step-by-step calculation
          Text(
            'Beregning trin for trin:',
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: KSizes.margin4x),

          // Step 1: BMR
          _buildCalculationStep(
            context: context,
            stepNumber: 1,
            title: 'Grundstofskifte (BMR)',
            description: 'Kalorier din krop bruger i hvile',
            calculation: _getBMRCalculation(profile),
            result: '${_calculateBMR(profile).round()} kcal',
            color: Colors.blue,
          ),
          SizedBox(height: KSizes.margin4x),

          // Step 2: Activity level
          _buildCalculationStep(
            context: context,
            stepNumber: 2,
            title: 'Aktivitetsniveau',
            description: _getActivityDescription(profile),
            calculation: _getActivityCalculation(profile),
            result: '${_calculateTDEE(profile).round()} kcal',
            color: Colors.green,
          ),
          SizedBox(height: KSizes.margin4x),

          // Step 3: Goal adjustment
          if (profile.goalType != GoalType.weightMaintenance)
            _buildCalculationStep(
              context: context,
              stepNumber: 3,
              title: 'Måljustering',
              description: _getGoalDescription(profile),
              calculation: _getGoalCalculation(profile),
              result: '${profile.targetCalories} kcal',
              color: _getGoalColor(profile.goalType),
            ),

          SizedBox(height: KSizes.margin6x),

          // Additional info
          _buildAdditionalInfo(context),
        ],
      ),
    );
  }

  Widget _buildFinalResultCard(BuildContext context, UserProfileModel profile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(KSizes.margin6x),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.local_fire_department,
            size: KSizes.iconXL,
            color: Colors.white,
          ),
          SizedBox(height: KSizes.margin2x),
          Text(
            'Dit daglige kaloriemål',
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: KSizes.margin1x),
          Text(
            '${profile.targetCalories} kcal',
            style: TextStyle(
              fontSize: KSizes.fontSizeXXL,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: KSizes.margin2x),
          Text(
            _getGoalSummary(profile),
            style: TextStyle(
              fontSize: KSizes.fontSizeS,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationStep({
    required BuildContext context,
    required int stepNumber,
    required String title,
    required String description,
    required String calculation,
    required String result,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusM),
      ),
      child: Padding(
        padding: EdgeInsets.all(KSizes.margin4x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$stepNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: KSizes.margin3x),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: KSizes.fontSizeM,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: KSizes.fontSizeS,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: KSizes.margin3x),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(KSizes.margin3x),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(KSizes.radiusS),
              ),
              child: Text(
                calculation,
                style: TextStyle(
                  fontSize: KSizes.fontSizeS,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            SizedBox(height: KSizes.margin2x),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resultat:',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  result,
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusM),
      ),
      child: Padding(
        padding: EdgeInsets.all(KSizes.margin4x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: KSizes.iconM,
                ),
                SizedBox(width: KSizes.margin2x),
                Text(
                  'Vigtigt at vide',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: KSizes.margin3x),
            _buildInfoPoint('Dette er et estimat baseret på standardformler'),
            _buildInfoPoint('Din faktiske kalorieforbrug kan variere'),
            _buildInfoPoint('Juster målene efter dine resultater'),
            _buildInfoPoint('Konsulter en sundhedsprofessionel ved tvivl'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: KSizes.margin2x),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: EdgeInsets.only(top: 6, right: KSizes.margin2x),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: KSizes.fontSizeS,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for calculations
  double _calculateBMR(UserProfileModel profile) {
    if (profile.dateOfBirth == null || 
        profile.currentWeightKg <= 0 || 
        profile.heightCm <= 0 ||
        profile.gender == null) {
      return 0;
    }

    final now = DateTime.now();
    int age = now.year - profile.dateOfBirth!.year;
    if (now.month < profile.dateOfBirth!.month ||
        (now.month == profile.dateOfBirth!.month && now.day < profile.dateOfBirth!.day)) {
      age--;
    }

    if (profile.gender == Gender.male) {
      return (10.0 * profile.currentWeightKg) + (6.25 * profile.heightCm) - (5.0 * age) + 5.0;
    } else {
      return (10.0 * profile.currentWeightKg) + (6.25 * profile.heightCm) - (5.0 * age) - 161.0;
    }
  }

  double _calculateTDEE(UserProfileModel profile) {
    final bmr = _calculateBMR(profile);
    if (bmr <= 0) return 0;

    // Use new activity system if available
    if (profile.workActivityLevel != null && profile.leisureActivityLevel != null) {
      double workMultiplier = 1.2; // Default sedentary
      if (profile.isCurrentlyWorkDay) {
        workMultiplier = switch (profile.workActivityLevel!) {
          WorkActivityLevel.sedentary => 1.2,
          WorkActivityLevel.light => 1.375,
          WorkActivityLevel.moderate => 1.55,
          WorkActivityLevel.heavy => 1.725,
          WorkActivityLevel.veryHeavy => 1.9,
        };
      }
      
      double leisureAddition = 0.0;
      if (profile.isLeisureActivityEnabledToday) {
        leisureAddition = switch (profile.leisureActivityLevel!) {
          LeisureActivityLevel.sedentary => 0.0,
          LeisureActivityLevel.lightlyActive => 0.155,
          LeisureActivityLevel.moderatelyActive => 0.35,
          LeisureActivityLevel.veryActive => 0.525,
          LeisureActivityLevel.extraActive => 0.7,
        };
      }
      
      return (bmr * workMultiplier) + (bmr * leisureAddition);
    }

    // Fall back to legacy system
    if (profile.activityLevel == null) return bmr * 1.2;
    
    final activityMultiplier = switch (profile.activityLevel!) {
      ActivityLevel.sedentary => 1.2,
      ActivityLevel.lightlyActive => 1.375,
      ActivityLevel.moderatelyActive => 1.55,
      ActivityLevel.veryActive => 1.725,
      ActivityLevel.extraActive => 1.9,
    };
    
    return bmr * activityMultiplier;
  }

  String _getBMRCalculation(UserProfileModel profile) {
    if (profile.dateOfBirth == null || profile.gender == null) {
      return 'Mangler data til beregning';
    }

    final now = DateTime.now();
    int age = now.year - profile.dateOfBirth!.year;
    if (now.month < profile.dateOfBirth!.month ||
        (now.month == profile.dateOfBirth!.month && now.day < profile.dateOfBirth!.day)) {
      age--;
    }

    if (profile.gender == Gender.male) {
      return '(10 × ${profile.currentWeightKg.toStringAsFixed(1)}) + (6.25 × ${profile.heightCm.toStringAsFixed(1)}) - (5 × $age) + 5';
    } else {
      return '(10 × ${profile.currentWeightKg.toStringAsFixed(1)}) + (6.25 × ${profile.heightCm.toStringAsFixed(1)}) - (5 × $age) - 161';
    }
  }

  String _getActivityDescription(UserProfileModel profile) {
    if (profile.workActivityLevel != null && profile.leisureActivityLevel != null) {
      return 'Baseret på dit arbejde og fritidsaktiviteter';
    }
    return 'Baseret på dit generelle aktivitetsniveau';
  }

  String _getActivityCalculation(UserProfileModel profile) {
    final bmr = _calculateBMR(profile);
    
    if (profile.workActivityLevel != null && profile.leisureActivityLevel != null) {
      final workMultiplier = profile.isCurrentlyWorkDay ? 
        _getWorkMultiplier(profile.workActivityLevel!) : 1.2;
      final leisureAddition = profile.isLeisureActivityEnabledToday ?
        _getLeisureAddition(profile.leisureActivityLevel!) : 0.0;
      
      return '${bmr.round()} × ${workMultiplier.toStringAsFixed(2)} + ${bmr.round()} × ${leisureAddition.toStringAsFixed(2)}';
    }
    
    if (profile.activityLevel != null) {
      final multiplier = _getActivityMultiplier(profile.activityLevel!);
      return '${bmr.round()} × ${multiplier.toStringAsFixed(2)}';
    }
    
    return '${bmr.round()} × 1.2 (sedentær)';
  }

  double _getWorkMultiplier(WorkActivityLevel level) {
    return switch (level) {
      WorkActivityLevel.sedentary => 1.2,
      WorkActivityLevel.light => 1.375,
      WorkActivityLevel.moderate => 1.55,
      WorkActivityLevel.heavy => 1.725,
      WorkActivityLevel.veryHeavy => 1.9,
    };
  }

  double _getLeisureAddition(LeisureActivityLevel level) {
    return switch (level) {
      LeisureActivityLevel.sedentary => 0.0,
      LeisureActivityLevel.lightlyActive => 0.155,
      LeisureActivityLevel.moderatelyActive => 0.35,
      LeisureActivityLevel.veryActive => 0.525,
      LeisureActivityLevel.extraActive => 0.7,
    };
  }

  double _getActivityMultiplier(ActivityLevel level) {
    return switch (level) {
      ActivityLevel.sedentary => 1.2,
      ActivityLevel.lightlyActive => 1.375,
      ActivityLevel.moderatelyActive => 1.55,
      ActivityLevel.veryActive => 1.725,
      ActivityLevel.extraActive => 1.9,
    };
  }

  String _getGoalDescription(UserProfileModel profile) {
    return switch (profile.goalType!) {
      GoalType.weightLoss => 'Kalorieunderskud for vægttab',
      GoalType.weightGain => 'Kalorieoverskud for vægtøgning',
      GoalType.muscleGain => 'Kalorieoverskud for muskelopbygning',
      GoalType.weightMaintenance => 'Ingen justering - vedligehold vægt',
    };
  }

  String _getGoalCalculation(UserProfileModel profile) {
    final tdee = _calculateTDEE(profile);
    final weeklyGoal = profile.weeklyGoalKg;
    final dailyAdjustment = (weeklyGoal * 7700) / 7; // 7700 kcal per kg

    return switch (profile.goalType!) {
      GoalType.weightLoss => '${tdee.round()} - ${dailyAdjustment.round()} (underskud)',
      GoalType.weightGain || GoalType.muscleGain => '${tdee.round()} + ${dailyAdjustment.round()} (overskud)',
      GoalType.weightMaintenance => '${tdee.round()} (ingen justering)',
    };
  }

  Color _getGoalColor(GoalType? goalType) {
    return switch (goalType) {
      GoalType.weightLoss => Colors.red,
      GoalType.weightGain => Colors.green,
      GoalType.muscleGain => Colors.orange,
      GoalType.weightMaintenance => Colors.blue,
      null => Colors.grey,
    };
  }

  String _getGoalSummary(UserProfileModel profile) {
    return switch (profile.goalType!) {
      GoalType.weightLoss => 'Optimeret for sundt vægttab',
      GoalType.weightGain => 'Optimeret for sund vægtøgning',
      GoalType.muscleGain => 'Optimeret for muskelopbygning',
      GoalType.weightMaintenance => 'Optimeret for at vedligeholde din nuværende vægt',
    };
  }
} 