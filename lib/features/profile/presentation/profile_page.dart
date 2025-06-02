import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/app_option_card.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../onboarding/presentation/onboarding_page.dart';
import '../../onboarding/domain/user_profile_model.dart';
import '../../info/presentation/info_page.dart';
import '../../food_database/application/food_database_cubit.dart';
import 'activity_settings_page.dart';
import 'goal_edit_page.dart';

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
                  StandardPageHeader(
                    title: userProfile.name.isNotEmpty ? userProfile.name : 'Din Profil',
                    subtitle: userProfile.name.isNotEmpty 
                        ? 'Administrer dine indstillinger og præferencer'
                        : 'Gennemgå onboarding for at sætte din profil op',
                    icon: MdiIcons.account,
                    iconColor: AppColors.primary,
                    onInfoTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const InfoPage(),
                        ),
                      );
                    },
                  ),
                  
                  KSizes.spacingVerticalXL,
                  
                  // Profile Summary Card (only if profile exists)
                  if (userProfile.name.isNotEmpty) ...[
                    _buildProfileSummarySection(context, userProfile),
                    KSizes.spacingVerticalXL,
                  ],
                  
                  // Physical Stats Card (only if data exists)
                  if (userProfile.heightCm > 0 || userProfile.currentWeightKg > 0) ...[
                    _buildPhysicalStatsSection(context, userProfile),
                    KSizes.spacingVerticalXL,
                  ],
                  
                  // Goals Card (only if goals exist)
                  if (userProfile.goalType != null || userProfile.targetCalories > 0) ...[
                    _buildGoalsSection(context, userProfile),
                    KSizes.spacingVerticalXL,
                  ],
                  
                  // Settings and Actions Section
                  _buildSettingsSection(context, ref, userProfile),
                  
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

  Widget _buildProfileSummarySection(BuildContext context, UserProfileModel userProfile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: KSizes.blurRadiusL,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  MdiIcons.accountDetails,
                  color: Colors.white,
                  size: KSizes.iconL,
                ),
              ),
              const SizedBox(width: KSizes.margin4x),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personlige oplysninger',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Dine grundlæggende profil informationer',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          // Profile details
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
    );
  }

  Widget _buildPhysicalStatsSection(BuildContext context, UserProfileModel userProfile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: KSizes.blurRadiusL,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary,
                      AppColors.secondary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  MdiIcons.scaleBalance,
                  color: Colors.white,
                  size: KSizes.iconL,
                ),
              ),
              const SizedBox(width: KSizes.margin4x),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fysiske data',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Højde, vægt og kropssammensætning',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          // Physical stats
          if (userProfile.heightCm > 0)
            _buildInfoRow('Højde', '${userProfile.heightCm.round()} cm', MdiIcons.human),
          
          if (userProfile.currentWeightKg > 0)
            _buildInfoRow('Nuværende vægt', '${userProfile.currentWeightKg.toStringAsFixed(1)} kg', MdiIcons.scale),
          
          if (userProfile.targetWeightKg > 0)
            _buildInfoRow('Målvægt', '${userProfile.targetWeightKg.toStringAsFixed(1)} kg', MdiIcons.target),
          
          if (userProfile.bmr > 0)
            _buildInfoRow('BMR', '${userProfile.bmr.round()} kcal/dag', MdiIcons.fire),
        ],
      ),
    );
  }

  Widget _buildGoalsSection(BuildContext context, UserProfileModel userProfile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: KSizes.blurRadiusL,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success,
                      AppColors.success.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  MdiIcons.target,
                  color: Colors.white,
                  size: KSizes.iconL,
                ),
              ),
              const SizedBox(width: KSizes.margin4x),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mål og præferencer',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Dine mål og træningsindstillinger',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          // Goals info
          if (userProfile.goalType != null)
            _buildInfoRow('Mål', _getGoalTypeText(userProfile.goalType!), MdiIcons.bullseyeArrow),
          
          if (userProfile.targetCalories > 0)
            _buildInfoRow('Dagligt kaloriemål', '${userProfile.targetCalories.round()} kcal', MdiIcons.fire),
          
          if (userProfile.weeklyGoalKg != 0)
            _buildInfoRow('Ugentlig vægtændring', '${userProfile.weeklyGoalKg > 0 ? '+' : ''}${userProfile.weeklyGoalKg.toStringAsFixed(1)} kg', MdiIcons.trendingUp),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref, UserProfileModel userProfile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: KSizes.blurRadiusL,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.info,
                      AppColors.info.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.info.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  MdiIcons.cog,
                  color: Colors.white,
                  size: KSizes.iconL,
                ),
              ),
              const SizedBox(width: KSizes.margin4x),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Indstillinger og handlinger',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Administrer din app og dine data',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          // Settings options
          if (userProfile.name.isEmpty)
            ProfileOptionCard(
              title: 'Gennemgå onboarding',
              subtitle: 'Sæt din profil op med personlige mål og præferencer',
              icon: MdiIcons.accountPlus,
              onTap: () => _navigateToOnboarding(context, ref),
            ),
          
          ProfileOptionCard(
            title: 'Aktivitetsindstillinger',
            subtitle: 'Justér aktivitetsniveau og træningstyper',
            icon: MdiIcons.runFast,
            onTap: () => _navigateToActivitySettings(context),
          ),
          
          // Add goal editing option
          ProfileOptionCard(
            title: 'Rediger mål',
            subtitle: 'Opdater dine vægtmål og ugentlige målsætninger',
            icon: MdiIcons.bullseyeArrow,
            onTap: () => _navigateToGoalEdit(context),
          ),
          
          if (userProfile.name.isNotEmpty)
            ProfileOptionCard(
              title: 'Rediger profil',
              subtitle: 'Opdater personlige oplysninger og mål',
              icon: MdiIcons.pencil,
              onTap: () => _editProfile(context, ref),
            ),
          
          // DEBUG: Force recalculate calories
          ProfileOptionCard(
            title: '🧪 Genberegn kalorier (DEBUG)',
            subtitle: 'Tvinger genberegning af kaloriemål (fikser gamle beregninger)',
            icon: MdiIcons.calculator,
            onTap: () => _forceRecalculateCalories(context, ref),
          ),
          
          ProfileOptionCard(
            title: 'Information',
            subtitle: 'Om appen, version og vilkår',
            icon: MdiIcons.informationOutline,
            onTap: () => _navigateToInfo(context),
          ),
          
          if (userProfile.name.isNotEmpty)
            ProfileOptionCard(
              title: 'Nulstil profil',
              subtitle: 'Genstart onboarding og ryd alle data',
              icon: MdiIcons.refresh,
              onTap: () => _showRestartOnboardingDialog(context, ref),
            ),
          
          ProfileOptionCard(
            title: 'Slet maddatabasen',
            subtitle: 'Fjern alle madoplysninger og data',
            icon: MdiIcons.delete,
            onTap: () => _showDeleteFoodDatabaseDialog(context, ref),
          ),
        ],
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
    // Restart onboarding flow to start from the beginning
    await ref.read(onboardingProvider.notifier).restartOnboardingFlow();
    
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const OnboardingPage(),
        ),
      );
    }
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

  void _forceRecalculateCalories(BuildContext context, WidgetRef ref) {
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
                    colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  MdiIcons.calculator,
                  color: Colors.white,
                  size: KSizes.iconS,
                ),
              ),
              const SizedBox(width: KSizes.margin3x),
              Text(
                'Genberegn kalorier',
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
              color: AppColors.success.withOpacity(0.05),
              borderRadius: BorderRadius.circular(KSizes.radiusL),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Vil du genberegne dit kaloriemål med de opdaterede beregninger?',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: KSizes.margin2x),
                Text(
                  'Dette vil rette eventuelle gamle fejlberegninger.',
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
                Navigator.of(context).pop();
                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
                
                // Force recalculate
                await ref.read(onboardingProvider.notifier).forceRecalculateTargets();
                
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Kalorier genberegnet!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
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
                'Genberegn',
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

  void _showDeleteFoodDatabaseDialog(BuildContext context, WidgetRef ref) {
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
                  MdiIcons.delete,
                  color: Colors.white,
                  size: KSizes.iconS,
                ),
              ),
              const SizedBox(width: KSizes.margin3x),
              Text(
                'Slet maddatabasen',
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
                  'Er du sikker på, at du vil slette alle madoplysninger og data?',
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
                await ref.read(foodDatabaseProvider.notifier).clearAllFoods();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Maddatabasen er nu tom!'),
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