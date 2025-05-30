import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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
      title: '📋 Din opsummering',
      subtitle: 'Gennemgå og bekræft dine oplysninger',
      children: [
        // Personal Information Card
        _buildPersonalInfoCard(context, state, ref),
        
        KSizes.spacingVerticalM,
        
        // Physical Information Card  
        _buildPhysicalInfoCard(context, state, ref),
        
        KSizes.spacingVerticalM,
        
        // Goals Information Card
        _buildGoalsInfoCard(context, state, ref),
        
        KSizes.spacingVerticalL,
        
        // Final calorie target - at the end
        _buildCalorieTargetCard(context, userProfile),
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
                      'Personligt tilpasset til dig',
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
              'Dette er din personlige kalorie-anbefaling baseret på alle dine oplysninger og mål.',
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

  Widget _buildPersonalInfoCard(BuildContext context, dynamic state, WidgetRef ref) {
    return _buildEditableCard(
      context: context,
      onTap: () => _navigateToStep(ref, OnboardingStep.basicInfo),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                MdiIcons.account,
                size: KSizes.iconM,
                color: AppColors.primary,
              ),
              KSizes.spacingHorizontalS,
              Expanded(
                child: Text(
                  'Personlige oplysninger',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: KSizes.fontWeightMedium,
                  ),
                ),
              ),
              Icon(
                MdiIcons.chevronRight,
                size: KSizes.iconM,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          KSizes.spacingVerticalM,
          
          _buildInfoRow(
            context,
            'Navn:',
            state.userProfile.name.isNotEmpty ? state.userProfile.name : 'Ikke angivet',
          ),
          
          _buildInfoRow(
            context,
            'Alder:',
            state.userProfile.dateOfBirth != null 
                ? '${_calculateAge(state.userProfile.dateOfBirth!)} år'
                : 'Ikke angivet',
          ),
          
          _buildInfoRow(
            context,
            'Køn:',
            _getGenderText(state.userProfile.gender),
          ),
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
          Row(
            children: [
              Icon(
                MdiIcons.humanMaleHeight,
                size: KSizes.iconM,
                color: AppColors.secondary,
              ),
              KSizes.spacingHorizontalS,
              Expanded(
                child: Text(
                  'Fysiske oplysninger',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: KSizes.fontWeightMedium,
                  ),
                ),
              ),
              Icon(
                MdiIcons.chevronRight,
                size: KSizes.iconM,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          KSizes.spacingVerticalM,
          
          _buildInfoRow(
            context,
            'Højde:',
            state.userProfile.heightCm > 0 
                ? '${state.userProfile.heightCm.round()} cm'
                : 'Ikke angivet',
          ),
          
          _buildInfoRow(
            context,
            'Nuværende vægt:',
            state.userProfile.currentWeightKg > 0 
                ? '${state.userProfile.currentWeightKg.toStringAsFixed(1)} kg'
                : 'Ikke angivet',
          ),
          
          if (state.userProfile.heightCm > 0 && state.userProfile.currentWeightKg > 0) ...[
            KSizes.spacingVerticalS,
            Row(
              children: [
                Text(
                  'BMI:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: KSizes.fontWeightMedium,
                  ),
                ),
                const Spacer(),
                Text(
                  '${state.userProfile.bmi.toStringAsFixed(1)} - ${state.userProfile.bmiCategory}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _getBMIColor(state.userProfile.bmi),
                    fontWeight: KSizes.fontWeightMedium,
                  ),
                ),
              ],
            ),
          ],
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
          Row(
            children: [
              Icon(
                MdiIcons.target,
                size: KSizes.iconM,
                color: AppColors.success,
              ),
              KSizes.spacingHorizontalS,
              Expanded(
                child: Text(
                  'Mål og kalorier',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: KSizes.fontWeightMedium,
                  ),
                ),
              ),
              Icon(
                MdiIcons.chevronRight,
                size: KSizes.iconM,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          KSizes.spacingVerticalM,
          
          _buildInfoRow(
            context,
            'Hovedmål:',
            _getGoalTypeText(state.userProfile.goalType),
          ),
          
          _buildInfoRow(
            context,
            'Målvægt:',
            state.userProfile.targetWeightKg > 0 
                ? '${state.userProfile.targetWeightKg.toStringAsFixed(1)} kg'
                : 'Ikke angivet',
          ),
          
          _buildInfoRow(
            context,
            'Daglige kalorier:',
            state.userProfile.targetCalories > 0 
                ? '${state.userProfile.targetCalories} kcal'
                : 'Ikke beregnet',
          ),
        ],
      ),
    );
  }

  Widget _buildEditableCard({
    required BuildContext context,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Card(
      elevation: 1,
      shadowColor: AppColors.primary.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        hoverColor: AppColors.primary.withOpacity(0.03),
        splashColor: AppColors.primary.withOpacity(0.06),
        child: Container(
          padding: const EdgeInsets.all(KSizes.margin4x),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(KSizes.radiusM),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  void _navigateToStep(WidgetRef ref, OnboardingStep step) {
    ref.read(onboardingProvider.notifier).goToStep(step);
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KSizes.margin2x),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: KSizes.fontWeightMedium,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _getGenderText(Gender? gender) {
    switch (gender) {
      case Gender.male:
        return 'Mand';
      case Gender.female:
        return 'Kvinde';
      case null:
        return 'Ikke angivet';
    }
  }

  String _getGoalTypeText(GoalType? goalType) {
    switch (goalType) {
      case GoalType.weightLoss:
        return 'Vægttab';
      case GoalType.weightMaintenance:
        return 'Vægtvedligeholdelse';
      case GoalType.weightGain:
        return 'Vægtøgning';
      case GoalType.muscleGain:
        return 'Muskelopbygning';
      case null:
        return 'Ikke angivet';
    }
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) {
      return AppColors.info;
    } else if (bmi < 25) {
      return AppColors.success;
    } else if (bmi < 30) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  int _calculateAge(DateTime dateOfBirth) {
    DateTime now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
} 