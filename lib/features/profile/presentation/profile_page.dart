import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_page_header.dart';
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
                  // Header with standardized design
                  StandardPageHeader(
                    title: userProfile.name.isNotEmpty ? userProfile.name : 'Din Profil',
                    subtitle: userProfile.name.isNotEmpty 
                        ? 'Administrer dine indstillinger og præferencer'
                        : 'Gennemgå onboarding for at sætte din profil op',
                    icon: MdiIcons.account,
                    iconColor: AppColors.primary,
                  ),
                  
                  const SizedBox(height: KSizes.margin4x),
                  
                  // Profile Summary Card (clickable to edit profile)
                  if (userProfile.name.isNotEmpty) ...[
                    _buildEditableProfileSection(context, ref, userProfile),
                    const SizedBox(height: KSizes.margin4x),
                  ],
                  
                  // Physical Stats Card (clickable to edit weight/goals)
                  if (userProfile.heightCm > 0 || userProfile.currentWeightKg > 0) ...[
                    _buildEditablePhysicalStatsSection(context, userProfile),
                    const SizedBox(height: KSizes.margin4x),
                  ],
                  
                  // Goals Card (clickable to edit goals)
                  if (userProfile.goalType != null || userProfile.targetCalories > 0) ...[
                    _buildEditableGoalsSection(context, userProfile),
                    const SizedBox(height: KSizes.margin4x),
                  ],
                  
                  // Activity Settings Card (clickable)
                  _buildEditableActivitySection(context),
                  const SizedBox(height: KSizes.margin4x),
                  
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
            
            // Content
            ...children,
          ],
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
              color: AppColors.surface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(KSizes.radiusS),
            ),
            child: Icon(
              icon,
              size: KSizes.iconS,
              color: AppColors.textSecondary,
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
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
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
            title: 'App indstillinger',
            subtitle: 'Data og systemindstillinger',
            icon: MdiIcons.cog,
            iconColor: AppColors.warning,
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          // Settings options
          _buildSettingsButton(
            context,
            'App information',
            'Om appen og vilkår',
            MdiIcons.informationOutline,
            () => _showInfoPage(context),
          ),
          
          const SizedBox(height: KSizes.margin3x),
          
          _buildSettingsButton(
            context,
            'Nulstil data',
            'Slet alle data og start forfra',
            MdiIcons.deleteOutline,
            () => _showResetDialog(context, ref),
            isDestructive: true,
          ),
          
          const SizedBox(height: KSizes.margin3x),
          
          _buildSettingsButton(
            context,
            'Gennemgå onboarding',
            'Start setup forfra',
            MdiIcons.restart,
            () => _startOnboarding(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KSizes.radiusM),
      child: Container(
        padding: const EdgeInsets.all(KSizes.margin4x),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(KSizes.margin2x),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(KSizes.radiusS),
              ),
              child: Icon(
                icon,
                size: KSizes.iconM,
                color: color,
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
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: KSizes.fontSizeS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              MdiIcons.chevronRight,
              color: AppColors.textSecondary,
              size: KSizes.iconS,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
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
        return 'Tabe sig';
      case GoalType.weightGain:
        return 'Tage på';
      case GoalType.weightMaintenance:
        return 'Fastholde vægt';
      case GoalType.muscleGain:
        return 'Bygge muskler';
    }
  }

  // Navigation methods
  void _editProfile(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileEditPage(),
      ),
    );
  }

  void _navigateToPhysicalStatsEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PhysicalStatsEditPage(),
      ),
    );
  }

  void _navigateToGoalEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GoalEditPage(),
      ),
    );
  }

  void _navigateToActivitySettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ActivitySettingsPage(),
      ),
    );
  }

  void _showInfoPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InfoPage(isInitialView: false),
      ),
    );
  }

  void _startOnboarding(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const OnboardingPage(),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nulstil alle data?'),
        content: const Text(
          'Dette vil slette alle dine data permanent, inkluderet mad-favoritter, aktiviteter, '
          'vægtregistreringer og profil indstillinger. Handlingen kan ikke fortrydes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuller'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetAllData(context, ref);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Nulstil'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllData(BuildContext context, WidgetRef ref) async {
    try {
      // Clear food favorites
      final foodService = FavoriteFoodService();
      await foodService.clearAllFavorites();
      
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Alle data er blevet nulstillet'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Navigate to onboarding
        _startOnboarding(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved nulstilling: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
} 