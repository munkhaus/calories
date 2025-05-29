import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/onboarding_notifier.dart';
import '../../domain/user_profile_model.dart';
import 'onboarding_base_layout.dart';

/// Goals step widget for onboarding
class GoalsStepWidget extends ConsumerWidget {
  const GoalsStepWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return OnboardingBaseLayout(
      children: [
        // Goal selection section
        OnboardingSection(
          child: _buildGoalTypeSection(context, state, notifier),
        ),
        
        KSizes.spacingVerticalL,
        
        // Activity level section
        OnboardingSection(
          child: _buildActivityLevelSection(context, state, notifier),
        ),
        
        KSizes.spacingVerticalL,
        
        // Weekly goal section (only show for weight loss/gain goals)
        if (state.userProfile.goalType == GoalType.weightLoss || 
            state.userProfile.goalType == GoalType.weightGain) ...[
          OnboardingSection(
            child: _buildWeeklyGoalSection(context, state, notifier),
          ),
          
          KSizes.spacingVerticalL,
        ],
        
        // Calorie preview
        _buildCaloriePreviewCard(context, state),
      ],
    );
  }

  Widget _buildGoalTypeSection(BuildContext context, dynamic state, dynamic notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingSectionHeader(
          icon: MdiIcons.target,
          title: 'Hvad er dit mål?',
          subtitle: 'Vælg dit primære sundhedsmål',
        ),
        
        KSizes.spacingVerticalM,
        
        // Goal options
        _buildGoalOption(
          context,
          GoalType.weightLoss,
          'Vægttab',
          'Jeg vil tabe mig og blive sundere',
          MdiIcons.trendingDown,
          AppColors.warning,
          state.userProfile.goalType == GoalType.weightLoss,
          () => notifier.updateGoalType(GoalType.weightLoss),
        ),
        
        KSizes.spacingVerticalS,
        
        _buildGoalOption(
          context,
          GoalType.weightMaintenance,
          'Vedligehold vægt',
          'Jeg vil holde min nuværende vægt',
          MdiIcons.minus,
          AppColors.info,
          state.userProfile.goalType == GoalType.weightMaintenance,
          () => notifier.updateGoalType(GoalType.weightMaintenance),
        ),
        
        KSizes.spacingVerticalS,
        
        _buildGoalOption(
          context,
          GoalType.weightGain,
          'Vægtøgning',
          'Jeg vil tage på og opbygge muskler',
          MdiIcons.trendingUp,
          AppColors.success,
          state.userProfile.goalType == GoalType.weightGain,
          () => notifier.updateGoalType(GoalType.weightGain),
        ),
      ],
    );
  }

  Widget _buildGoalOption(
    BuildContext context,
    GoalType goalType,
    String title,
    String description,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(KSizes.margin4x),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(KSizes.margin2x),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : AppColors.surface,
                borderRadius: BorderRadius.circular(KSizes.radiusS),
              ),
              child: Icon(
                icon,
                color: isSelected ? color : AppColors.textSecondary,
                size: KSizes.iconM,
              ),
            ),
            KSizes.spacingHorizontalM,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isSelected ? color : AppColors.textPrimary,
                      fontWeight: KSizes.fontWeightMedium,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? color.withOpacity(0.8) : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: KSizes.iconM,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityLevelSection(BuildContext context, dynamic state, dynamic notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingSectionHeader(
          icon: MdiIcons.run,
          title: 'Hvor aktiv er du?',
          subtitle: 'Dit aktivitetsniveau hjælper os med at beregne dine kaloriebehov',
        ),
        
        KSizes.spacingVerticalM,
        
        // Activity level options
        _buildActivityOption(
          context,
          ActivityLevel.sedentary,
          'Stillesiddende',
          'Kontorarbejde, lidt motion',
          MdiIcons.seatReclineNormal,
          AppColors.info,
          state.userProfile.activityLevel == ActivityLevel.sedentary,
          () => notifier.updateActivityLevel(ActivityLevel.sedentary),
        ),
        
        KSizes.spacingVerticalS,
        
        _buildActivityOption(
          context,
          ActivityLevel.lightlyActive,
          'Let aktiv',
          '1-3 dage træning om ugen',
          MdiIcons.walk,
          AppColors.primary,
          state.userProfile.activityLevel == ActivityLevel.lightlyActive,
          () => notifier.updateActivityLevel(ActivityLevel.lightlyActive),
        ),
        
        KSizes.spacingVerticalS,
        
        _buildActivityOption(
          context,
          ActivityLevel.moderatelyActive,
          'Moderat aktiv',
          '3-5 dage træning om ugen',
          MdiIcons.run,
          AppColors.secondary,
          state.userProfile.activityLevel == ActivityLevel.moderatelyActive,
          () => notifier.updateActivityLevel(ActivityLevel.moderatelyActive),
        ),
        
        KSizes.spacingVerticalS,
        
        _buildActivityOption(
          context,
          ActivityLevel.veryActive,
          'Meget aktiv',
          '6-7 dage træning om ugen',
          MdiIcons.bike,
          AppColors.warning,
          state.userProfile.activityLevel == ActivityLevel.veryActive,
          () => notifier.updateActivityLevel(ActivityLevel.veryActive),
        ),
        
        KSizes.spacingVerticalS,
        
        _buildActivityOption(
          context,
          ActivityLevel.extraActive,
          'Ekstra aktiv',
          'Daglig træning + fysisk job',
          MdiIcons.dumbbell,
          AppColors.success,
          state.userProfile.activityLevel == ActivityLevel.extraActive,
          () => notifier.updateActivityLevel(ActivityLevel.extraActive),
        ),
      ],
    );
  }

  Widget _buildActivityOption(
    BuildContext context,
    ActivityLevel activityLevel,
    String title,
    String description,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(KSizes.margin4x),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(KSizes.margin2x),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : AppColors.surface,
                borderRadius: BorderRadius.circular(KSizes.radiusS),
              ),
              child: Icon(
                icon,
                color: isSelected ? color : AppColors.textSecondary,
                size: KSizes.iconM,
              ),
            ),
            KSizes.spacingHorizontalM,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isSelected ? color : AppColors.textPrimary,
                      fontWeight: KSizes.fontWeightMedium,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? color.withOpacity(0.8) : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: KSizes.iconM,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyGoalSection(BuildContext context, dynamic state, dynamic notifier) {
    final isWeightLoss = state.userProfile.goalType == GoalType.weightLoss;
    final title = isWeightLoss ? 'Hvor meget vil du tabe om ugen?' : 'Hvor meget vil du øge om ugen?';
    final color = isWeightLoss ? AppColors.warning : AppColors.success;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingSectionHeader(
          icon: MdiIcons.calendar,
          title: title,
          subtitle: 'Et realistisk ugentligt mål er mellem 0.2-1.0 kg',
          iconColor: color,
        ),
        
        KSizes.spacingVerticalM,
        
        // Weekly Goal Display using standardized component
        OnboardingMetricDisplay(
          value: state.userProfile.weeklyGoalKg.toStringAsFixed(1),
          unit: 'kg/uge',
          color: color,
        ),
        
        KSizes.spacingVerticalM,
        
        // Weekly Goal Slider using standardized component
        OnboardingSlider(
          value: state.userProfile.weeklyGoalKg,
          min: 0.2,
          max: 1.0,
          divisions: 8,
          onChanged: notifier.updateWeeklyGoal,
          color: color,
          minLabel: '0.2 kg',
          maxLabel: '1.0 kg',
        ),
      ],
    );
  }

  Widget _buildCaloriePreviewCard(BuildContext context, dynamic state) {
    final targetCalories = state.userProfile.targetCalories;
    final targetProtein = state.userProfile.targetProteinG;
    final targetFat = state.userProfile.targetFatG;
    final targetCarbs = state.userProfile.targetCarbsG;

    return Container(
      decoration: AppDesign.sectionDecoration,
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin4x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  MdiIcons.calculator,
                  size: KSizes.iconM,
                  color: AppColors.primary,
                ),
                KSizes.spacingHorizontalS,
                Text(
                  'Dine beregnede mål',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            KSizes.spacingVerticalM,
            
            // Calories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Daglig kaloriemål:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Text(
                  '$targetCalories kcal',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: KSizes.fontWeightBold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            
            KSizes.spacingVerticalS,
            
            // Macronutrients with clear, spacious layout
            KSizes.spacingVerticalS,
            
            // Macronutrient header
            Text(
              'Daglige makronæringsstoffer:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: KSizes.fontWeightMedium,
                color: AppColors.textSecondary,
              ),
            ),
            
            KSizes.spacingVerticalXS,
            
            // Macronutrient cards in a column for better readability
            Column(
              children: [
                _buildMacroRow(
                  context,
                  'Protein (byggesten)',
                  '${targetProtein.round()}g',
                  AppColors.error,
                  MdiIcons.dumbbell,
                ),
                SizedBox(height: KSizes.margin1x),
                _buildMacroRow(
                  context,
                  'Fedt (energi)',
                  '${targetFat.round()}g',
                  AppColors.warning,
                  MdiIcons.flash,
                ),
                SizedBox(height: KSizes.margin1x),
                _buildMacroRow(
                  context,
                  'Kulhydrater (brændstof)',
                  '${targetCarbs.round()}g',
                  AppColors.info,
                  MdiIcons.fire,
                ),
              ],
            ),
            
            KSizes.spacingVerticalS,
            
            Text(
              'Disse værdier kan justeres senere i appen',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow(BuildContext context, String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: KSizes.iconM,
          color: color,
        ),
        KSizes.spacingHorizontalM,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: KSizes.fontWeightMedium,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: KSizes.fontWeightBold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 