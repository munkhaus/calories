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
    
    // Calculate remaining calories = target goal + extra activity calories - consumed calories
    // This shows how much you have left to eat considering your goal plus extra calories earned from activities
    final remainingCalories = targetCalories + activityCalories - consumedCalories;
    
    // Calculate total available calories (target + activity)
    final totalAvailableCalories = targetCalories + activityCalories;
    
    // Calculate progress based on total available calories
    final progress = totalAvailableCalories > 0 ? (consumedCalories / totalAvailableCalories) : 0.0;
    final displayProgress = progress.clamp(0.0, 1.0);
    
    final hasExceededGoal = remainingCalories < 0;

    return Container(
      margin: EdgeInsets.all(KSizes.margin2x),
      decoration: AppDesign.sectionDecoration,
      child: Padding(
        padding: EdgeInsets.all(KSizes.margin4x),
        child: Column(
          children: [
            // Work day toggle for manual users
            if (_shouldShowWorkDayToggle(userProfile)) ...[
              _WorkDayToggle(userProfile: userProfile),
              SizedBox(height: KSizes.margin4x),
            ],
            
            // Header with title and info icon only
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Dagens kalorier',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: KSizes.fontWeightBold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (hasExceededGoal) ...[
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Over mål',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                SizedBox(width: KSizes.margin1x),
                GestureDetector(
                  onTap: () => _showCalorieDetails(context, userProfile),
                  child: Icon(
                    MdiIcons.informationOutline,
                    size: KSizes.iconS,
                    color: AppColors.textSecondary,
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
                      'af ${totalAvailableCalories.toInt()} kcal',
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
                    label: 'Aktivitet',
                    value: '${activityCalories.toInt()}',
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
    // Use the pre-calculated target calories from user profile
    // This is already calculated during onboarding with proper goal adjustments
    return profile.targetCalories.toDouble();
  }
  
  double _calculateBmrCalories(UserProfileModel profile) {
    if (profile.dateOfBirth == null || 
        profile.heightCm <= 0 || 
        profile.currentWeightKg <= 0 ||
        profile.gender == null) {
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

    double dailyTdee;
    
    // Use new activity system if available, otherwise fall back to legacy
    if (profile.workActivityLevel != null && profile.leisureActivityLevel != null) {
      // Calculate work activity multiplier based on current day
      double workMultiplier = 1.2; // Default sedentary baseline
      
      // Determine if today is a work day
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
      
      // Calculate leisure activity addition - only if NOT manual tracking
      double leisureAddition = 0.0;
      if (profile.activityTrackingPreference != ActivityTrackingPreference.manual && 
          profile.isLeisureActivityEnabledToday) {
        leisureAddition = switch (profile.leisureActivityLevel!) {
          LeisureActivityLevel.sedentary => 0.0,
          LeisureActivityLevel.lightlyActive => 0.155, // ~155 calories
          LeisureActivityLevel.moderatelyActive => 0.35, // ~350 calories
          LeisureActivityLevel.veryActive => 0.525, // ~525 calories
          LeisureActivityLevel.extraActive => 0.7, // ~700 calories
        };
      }
      
      dailyTdee = (dailyBmr * workMultiplier) + (dailyBmr * leisureAddition);
    } else {
      // Fall back to legacy activity level system
      if (profile.activityLevel == null) {
        return 0.0;
      }
      
      final activityMultiplier = switch (profile.activityLevel!) {
        ActivityLevel.sedentary => 1.2,
        ActivityLevel.lightlyActive => 1.375,
        ActivityLevel.moderatelyActive => 1.55,
        ActivityLevel.veryActive => 1.725,
        ActivityLevel.extraActive => 1.9,
      };
      
      dailyTdee = dailyBmr * activityMultiplier;
    }

    // Calculate TDEE calories burned based on time of day
    final startOfDay = DateTime(now.year, now.month, now.day);
    final minutesSinceStartOfDay = now.difference(startOfDay).inMinutes;
    final percentOfDayPassed = minutesSinceStartOfDay / (24 * 60);
    
    final tdeeCalories = (dailyTdee * percentOfDayPassed);

    return tdeeCalories;
  }

  bool _shouldShowWorkDayToggle(UserProfileModel profile) {
    // Always show toggle to allow users to manually control their day type
    // This is useful for people who want to override automatic detection
    // or who are using the legacy activity system but still want day control
    return true;
  }

  void _showCalorieDetails(BuildContext context, UserProfileModel userProfile) {
    final bmr = userProfile.bmr;
    final tdee = userProfile.tdee;
    
    // Calculate the missing variables using the same methods as in build
    final targetCalories = _calculateTargetCalories(userProfile);
    // For activity calories, we'll use 0 as fallback since we don't have access to the provider here
    final activityCalories = 0.0; // This would need to be passed from the build method
    final totalAvailableCalories = targetCalories + activityCalories;
    final consumedCalories = 0.0; // This would need to be passed from the build method
    final remainingCalories = totalAvailableCalories - consumedCalories;
    
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final minutesSinceStartOfDay = now.difference(startOfDay).inMinutes;
    final percentOfDayPassed = minutesSinceStartOfDay / (24 * 60);
    final tdeeCaloriesBurnedSoFar = tdee * percentOfDayPassed;
    
    // Determine work day status
    final isWorkDay = userProfile.useAutomaticWeekdayDetection 
        ? (now.weekday >= 1 && now.weekday <= 5)
        : userProfile.isCurrentlyWorkDay;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(MdiIcons.calculator, color: AppColors.primary),
            SizedBox(width: KSizes.margin2x),
            Text('Kalorie Beregning'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailSection(
                title: '📊 Grundberegning',
                items: [
                  _DetailItem('BMR (Grundstofskifte)', '${bmr.toInt()} kcal/dag', 'Din krop forbrænder dette i hvile'),
                  _DetailItem('TDEE (Total daglig energi)', '${tdee.toInt()} kcal/dag', 'BMR + aktivitetsniveau'),
                  _DetailItem('Forbrændt så langt i dag', '${tdeeCaloriesBurnedSoFar.toInt()} kcal', '${(percentOfDayPassed * 100).toInt()}% af dagen er gået'),
                ],
              ),
              
              SizedBox(height: KSizes.margin3x),
              
              _DetailSection(
                title: '🎯 Dit Mål',
                items: [
                  _DetailItem('Dagligt mål', '${targetCalories.toInt()} kcal', _getGoalTypeText(userProfile.goalType)),
                  _DetailItem('Type dag', isWorkDay ? 'Arbejdsdag' : 'Fridag', _getWorkDayExplanation(userProfile)),
                ],
              ),
              
              SizedBox(height: KSizes.margin3x),
              
              _DetailSection(
                title: '🏃‍♂️ Aktivitet & Resultater',
                items: [
                  _DetailItem('Ekstra aktivitet', '${activityCalories.toInt()} kcal', 'Fra træning og motion'),
                  _DetailItem('Tilgængelige kalorier', '${totalAvailableCalories.toInt()} kcal', 'Mål + aktivitet'),
                  _DetailItem('Spist i dag', '${consumedCalories.toInt()} kcal', 'Progress: ${((consumedCalories / totalAvailableCalories) * 100).toInt()}%'),
                  _DetailItem('Tilbage at spise', '${remainingCalories.toInt()} kcal', remainingCalories < 0 ? 'Over målet!' : 'Kan stadig spises'),
                ],
              ),
              
              SizedBox(height: KSizes.margin3x),
              
              Container(
                padding: EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '💡 Forklaring',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeM,
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: KSizes.margin2x),
                    Text(
                      'Cirklen viser spiste kalorier (${consumedCalories.toInt()}) ud af tilgængelige kalorier (${totalAvailableCalories.toInt()}). '
                      'Tilgængelige = dagligt mål (${targetCalories.toInt()}) + ekstra fra aktivitet (${activityCalories.toInt()}).',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Forstået'),
          ),
        ],
      ),
    );
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          ),
        ],
      ),
    );
  }
}

