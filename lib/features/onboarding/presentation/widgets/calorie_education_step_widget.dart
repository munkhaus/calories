import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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
          icon: MdiIcons.lightbulbOutline,
          color: AppColors.info,
        ),
        
        KSizes.spacingVerticalL,
        
        // Step 1: Base Metabolic Rate (BMR)
        _buildCalculationStep(
          context: context,
          title: 'Grundforbrug',
          subtitle: 'Kalorier din krop bruger i hvile',
          value: '${_calculateBMR(userProfile).round()} kcal',
          explanation: 'Dit grundforbrug er den energi din krop bruger bare for at holde dig i live - vejrtrækning, hjerteslag, fordøjelse og så videre.',
          icon: MdiIcons.heart,
          color: AppColors.primary,
        ),
        
        KSizes.spacingVerticalM,
        
        // Step 2: Activity multiplier
        _buildCalculationStep(
          context: context,
          title: 'Dit aktivitetsniveau',
          subtitle: 'Baseret på arbejde og fritid',
          value: '${_calculateTDEE(userProfile).round()} kcal',
          explanation: 'Vi lægger ekstra kalorier til baseret på hvor aktiv du er. Jo mere du bevæger dig, jo flere kalorier forbrænder du.',
          icon: MdiIcons.run,
          color: AppColors.secondary,
        ),
        
        KSizes.spacingVerticalM,
        
        // Step 3: Goal adjustment
        _buildCalculationStep(
          context: context,
          title: 'Justering for dit mål',
          subtitle: _getGoalAdjustmentDescription(userProfile.goalType),
          value: _getGoalAdjustmentText(userProfile),
          explanation: _getGoalExplanation(userProfile.goalType),
          icon: _getGoalIcon(userProfile.goalType),
          color: AppColors.success,
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
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              // Icon container
              Container(
                padding: EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                ),
                child: Icon(
                  MdiIcons.target,
                  color: AppColors.primary,
                  size: KSizes.iconM,
                ),
              ),
              
              SizedBox(width: KSizes.margin3x),
              
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dit daglige kaloriemål',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: KSizes.fontWeightSemiBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Dit personlige resultat',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: KSizes.margin3x),
          
          // Explanation first
          Container(
            padding: EdgeInsets.all(KSizes.margin3x),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(KSizes.radiusS),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
            child: Text(
              'Dette er dit personlige kaloriemål baseret på dine oplysninger. Se nedenfor hvordan vi beregner det.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
          
          SizedBox(height: KSizes.margin3x),
          
          // Final result - prominently displayed
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(KSizes.margin6x),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(KSizes.radiusM),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${userProfile.targetCalories}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: KSizes.fontWeightBold,
                      ),
                    ),
                    SizedBox(width: KSizes.margin1x),
                    Text(
                      'kcal',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: KSizes.fontWeightMedium,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: KSizes.margin1x),
                Text(
                  'per dag',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
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
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              // Icon container
              Container(
                padding: EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: KSizes.iconM,
                ),
              ),
              
              SizedBox(width: KSizes.margin3x),
              
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: KSizes.fontWeightSemiBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: KSizes.margin3x),
          
          // Explanation first - what is this concept?
          Container(
            padding: EdgeInsets.all(KSizes.margin3x),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(KSizes.radiusS),
              border: Border.all(
                color: color.withOpacity(0.1),
              ),
            ),
            child: Text(
              explanation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
          
          // Then show the result - now it makes sense!
          if (value.isNotEmpty) ...[
            SizedBox(height: KSizes.margin3x),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(KSizes.margin4x),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(KSizes.radiusM),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
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

  Widget _buildTrustIndicators(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.info.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                MdiIcons.informationOutline,
                color: AppColors.info,
                size: KSizes.iconM,
              ),
              SizedBox(width: KSizes.margin2x),
              Text(
                'Sådan beregner vi det',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.info,
                  fontWeight: KSizes.fontWeightSemiBold,
                ),
              ),
            ],
          ),
          
          SizedBox(height: KSizes.margin3x),
          
          // Simple calculation explanation
          _buildCalculationPoint(
            context,
            'Din krop forbrænder kalorier bare for at fungere - det kalder vi grundforbrug',
            MdiIcons.heart,
          ),
          
          SizedBox(height: KSizes.margin2x),
          
          _buildCalculationPoint(
            context,
            'Vi lægger kalorier til baseret på hvor aktiv du er i dit arbejde og din fritid',
            MdiIcons.run,
          ),
          
          SizedBox(height: KSizes.margin2x),
          
          _buildCalculationPoint(
            context,
            'Endelig justerer vi for dit mål - færre kalorier for vægttab, flere for vægtøgning',
            MdiIcons.target,
          ),
          
          SizedBox(height: KSizes.margin3x),
          
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

  Widget _buildCalculationPoint(BuildContext context, String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(KSizes.margin1x),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.2),
            borderRadius: BorderRadius.circular(KSizes.radiusS),
          ),
          child: Icon(
            icon,
            color: AppColors.info,
            size: KSizes.iconS,
          ),
        ),
        SizedBox(width: KSizes.margin3x),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessSummary(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.info.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                MdiIcons.lightbulbOn,
                color: AppColors.info,
                size: KSizes.iconM,
              ),
              SizedBox(width: KSizes.margin2x),
              Text(
                'Sådan hænger det sammen',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.info,
                  fontWeight: KSizes.fontWeightSemiBold,
                ),
              ),
            ],
          ),
          
          SizedBox(height: KSizes.margin3x),
          
          Text(
            'Vi starter med at beregne hvor mange kalorier din krop bruger i hvile, lægger til for din daglige aktivitet, og justerer så op eller ned baseret på dit mål. På den måde får du et realistisk kaloriemål der passer til dit liv.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          
          SizedBox(height: KSizes.margin3x),
          
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
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                MdiIcons.alertOutline,
                color: AppColors.warning,
                size: KSizes.iconM,
              ),
              SizedBox(width: KSizes.margin2x),
              Text(
                'Vigtige forbehold',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.warning,
                  fontWeight: KSizes.fontWeightSemiBold,
                ),
              ),
            ],
          ),
          
          SizedBox(height: KSizes.margin3x),
          
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
              color: AppColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: KSizes.margin2x),
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

  IconData _getGoalIcon(GoalType? goalType) {
    switch (goalType) {
      case GoalType.weightLoss:
        return MdiIcons.trendingDown;
      case GoalType.weightGain:
        return MdiIcons.trendingUp;
      case GoalType.muscleGain:
        return MdiIcons.dumbbell;
      case GoalType.weightMaintenance:
        return MdiIcons.scaleBalance;
      default:
        return MdiIcons.target;
    }
  }
} 