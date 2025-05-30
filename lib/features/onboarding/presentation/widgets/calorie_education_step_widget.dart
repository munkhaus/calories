import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/onboarding_notifier.dart';
import '../../domain/user_profile_model.dart';
import 'onboarding_base_layout.dart';

/// Calorie education step widget for onboarding
class CalorieEducationStepWidget extends ConsumerWidget {
  const CalorieEducationStepWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final userProfile = state.userProfile;

    return OnboardingBaseLayout(
      title: '🎯 Sådan finder vi dit kaloriebehov',
      subtitle: 'Forstå processen bag din personlige beregning',
      children: [
        // Final calorie target - prominent display
        _buildCalorieTargetCard(context, userProfile),
        
        KSizes.spacingVerticalL,
        
        // Educational note
        OnboardingHelpText(
          text: 'Dette er din personlige udregning - se hvordan vi kommer frem til tallet:',
          type: OnboardingHelpType.neutral,
        ),
        
        KSizes.spacingVerticalL,
        
        // Step 1: Base Metabolic Rate (BMR)
        _buildCalculationStep(
          context: context,
          title: '1. Basalstofskifte (BMR)',
          subtitle: 'Hvor mange kalorier din krop bruger i hvile',
          value: '${userProfile.bmr.toStringAsFixed(0)} kcal',
          explanation: 'Din krop bruger ${userProfile.bmr.toStringAsFixed(0)} kalorier hver dag bare for at holde de basale funktioner i gang. Dette tal beregnes ud fra din alder (${userProfile.age}), køn, højde (${userProfile.heightCm} cm) og vægt (${userProfile.currentWeightKg} kg).',
        ),
        
        KSizes.spacingVerticalL,
        
        // Step 2: Activity multiplier
        _buildCalculationStep(
          context: context,
          title: '2. Aktivitetsfaktor',
          subtitle: 'Ekstra kalorier fra din daglige aktivitet',
          value: '${(userProfile.tdee - userProfile.bmr).toStringAsFixed(0)} kcal',
          explanation: _getActivityExplanation(userProfile),
        ),
        
        KSizes.spacingVerticalL,
        
        // Step 3: Total Daily Energy Expenditure (TDEE)
        _buildCalculationStep(
          context: context,
          title: '3. TDEE (Totalt energiforbrug)',
          subtitle: 'Dine samlede daglige kalorieforbrug',
          value: '${userProfile.tdee.toStringAsFixed(0)} kcal',
          explanation: 'Dette er det samlede antal kalorier din krop bruger på en gennemsnitlig dag. BMR (${userProfile.bmr.toStringAsFixed(0)}) + aktivitet (${(userProfile.tdee - userProfile.bmr).toStringAsFixed(0)}) = ${userProfile.tdee.toStringAsFixed(0)} kalorier.',
        ),
        
        KSizes.spacingVerticalL,
        
        // Step 4: Goal adjustment
        _buildCalculationStep(
          context: context,
          title: '4. Måljustering',
          subtitle: _getGoalAdjustmentDescription(userProfile.goalType),
          value: _getGoalAdjustmentText(userProfile),
          explanation: _getGoalExplanation(userProfile.goalType),
        ),
        
        KSizes.spacingVerticalL,
        
        // Step 5: Final target
        _buildCalculationStep(
          context: context,
          title: '5. Dit daglige kaloriemål',
          subtitle: 'Hvor mange kalorier du skal spise dagligt',
          value: '${userProfile.targetCalories.toStringAsFixed(0)} kcal',
          explanation: 'Dette er dit personlige kaloriemål beregnet ud fra dit TDEE (${userProfile.tdee.toStringAsFixed(0)}) ${userProfile.goalType == GoalType.weightLoss ? 'minus' : userProfile.goalType == GoalType.weightMaintenance ? 'uden' : 'plus'} justering for dit mål.',
        ),
        
        KSizes.spacingVerticalL,
        
        // Simple process explanation
        _buildProcessSummary(context),
        
        // Weight loss guidance (only for weight loss goal)
        if (userProfile.goalType == GoalType.weightLoss) ...[
          KSizes.spacingVerticalL,
          _buildWeightLossGuidance(context, userProfile),
        ],
        
        KSizes.spacingVerticalL,
      ],
    );
  }

  Widget _buildCalorieTargetCard(BuildContext context, UserProfileModel userProfile) {
    return Container(
      padding: EdgeInsets.all(KSizes.margin6x),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Dit daglige kaloriemål',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: KSizes.fontWeightSemiBold,
              color: AppColors.textPrimary,
            ),
          ),
          
          KSizes.spacingVerticalL,
          
          // Final result - prominently displayed
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                userProfile.targetCalories.toString(),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: KSizes.fontWeightBold,
                ),
              ),
              KSizes.spacingHorizontalS,
              Text(
                'kcal',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: KSizes.fontWeightMedium,
                ),
              ),
            ],
          ),
          KSizes.spacingVerticalS,
          Text(
            'per dag',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          KSizes.spacingVerticalL,
          
          // Simple explanation
          OnboardingHelpText(
            text: 'Dette er din personlige kalorie-anbefaling baseret på alle dine oplysninger og mål.',
            type: OnboardingHelpType.positive,
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationStep({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String value,
    required String explanation,
  }) {
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and subtitle
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: KSizes.fontWeightSemiBold,
              color: AppColors.textPrimary,
            ),
          ),
          KSizes.spacingVerticalXS,
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          KSizes.spacingVerticalM,
          
          // Explanation
          OnboardingHelpText(
            text: explanation,
            type: OnboardingHelpType.neutral,
          ),
          
          // Result value
          if (value.isNotEmpty) ...[
            KSizes.spacingVerticalM,
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(KSizes.margin4x),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(KSizes.radiusM),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: KSizes.fontWeightBold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProcessSummary(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sådan hænger det sammen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: KSizes.fontWeightSemiBold,
            ),
          ),
          
          KSizes.spacingVerticalM,
          
          Text(
            'Beregningen starter med at finde hvor mange kalorier din krop bruger i hvile, lægger til for din daglige aktivitet, og justerer så op eller ned baseret på dit mål. På den måde får du et realistisk kaloriemål der passer til dit liv.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          
          KSizes.spacingVerticalM,
          
          Text(
            'Beregningerne tager højde for din alder, køn, højde og vægt, så de passer til netop dig.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightLossGuidance(BuildContext context, UserProfileModel userProfile) {
    // Calculate user's specific deficit and goal
    final weeklyGoal = userProfile.weeklyGoalKg;
    final dailyDeficit = (weeklyGoal * 7700) / 7; // 7700 kcal per kg fat
    final tdee = userProfile.tdee;
    final targetCalories = userProfile.targetCalories;
    final actualDeficit = tdee - targetCalories;
    
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dit vægttab mål',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.info,
              fontWeight: KSizes.fontWeightSemiBold,
            ),
          ),
          
          KSizes.spacingVerticalM,
          
          OnboardingHelpText(
            text: 'Dit mål er at tabe ${weeklyGoal.toStringAsFixed(1)} kg om ugen. For at opnå dette har vi beregnet et dagligt kalorieunderskud på ${actualDeficit.round()} kalorier. Dette betyder du forbrænder ${actualDeficit.round()} kalorier mere end du spiser hver dag.\n\nHusk at vægttab er individuelt og afhænger af faktorer som alder, køn, fysisk aktivitet og helbredstilstand. Tal med en sundhedsprofessionel for personlig rådgivning.',
            type: OnboardingHelpType.neutral,
          ),
        ],
      ),
    );
  }

  // Calculation methods (same as summary widget)
  String _getGoalAdjustmentText(UserProfileModel profile) {
    switch (profile.goalType) {
      case GoalType.weightLoss:
        final adjustment = (profile.weeklyGoalKg * 7700) / 7;
        return '-${adjustment.round()} kcal';
      case GoalType.weightGain:
      case GoalType.muscleGain:
        final adjustment = (profile.weeklyGoalKg * 7700) / 7;
        return '+${adjustment.round()} kcal';
      case GoalType.weightMaintenance:
        return '0 kcal';
      default:
        return 'Ikke beregnet';
    }
  }

  String _getActivityExplanation(UserProfileModel profile) {
    if (profile.activityTrackingPreference == ActivityTrackingPreference.manual) {
      return 'Du har valgt manuel registrering af aktivitet. Dit arbejdsaktivitetsniveau (${profile.workActivityLevel?.name ?? 'ukendt'}) bruges altid, men fritidsaktivitet tilføjes ikke automatisk. Du kan tilføje specifikke aktiviteter manuelt.';
    }
    
    return 'Baseret på dit arbejdsaktivitetsniveau (${profile.workActivityLevel?.name ?? 'ukendt'}) og fritidsaktivitetsniveau (${profile.leisureActivityLevel?.name ?? 'ukendt'}) beregnes ekstra kalorier til din daglige aktivitet.';
  }

  String _getGoalAdjustmentDescription(GoalType? goalType) {
    switch (goalType) {
      case GoalType.weightLoss:
        return 'Underskud for vægttab';
      case GoalType.weightGain:
      case GoalType.muscleGain:
        return 'Overskud for vægtøgning';
      case GoalType.weightMaintenance:
        return 'Ingen justering';
      default:
        return 'Baseret på dit mål';
    }
  }

  String _getGoalExplanation(GoalType? goalType) {
    switch (goalType) {
      case GoalType.weightLoss:
        return 'For at tabe vægt beregnes et kalorieunderskud som gør det lettere at følge planen.';
      case GoalType.weightGain:
        return 'For at tage på beregnes ekstra kalorier til at bygge vægt på en kontrolleret måde.';
      case GoalType.muscleGain:
        return 'For at bygge muskler beregnes et kalorieoverskud plus protein til muskelvækst.';
      case GoalType.weightMaintenance:
        return 'For at holde din vægt matches kalorieforbrug og indtag så tæt som muligt.';
      default:
        return 'Dit kaloriemål er tilpasset til dit specifikke mål.';
    }
  }
} 