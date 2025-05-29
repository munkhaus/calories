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
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        gradient: AppDesign.backgroundGradient,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KSizes.margin4x),
          child: Column(
            children: [
              // Top spacing
              SizedBox(height: screenHeight * 0.1),
              
              // Hero Section - Centrally positioned
              Expanded(
                flex: 3,
                child: _buildHeroSection(context, state),
              ),
              
              // Action Section - Fixed at bottom
              _buildActionSection(context, ref),
              
              // Bottom spacing
              const SizedBox(height: KSizes.margin6x),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, dynamic state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Success Animation Container
        Container(
          width: 120,
          height: 120,
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
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.success.withOpacity(0.1),
                blurRadius: 48,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Icon(
            MdiIcons.checkBold,
            size: 60,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: KSizes.margin6x),
        
        // Success Message
        Text(
          'Fantastisk! 🎉',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: KSizes.margin3x),
        
        Text(
          'Din profil er nu komplet!',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: KSizes.margin6x),
        
        // Profile Summary Card
        _buildProfileSummaryCard(context, state),
      ],
    );
  }

  Widget _buildProfileSummaryCard(BuildContext context, dynamic state) {
    final userProfile = state.userProfile;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin4x),
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
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: KSizes.margin4x),
          
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
      padding: const EdgeInsets.symmetric(vertical: KSizes.margin2x),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat.value,
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

  Widget _buildActionSection(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Main CTA Button
        Container(
          width: double.infinity,
          height: 56,
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
                blurRadius: 16,
                offset: const Offset(0, 8),
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
                        fontWeight: FontWeight.bold,
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
        
        const SizedBox(height: KSizes.margin4x),
        
        // Secondary Action
        TextButton.icon(
          onPressed: () => _showEditProfileDialog(context, ref),
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
              fontWeight: FontWeight.w500,
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

  /// Show edit profile confirmation dialog
  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusL),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(KSizes.margin2x),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(KSizes.radiusM),
              ),
              child: Icon(
                MdiIcons.pencil,
                color: AppColors.primary,
                size: KSizes.iconM,
              ),
            ),
            KSizes.spacingHorizontalM,
            Expanded(
              child: Text(
                'Rediger profil',
                style: TextStyle(
                  fontSize: KSizes.fontSizeXL,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Vil du gå tilbage til onboarding for at redigere dine oplysninger?',
          style: TextStyle(
            fontSize: KSizes.fontSizeM,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Annuller',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(onboardingProvider.notifier).restartOnboardingFlow();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Rediger'),
          ),
        ],
      ),
    );
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