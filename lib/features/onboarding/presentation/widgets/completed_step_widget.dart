import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/navigation/app_navigation.dart';
import '../onboarding_page.dart';
import '../../application/onboarding_notifier.dart';

/// Modern, symmetrical completed step widget for onboarding
class CompletedStepWidget extends ConsumerWidget {
  const CompletedStepWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: AppDesign.backgroundGradient,
      ),
      child: Column(
        children: [
          // Main content area with scroll
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(KSizes.margin4x),
              child: Column(
                children: [
                  const SizedBox(height: KSizes.margin4x),
                  
                  // Hero Section
                  _buildHeroSection(context, state),
                  
                  const SizedBox(height: KSizes.margin6x),
                ],
              ),
            ),
          ),
          
          // Bottom button area - fixed at bottom
          Container(
            padding: const EdgeInsets.all(KSizes.margin4x),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: _buildActionSection(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, dynamic state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Success Animation Container - slightly smaller
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.success,
                AppColors.success.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withOpacity(0.3),
                blurRadius: KSizes.blurRadiusL,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.success.withOpacity(0.1),
                blurRadius: KSizes.blurRadiusXL,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Icon(
            MdiIcons.checkBold,
            size: KSizes.iconL,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: KSizes.margin4x),
        
        // Success Message
        Text(
          'Fantastisk! 🎉',
          style: TextStyle(
            fontSize: KSizes.fontSizeXXL,
            fontWeight: KSizes.fontWeightBold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: KSizes.margin2x),
        
        Text(
          'Din profil er nu komplet!',
          style: TextStyle(
            fontSize: KSizes.fontSizeL,
            color: AppColors.textSecondary,
            fontWeight: KSizes.fontWeightMedium,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: KSizes.margin4x),
        
        // Profile Summary Card
        _buildProfileSummaryCard(context, state),
      ],
    );
  }

  Widget _buildProfileSummaryCard(BuildContext context, dynamic state) {
    final userProfile = state.userProfile;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin3x),
      decoration: AppDesign.cardDecoration.copyWith(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            AppColors.primary.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  MdiIcons.accountCircle,
                  color: AppColors.primary,
                  size: KSizes.iconM,
                ),
              ),
              KSizes.spacingHorizontalM,
              Text(
                'Din profil',
                style: TextStyle(
                  fontSize: KSizes.fontSizeL,
                  fontWeight: KSizes.fontWeightSemiBold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: KSizes.margin3x),
          
          // Profile Stats Grid
          _buildProfileStatsGrid(userProfile),
        ],
      ),
    );
  }

  Widget _buildProfileStatsGrid(dynamic userProfile) {
    final stats = [
      _ProfileStat(
        icon: MdiIcons.account,
        label: 'Navn',
        value: userProfile.name.isNotEmpty ? userProfile.name : 'Ikke angivet',
      ),
      _ProfileStat(
        icon: MdiIcons.fire,
        label: 'Daglige kalorier',
        value: userProfile.targetCalories > 0 
            ? '${userProfile.targetCalories} kcal' 
            : 'Ikke beregnet',
      ),
      _ProfileStat(
        icon: MdiIcons.target,
        label: 'Mål',
        value: userProfile.goalType != null 
            ? _getGoalTypeText(userProfile.goalType)
            : 'Ikke valgt',
      ),
    ];

    return Column(
      children: stats.map((stat) => _buildStatItem(stat)).toList(),
    );
  }

  Widget _buildStatItem(_ProfileStat stat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KSizes.margin1x),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(KSizes.radiusM),
            ),
            child: Icon(
              stat.icon,
              color: AppColors.primary,
              size: KSizes.iconS,
            ),
          ),
          
          KSizes.spacingHorizontalM,
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label,
                  style: TextStyle(
                    fontSize: KSizes.fontSizeS,
                    color: AppColors.textSecondary,
                    fontWeight: KSizes.fontWeightMedium,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat.value,
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    color: AppColors.textPrimary,
                    fontWeight: KSizes.fontWeightSemiBold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Main CTA Button
        Container(
          width: double.infinity,
          height: KSizes.buttonHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(KSizes.radiusL),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: KSizes.blurRadiusL,
                offset: KSizes.shadowOffsetL,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _navigateToMainApp(context),
              borderRadius: BorderRadius.circular(KSizes.radiusL),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      MdiIcons.rocketLaunch,
                      color: Colors.white,
                      size: KSizes.iconM,
                    ),
                    KSizes.spacingHorizontalM,
                    Text(
                      'Kom i gang!',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightBold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: KSizes.margin3x),
        
        // Secondary Action
        TextButton.icon(
          onPressed: () => _editProfile(context, ref),
          icon: Icon(
            MdiIcons.pencil,
            size: KSizes.iconS,
            color: AppColors.textSecondary,
          ),
          label: Text(
            'Rediger profil',
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              color: AppColors.textSecondary,
              fontWeight: KSizes.fontWeightMedium,
            ),
          ),
        ),
      ],
    );
  }

  /// Navigate to main app
  void _navigateToMainApp(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AppNavigation()),
      (route) => false,
    );
  }

  /// Edit profile by restarting onboarding flow
  void _editProfile(BuildContext context, WidgetRef ref) {
    ref.read(onboardingProvider.notifier).restartOnboardingFlow();
  }

  String _getGoalTypeText(dynamic goalType) {
    return switch (goalType.toString()) {
      'GoalType.weightLoss' => 'Vægttab',
      'GoalType.weightGain' => 'Vægtøgning',
      'GoalType.maintainWeight' => 'Vedligehold vægt',
      _ => 'Ukendt mål',
    };
  }
}

/// Helper class for profile stats
class _ProfileStat {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileStat({
    required this.icon,
    required this.label,
    required this.value,
  });
} 