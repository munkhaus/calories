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
        ),
        
        KSizes.spacingVerticalL,
        
        // Step 1: Base Metabolic Rate (BMR)
        _buildCalculationStep(
          context: context,
          title: 'Grundforbrug',
          subtitle: 'Kalorier din krop bruger i hvile',
          value: '${_calculateBMR(userProfile).round()} kcal',
          explanation: 'Dit grundforbrug er den energi din krop bruger bare for at holde dig i live - vejrtrækning, hjerteslag, fordøjelse og så videre.',
        ),
        
        KSizes.spacingVerticalM,
        
        // Step 2: Activity multiplier
        _buildCalculationStep(
          context: context,
          title: 'Dit aktivitetsniveau',
          subtitle: 'Baseret på arbejde og fritid',
          value: '${_calculateTDEE(userProfile).round()} kcal',
          explanation: 'Vi lægger ekstra kalorier til baseret på hvor aktiv du er. Jo mere du bevæger dig, jo flere kalorier forbrænder du.',
        ),
        
        KSizes.spacingVerticalM,
        
        // Step 3: Goal adjustment
        _buildCalculationStep(
          context: context,
          title: 'Justering for dit mål',
          subtitle: _getGoalAdjustmentDescription(userProfile.goalType),
          value: _getGoalAdjustmentText(userProfile),
          explanation: _getGoalExplanation(userProfile.goalType),
        ),
        
        KSizes.spacingVerticalL,
        
        // Simple process explanation
        _buildProcessSummary(context),
        
        KSizes.spacingVerticalL,
        
        // Medical disclaimers - multiple points with consistent styling
        _buildMedicalDisclaimers(context),
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
            'Vi starter med at beregne hvor mange kalorier din krop bruger i hvile, lægger til for din daglige aktivitet, og justerer så op eller ned baseret på dit mål. På den måde får du et realistisk kaloriemål der passer til dit liv.',
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

  Widget _buildMedicalDisclaimers(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vigtige forbehold',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: KSizes.fontWeightSemiBold,
            ),
          ),
          
          KSizes.spacingVerticalM,
          
          ..._buildDisclaimerPoints(context),
        ],
      ),
    );
  }

  List<Widget> _buildDisclaimerPoints(BuildContext context) {
    final disclaimers = [
      'Disse beregninger er vejledende og dit faktiske behov kan variere',
      'Rådfør dig altid med en læge før større ændringer i dit kostmønster',
      'Appen erstatter ikke professionel medicinsk eller ernæringsmæssig rådgivning',
      'Individuelle faktorer som medicin og helbredstilstand kan påvirke dit behov',
      'Start med mindre ændringer og justér gradvist baseret på dine resultater'
    ];

    return disclaimers.map((disclaimer) => Padding(
      padding: EdgeInsets.only(bottom: KSizes.margin2x),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          KSizes.spacingHorizontalS,
          Expanded(
            child: Text(
              disclaimer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  // Calculation methods (same as summary widget)
  double _calculateBMR(UserProfileModel profile) {
    if (profile.dateOfBirth == null || profile.currentWeightKg <= 0 || profile.heightCm <= 0 || profile.gender == null) {
      return 0;
    }

    final now = DateTime.now();
    int age = now.year - profile.dateOfBirth!.year;
    if (now.month < profile.dateOfBirth!.month ||
        (now.month == profile.dateOfBirth!.month && now.day < profile.dateOfBirth!.day)) {
      age--;
    }

    if (profile.gender == Gender.male) {
      return (10.0 * profile.currentWeightKg) + (6.25 * profile.heightCm) - (5.0 * age) + 5.0;
    } else {
      return (10.0 * profile.currentWeightKg) + (6.25 * profile.heightCm) - (5.0 * age) - 161.0;
    }
  }

  double _calculateTDEE(UserProfileModel profile) {
    final bmr = _calculateBMR(profile);
    if (bmr <= 0) return 0;

    if (profile.workActivityLevel != null && profile.leisureActivityLevel != null) {
      double workMultiplier = 1.2;
      if (profile.isCurrentlyWorkDay) {
        workMultiplier = switch (profile.workActivityLevel!) {
          WorkActivityLevel.sedentary => 1.2,
          WorkActivityLevel.light => 1.375,
          WorkActivityLevel.moderate => 1.55,
          WorkActivityLevel.heavy => 1.725,
          WorkActivityLevel.veryHeavy => 1.9,
        };
      }
      
      double leisureAddition = 0.0;
      if (profile.isLeisureActivityEnabledToday) {
        leisureAddition = switch (profile.leisureActivityLevel!) {
          LeisureActivityLevel.sedentary => 0.0,
          LeisureActivityLevel.lightlyActive => 0.155,
          LeisureActivityLevel.moderatelyActive => 0.35,
          LeisureActivityLevel.veryActive => 0.525,
          LeisureActivityLevel.extraActive => 0.7,
        };
      }
      
      return (bmr * workMultiplier) + (bmr * leisureAddition);
    }

    if (profile.activityLevel != null) {
      final multiplier = switch (profile.activityLevel!) {
        ActivityLevel.sedentary => 1.2,
        ActivityLevel.lightlyActive => 1.375,
        ActivityLevel.moderatelyActive => 1.55,
        ActivityLevel.veryActive => 1.725,
        ActivityLevel.extraActive => 1.9,
      };
      return bmr * multiplier;
    }
    
    return bmr * 1.2;
  }

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
        return 'For at tabe vægt skal du spise lidt færre kalorier end du forbrænder. Vi laver et moderat underskud som gør det lettere at følge.';
      case GoalType.weightGain:
        return 'For at tage på skal du spise lidt flere kalorier end du forbrænder. Vi giver dig ekstra kalorier til at bygge vægt på.';
      case GoalType.muscleGain:
        return 'For at bygge muskler skal du have lidt flere kalorier end du forbrænder, plus træning. Vi giver dig det der skal til.';
      case GoalType.weightMaintenance:
        return 'For at holde din vægt skal du spise cirka lige så mange kalorier som du forbrænder hver dag.';
      default:
        return 'Dit kaloriemål er tilpasset til dit specifikke mål.';
    }
  }
} 