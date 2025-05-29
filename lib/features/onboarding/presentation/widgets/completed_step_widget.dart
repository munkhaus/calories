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
                  _buildReadyToStartCard(context),
                  
                  const SizedBox(height: KSizes.margin6x),
                  
                  // Start Journey Button
                  _buildStartJourneyButton(context),
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

  Widget _buildReadyToStartCard(BuildContext context) {
    return Container(
      decoration: AppDesign.sectionDecoration,
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin4x),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(KSizes.margin4x),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.success, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(KSizes.radiusXL),
              ),
              child: Icon(
                MdiIcons.rocketLaunch,
                color: Colors.white,
                size: KSizes.iconXL,
              ),
            ),
            
            KSizes.spacingVerticalM,
            
            Text(
              'Fantastisk! 🎉',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.success,
                fontWeight: KSizes.fontWeightBold,
              ),
              textAlign: TextAlign.center,
            ),
            
            KSizes.spacingVerticalS,
            
            Text(
              'Din personlige sundhedsplan er nu klar!\nLad os starte din rejse mod en sundere livsstil.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            KSizes.spacingVerticalL,
            
            Container(
              padding: const EdgeInsets.all(KSizes.margin3x),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(KSizes.radiusM),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    MdiIcons.checkCircle,
                    color: AppColors.success,
                    size: KSizes.iconS,
                  ),
                  KSizes.spacingHorizontalS,
                  Expanded(
                    child: Text(
                      'Tryk på "Start rejsen" for at gå til dit dashboard',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.success,
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
    );
  }

  Widget _buildStartJourneyButton(BuildContext context) {
    return Positioned(
      left: KSizes.margin4x,
      right: KSizes.margin4x,
      bottom: KSizes.margin6x,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.success, AppColors.primary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(KSizes.radiusXL),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withOpacity(0.3),
              blurRadius: KSizes.blurRadiusL,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(KSizes.radiusXL),
            onTap: () {
              // Navigate to dashboard - the AppWrapper will handle this automatically
              // when onboarding is completed
              Navigator.of(context).pushReplacementNamed('/dashboard');
            },
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    MdiIcons.rocketLaunch,
                    color: Colors.white,
                    size: KSizes.iconM,
                  ),
                  KSizes.spacingHorizontalS,
                  Text(
                    'Start rejsen',
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