import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/onboarding_notifier.dart';
import '../../domain/user_profile_model.dart';

/// Goals step widget for onboarding
class GoalsStepWidget extends ConsumerWidget {
  const GoalsStepWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        gradient: AppDesign.backgroundGradient,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(KSizes.margin4x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KSizes.spacingVerticalM,
            
            // Goal Type Selection
            _buildModernSection(
              context,
              child: _buildGoalTypeSection(context, state, notifier),
            ),
            
            KSizes.spacingVerticalL,
            
            // Activity Level Selection
            _buildModernSection(
              context,
              child: _buildActivityLevelSection(context, state, notifier),
            ),
            
            // Weekly Goal Adjustment
            if (state.userProfile.goalType != null && 
                state.userProfile.goalType != GoalType.weightMaintenance) ...[
              KSizes.spacingVerticalL,
              _buildModernSection(
                context,
                child: _buildWeeklyGoalSection(context, state, notifier),
              ),
            ],
            
            // Calorie Preview Card
            if (state.userProfile.goalType != null && state.userProfile.activityLevel != null) ...[
              KSizes.spacingVerticalL,
              _buildModernSection(
                context,
                child: _buildCaloriePreviewCard(context, state),
              ),
            ],
            
            KSizes.spacingVerticalXL,
          ],
        ),
      ),
    );
  }

  Widget _buildModernSection(BuildContext context, {required Widget child}) {
    return Container(
      decoration: AppDesign.sectionDecoration,
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin4x),
        child: child,
      ),
    );
  }

  Widget _buildGoalTypeSection(BuildContext context, dynamic state, dynamic notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              MdiIcons.target,
              size: KSizes.iconM,
              color: AppColors.primary,
            ),
            KSizes.spacingHorizontalS,
            Text(
              'Hvad er dit mål?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        KSizes.spacingVerticalS,
        Text(
          'Vælg hvad du gerne vil opnå med appen',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        KSizes.spacingVerticalM,
        
        // Goal Type Options
        _buildGoalTypeOption(
          context,
          GoalType.weightLoss,
          'Vægttab',
          'Forbrænde fedt og tabe vægt',
          MdiIcons.trendingDown,
          AppColors.warning,
          state.userProfile.goalType == GoalType.weightLoss,
          () => notifier.updateGoalType(GoalType.weightLoss),
        ),
        
        KSizes.spacingVerticalM,
        
        _buildGoalTypeOption(
          context,
          GoalType.weightMaintenance,
          'Vægtvedligeholdelse',
          'Holde nuværende vægt og blive sundere',
          MdiIcons.equal,
          AppColors.info,
          state.userProfile.goalType == GoalType.weightMaintenance,
          () => notifier.updateGoalType(GoalType.weightMaintenance),
        ),
        
        KSizes.spacingVerticalM,
        
        _buildGoalTypeOption(
          context,
          GoalType.weightGain,
          'Vægtøgning',
          'Øge vægt på en sund måde',
          MdiIcons.trendingUp,
          AppColors.success,
          state.userProfile.goalType == GoalType.weightGain,
          () => notifier.updateGoalType(GoalType.weightGain),
        ),
        
        KSizes.spacingVerticalM,
        
        _buildGoalTypeOption(
          context,
          GoalType.muscleGain,
          'Muskelopbygning',
          'Bygge muskelmasse og styrke',
          MdiIcons.armFlex,
          AppColors.secondary,
          state.userProfile.goalType == GoalType.muscleGain,
          () => notifier.updateGoalType(GoalType.muscleGain),
        ),
      ],
    );
  }

  Widget _buildGoalTypeOption(
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
        Row(
          children: [
            Icon(
              MdiIcons.run,
              size: KSizes.iconM,
              color: AppColors.primary,
            ),
            KSizes.spacingHorizontalS,
            Text(
              'Hvor aktiv er du?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        KSizes.spacingVerticalS,
        Text(
          'Dette hjælper os med at beregne dine kaloriebehov',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        KSizes.spacingVerticalM,
        
        // Activity Level Options
        _buildActivityLevelOption(
          context,
          ActivityLevel.sedentary,
          'Stillestående',
          'Kontorarbejde, ingen regelmæssig motion',
          MdiIcons.laptopAccount,
          state.userProfile.activityLevel == ActivityLevel.sedentary,
          () => notifier.updateActivityLevel(ActivityLevel.sedentary),
        ),
        
        KSizes.spacingVerticalS,
        
        _buildActivityLevelOption(
          context,
          ActivityLevel.lightlyActive,
          'Let aktiv',
          'Let træning 1-3 dage om ugen',
          MdiIcons.walk,
          state.userProfile.activityLevel == ActivityLevel.lightlyActive,
          () => notifier.updateActivityLevel(ActivityLevel.lightlyActive),
        ),
        
        KSizes.spacingVerticalS,
        
        _buildActivityLevelOption(
          context,
          ActivityLevel.moderatelyActive,
          'Moderat aktiv',
          'Moderat træning 3-5 dage om ugen',
          MdiIcons.bike,
          state.userProfile.activityLevel == ActivityLevel.moderatelyActive,
          () => notifier.updateActivityLevel(ActivityLevel.moderatelyActive),
        ),
        
        KSizes.spacingVerticalS,
        
        _buildActivityLevelOption(
          context,
          ActivityLevel.veryActive,
          'Meget aktiv',
          'Hård træning 6-7 dage om ugen',
          MdiIcons.run,
          state.userProfile.activityLevel == ActivityLevel.veryActive,
          () => notifier.updateActivityLevel(ActivityLevel.veryActive),
        ),
        
        KSizes.spacingVerticalS,
        
        _buildActivityLevelOption(
          context,
          ActivityLevel.extraActive,
          'Ekstra aktiv',
          'Meget hård træning, fysisk job',
          MdiIcons.weightLifter,
          state.userProfile.activityLevel == ActivityLevel.extraActive,
          () => notifier.updateActivityLevel(ActivityLevel.extraActive),
        ),
      ],
    );
  }

  Widget _buildActivityLevelOption(
    BuildContext context,
    ActivityLevel activityLevel,
    String title,
    String description,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(KSizes.margin3x),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: KSizes.iconM,
            ),
            KSizes.spacingHorizontalM,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: isSelected ? KSizes.fontWeightMedium : KSizes.fontWeightRegular,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected ? AppColors.primary.withOpacity(0.8) : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: KSizes.iconS,
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
        Row(
          children: [
            Icon(
              MdiIcons.calendar,
              size: KSizes.iconM,
              color: AppColors.primary,
            ),
            KSizes.spacingHorizontalS,
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        KSizes.spacingVerticalS,
        Text(
          'Et realistisk ugentligt mål er mellem 0.2-1.0 kg',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        KSizes.spacingVerticalM,
        
        // Weekly Goal Display
        Container(
          padding: const EdgeInsets.all(KSizes.margin4x),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(KSizes.radiusM),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${state.userProfile.weeklyGoalKg.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: KSizes.fontWeightBold,
                ),
              ),
              Text(
                ' kg/uge',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
        ),
        
        KSizes.spacingVerticalM,
        
        // Weekly Goal Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.3),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
            trackHeight: 6,
          ),
          child: Slider(
            value: state.userProfile.weeklyGoalKg.clamp(0.2, 1.0),
            min: 0.2,
            max: 1.0,
            divisions: 8,
            onChanged: notifier.updateWeeklyGoal,
          ),
        ),
        
        // Weekly Goal Range Labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: KSizes.margin2x),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0.2 kg',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                '1.0 kg',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCaloriePreviewCard(BuildContext context, dynamic state) {
    final targetCalories = state.userProfile.targetCalories;
    final targetProtein = state.userProfile.targetProteinG;
    final targetFat = state.userProfile.targetFatG;
    final targetCarbs = state.userProfile.targetCarbsG;

    return Card(
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
                Text(
                  'Daglig kaloriemål:',
                  style: Theme.of(context).textTheme.bodyLarge,
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
            
            // Macronutrients
            Row(
              children: [
                Expanded(
                  child: _buildMacroItem(
                    context,
                    'Protein',
                    '${targetProtein.round()}g',
                    AppColors.error,
                  ),
                ),
                Expanded(
                  child: _buildMacroItem(
                    context,
                    'Fedt',
                    '${targetFat.round()}g',
                    AppColors.warning,
                  ),
                ),
                Expanded(
                  child: _buildMacroItem(
                    context,
                    'Kulhydrater',
                    '${targetCarbs.round()}g',
                    AppColors.success,
                  ),
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

  Widget _buildMacroItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
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
    );
  }
} 