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

/// Widget showing daily calorie intake vs goal with circular progress and stats
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
    // This ensures that leisure activity toggle immediately affects calories
    final currentTdee = _calculateCurrentTdee(userProfile);
    final dynamicTargetCalories = _calculateDynamicTargetCalories(userProfile, currentTdee);
    
    final activityCalories = ref.watch(activityCaloriesForSelectedDateProvider).toDouble();
    final totalAvailableCalories = dynamicTargetCalories + activityCalories;
    
    // Get consumed calories - use provider that will update automatically
    final consumedCalories = ref.watch(totalCaloriesForSelectedDateProvider);
    
    // Calculate remaining calories and progress
    final remainingCalories = totalAvailableCalories - consumedCalories;
    
    // Prevent division by zero and invalid progress during initial load
    double progress = 0.0;
    if (totalAvailableCalories > 0 && !totalAvailableCalories.isNaN && !consumedCalories.isNaN) {
      progress = consumedCalories / totalAvailableCalories;
    }
    
    final displayProgress = progress.clamp(0.0, 1.2); // Allow overflow visualization
    final hasExceededGoal = consumedCalories > totalAvailableCalories;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
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
            // Header section with improved typography
            Row(
              children: [
                // Modern icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.secondary,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    MdiIcons.fire,
                    color: Colors.white,
                    size: KSizes.iconM,
                  ),
                ),
                
                const SizedBox(width: KSizes.margin3x),
                
                // Title and date in same row
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Dagens kalorier',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeXL,
                          fontWeight: KSizes.fontWeightBold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      
                      const SizedBox(width: KSizes.margin3x),
                      
                      // Date selector with modern design
                      GestureDetector(
                        onTap: () => _showDatePicker(context, ref),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: KSizes.margin2x,
                            vertical: KSizes.margin1x,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(KSizes.radiusM),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                MdiIcons.calendar,
                                size: KSizes.iconXS,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: KSizes.margin1x),
                              Text(
                                selectedDateNotifier.formattedDate,
                                style: TextStyle(
                                  fontSize: KSizes.fontSizeS,
                                  color: AppColors.primary,
                                  fontWeight: KSizes.fontWeightSemiBold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Info button only
                _buildControlButton(
                  icon: MdiIcons.informationOutline,
                  onTap: () => _showCalorieDetails(context, userProfile),
                  isPrimary: true,
                ),
              ],
            ),
            
            const SizedBox(height: KSizes.margin2x),
            
            // Navigation controls in separate row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: MdiIcons.chevronLeft,
                  onTap: selectedDateNotifier.previousDay,
                ),
                const SizedBox(width: KSizes.margin4x),
                _buildControlButton(
                  icon: MdiIcons.chevronRight,
                  onTap: selectedDateNotifier.nextDay,
                ),
              ],
            ),
            
            SizedBox(height: KSizes.margin6x),
            
            // Enhanced circular progress with modern design
            Stack(
              alignment: Alignment.center,
              children: [
                // Background circle with stronger contrast
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface.withOpacity(0.8),
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                
                // Progress indicator with stronger contrast
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: displayProgress,
                    strokeWidth: 14,
                    backgroundColor: AppColors.surface.withOpacity(0.6),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(displayProgress),
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                
                // Center content with improved contrast and background
                Container(
                  width: 140,
                  height: 140,
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
                      Text(
                        '${consumedCalories.toInt()}',
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -1,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'af ${totalAvailableCalories.toInt()} kcal',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeM,
                          color: AppColors.textSecondary,
                          fontWeight: KSizes.fontWeightBold,
                        ),
                      ),
                      SizedBox(height: KSizes.margin1x),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KSizes.margin2x,
                          vertical: KSizes.margin1x,
                        ),
                        decoration: BoxDecoration(
                          color: _getProgressColor(displayProgress).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(KSizes.radiusL),
                          border: Border.all(
                            color: _getProgressColor(displayProgress).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          hasExceededGoal 
                              ? 'Over målet!' 
                              : '${(displayProgress * 100).toInt()}% af målet',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeXS,
                            color: _getProgressColor(displayProgress),
                            fontWeight: KSizes.fontWeightBold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: KSizes.margin8x),
            
            // Modern stats cards
            Row(
              children: [
                Expanded(
                  child: _buildModernStatCard(
                    label: 'Tilbage',
                    value: hasExceededGoal 
                        ? '+${(-remainingCalories).toInt()}'
                        : '${remainingCalories.toInt()}',
                    color: hasExceededGoal ? AppColors.error : AppColors.success,
                    icon: hasExceededGoal ? MdiIcons.trendingUp : MdiIcons.target,
                  ),
                ),
                
                SizedBox(width: KSizes.margin4x),
                
                Expanded(
                  child: _buildModernStatCard(
                    label: 'Aktivitet',
                    value: '+${activityCalories.toInt()}',
                    color: AppColors.secondary,
                    icon: MdiIcons.runFast,
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

  Widget _buildModernStatCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
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
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    // Handle invalid progress values during initial load
    if (progress.isNaN || progress.isInfinite) {
      return AppColors.primary;
    }
    
    if (progress >= 1.0) return AppColors.error;
    if (progress >= 0.8) return AppColors.warning; 
    return AppColors.primary;
  }

  void _showDatePicker(BuildContext context, WidgetRef ref) async {
    final selectedDate = ref.read(selectedDateProvider);
    final selectedDateNotifier = ref.read(selectedDateProvider.notifier);
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)), // 1 year back
      lastDate: DateTime.now().add(const Duration(days: 30)), // 30 days forward
      locale: const Locale('da', 'DK'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      selectedDateNotifier.selectDate(pickedDate);
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