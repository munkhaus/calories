import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../onboarding/presentation/onboarding_page.dart';
import '../../onboarding/domain/user_profile_model.dart';
import '../../info/presentation/info_page.dart';
import 'activity_settings_page.dart';

/// Profile page showing user onboarding results and settings
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final userProfile = onboardingState.userProfile;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(KSizes.margin4x),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(context, userProfile),
                  
                  KSizes.spacingVerticalL,
                  
                  // Profile Summary Card
                  if (userProfile.name.isNotEmpty)
                    _buildProfileSummaryCard(context, userProfile),
                  
                  if (userProfile.name.isNotEmpty)
                    KSizes.spacingVerticalM,
                  
                  // Physical Stats Card
                  if (userProfile.heightCm > 0 || userProfile.currentWeightKg > 0)
                    _buildPhysicalStatsCard(context, userProfile),
                  
                  if (userProfile.heightCm > 0 || userProfile.currentWeightKg > 0)
                    KSizes.spacingVerticalM,
                  
                  // Goals Card
                  if (userProfile.goalType != null || userProfile.targetCalories > 0)
                    _buildGoalsCard(context, userProfile),
                  
                  if (userProfile.goalType != null || userProfile.targetCalories > 0)
                    KSizes.spacingVerticalM,
                  
                  // Actions Card
                  _buildActionsCard(context, ref),
                  
                  KSizes.spacingVerticalXL,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfileModel userProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(KSizes.margin3x),
              decoration: AppDesign.iconContainerDecoration(AppColors.primary),
              child: Icon(
                MdiIcons.account,
                color: Colors.white,
                size: KSizes.iconL,
              ),
            ),
            KSizes.spacingHorizontalM,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Din Profil',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeHeading,
                      fontWeight: KSizes.fontWeightBold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (userProfile.name.isNotEmpty)
                    Text(
                      userProfile.name,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (userProfile.name.isEmpty) ...[
          KSizes.spacingVerticalM,
          Container(
            padding: const EdgeInsets.all(KSizes.margin4x),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(KSizes.radiusL),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  MdiIcons.informationOutline,
                  color: AppColors.info,
                  size: KSizes.iconM,
                ),
                KSizes.spacingHorizontalM,
                Expanded(
                  child: Text(
                    'Gennemgå onboarding for at sætte din profil op',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeM,
                      color: AppColors.info,
                      fontWeight: KSizes.fontWeightMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProfileSummaryCard(BuildContext context, UserProfileModel userProfile) {
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
                  MdiIcons.accountDetails,
                  color: AppColors.primary,
                  size: KSizes.iconM,
                ),
                KSizes.spacingHorizontalS,
                Text(
                  'Personlige oplysninger',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeXL,
                    fontWeight: KSizes.fontWeightSemiBold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            KSizes.spacingVerticalM,
            
            if (userProfile.name.isNotEmpty)
              _buildInfoRow('Navn', userProfile.name, MdiIcons.account),
            
            if (userProfile.dateOfBirth != null)
              _buildInfoRow(
                'Alder', 
                '${_calculateAge(userProfile.dateOfBirth!)} år', 
                MdiIcons.cake,
              ),
            
            if (userProfile.gender != null)
              _buildInfoRow(
                'Køn', 
                _getGenderText(userProfile.gender!), 
                MdiIcons.humanMaleFemale,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalStatsCard(BuildContext context, UserProfileModel userProfile) {
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
                  MdiIcons.humanMaleHeight,
                  color: AppColors.secondary,
                  size: KSizes.iconM,
                ),
                KSizes.spacingHorizontalS,
                Text(
                  'Fysiske mål',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeXL,
                    fontWeight: KSizes.fontWeightSemiBold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            KSizes.spacingVerticalM,
            
            if (userProfile.heightCm > 0)
              _buildInfoRow(
                'Højde', 
                '${userProfile.heightCm.round()} cm', 
                MdiIcons.humanMaleHeight,
              ),
            
            if (userProfile.currentWeightKg > 0)
              _buildInfoRow(
                'Nuværende vægt', 
                '${userProfile.currentWeightKg.toStringAsFixed(1)} kg', 
                MdiIcons.scaleBalance,
              ),
            
            if (userProfile.targetWeightKg > 0)
              _buildInfoRow(
                'Målvægt', 
                '${userProfile.targetWeightKg.toStringAsFixed(1)} kg', 
                MdiIcons.target,
              ),
            
            if (userProfile.heightCm > 0 && userProfile.currentWeightKg > 0) ...[
              KSizes.spacingVerticalS,
              Container(
                padding: const EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Row(
                  children: [
                    Icon(
                      MdiIcons.calculator,
                      color: AppColors.success,
                      size: KSizes.iconS,
                    ),
                    KSizes.spacingHorizontalS,
                    Text(
                      'BMI: ${userProfile.bmi.toStringAsFixed(1)} (${userProfile.bmiCategory})',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        color: AppColors.success,
                        fontWeight: KSizes.fontWeightMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsCard(BuildContext context, UserProfileModel userProfile) {
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
                  MdiIcons.target,
                  color: AppColors.success,
                  size: KSizes.iconM,
                ),
                KSizes.spacingHorizontalS,
                Text(
                  'Mål & Kalorier',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeXL,
                    fontWeight: KSizes.fontWeightSemiBold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            KSizes.spacingVerticalM,
            
            if (userProfile.goalType != null)
              _buildInfoRow(
                'Mål', 
                _getGoalTypeText(userProfile.goalType!), 
                MdiIcons.flagOutline,
              ),
            
            // Show new activity system if available, otherwise legacy
            if (userProfile.workActivityLevel != null && userProfile.leisureActivityLevel != null) ...[
              _buildInfoRow(
                'Aktivitetstracking', 
                _getActivityTrackingText(userProfile.activityTrackingPreference), 
                MdiIcons.chartLine,
              ),
              _buildInfoRow(
                'Arbejde', 
                _getWorkActivityText(userProfile.workActivityLevel!), 
                MdiIcons.briefcase,
              ),
              _buildInfoRow(
                'Fritid', 
                _getLeisureActivityText(userProfile.leisureActivityLevel!), 
                MdiIcons.run,
              ),
            ] else if (userProfile.activityLevel != null) ...[
              _buildInfoRow(
                'Aktivitetsniveau', 
                _getActivityLevelText(userProfile.activityLevel!), 
                MdiIcons.run,
              ),
            ],
            
            if (userProfile.targetCalories > 0) ...[
              KSizes.spacingVerticalM,
              Container(
                padding: const EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.secondary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          MdiIcons.fire,
                          color: AppColors.warning,
                          size: KSizes.iconM,
                        ),
                        KSizes.spacingHorizontalS,
                        Text(
                          '${userProfile.targetCalories} kcal/dag',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeXL,
                            fontWeight: KSizes.fontWeightBold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    
                    if (userProfile.targetProteinG > 0) ...[
                      KSizes.spacingVerticalM,
                      Row(
                        children: [
                          Expanded(
                            child: _buildMacroChip(
                              'Protein',
                              '${userProfile.targetProteinG.round()}g',
                              AppColors.error,
                            ),
                          ),
                          KSizes.spacingHorizontalS,
                          Expanded(
                            child: _buildMacroChip(
                              'Fedt',
                              '${userProfile.targetFatG.round()}g',
                              AppColors.warning,
                            ),
                          ),
                          KSizes.spacingHorizontalS,
                          Expanded(
                            child: _buildMacroChip(
                              'Kulhydrater',
                              '${userProfile.targetCarbsG.round()}g',
                              AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context, WidgetRef ref) {
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
                  MdiIcons.cog,
                  color: AppColors.info,
                  size: KSizes.iconM,
                ),
                KSizes.spacingHorizontalS,
                Text(
                  'Handlinger',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeXL,
                    fontWeight: KSizes.fontWeightSemiBold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            KSizes.spacingVerticalM,
            
            // Edit Profile Button
            _buildActionButton(
              icon: MdiIcons.accountEdit,
              title: 'Rediger profil',
              subtitle: 'Opdater dine oplysninger',
              gradient: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              onTap: () => _editProfile(context, ref),
            ),
            
            KSizes.spacingVerticalM,
            
            // Activity Settings Button
            _buildActionButton(
              icon: MdiIcons.run,
              title: 'Aktivitetsindstillinger',
              subtitle: 'Juster dit arbejde og fritidsaktiviteter',
              gradient: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
              onTap: () => _navigateToActivitySettings(context),
            ),
            
            KSizes.spacingVerticalM,
            
            // Info Button
            _buildActionButton(
              icon: MdiIcons.informationOutline,
              title: 'Information & Ansvarsfraskrivelse',
              subtitle: 'Vigtig information om appen',
              gradient: [AppColors.info, AppColors.info.withOpacity(0.8)],
              onTap: () => _navigateToInfo(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KSizes.margin1x),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.textTertiary,
            size: KSizes.iconS,
          ),
          KSizes.spacingHorizontalM,
          Text(
            '$label:',
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              color: AppColors.textSecondary,
              fontWeight: KSizes.fontWeightMedium,
            ),
          ),
          KSizes.spacingHorizontalS,
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: KSizes.fontSizeM,
                color: AppColors.textPrimary,
                fontWeight: KSizes.fontWeightMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KSizes.margin2x,
        vertical: KSizes.margin1x,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusS),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: KSizes.fontSizeXS,
              color: color,
              fontWeight: KSizes.fontWeightMedium,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: KSizes.fontSizeS,
              color: color,
              fontWeight: KSizes.fontWeightBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        child: Container(
          padding: const EdgeInsets.all(KSizes.margin4x),
          decoration: AppDesign.quickActionDecoration(gradient),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
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
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightSemiBold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                MdiIcons.chevronRight,
                color: Colors.white.withOpacity(0.8),
                size: KSizes.iconM,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editProfile(BuildContext context, WidgetRef ref) {
    // Restart onboarding flow to start from welcome step (preserve data)
    ref.read(onboardingProvider.notifier).restartOnboardingFlow();
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OnboardingPage(),
      ),
    );
  }

  void _navigateToActivitySettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ActivitySettingsPage(),
      ),
    );
  }

  void _navigateToInfo(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const InfoPage(),
      ),
    );
  }

  int _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  String _getGenderText(Gender? gender) {
    return switch (gender) {
      Gender.male => 'Mand',
      Gender.female => 'Kvinde',
      null => 'Ikke angivet',
    };
  }

  String _getGoalTypeText(GoalType goalType) {
    return switch (goalType) {
      GoalType.weightLoss => 'Vægttab',
      GoalType.weightGain => 'Vægtforøgelse',
      GoalType.muscleGain => 'Muskelopbygning',
      GoalType.weightMaintenance => 'Vedligeholdelse',
    };
  }

  String _getActivityLevelText(ActivityLevel activityLevel) {
    return switch (activityLevel) {
      ActivityLevel.sedentary => 'Stillesiddende',
      ActivityLevel.lightlyActive => 'Let aktiv',
      ActivityLevel.moderatelyActive => 'Moderat aktiv',
      ActivityLevel.veryActive => 'Meget aktiv',
      ActivityLevel.extraActive => 'Ekstremt aktiv',
    };
  }

  String _getActivityTrackingText(ActivityTrackingPreference activityTrackingPreference) {
    return switch (activityTrackingPreference) {
      ActivityTrackingPreference.automatic => 'Automatisk',
      ActivityTrackingPreference.manual => 'Manuel',
      ActivityTrackingPreference.hybrid => 'Hybrid',
    };
  }

  String _getWorkActivityText(WorkActivityLevel workActivityLevel) {
    return switch (workActivityLevel) {
      WorkActivityLevel.sedentary => 'Kontorarbejde',
      WorkActivityLevel.light => 'Let fysisk arbejde',
      WorkActivityLevel.moderate => 'Moderat fysisk arbejde',
      WorkActivityLevel.heavy => 'Hård fysisk arbejde',
      WorkActivityLevel.veryHeavy => 'Meget hård fysisk arbejde',
    };
  }

  String _getLeisureActivityText(LeisureActivityLevel leisureActivityLevel) {
    return switch (leisureActivityLevel) {
      LeisureActivityLevel.sedentary => 'Ingen/minimal aktivitet',
      LeisureActivityLevel.lightlyActive => 'Let aktivitet (1-3 dage/uge)',
      LeisureActivityLevel.moderatelyActive => 'Moderat aktivitet (3-5 dage/uge)',
      LeisureActivityLevel.veryActive => 'Meget aktivitet (6-7 dage/uge)',
      LeisureActivityLevel.extraActive => 'Ekstra aktivitet (daglig)',
    };
  }
} 