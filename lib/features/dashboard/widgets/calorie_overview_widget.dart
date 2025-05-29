import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../onboarding/domain/user_profile_model.dart';
import '../../food_logging/application/food_logging_notifier.dart';
import '../../activity/application/activity_calories_notifier.dart';

/// Widget showing daily calorie intake vs goal with circular progress and stats
class CalorieOverviewWidget extends ConsumerWidget {
  const CalorieOverviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final userProfile = onboardingState.userProfile;
    final consumedCalories = ref.watch(totalCaloriesProvider);
    final activityCaloriesAsync = ref.watch(activityCaloriesProvider);

    // Calculate target calories based on user profile
    final targetCalories = _calculateTargetCalories(userProfile);
    
    // Get activity calories safely
    final activityCalories = activityCaloriesAsync.when(
      data: (calories) => calories.toDouble(),
      loading: () => 0.0,
      error: (error, stack) => 0.0,
    );
    
    // Calculate TDEE calories burned so far today
    final tdeeCalories = _calculateBmrCalories(userProfile);
    
    // Calculate total burned calories (TDEE + extra activities)
    final totalBurnedCalories = tdeeCalories + activityCalories;
    
    // Calculate remaining calories = target goal + extra activity calories - consumed calories - TDEE burned so far today
    // This shows how much you have left to eat considering what you've consumed, already burned, and extra activities you've done
    final remainingCalories = targetCalories + activityCalories - consumedCalories - tdeeCalories;
    
    // Calculate progress
    final progress = targetCalories > 0 ? (consumedCalories / targetCalories) : 0.0;
    final displayProgress = progress.clamp(0.0, 1.0);
    
    final hasExceededGoal = remainingCalories < 0;

    return Container(
      margin: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(KSizes.margin6x),
        child: Column(
          children: [
            // Header with icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(KSizes.margin2x),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.2),
                        AppColors.secondary.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                  ),
                  child: Icon(
                    MdiIcons.fire,
                    color: AppColors.primary,
                    size: KSizes.iconS,
                  ),
                ),
                SizedBox(width: KSizes.margin2x),
                Text(
                  'Dagens kalorier',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeXL,
                    fontWeight: KSizes.fontWeightBold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: KSizes.margin6x),
            
            // Enhanced circular progress indicator
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.secondary.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: displayProgress,
                    strokeWidth: 8,
                    backgroundColor: AppColors.surface.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      displayProgress >= 1.0 
                          ? AppColors.error 
                          : displayProgress >= 0.8 
                              ? AppColors.warning 
                              : AppColors.primary,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${consumedCalories.toInt()}',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'af ${targetCalories.toInt()} kcal',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS,
                        color: AppColors.textSecondary,
                        fontWeight: KSizes.fontWeightMedium,
                      ),
                    ),
                    SizedBox(height: KSizes.margin1x),
                    Text(
                      hasExceededGoal ? 'Overskudt!' : '${(displayProgress * 100).toInt()}% af målet',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXS,
                        color: hasExceededGoal ? AppColors.error : AppColors.primary,
                        fontWeight: KSizes.fontWeightMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: KSizes.margin6x),
            
            // Stats row with proper spacing
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Tilbage',
                    value: hasExceededGoal 
                        ? '+${(-remainingCalories).toInt()}'
                        : '${remainingCalories.toInt()}',
                    color: hasExceededGoal ? AppColors.error : AppColors.success,
                  ),
                ),
                SizedBox(width: KSizes.margin3x),
                Expanded(
                  child: _StatCard(
                    label: 'Spist',
                    value: '${consumedCalories.toInt()}',
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: KSizes.margin3x),
                Expanded(
                  child: _StatCard(
                    label: 'Forbrændt',
                    value: '${totalBurnedCalories.toInt()}',
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTargetCalories(UserProfileModel profile) {
    if (profile.dateOfBirth == null || 
        profile.heightCm <= 0 || 
        profile.currentWeightKg <= 0 ||
        profile.gender == null ||
        profile.activityLevel == null) {
      return 2000; // Default fallback
    }

    // Calculate age from date of birth
    final now = DateTime.now();
    final birthDate = profile.dateOfBirth!;
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    // Mifflin-St Jeor Equation for BMR
    double bmr;
    if (profile.gender == Gender.male) {
      bmr = (10 * profile.currentWeightKg) + 
            (6.25 * profile.heightCm) - 
            (5 * age) + 5;
    } else {
      bmr = (10 * profile.currentWeightKg) + 
            (6.25 * profile.heightCm) - 
            (5 * age) - 161;
    }

    // Apply activity factor
    double activityFactor = 1.2; // Default to sedentary
    switch (profile.activityLevel!) {
      case ActivityLevel.sedentary:
        activityFactor = 1.2;
        break;
      case ActivityLevel.lightlyActive:
        activityFactor = 1.375;
        break;
      case ActivityLevel.moderatelyActive:
        activityFactor = 1.55;
        break;
      case ActivityLevel.veryActive:
        activityFactor = 1.725;
        break;
      case ActivityLevel.extraActive:
        activityFactor = 1.9;
        break;
    }

    return bmr * activityFactor;
  }

  double _calculateBmrCalories(UserProfileModel profile) {
    if (profile.dateOfBirth == null || 
        profile.heightCm <= 0 || 
        profile.currentWeightKg <= 0 ||
        profile.gender == null ||
        profile.activityLevel == null) {
      return 0.0;
    }

    // Calculate age from date of birth
    final now = DateTime.now();
    final birthDate = profile.dateOfBirth!;
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    // Mifflin-St Jeor Equation for BMR (daily rate)
    double dailyBmr;
    if (profile.gender == Gender.male) {
      dailyBmr = (10 * profile.currentWeightKg) + 
                 (6.25 * profile.heightCm) - 
                 (5 * age) + 5;
    } else {
      dailyBmr = (10 * profile.currentWeightKg) + 
                 (6.25 * profile.heightCm) - 
                 (5 * age) - 161;
    }

    // Apply activity factor to get TDEE
    double activityFactor = 1.2;
    switch (profile.activityLevel!) {
      case ActivityLevel.sedentary:
        activityFactor = 1.2;
        break;
      case ActivityLevel.lightlyActive:
        activityFactor = 1.375;
        break;
      case ActivityLevel.moderatelyActive:
        activityFactor = 1.55;
        break;
      case ActivityLevel.veryActive:
        activityFactor = 1.725;
        break;
      case ActivityLevel.extraActive:
        activityFactor = 1.9;
        break;
    }

    final dailyTdee = dailyBmr * activityFactor;

    // Calculate TDEE calories burned based on time of day
    final startOfDay = DateTime(now.year, now.month, now.day);
    final minutesSinceStartOfDay = now.difference(startOfDay).inMinutes;
    final percentOfDayPassed = minutesSinceStartOfDay / (24 * 60);
    
    final tdeeCalories = (dailyTdee * percentOfDayPassed);

    return tdeeCalories;
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(KSizes.margin3x),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: KSizes.fontSizeL,
              fontWeight: KSizes.fontWeightBold,
              color: color,
            ),
          ),
          SizedBox(height: KSizes.margin1x),
          Text(
            label,
            style: TextStyle(
              fontSize: KSizes.fontSizeXS,
              color: AppColors.textSecondary,
              fontWeight: KSizes.fontWeightMedium,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 