import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../onboarding/domain/user_profile_model.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../food_logging/application/food_logging_notifier.dart';
import '../application/date_aware_providers.dart';
import '../../onboarding/presentation/widgets/onboarding_base_layout.dart';

class CalorieCalculationPage extends ConsumerWidget {
  const CalorieCalculationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final userProfile = onboardingState.userProfile;
    final foodState = ref.watch(foodLoggingProvider);
    final activityState = ref.watch(activityNotifierProvider);

    // Calculate all necessary values
    final bmr = userProfile.bmr;
    final currentTdee = _calculateCurrentTdee(userProfile);
    final dynamicTargetCalories = _calculateTargetCalories(userProfile);
    final activityCalories = _getTotalActivityCalories(activityState);
    final consumedCalories = foodState.mealsForDate.fold(0.0, (sum, meal) => sum + meal.calories);
    final totalAvailableCalories = dynamicTargetCalories + activityCalories;
    final remainingCalories = totalAvailableCalories - consumedCalories;

    // Calculate TDEE burned so far today
    final now = DateTime.now();
    final secondsInDay = 24 * 60 * 60;
    final secondsSoFar = (now.hour * 3600) + (now.minute * 60) + now.second;
    final percentOfDayPassed = secondsSoFar / secondsInDay;
    final tdeeCaloriesBurnedSoFar = currentTdee * percentOfDayPassed;

    final isWorkDay = userProfile.useAutomaticWeekdayDetection 
        ? (now.weekday >= 1 && now.weekday <= 5)
        : userProfile.isCurrentlyWorkDay;
    
    final leisureActivityEnabled = userProfile.isLeisureActivityEnabledToday;

