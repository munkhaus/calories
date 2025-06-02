import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../onboarding/presentation/onboarding_page.dart';
import '../../onboarding/domain/user_profile_model.dart';
import '../../info/presentation/info_page.dart';
import '../../food_database/application/food_database_cubit.dart';
import '../../food_logging/domain/i_favorite_food_service.dart';
import '../../food_logging/infrastructure/favorite_food_service.dart';
import '../../onboarding/presentation/widgets/onboarding_base_layout.dart';
import 'activity_settings_page.dart';
import 'goal_edit_page.dart';
import 'profile_edit_page.dart';
import 'physical_stats_edit_page.dart';

/// Profile page showing user onboarding results and settings
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final userProfile = onboardingState.userProfile;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(KSizes.margin4x),
              child: Column(
                children: [
                  // Header with new design
                  OnboardingSection(
                    gradientColor: AppColors.primary,
                    child: OnboardingSectionHeader(
                      title: userProfile.name.isNotEmpty ? userProfile.name : 'Din Profil',
                      subtitle: userProfile.name.isNotEmpty 
                          ? 'Administrer dine indstillinger og præferencer'
                          : 'Gennemgå onboarding for at sætte din profil op',
                      icon: MdiIcons.account,
                      iconColor: AppColors.primary,
                    ),
                  ),
                  
                  KSizes.spacingVerticalXL,
                  
                  // Profile Summary Card (clickable to edit profile)
                  if (userProfile.name.isNotEmpty) ...[
                    _buildEditableProfileSection(context, ref, userProfile),
                    KSizes.spacingVerticalXL,
                  ],
                  
                  // Physical Stats Card (clickable to edit weight/goals)
                  if (userProfile.heightCm > 0 || userProfile.currentWeightKg > 0) ...[
                    _buildEditablePhysicalStatsSection(context, userProfile),
                    KSizes.spacingVerticalXL,
                  ],
                  
                  // Goals Card (clickable to edit goals)
                  if (userProfile.goalType != null || userProfile.targetCalories > 0) ...[
                    _buildEditableGoalsSection(context, userProfile),
                    KSizes.spacingVerticalXL,
                  ],
                  
                  // Activity Settings Card (clickable)
                  _buildEditableActivitySection(context),
                  KSizes.spacingVerticalXL,
                  
                  // App Settings and Data Management Section
                  _buildAppSettingsSection(context, ref, userProfile),
                  
                  // Bottom padding
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableProfileSection(BuildContext context, WidgetRef ref, UserProfileModel userProfile) {
    return _buildClickableSection(
      gradientColor: AppColors.primary,
      title: 'Personlige oplysninger',
      subtitle: 'Navn, alder og køn',
      icon: MdiIcons.accountDetails,
      onTap: () => _editProfile(context, ref),
      children: [
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
    );
  }

  Widget _buildEditablePhysicalStatsSection(BuildContext context, UserProfileModel userProfile) {
    return _buildClickableSection(
      gradientColor: AppColors.info,
      title: 'Fysiske data',
      subtitle: 'Højde, vægt og kropssammensætning',
      icon: MdiIcons.scaleBalance,
      onTap: () => _navigateToPhysicalStatsEdit(context),
      children: [
        if (userProfile.heightCm > 0)
          _buildInfoRow('Højde', '${userProfile.heightCm.round()} cm', MdiIcons.human),
        
        if (userProfile.currentWeightKg > 0)
          _buildInfoRow('Nuværende vægt', '${userProfile.currentWeightKg.toStringAsFixed(1)} kg', MdiIcons.scale),
        
        if (userProfile.targetWeightKg > 0)
          _buildInfoRow('Målvægt', '${userProfile.targetWeightKg.toStringAsFixed(1)} kg', MdiIcons.target),
        
        if (userProfile.bmr > 0)
          _buildInfoRow('BMR', '${userProfile.bmr.round()} kcal/dag', MdiIcons.fire),
      ],
    );
  }

  Widget _buildEditableGoalsSection(BuildContext context, UserProfileModel userProfile) {
    return _buildClickableSection(
      gradientColor: AppColors.success,
      title: 'Mål og præferencer',
      subtitle: 'Vægtmål og ugentlige målsætninger',
      icon: MdiIcons.target,
      onTap: () => _navigateToGoalEdit(context),
      children: [
        if (userProfile.goalType != null)
          _buildInfoRow('Mål', _getGoalTypeText(userProfile.goalType!), MdiIcons.bullseyeArrow),
        
        if (userProfile.targetCalories > 0)
          _buildInfoRow('Dagligt kaloriemål', '${userProfile.targetCalories.round()} kcal', MdiIcons.fire),
        
        if (userProfile.weeklyGoalKg != 0)
          _buildInfoRow('Ugentlig vægtændring', '${userProfile.weeklyGoalKg > 0 ? '+' : ''}${userProfile.weeklyGoalKg.toStringAsFixed(1)} kg', MdiIcons.trendingUp),
      ],
    );
  }

  Widget _buildEditableActivitySection(BuildContext context) {
    return _buildClickableSection(
      gradientColor: AppColors.secondary,
      title: 'Aktivitetsindstillinger',
      subtitle: 'Aktivitetsniveau og træningstyper',
      icon: MdiIcons.runFast,
      onTap: () => _navigateToActivitySettings(context),
      children: [
        _buildInfoRow('Indstillinger', 'Klik for at redigere', MdiIcons.cog),
      ],
    );
  }

  Widget _buildClickableSection({
    required Color gradientColor,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KSizes.radiusXL),
      child: OnboardingSection(
        gradientColor: gradientColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: OnboardingSectionHeader(
                    title: title,
                    subtitle: subtitle,
                    icon: icon,
                    iconColor: gradientColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(KSizes.margin2x),
                  decoration: BoxDecoration(
                    color: gradientColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(KSizes.radiusS),
                  ),
                  child: Icon(
                    MdiIcons.chevronRight,
                    color: gradientColor,
                    size: KSizes.iconM,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: KSizes.margin6x),
            
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettingsSection(BuildContext context, WidgetRef ref, UserProfileModel userProfile) {
    return OnboardingSection(
      gradientColor: AppColors.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingSectionHeader(
            title: 'App og dataindstillinger',
            subtitle: 'Administrer dine data og app-indstillinger',
            icon: MdiIcons.cog,
            iconColor: AppColors.warning,
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          // Settings options
          if (userProfile.name.isEmpty)
            _buildSettingsOption(
              title: 'Gennemgå onboarding',
              subtitle: 'Sæt din profil op med personlige mål og præferencer',
              icon: MdiIcons.accountPlus,
              onTap: () => _navigateToOnboarding(context, ref),
            ),

          _buildSettingsOption(
            title: 'Slet alle mad favoritter',
            subtitle: 'Fjern alle dine gemte mad favoritter',
            icon: MdiIcons.heartRemove,
            onTap: () => _showClearFavoritesDialog(context, ref),
          ),
          
          _buildSettingsOption(
            title: 'Information',
            subtitle: 'Om appen, version og vilkår',
            icon: MdiIcons.informationOutline,
            onTap: () => _navigateToInfo(context),
          ),
          
          if (userProfile.name.isNotEmpty)
            _buildSettingsOption(
              title: 'Nulstil profil',
              subtitle: 'Genstart onboarding og ryd alle data',
              icon: MdiIcons.refresh,
              onTap: () => _showRestartOnboardingDialog(context, ref),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KSizes.margin4x),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        child: Container(
          padding: const EdgeInsets.all(KSizes.margin4x),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.8),
                Colors.white.withOpacity(0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(KSizes.radiusL),
            border: Border.all(
              color: AppColors.textSecondary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: KSizes.iconM,
                ),
              ),
              const SizedBox(width: KSizes.margin3x),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        fontWeight: KSizes.fontWeightMedium,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                MdiIcons.chevronRight,
                color: AppColors.textTertiary,
                size: KSizes.iconS,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KSizes.margin4x),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(KSizes.margin2x),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(KSizes.radiusS),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: KSizes.iconM,
            ),
          ),
          const SizedBox(width: KSizes.margin3x),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: KSizes.fontSizeS,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    fontWeight: KSizes.fontWeightMedium,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  String _getGenderText(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'Mand';
      case Gender.female:
        return 'Kvinde';
    }
  }

  String _getGoalTypeText(GoalType goalType) {
    switch (goalType) {
      case GoalType.weightLoss:
        return 'Tab vægt';
      case GoalType.weightMaintenance:
        return 'Vedligehold vægt';
      case GoalType.weightGain:
        return 'Tag på i vægt';
      case GoalType.muscleGain:
        return 'Byg muskler';
    }
  }

  void _editProfile(BuildContext context, WidgetRef ref) async {
    // Navigate to dedicated profile edit page for name, age, and gender
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileEditPage(),
      ),
    );
  }

  void _navigateToOnboarding(BuildContext context, WidgetRef ref) {
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

  void _navigateToGoalEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GoalEditPage(),
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

  void _navigateToPhysicalStatsEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PhysicalStatsEditPage(),
      ),
    );
  }

  void _showRestartOnboardingDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KSizes.radiusXL),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.warning, AppColors.warning.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  MdiIcons.refresh,
                  color: Colors.white,
                  size: KSizes.iconS,
                ),
              ),
              const SizedBox(width: KSizes.margin3x),
              Text(
                'Genstart onboarding',
                style: TextStyle(
                  fontSize: KSizes.fontSizeL,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(KSizes.margin4x),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.05),
              borderRadius: BorderRadius.circular(KSizes.radiusL),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Er du sikker på, at du vil genstarte onboarding processen?',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: KSizes.margin2x),
                Text(
                  'Dine eksisterende data bliver ikke slettet.',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeS,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: KSizes.margin4x,
                  vertical: KSizes.margin2x,
                ),
              ),
              child: Text(
                'Annuller',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(onboardingProvider.notifier).restartOnboardingFlow();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  // Navigate to onboarding
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const OnboardingPage(),
                    ),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: KSizes.margin4x,
                  vertical: KSizes.margin2x,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KSizes.radiusL),
                ),
              ),
              child: Text(
                'Genstart',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showClearFavoritesDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KSizes.radiusXL),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.warning, AppColors.warning.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  MdiIcons.heartRemove,
                  color: Colors.white,
                  size: KSizes.iconS,
                ),
              ),
              const SizedBox(width: KSizes.margin3x),
              Text(
                'Slet alle mad favoritter',
                style: TextStyle(
                  fontSize: KSizes.fontSizeL,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(KSizes.margin4x),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.05),
              borderRadius: BorderRadius.circular(KSizes.radiusL),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Er du sikker på, at du vil slette alle dine gemte mad favoritter?',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: KSizes.margin2x),
                Text(
                  'Dette kan ikke gendannes.',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeS,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: KSizes.margin4x,
                  vertical: KSizes.margin2x,
                ),
              ),
              child: Text(
                'Annuller',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final service = FavoriteFoodService();
                await service.clearAllFavorites();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Alle mad favoritter er nu fjernet!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: KSizes.margin4x,
                  vertical: KSizes.margin2x,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KSizes.radiusL),
                ),
              ),
              child: Text(
                'Slet',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
} 