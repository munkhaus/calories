import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/onboarding_notifier.dart';
import '../../domain/onboarding_step.dart';
import '../../domain/user_profile_model.dart';
import 'onboarding_base_layout.dart';

/// Summary step widget for onboarding
class SummaryStepWidget extends ConsumerWidget {
  const SummaryStepWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final userProfile = state.userProfile;

    return OnboardingBaseLayout(
      title: 'Din opsummering',
      subtitle: 'Gennemgå og bekræft dine oplysninger',
      children: [
        // Personal Information Card - simplified
        _buildPersonalInfoCard(context, state, ref),
        
        KSizes.spacingVerticalM,
        
        // Physical Information Card - simplified
        _buildPhysicalInfoCard(context, state, ref),
        
        KSizes.spacingVerticalM,
        
        // Goals Information Card - simplified
        _buildGoalsInfoCard(context, state, ref),
        
        KSizes.spacingVerticalL,
        
        // Final calorie target - clean and prominent
        _buildCalorieTargetCard(context, userProfile),
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

  Widget _buildPersonalInfoCard(BuildContext context, dynamic state, WidgetRef ref) {
    return _buildEditableCard(
      context: context,
      onTap: () => _navigateToStep(ref, OnboardingStep.basicInfo),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personlige oplysninger',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: KSizes.fontWeightSemiBold,
              color: AppColors.textPrimary,
            ),
          ),
          
          KSizes.spacingVerticalM,
          
          _buildInfoRow('Navn', state.userProfile.name),
          _buildInfoRow('Alder', _calculateAge(state.userProfile.dateOfBirth).toString() + ' år'),
          _buildInfoRow('Køn', _getGenderText(state.userProfile.gender)),
        ],
      ),
    );
  }

  Widget _buildPhysicalInfoCard(BuildContext context, dynamic state, WidgetRef ref) {
    return _buildEditableCard(
      context: context,
      onTap: () => _navigateToStep(ref, OnboardingStep.healthInfo),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fysiske oplysninger',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: KSizes.fontWeightSemiBold,
              color: AppColors.textPrimary,
            ),
          ),
          
          KSizes.spacingVerticalM,
          
          _buildInfoRow('Højde', state.userProfile.heightCm.round().toString() + ' cm'),
          _buildInfoRow('Vægt', state.userProfile.currentWeightKg.toStringAsFixed(1) + ' kg'),
          _buildInfoRow('BMI', _calculateBMI(state.userProfile).toStringAsFixed(1)),
        ],
      ),
    );
  }

  Widget _buildGoalsInfoCard(BuildContext context, dynamic state, WidgetRef ref) {
    return _buildEditableCard(
      context: context,
      onTap: () => _navigateToStep(ref, OnboardingStep.goals),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mål og aktivitet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: KSizes.fontWeightSemiBold,
              color: AppColors.textPrimary,
            ),
          ),
          
          KSizes.spacingVerticalM,
          
          _buildInfoRow('Hovedmål', _getGoalTypeText(state.userProfile.goalType)),
          _buildInfoRow('Arbejde', _getWorkActivityText(state.userProfile.workActivityLevel)),
          _buildInfoRow('Motion', _getLeisureActivityText(state.userProfile.leisureActivityLevel)),
          
          // Only show target weight and weekly goal if relevant
          if (state.userProfile.goalType != GoalType.weightMaintenance && 
              state.userProfile.targetWeightKg > 0) ...[
            _buildInfoRow('Målvægt', state.userProfile.targetWeightKg.toStringAsFixed(1) + ' kg'),
          ],
          if (state.userProfile.weeklyGoalKg > 0) ...[
            _buildInfoRow('Ugentligt mål', state.userProfile.weeklyGoalKg.toStringAsFixed(1) + ' kg/uge'),
          ],
        ],
      ),
    );
  }

  Widget _buildEditableCard({
    required BuildContext context,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        child: Padding(
          padding: EdgeInsets.all(KSizes.margin2x),
          child: Row(
            children: [
              Expanded(child: child),
              Icon(
                Icons.edit,
                color: AppColors.primary,
                size: KSizes.iconS,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: KSizes.margin2x),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: KSizes.fontSizeM,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: KSizes.fontSizeM,
                fontWeight: KSizes.fontWeightMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToStep(WidgetRef ref, OnboardingStep step) {
    ref.read(onboardingProvider.notifier).goToStep(step);
  }

  int _calculateAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  double _calculateBMI(UserProfileModel profile) {
    if (profile.heightCm <= 0 || profile.currentWeightKg <= 0) return 0;
    final heightM = profile.heightCm / 100;
    return profile.currentWeightKg / (heightM * heightM);
  }

  String _getGenderText(Gender? gender) {
    switch (gender) {
      case Gender.male:
        return 'Mand';
      case Gender.female:
        return 'Kvinde';
      case null:
        return '';
    }
  }

  String _getGoalTypeText(GoalType? goalType) {
    switch (goalType) {
      case GoalType.weightLoss:
        return 'Tabe vægt';
      case GoalType.weightMaintenance:
        return 'Vedligeholde vægt';
      case GoalType.weightGain:
        return 'Tage på';
      case GoalType.muscleGain:
        return 'Bygge muskler';
      case null:
        return '';
    }
  }

  String _getWorkActivityText(WorkActivityLevel? level) {
    switch (level) {
      case WorkActivityLevel.sedentary:
        return 'Stillesiddende';
      case WorkActivityLevel.light:
        return 'Let aktivitet';
      case WorkActivityLevel.moderate:
        return 'Moderat aktivitet';
      case WorkActivityLevel.heavy:
        return 'Tung aktivitet';
      case WorkActivityLevel.veryHeavy:
        return 'Meget tung aktivitet';
      case null:
        return '';
    }
  }

  String _getLeisureActivityText(LeisureActivityLevel? level) {
    switch (level) {
      case LeisureActivityLevel.sedentary:
        return 'Ikke aktiv';
      case LeisureActivityLevel.lightlyActive:
        return 'Let aktiv';
      case LeisureActivityLevel.moderatelyActive:
        return 'Moderat aktiv';
      case LeisureActivityLevel.veryActive:
        return 'Meget aktiv';
      case LeisureActivityLevel.extraActive:
        return 'Ekstremt aktiv';
      case null:
        return 'Manuel registrering';
    }
  }
}