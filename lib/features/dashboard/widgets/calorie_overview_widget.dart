import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../onboarding/domain/user_profile_model.dart';

/// Widget showing daily calorie intake vs goal with circular progress
class CalorieOverviewWidget extends ConsumerWidget {
  const CalorieOverviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final userProfile = onboardingState.userProfile;

    // Calculate target calories based on user profile
    final targetCalories = _calculateTargetCalories(userProfile);
    
    // TODO: Get actual consumed calories from food log
    const consumedCalories = 847; // Placeholder data
    
    final progress = targetCalories > 0 ? (consumedCalories / targetCalories).clamp(0.0, 1.0) : 0.0;
    final remainingCalories = (targetCalories - consumedCalories).clamp(0, double.infinity);

    return Container(
      decoration: AppDesign.sectionDecoration,
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin3x),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(KSizes.margin1x),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                          ),
                          borderRadius: BorderRadius.circular(KSizes.radiusM),
                        ),
                        child: Icon(
                          MdiIcons.fire,
                          color: Colors.white,
                          size: KSizes.iconS,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dagens kalorier',
                              style: TextStyle(
                                fontSize: KSizes.fontSizeM,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${DateTime.now().day}. ${_getMonthName(DateTime.now().month)}',
                              style: TextStyle(
                                fontSize: KSizes.fontSizeXS,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: progress >= 0.9 
                        ? AppColors.success.withOpacity(0.1) 
                        : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(KSizes.radiusL),
                  ),
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeS,
                      fontWeight: FontWeight.w700,
                      color: progress >= 0.9 ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: KSizes.margin3x),
            
            // Circular progress indicator - centered and larger
            SizedBox(
              height: 140,
              child: Center(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background gradient circle
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.05),
                              AppColors.primary.withOpacity(0.15),
                            ],
                          ),
                        ),
                      ),
                      // Background progress ring
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 12,
                          backgroundColor: AppColors.surface,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                        ),
                      ),
                      // Main progress ring
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0 
                                ? AppColors.error 
                                : progress >= 0.8 
                                    ? AppColors.warning 
                                    : AppColors.primary,
                          ),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      // Center content
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(KSizes.radiusS),
                            ),
                            child: Text(
                              'spist',
                              style: TextStyle(
                                fontSize: KSizes.fontSizeXS,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${consumedCalories.toInt()}',
                            style: TextStyle(
                              fontSize: KSizes.fontSizeXL,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'af ${targetCalories.toInt()} kcal',
                            style: TextStyle(
                              fontSize: KSizes.fontSizeXS,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: KSizes.margin2x),
            
            // Stats cards in horizontal row below circle
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Mål',
                    value: '${targetCalories.toInt()}',
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    label: 'Forbrændt',
                    value: '340', // TODO: Get from activity tracking
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    label: 'Tilbage',
                    value: '${remainingCalories.toInt()}',
                    color: remainingCalories > 0 ? AppColors.warning : AppColors.error,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: KSizes.margin4x),
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

  String _getMonthName(int month) {
    const months = [
      '', 'januar', 'februar', 'marts', 'april', 'maj', 'juni',
      'juli', 'august', 'september', 'oktober', 'november', 'december'
    ];
    return months[month];
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
      height: 75, // Reduced from 90 to 75 to fix overflow
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: KSizes.margin2x, vertical: KSizes.margin2x),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with colored background
            Container(
              width: KSizes.iconM,
              height: KSizes.iconM,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(KSizes.radiusXS),
              ),
              child: Icon(
                _getIconForLabel(label),
                color: Colors.white,
                size: KSizes.iconS,
              ),
            ),
            SizedBox(height: KSizes.margin1x),
            // Value
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: KSizes.fontSizeS,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Label
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: KSizes.fontSizeXS,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Mål':
        return MdiIcons.target; // Target icon for goal calories
      case 'Forbrændt':
        return MdiIcons.fire; // Fire icon for burned calories
      case 'Tilbage':
        return MdiIcons.minusCircle; // Minus icon for remaining calories
      default:
        return MdiIcons.fire;
    }
  }
} 