import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/navigation/app_navigation.dart';
import '../../application/onboarding_notifier.dart';

/// Modern, symmetrical completed step widget for onboarding
class CompletedStepWidget extends ConsumerStatefulWidget {
  const CompletedStepWidget({super.key});

  @override
  ConsumerState<CompletedStepWidget> createState() => _CompletedStepWidgetState();
}

class _CompletedStepWidgetState extends ConsumerState<CompletedStepWidget> {
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
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
              'Din personlige plan er nu klar!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            KSizes.spacingVerticalL,
          ],
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
              onTap: _isNavigating ? null : () => _navigateToMainApp(context),
              borderRadius: BorderRadius.circular(KSizes.radiusL),
              child: Center(
                child: _isNavigating
                    ? SizedBox(
                        width: KSizes.iconM,
                        height: KSizes.iconM,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            MdiIcons.rocketLaunch,
                            color: Colors.white,
                            size: KSizes.iconM,
                          ),
                          KSizes.spacingHorizontalM,
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
  void _navigateToMainApp(BuildContext context) async {
    setState(() {
      _isNavigating = true;
    });
    
    // Add small delay for UX feedback
    await Future.delayed(Duration(milliseconds: 500));
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AppNavigation()),
        (route) => false,
      );
    }
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