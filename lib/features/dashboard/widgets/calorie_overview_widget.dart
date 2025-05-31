import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../onboarding/domain/user_profile_model.dart';
import '../../food_logging/application/food_logging_notifier.dart';
import '../application/selected_date_provider.dart';
import '../application/date_aware_providers.dart';

/// Widget showing daily calorie intake vs goal with contextual guidance and actionable insights
class CalorieOverviewWidget extends ConsumerWidget {
  const CalorieOverviewWidget({super.key});
 
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final userProfile = onboardingState.userProfile;
    final selectedDateNotifier = ref.read(selectedDateProvider.notifier);
    
    // Trigger date-aware activity loading
    ref.watch(dateAwareActivityProvider);
    
    // Calculate target calories dynamically based on current profile state
    final currentTdee = _calculateCurrentTdee(userProfile);
    final dynamicTargetCalories = _calculateDynamicTargetCalories(userProfile, currentTdee);
    
    final activityCalories = ref.watch(activityCaloriesForSelectedDateProvider).toDouble();
    final totalAvailableCalories = dynamicTargetCalories + activityCalories;
    
    // Get consumed calories
    final consumedCalories = ref.watch(totalCaloriesForSelectedDateProvider);
    
    // Calculate remaining calories and progress
    final remainingCalories = totalAvailableCalories - consumedCalories;
    
    // Calculate time-based context
    final timeContext = _calculateTimeContext();
    final caloriesByTimeOfDay = _calculateExpectedCaloriesByTime(totalAvailableCalories);
    final isAheadOfPace = consumedCalories < caloriesByTimeOfDay;
    
    // Calculate next meal suggestion
    final nextMealSuggestion = _calculateNextMealSuggestion(remainingCalories, timeContext);
    
    // Prevent division by zero and invalid progress
    double progress = 0.0;
    if (totalAvailableCalories > 0 && !totalAvailableCalories.isNaN && !consumedCalories.isNaN) {
      progress = consumedCalories / totalAvailableCalories;
    }
    