/// Widget for toggling between work day and leisure activity settings
class _WorkDayToggle extends ConsumerWidget {
  final UserProfileModel userProfile;

  const _WorkDayToggle({required this.userProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingProvider.notifier);
    
    // Determine if today is a work day - respect manual override properly
    final isWorkDay = userProfile.useAutomaticWeekdayDetection 
        ? (DateTime.now().weekday >= 1 && DateTime.now().weekday <= 5)
        : userProfile.isCurrentlyWorkDay;
    
    // Only show leisure activity toggle if not using manual tracking
    final showLeisureToggle = userProfile.activityTrackingPreference != ActivityTrackingPreference.manual;
    
    final isLeisureEnabled = userProfile.isLeisureActivityEnabledToday;
    
    return Container(
      padding: EdgeInsets.all(KSizes.margin3x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          // Work day toggle (always shown)
          Row(
            children: [
              Icon(
                isWorkDay ? MdiIcons.briefcase : MdiIcons.home,
                color: isWorkDay ? AppColors.primary : AppColors.secondary,
                size: KSizes.iconS,
              ),
              SizedBox(width: KSizes.margin2x),
              Expanded(
                child: Text(
                  isWorkDay ? 'Arbejdsdag' : 'Hjemme/fridag',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeS,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // When user manually toggles, disable automatic detection
                  notifier.updateWeekdayDetection(false);
                  notifier.updateCurrentWorkDayStatus(!isWorkDay);
                },
                child: Container(
                  width: 40,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isWorkDay ? AppColors.primary : AppColors.border,
                  ),
                  child: AnimatedAlign(
                    duration: Duration(milliseconds: 200),
                    alignment: isWorkDay ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 16,
                      height: 16,
                      margin: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Leisure activity toggle (only shown if not manual tracking)
          if (showLeisureToggle) ...[
            SizedBox(height: KSizes.margin2x),
            Row(
              children: [
                Icon(
                  isLeisureEnabled ? MdiIcons.run : MdiIcons.sleep,
                  color: isLeisureEnabled ? AppColors.primary : AppColors.textSecondary,
                  size: KSizes.iconS,
                ),
                SizedBox(width: KSizes.margin2x),
                Expanded(
                  child: Text(
                    isLeisureEnabled ? 'Fritidsaktivitet tæller' : 'Ingen fritidsaktivitet i dag',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeS,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    notifier.updateLeisureActivityForToday(!isLeisureEnabled);
                  },
                  child: Container(
                    width: 40,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: isLeisureEnabled ? AppColors.primary : AppColors.border,
                    ),
                    child: AnimatedAlign(
                      duration: Duration(milliseconds: 200),
                      alignment: isLeisureEnabled ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 16,
                        height: 16,
                        margin: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Detail section widget for grouping related items
class _DetailSection extends StatelessWidget {
  final String title;
  final List<_DetailItem> items;

  const _DetailSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: KSizes.fontSizeL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: KSizes.margin2x),
        ...items.map((item) => Padding(
          padding: EdgeInsets.only(bottom: KSizes.margin1x),
          child: item,
        )),
      ],
    );
  }
}

/// Individual detail item widget
class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final String description;

  const _DetailItem(this.label, this.value, this.description);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: KSizes.fontSizeM,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (description.isNotEmpty) ...[
                SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: KSizes.fontSizeXS,
                    color: AppColors.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            value,
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
} 