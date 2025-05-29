import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../food_logging/application/food_logging_notifier.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../onboarding/domain/user_profile_model.dart';

/// Widget showing daily nutrition in a user-friendly way
class DailyNutritionWidget extends ConsumerWidget {
  const DailyNutritionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutrition = ref.watch(dailyNutritionProvider);
    final userProfile = ref.watch(onboardingProvider).userProfile;
    
    // Calculate targets based on user profile
    final targets = _calculateNutritionTargets(userProfile);
    
    // Calculate progress for each macronutrient
    final proteinProgress = targets['protein']! > 0 ? (nutrition['protein']! / targets['protein']!).clamp(0.0, 1.0) : 0.0;
    final carbsProgress = targets['carbs']! > 0 ? (nutrition['carbs']! / targets['carbs']!).clamp(0.0, 1.0) : 0.0;
    final fatProgress = targets['fat']! > 0 ? (nutrition['fat']! / targets['fat']!).clamp(0.0, 1.0) : 0.0;
    
    return Container(
      decoration: AppDesign.sectionDecoration,
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin4x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - more user-friendly
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(KSizes.margin1x),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary.withOpacity(0.2),
                        AppColors.primary.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                  ),
                  child: Icon(
                    MdiIcons.chartDonut,
                    color: AppColors.secondary,
                    size: KSizes.iconS,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hvordan spiser du?',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeL,
                      fontWeight: KSizes.fontWeightSemiBold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(KSizes.radiusS),
                  ),
                  child: Text(
                    'Godt på vej',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeXS,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: KSizes.margin3x),
            
            // Simplified nutrition cards - focus on progress and simple language
            Row(
              children: [
                Expanded(
                  child: _SimplifiedNutritionCard(
                    title: 'Protein',
                    subtitle: 'Opbygger muskler',
                    progress: proteinProgress,
                    progressText: '${nutrition['protein']}g / ${targets['protein']}g',
                    color: AppColors.error,
                    icon: MdiIcons.dumbbell,
                  ),
                ),
                const SizedBox(width: KSizes.margin2x),
                Expanded(
                  child: _SimplifiedNutritionCard(
                    title: 'Energi',
                    subtitle: 'Fra kulhydrater',
                    progress: carbsProgress,
                    progressText: '${nutrition['carbs']}g / ${targets['carbs']}g',
                    color: AppColors.warning,
                    icon: MdiIcons.flash,
                  ),
                ),
                const SizedBox(width: KSizes.margin2x),
                Expanded(
                  child: _SimplifiedNutritionCard(
                    title: 'Sundt fedt',
                    subtitle: 'Vigtige næringsstoffer',
                    progress: fatProgress,
                    progressText: '${nutrition['fat']}g / ${targets['fat']}g',
                    color: AppColors.success,
                    icon: MdiIcons.heart,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: KSizes.margin2x),
            
            // Simple encouragement message instead of technical data
            Container(
              padding: const EdgeInsets.all(KSizes.margin2x),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(KSizes.radiusM),
              ),
              child: Row(
                children: [
                  Icon(
                    MdiIcons.lightbulb,
                    color: AppColors.info,
                    size: KSizes.iconS,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Du spiser varieret og sundt i dag! 👍',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS,
                        color: AppColors.info,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _calculateNutritionTargets(UserProfileModel userProfile) {
    // Calculate nutrition targets based on user profile
    // Basic calculations: protein 1.6g/kg body weight, carbs 45-65% of calories, fat 20-35% of calories
    
    final weight = userProfile.currentWeightKg;
    final targetCalories = userProfile.tdee; // Use the TDEE from user profile
    
    final proteinTarget = weight * 1.6; // 1.6g per kg body weight
    final carbsTarget = (targetCalories * 0.55) / 4; // 55% of calories, 4 cal/g
    final fatTarget = (targetCalories * 0.25) / 9; // 25% of calories, 9 cal/g
    
    return {
      'protein': proteinTarget,
      'carbs': carbsTarget,
      'fat': fatTarget,
    };
  }

  double _calculateTargetCalories(UserProfileModel userProfile) {
    // Use the TDEE calculation from user profile model
    return userProfile.tdee;
  }
}

class _SimplifiedNutritionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final String progressText;
  final Color color;
  final IconData icon;

  const _SimplifiedNutritionCard({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.progressText,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KSizes.margin2x),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon and title
          Icon(
            icon,
            color: color,
            size: KSizes.iconM,
          ),
          
          const SizedBox(height: 6),
          
          Text(
            title,
            style: TextStyle(
              fontSize: KSizes.fontSizeS,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          Text(
            subtitle,
            style: TextStyle(
              fontSize: KSizes.fontSizeXS,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          // Progress indicator - simplified
          Container(
            height: KSizes.margin1x,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(KSizes.radiusXS),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(KSizes.radiusXS),
                ),
              ),
            ),
          ),
          
          SizedBox(height: KSizes.margin1x),
          
          // Progress text instead of numbers
          Text(
            progressText,
            style: TextStyle(
              fontSize: KSizes.fontSizeXS,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 