    final displayProgress = progress.clamp(0.0, 1.2);
    final hasExceededGoal = consumedCalories > totalAvailableCalories;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: _getContextualGradient(progress, isAheadOfPace),
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: _getProgressColor(displayProgress).withOpacity(0.15),
            blurRadius: KSizes.blurRadiusXL,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin6x),
        child: Column(
          children: [
            // Enhanced header with contextual status
            Row(
              children: [
                // Dynamic status icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getStatusIconColors(progress, isAheadOfPace),
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _getProgressColor(displayProgress).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getStatusIcon(progress, isAheadOfPace),
                    color: Colors.white,
                    size: KSizes.iconM,
                  ),
                ),
                
                const SizedBox(width: KSizes.margin3x),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dagens kalorier',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeL,
                          fontWeight: KSizes.fontWeightBold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      
                      // Removed contextual status message per user request
                      // SizedBox(height: KSizes.margin1x),
                      // Text(
                      //   _getContextualStatusMessage(progress, isAheadOfPace, timeContext, remainingCalories),
                      //   style: TextStyle(
                      //     fontSize: KSizes.fontSizeS,
                      //     color: _getStatusColor(progress, isAheadOfPace),
                      //     fontWeight: KSizes.fontWeightMedium,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                
                // Info button
                _buildControlButton(
                  icon: MdiIcons.informationOutline,
                  onTap: () => _showCalorieDetails(context, userProfile),
                  isPrimary: true,
                ),
              ],
            ),
            
            SizedBox(height: KSizes.margin6x),
            
            // Enhanced progress visualization with better context
            Stack(
              alignment: Alignment.center,
              children: [
                // Background circle with pace indicator
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface.withOpacity(0.8),
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                ),
                
                // Pace indicator (expected consumption by time of day)
                if (caloriesByTimeOfDay > 0) ...[
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: (caloriesByTimeOfDay / totalAvailableCalories).clamp(0.0, 1.0),
                      strokeWidth: 4,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.textSecondary.withOpacity(0.3),
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ],
                
                // Main progress indicator
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: displayProgress,
                    strokeWidth: 16,
                    backgroundColor: AppColors.surface.withOpacity(0.6),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(displayProgress),
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                
                // Center content with actionable information
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.95),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Primary number - remaining calories instead of consumed
                      Text(
                        hasExceededGoal 
                            ? '+${(-remainingCalories).toInt()}'
                            : '${remainingCalories.toInt()}',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: _getProgressColor(displayProgress),
                          letterSpacing: -1,
                        ),
                      ),
                      
                      Text(
                        hasExceededGoal ? 'over målet' : 'kcal tilbage',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeS,
                          color: AppColors.textSecondary,
                          fontWeight: KSizes.fontWeightMedium,
                        ),
                      ),
                      
                      SizedBox(height: KSizes.margin2x),
                      
                      // Removed actionable insight per user request
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: KSizes.margin2x,
                      //     vertical: KSizes.margin1x,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: _getProgressColor(displayProgress).withOpacity(0.15),
                      //     borderRadius: BorderRadius.circular(KSizes.radiusL),
                      //     border: Border.all(
                      //       color: _getProgressColor(displayProgress).withOpacity(0.3),
                      //       width: 1,
                      //     ),
                      //   ),
                      //   child: Text(
                      //     nextMealSuggestion,
                      //     style: TextStyle(
                      //       fontSize: KSizes.fontSizeXS,
                      //       color: _getProgressColor(displayProgress),
                      //       fontWeight: KSizes.fontWeightBold,
                      //     ),
                      //     textAlign: TextAlign.center,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: KSizes.margin8x),
            
            // Enhanced stat cards with more actionable information
            Row(
              children: [
                Expanded(
                  child: _buildEnhancedStatCard(
                    label: 'Spist i dag',
                    value: '${consumedCalories.toInt()}',
                    unit: 'kcal',
                    subtitle: '${(progress * 100).toInt()}% af målet',
                    color: _getProgressColor(displayProgress),
                    icon: MdiIcons.silverwareForkKnife,
                    trend: isAheadOfPace ? 'over pace' : 'under pace',
                  ),
                ),
                
                SizedBox(width: KSizes.margin4x),
                
                Expanded(
                  child: _buildEnhancedStatCard(
                    label: 'Aktivitet',
                    value: '+${activityCalories.toInt()}',
                    unit: 'kcal',
                    subtitle: 'ekstra budget',
                    color: AppColors.secondary,
                    icon: MdiIcons.runFast,
                    trend: activityCalories > 0 ? 'active' : 'sedentary',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: isPrimary 
              ? LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                )
              : null,
          color: isPrimary ? null : AppColors.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          border: Border.all(
            color: isPrimary 
                ? Colors.transparent 
                : AppColors.border.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: isPrimary ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Icon(
          icon,
          size: KSizes.iconXS,
          color: isPrimary ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildEnhancedStatCard({
    required String label,
    required String value,
    required String unit,
    required String subtitle,
    required Color color,
    required IconData icon,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(KSizes.margin2x),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(KSizes.radiusS),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: KSizes.iconS,
            ),
          ),
          
          SizedBox(height: KSizes.margin3x),
          
          Text(
            value,
            style: TextStyle(
              fontSize: KSizes.fontSizeXL,
              fontWeight: KSizes.fontWeightBold,
              color: color,
            ),
          ),
          
          SizedBox(height: KSizes.margin1x),
          
          Text(
            label,
            style: TextStyle(
              fontSize: KSizes.fontSizeS,
              color: AppColors.textSecondary,
              fontWeight: KSizes.fontWeightMedium,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: KSizes.margin1x),
          
          Text(
            subtitle,
            style: TextStyle(
              fontSize: KSizes.fontSizeXS,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    // Handle invalid progress values during initial load
    if (progress.isNaN || progress.isInfinite) {
      return const Color(0xFF4CAF50); // Green for default
    }
    
    // Clamp progress to reasonable bounds
    progress = progress.clamp(0.0, 1.2);
    
    // Create gradual color transition from green to orange to red
    // Green zone is much larger when there are many calories remaining
    if (progress <= 0.8) {
      // Many calories remaining: Green
      return const Color(0xFF4CAF50); // Standard green
    } else if (progress <= 0.9) {
      // Getting close to goal: Orange
      return const Color(0xFFFF9800); // Orange
    } else if (progress <= 1.0) {
      // Very close to goal: Dark orange  
      return const Color(0xFFFF5722); // Dark orange
    } else if (progress <= 1.1) {
      // Over goal: Red
      return const Color(0xFFF44336); // Red
    } else {
      // Way over goal: Dark red
      return const Color(0xFFD32F2F); // Dark red
    }
  }

  void _showCalorieDetails(BuildContext context, UserProfileModel userProfile) {
    // Calculate current TDEE for display purposes (this is raw TDEE without goal adjustments)
    final currentTdee = _calculateCurrentTdee(userProfile);
    final bmr = userProfile.bmr;
    
    // Calculate dynamic target calories based on current leisure activity status
    final dynamicTargetCalories = _calculateDynamicTargetCalories(userProfile, currentTdee);
    
    // For activity calories, get the current values from providers (would be better to pass these)
    final activityCalories = 0.0; // This would need to be passed from the build method
    final totalAvailableCalories = dynamicTargetCalories + activityCalories;
    final consumedCalories = 0.0; // This would need to be passed from the build method
    final remainingCalories = totalAvailableCalories - consumedCalories;
    
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final minutesSinceStartOfDay = now.difference(startOfDay).inMinutes;
    final percentOfDayPassed = minutesSinceStartOfDay / (24 * 60);
    final tdeeCaloriesBurnedSoFar = currentTdee * percentOfDayPassed;
    
    // Determine work day status
    final isWorkDay = userProfile.useAutomaticWeekdayDetection 
        ? (now.weekday >= 1 && now.weekday <= 5)
        : userProfile.isCurrentlyWorkDay;
    
    // Determine leisure activity status
    final leisureActivityEnabled = userProfile.isLeisureActivityEnabledToday;
    
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
                  _DetailItem('TDEE (Total daglig energi)', '${currentTdee.toInt()} kcal/dag', 'BMR + aktivitetsniveau'),
                  _DetailItem('Forbrændt så langt i dag', '${tdeeCaloriesBurnedSoFar.toInt()} kcal', '${(percentOfDayPassed * 100).toInt()}% af dagen er gået'),
                ],
              ),
              
              SizedBox(height: KSizes.margin3x),
              
              _DetailSection(
                title: '🎯 Dit Mål',
                items: [
                  _DetailItem('Dagligt mål', '${dynamicTargetCalories.toInt()} kcal', _getGoalTypeText(userProfile.goalType)),
                  _DetailItem('Måljustering', '${(dynamicTargetCalories - currentTdee).toInt()} kcal', _getGoalAdjustmentText(userProfile.goalType, userProfile.weeklyGoalKg)),
                  _DetailItem('Type dag', isWorkDay ? 'Arbejdsdag' : 'Fridag', _getWorkDayExplanation(userProfile)),
                  _DetailItem('Fritidsaktivitet', leisureActivityEnabled ? 'Aktiveret' : 'Deaktiveret', leisureActivityEnabled ? 'Fritidsaktivitet tæller med i dagens TDEE' : 'Kun arbejdsaktivitet tæller med'),
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
                      'Din TDEE (${currentTdee.toInt()} kcal) justeres med ${(dynamicTargetCalories - currentTdee).toInt()} kcal for at nå dit mål. '
                      'Fritidsaktivitet er ${leisureActivityEnabled ? 'aktiveret' : 'deaktiveret'} i dag. '
                      'Cirklen viser spiste kalorier (${consumedCalories.toInt()}) ud af tilgængelige kalorier (${totalAvailableCalories.toInt()}).',
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

  String _getGoalAdjustmentText(GoalType? goalType, double weeklyGoalKg) {
    switch (goalType) {
      case GoalType.weightLoss:
        return 'Underskud for ${weeklyGoalKg}kg/uge vægttab';
      case GoalType.weightGain:
        return 'Overskud for ${weeklyGoalKg}kg/uge vægtøgning';
      case GoalType.muscleGain:
        return 'Overskud for ${weeklyGoalKg}kg/uge muskelvækst';
      case GoalType.weightMaintenance:
        return 'Ingen justering - vedligehold vægt';
      default:
        return 'Ingen justering';
    }
  }

  double _calculateTargetCalories(UserProfileModel profile) {
    // Use the pre-calculated target calories from user profile
    // This is already calculated during onboarding with proper goal adjustments
    return profile.targetCalories.toDouble();
  }
  
  double _calculateCurrentTdee(UserProfileModel profile) {
    // Calculate BMR first
    if (profile.dateOfBirth == null || 
        profile.heightCm <= 0 || 
        profile.currentWeightKg <= 0 ||
        profile.gender == null) {
      return profile.tdee; // Fallback to pre-calculated TDEE
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

    double tdee;
    
    // Use new activity system if available
    if (profile.workActivityLevel != null && profile.leisureActivityLevel != null) {
      // Calculate work activity multiplier based on current day
      double workMultiplier = 1.2; // Default sedentary baseline
      
      // Determine if today is a work day using CURRENT profile state
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
      
      // Calculate leisure activity addition using CURRENT profile state
      double leisureAddition = 0.0;
      if (profile.activityTrackingPreference != ActivityTrackingPreference.manual && 
          profile.isLeisureActivityEnabledToday) { // This reflects current toggle state
        leisureAddition = switch (profile.leisureActivityLevel!) {
          LeisureActivityLevel.sedentary => 0.0,
          LeisureActivityLevel.lightlyActive => 0.155,
          LeisureActivityLevel.moderatelyActive => 0.35,
          LeisureActivityLevel.veryActive => 0.525,
          LeisureActivityLevel.extraActive => 0.7,
        };
      }
      
      tdee = (bmr * workMultiplier) + (bmr * leisureAddition);
    } else {
      // Fall back to legacy activity level system
      if (profile.activityLevel == null) {
        return profile.tdee;
      }
      
      final activityMultiplier = switch (profile.activityLevel!) {
        ActivityLevel.sedentary => 1.2,
        ActivityLevel.lightlyActive => 1.375,
        ActivityLevel.moderatelyActive => 1.55,
        ActivityLevel.veryActive => 1.725,
        ActivityLevel.extraActive => 1.9,
      };
      
      tdee = bmr * activityMultiplier;
    }

    // Return raw TDEE (total daily energy expenditure) without goal adjustments
    return tdee;
  }

  double _calculateDynamicTargetCalories(UserProfileModel profile, double currentTdee) {
    // Apply goal-based calorie adjustment to current TDEE
    double targetCalories = currentTdee;
    
    if (profile.goalType == GoalType.weightLoss) {
      // Weight loss: create caloric deficit
      final weeklyDeficitKcal = profile.weeklyGoalKg * 7700.0; // 1 kg fat ≈ 7700 kcal
      final dailyDeficitKcal = weeklyDeficitKcal / 7.0;
      targetCalories = currentTdee - dailyDeficitKcal;
    } else if (profile.goalType == GoalType.weightGain || profile.goalType == GoalType.muscleGain) {
      // Weight gain: create caloric surplus
      final weeklySurplusKcal = profile.weeklyGoalKg * 7700.0;
      final dailySurplusKcal = weeklySurplusKcal / 7.0;
      targetCalories = currentTdee + dailySurplusKcal;
    } else if (profile.goalType == GoalType.weightMaintenance) {
      // Maintenance: no adjustment needed
      targetCalories = currentTdee;
    }

    // Safety bounds
    return targetCalories.clamp(800.0, 4000.0);
  }

  String _calculateTimeContext() {
    final now = DateTime.now();
    final hour = now.hour;
    
    if (hour >= 5 && hour < 10) return 'morning';
    if (hour >= 10 && hour < 14) return 'midday';
    if (hour >= 14 && hour < 18) return 'afternoon';
    if (hour >= 18 && hour < 22) return 'evening';
    return 'night';
  }

  double _calculateExpectedCaloriesByTime(double totalCalories) {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final totalMinutesInDay = 24 * 60;
    final currentMinutes = hour * 60 + minute;
    
    // Assume most calories are consumed between 6 AM and 10 PM (16 hours)
    final activeStartHour = 6;
    final activeEndHour = 22;
    
    if (hour < activeStartHour) return 0.0;
    if (hour >= activeEndHour) return totalCalories;
    
    final activeMinutes = (activeEndHour - activeStartHour) * 60;
    final minutesSinceActiveStart = (hour - activeStartHour) * 60 + minute;
    
    // Progressive consumption: lighter breakfast, heavier lunch/dinner
    double progressFactor;
    if (hour < 12) {
      // Morning: slower consumption
      progressFactor = (minutesSinceActiveStart / activeMinutes) * 0.6;
    } else if (hour < 18) {
      // Afternoon: faster consumption
      progressFactor = 0.6 + ((minutesSinceActiveStart - 6*60) / activeMinutes) * 0.3;
    } else {
      // Evening: final consumption
      progressFactor = 0.9 + ((minutesSinceActiveStart - 12*60) / activeMinutes) * 0.1;
    }
    
    return totalCalories * progressFactor.clamp(0.0, 1.0);
  }

  String _calculateNextMealSuggestion(double remainingCalories, String timeContext) {
    if (remainingCalories <= 0) return 'Målet nået!';
    
    switch (timeContext) {
      case 'morning':
        if (remainingCalories > 800) return 'Plads til morgenmad';
        if (remainingCalories > 400) return 'Let morgenmad';
        return 'Kaffe + snack';
        
      case 'midday':
        if (remainingCalories > 1200) return 'Plads til stor frokost';
        if (remainingCalories > 600) return 'Normal frokost';
        return 'Let frokost';
        
      case 'afternoon':
        if (remainingCalories > 800) return 'Healthy snack tid';
        if (remainingCalories > 400) return 'Let mellemmåltid';
        return 'Små snacks';
        
      case 'evening':
        if (remainingCalories > 600) return 'Plads til aftensmad';
        if (remainingCalories > 300) return 'Let aftensmad';
        return 'Meget let måltid';
        
      default:
        return 'Godt arbejde i dag!';
    }
  }
  
  LinearGradient _getContextualGradient(double progress, bool isAheadOfPace) {
    if (progress > 1.0) {
      // Over goal - red gradient
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.error.withOpacity(0.1),
          Colors.white.withOpacity(0.95),
        ],
      );
    } else if (isAheadOfPace) {
      // Ahead of pace - orange gradient
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.warning.withOpacity(0.1),
          Colors.white.withOpacity(0.95),
        ],
      );
    } else {
      // On track - green gradient
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.success.withOpacity(0.1),
          Colors.white.withOpacity(0.95),
        ],
      );
    }
  }
  
  String _getContextualStatusMessage(double progress, bool isAheadOfPace, String timeContext, double remainingCalories) {
    if (progress > 1.0) {
      return 'Over målet - vælg lette alternativer resten af dagen';
    }
    
    final timeMessage = switch (timeContext) {
      'morning' => 'God morgen!',
      'midday' => 'Midt på dagen',
      'afternoon' => 'Eftermiddag',
      'evening' => 'Aftentime',
      _ => 'Sent på aftenen',
    };
    
    if (isAheadOfPace) {
      return '$timeMessage - Du spiser hurtigere end normalt';
    } else if (progress < 0.3) {
      return '$timeMessage - Husk at spise nok i dag';
    } else {
      return '$timeMessage - Du er godt på vej';
    }
  }
  
  Color _getStatusColor(double progress, bool isAheadOfPace) {
    if (progress > 1.0) return AppColors.error;
    if (isAheadOfPace) return AppColors.warning;
    if (progress < 0.3) return AppColors.info;
    return AppColors.success;
  }
  
  List<Color> _getStatusIconColors(double progress, bool isAheadOfPace) {
    final baseColor = _getStatusColor(progress, isAheadOfPace);
    return [baseColor, baseColor.withOpacity(0.8)];
  }
  
  IconData _getStatusIcon(double progress, bool isAheadOfPace) {
    if (progress > 1.0) return MdiIcons.alertCircle;
    if (isAheadOfPace) return MdiIcons.speedometer;
    if (progress < 0.3) return MdiIcons.silverwareForkKnife;
    return MdiIcons.checkCircle;
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