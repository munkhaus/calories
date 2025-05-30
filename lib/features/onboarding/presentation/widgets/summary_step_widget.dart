import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/onboarding_notifier.dart';
import '../../domain/onboarding_step.dart';
import '../../domain/user_profile_model.dart';

/// Summary step widget for onboarding
class SummaryStepWidget extends ConsumerWidget {
  const SummaryStepWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);

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
            
            // Header
            _buildHeader(context),
            
            KSizes.spacingVerticalL,
            
            // Personal Information Card
            _buildPersonalInfoCard(context, state, ref),
            
            KSizes.spacingVerticalM,
            
            // Physical Information Card
            _buildPhysicalInfoCard(context, state, ref),
            
            KSizes.spacingVerticalM,
            
            // Goals Information Card
            _buildGoalsInfoCard(context, state, ref),
            
            KSizes.spacingVerticalM,
            
            // Calculated Values Card
            _buildCalculatedValuesCard(context, state),
            
            KSizes.spacingVerticalL,
            
            // Weight goal section
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    context,
                    'Nuværende vægt',
                    '${state.userProfile.currentWeightKg.toStringAsFixed(1)} kg',
                    MdiIcons.scaleBalance,
                    AppColors.primary,
                  ),
                ),
                SizedBox(width: KSizes.margin3x),
                Expanded(
                  child: _buildInfoCard(
                    context,
                    'Målvægt',
                    '${state.userProfile.targetWeightKg.toStringAsFixed(1)} kg',
                    MdiIcons.target,
                    AppColors.success,
                  ),
                ),
              ],
            ),
            
            KSizes.spacingVerticalL,
            
            // Calorie target (simplified)
            Container(
              padding: EdgeInsets.all(KSizes.margin4x),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(KSizes.radiusM),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(KSizes.margin2x),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(KSizes.radiusS),
                        ),
                        child: Icon(
                          MdiIcons.target,
                          color: AppColors.primary,
                          size: KSizes.iconM,
                        ),
                      ),
                      SizedBox(width: KSizes.margin3x),
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
                            SizedBox(height: KSizes.margin1x),
                            Row(
                              children: [
                                Text(
                                  '${state.userProfile.targetCalories}',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: KSizes.fontWeightBold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(width: KSizes.margin1x),
                                Text(
                                  'kcal',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: KSizes.margin3x),
                  
                  Container(
                    padding: EdgeInsets.all(KSizes.margin3x),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(KSizes.radiusS),
                      border: Border.all(
                        color: AppColors.info.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          MdiIcons.lightbulbOutline,
                          color: AppColors.info,
                          size: KSizes.iconS,
                        ),
                        SizedBox(width: KSizes.margin2x),
                        Expanded(
                          child: Text(
                            'Dette er beregnet ud fra dine oplysninger og mål',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.info,
                              fontWeight: KSizes.fontWeightMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            KSizes.spacingVerticalL,
            
            // Ready to Start Card
            _buildReadyToStartCard(context),
            
            KSizes.spacingVerticalXL,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          MdiIcons.clipboardCheck,
          size: KSizes.iconL,
          color: AppColors.primary,
        ),
        KSizes.spacingHorizontalM,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Opsummering',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: KSizes.fontWeightBold,
                ),
              ),
              Text(
                'Gennemgå dine oplysninger før vi starter',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildCalculatedValuesCard(BuildContext context, dynamic state) {
    // This method is no longer needed since we moved calorie calculations to a separate step
    return SizedBox.shrink();
  }

  Widget _buildReadyToStartCard(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(KSizes.margin6x),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.secondary.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(KSizes.radiusM),
        ),
        child: Column(
          children: [
            Icon(
              MdiIcons.rocketLaunch,
              size: KSizes.iconXL,
              color: AppColors.primary,
            ),
            KSizes.spacingVerticalM,
            Text(
              'Klar til at starte!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: KSizes.fontWeightBold,
                color: AppColors.primary,
              ),
            ),
            KSizes.spacingVerticalL,
          ],
        ),
      ),
    );
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

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
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
          SizedBox(height: KSizes.margin2x),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: KSizes.fontWeightMedium,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: KSizes.margin1x),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: KSizes.fontWeightBold,
            ),
            textAlign: TextAlign.center,
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