    return Scaffold(
      appBar: AppBar(
        title: Text('Kalorie Beregning'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(KSizes.margin4x),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with overview
                _buildHeaderSection(context, userProfile, totalAvailableCalories, consumedCalories, remainingCalories),
                
                KSizes.spacingVerticalL,
                
                // Grundberegning
                _buildCalculationSection(
                  context: context,
                  title: 'Grundberegning',
                  icon: MdiIcons.calculator,
                  color: AppColors.primary,
                  items: [
                    _CalculationItem('BMR (Grundstofskifte)', '${bmr.round()} kcal/dag', 'Din krop forbrænder dette i hvile'),
                    _CalculationItem('TDEE (Total daglig energi)', '${currentTdee.round()} kcal/dag', 'BMR + aktivitetsniveau'),
                    _CalculationItem('Forbrændt så langt i dag', '${tdeeCaloriesBurnedSoFar.round()} kcal', '${(percentOfDayPassed * 100).round()}% af dagen er gået'),
                  ],
                ),
                
                KSizes.spacingVerticalL,
                
                // Dit Mål
                _buildCalculationSection(
                  context: context,
                  title: 'Dit Mål',
                  icon: MdiIcons.target,
                  color: AppColors.success,
                  items: [
                    _CalculationItem('Dagligt mål', '${dynamicTargetCalories.round()} kcal', _getGoalTypeText(userProfile.goalType)),
                    _CalculationItem('Måljustering', '${(dynamicTargetCalories - currentTdee).round()} kcal', _getGoalAdjustmentText(userProfile.goalType, userProfile.weeklyGoalKg)),
                    _CalculationItem('Type dag', isWorkDay ? 'Arbejdsdag' : 'Fridag', _getWorkDayExplanation(userProfile)),
                    _CalculationItem('Fritidsaktivitet', leisureActivityEnabled ? 'Aktiveret' : 'Deaktiveret', leisureActivityEnabled ? 'Fritidsaktivitet tæller med i dagens TDEE' : 'Kun arbejdsaktivitet tæller med'),
                  ],
                ),
                
                KSizes.spacingVerticalL,
                
                // Aktivitet & Resultater
                _buildCalculationSection(
                  context: context,
                  title: 'Aktivitet & Resultater',
                  icon: MdiIcons.run,
                  color: AppColors.warning,
                  items: [
                    _CalculationItem('Ekstra aktivitet', '${activityCalories.round()} kcal', 'Fra træning og motion'),
                    _CalculationItem('Tilgængelige kalorier', '${totalAvailableCalories.round()} kcal', 'Mål + aktivitet'),
                    _CalculationItem('Spist i dag', '${consumedCalories.round()} kcal', 'Progress: ${((consumedCalories / totalAvailableCalories) * 100).round()}%'),
                    _CalculationItem('Tilbage at spise', '${remainingCalories.round()} kcal', remainingCalories < 0 ? 'Over målet!' : 'Kan stadig spises'),
                  ],
                ),
                
                KSizes.spacingVerticalL,
                
                // Forklaring
                _buildExplanationSection(context, currentTdee, dynamicTargetCalories, leisureActivityEnabled, consumedCalories, totalAvailableCalories),
                
                // Extra spacing at bottom
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, UserProfileModel userProfile, double totalAvailable, double consumed, double remaining) {
    final progress = totalAvailable > 0 ? (consumed / totalAvailable).clamp(0.0, 1.2) : 0.0;
    
    return OnboardingSection(
      gradientColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingSectionHeader(
            title: 'Din Kalorie Status',
            subtitle: 'Dagens kalorie oversigt og beregninger',
            icon: MdiIcons.fire,
            iconColor: AppColors.primary,
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          // Progress display like goal edit page
          Container(
            padding: const EdgeInsets.all(KSizes.margin4x),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.05),
                  AppColors.primary.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(KSizes.radiusL),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spist i dag',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${consumed.round()} kcal',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: progress > 1.0 ? 1.0 : progress,
                    strokeWidth: 6,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress > 1.0 ? AppColors.error : AppColors.primary,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Tilbage',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${remaining.round()} kcal',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightBold,
                        color: remaining < 0 ? AppColors.error : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required List<_CalculationItem> items,
  }) {
    return OnboardingSection(
      gradientColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingSectionHeader(
            title: title,
            subtitle: 'Detaljer og beregninger',
            icon: icon,
            iconColor: color,
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          ...items.map((item) => _buildCalculationItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildCalculationItem(BuildContext context, _CalculationItem item) {
    return Padding(
      padding: EdgeInsets.only(bottom: KSizes.margin3x),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    fontWeight: KSizes.fontWeightMedium,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: KSizes.fontSizeS,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item.value,
              style: TextStyle(
                fontSize: KSizes.fontSizeL,
                fontWeight: KSizes.fontWeightBold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationSection(BuildContext context, double currentTdee, double dynamicTargetCalories, bool leisureActivityEnabled, double consumedCalories, double totalAvailableCalories) {
    return OnboardingSection(
      gradientColor: AppColors.info,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingSectionHeader(
            title: 'Forklaring',
            subtitle: 'Sådan beregner vi dine kalorier',
            icon: MdiIcons.lightbulb,
            iconColor: AppColors.info,
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          OnboardingHelpText(
            text: 'Din TDEE (${currentTdee.toInt()} kcal) justeres med ${(dynamicTargetCalories - currentTdee).toInt()} kcal for at nå dit mål. '
                  'Fritidsaktivitet er ${leisureActivityEnabled ? 'aktiveret' : 'deaktiveret'} i dag. '
                  'Cirklen viser spiste kalorier (${consumedCalories.toInt()}) ud af tilgængelige kalorier (${totalAvailableCalories.toInt()}).',
            type: OnboardingHelpType.neutral,
          ),
        ],
      ),
    );
  }

  // Helper methods (copied from original implementation)
  
  double _calculateCurrentTdee(UserProfileModel profile) {
    if (profile.dateOfBirth == null || 
        profile.heightCm <= 0 || 
        profile.currentWeightKg <= 0 ||
        profile.gender == null) {
      return profile.tdee;
    }

    final now = DateTime.now();
    final birthDate = profile.dateOfBirth!;
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

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

    double tdee;
    
    if (profile.workActivityLevel != null && profile.leisureActivityLevel != null) {
      double workMultiplier = 1.2;
      
      final isWorkDay = profile.useAutomaticWeekdayDetection 
          ? (now.weekday >= 1 && now.weekday <= 5)
          : profile.isCurrentlyWorkDay;
      
      if (isWorkDay) {
        workMultiplier = switch (profile.workActivityLevel!) {
          WorkActivityLevel.sedentary => 1.2,
          WorkActivityLevel.light => 1.375,
          WorkActivityLevel.moderate => 1.55,
          WorkActivityLevel.heavy => 1.725,
          WorkActivityLevel.veryHeavy => 1.9,
        };
      }

      double leisureMultiplier = 1.0;
      if (profile.isLeisureActivityEnabledToday) {
        leisureMultiplier = switch (profile.leisureActivityLevel!) {
          LeisureActivityLevel.sedentary => 1.0,
          LeisureActivityLevel.lightlyActive => 1.2,
          LeisureActivityLevel.moderatelyActive => 1.375,
          LeisureActivityLevel.veryActive => 1.55,
          LeisureActivityLevel.extraActive => 1.725,
        };
      }

      tdee = bmr * workMultiplier * leisureMultiplier;
    } else {
      tdee = profile.tdee;
    }

    return tdee;
  }

  double _calculateTargetCalories(UserProfileModel profile) {
    return profile.targetCalories.toDouble();
  }

  double _getTotalActivityCalories(dynamic activityState) {
    if (activityState.state.todaysActivitiesState.isSuccess) {
      final activities = activityState.state.todaysActivitiesState.data!;
      return activities.fold<double>(0.0, (double sum, dynamic activity) => sum + (activity.caloriesBurned as num).toDouble());
    }
    return 0.0;
  }

  String _getGoalTypeText(GoalType? goalType) {
    switch (goalType) {
      case GoalType.weightLoss:
        return 'Vægttab';
      case GoalType.weightGain:
        return 'Vægtøgning';
      case GoalType.muscleGain:
        return 'Muskelvækst';
      case GoalType.weightMaintenance:
        return 'Vægtvedligeholdelse';
      default:
        return 'Ikke sat';
    }
  }

  String _getWorkDayExplanation(UserProfileModel profile) {
    if (profile.workActivityLevel == null) {
      return 'Bruger gammelt aktivitetssystem';
    }
    
    if (profile.useAutomaticWeekdayDetection) {
      return 'Automatisk detekteret (Man-Fre = arbejdsdage)';
    } else {
      return 'Manuel indstilling';
    }
  }

  String _getGoalAdjustmentText(GoalType? goalType, double weeklyGoalKg) {
    final roundedWeeklyGoal = weeklyGoalKg == weeklyGoalKg.roundToDouble() 
        ? weeklyGoalKg.toInt().toString() 
        : weeklyGoalKg.toStringAsFixed(1);
        
    switch (goalType) {
      case GoalType.weightLoss:
        return 'Underskud for ${roundedWeeklyGoal}kg/uge vægttab';
      case GoalType.weightGain:
        return 'Overskud for ${roundedWeeklyGoal}kg/uge vægtøgning';
      case GoalType.muscleGain:
        return 'Overskud for ${roundedWeeklyGoal}kg/uge muskelvækst';
      case GoalType.weightMaintenance:
        return 'Ingen justering - vedligehold vægt';
      default:
        return 'Ingen justering';
    }
  }
}

class _CalculationItem {
  final String label;
  final String value;
  final String description;

  const _CalculationItem(this.label, this.value, this.description);
} 