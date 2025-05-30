import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/onboarding_notifier.dart';
import '../../domain/user_profile_model.dart';
import 'onboarding_base_layout.dart';

/// Step for selecting leisure activity level
class LeisureActivityStepWidget extends ConsumerWidget {
  const LeisureActivityStepWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    
    // Determine if leisure activity is enabled
    final bool isLeisureActivityEnabled = state.userProfile.activityTrackingPreference != ActivityTrackingPreference.manual;

    return OnboardingBaseLayout(
      title: '🏃‍♂️ Hvor aktiv er du i fritiden?',
      subtitle: 'Vælg dit normale aktivitetsniveau eller manuel registrering',
      children: [
        // Activity tracking preference section
        OnboardingSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OnboardingSectionHeader(
                icon: Icons.settings_outlined,
                title: 'Hvordan vil du tracke aktivitet?',
                subtitle: 'Fast niveau eller dag-for-dag registrering?',
                iconColor: AppColors.primary,
              ),
              
              KSizes.spacingVerticalL,
              
              // Activity tracking toggle options with consistent primary color
              OnboardingOptionCard(
                title: 'Fast aktivitetsniveau',
                description: 'Vælg dit normale aktivitetsniveau i fritiden',
                icon: MdiIcons.checkCircle,
                color: AppColors.primary,
                isSelected: isLeisureActivityEnabled,
                onTap: () {
                  notifier.updateActivityTrackingPreference(ActivityTrackingPreference.automatic);
                  // Set a default leisure activity level if none is selected
                  if (notifier.state.userProfile.leisureActivityLevel == null) {
                    notifier.updateLeisureActivityLevel(LeisureActivityLevel.lightlyActive);
                  }
                },
              ),
              
              KSizes.spacingVerticalM,
              
              OnboardingOptionCard(
                title: 'Manuel registrering',
                description: 'Jeg vil angive mine aktiviteter dag for dag',
                icon: MdiIcons.pencilOutline,
                color: AppColors.primary,
                isSelected: !isLeisureActivityEnabled,
                onTap: () {
                  notifier.updateActivityTrackingPreference(ActivityTrackingPreference.manual);
                },
              ),
            ],
          ),
        ),
        
        // Activity level options (disabled if leisure activity is turned off)
        if (isLeisureActivityEnabled) ...[
          KSizes.spacingVerticalL,
          
          OnboardingSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OnboardingSectionHeader(
                  icon: Icons.fitness_center,
                  title: 'Vælg dit aktivitetsniveau',
                  subtitle: 'Dit typiske niveau i en uge.',
                  iconColor: AppColors.primary,
                ),
                
                KSizes.spacingVerticalL,
                
                // Activity level cards with consistent primary color
                OnboardingOptionCard(
                  title: 'Ikke aktiv',
                  description: 'Sidder hovedsageligt ned, ingen motion',
                  icon: MdiIcons.televisionClassic,
                  color: AppColors.primary,
                  isSelected: state.userProfile.leisureActivityLevel == LeisureActivityLevel.sedentary,
                  onTap: () => notifier.updateLeisureActivityLevel(LeisureActivityLevel.sedentary),
                ),
                
                KSizes.spacingVerticalM,
                
                OnboardingOptionCard(
                  title: 'Let aktiv',
                  description: 'Lettere motion 1-3 gange om ugen',
                  icon: MdiIcons.walk,
                  color: AppColors.primary,
                  isSelected: state.userProfile.leisureActivityLevel == LeisureActivityLevel.lightlyActive,
                  onTap: () => notifier.updateLeisureActivityLevel(LeisureActivityLevel.lightlyActive),
                ),
                
                KSizes.spacingVerticalM,
                
                OnboardingOptionCard(
                  title: 'Moderat aktiv',
                  description: 'Moderat motion 3-5 gange om ugen',
                  icon: MdiIcons.bike,
                  color: AppColors.primary,
                  isSelected: state.userProfile.leisureActivityLevel == LeisureActivityLevel.moderatelyActive,
                  onTap: () => notifier.updateLeisureActivityLevel(LeisureActivityLevel.moderatelyActive),
                ),
                
                KSizes.spacingVerticalM,
                
                OnboardingOptionCard(
                  title: 'Meget aktiv',
                  description: 'Intens træning 6-7 gange om ugen',
                  icon: MdiIcons.dumbbell,
                  color: AppColors.primary,
                  isSelected: state.userProfile.leisureActivityLevel == LeisureActivityLevel.veryActive,
                  onTap: () => notifier.updateLeisureActivityLevel(LeisureActivityLevel.veryActive),
                ),
                
                KSizes.spacingVerticalM,
                
                OnboardingOptionCard(
                  title: 'Ekstremt aktiv',
                  description: 'Daglig hård træning eller fysisk job + træning',
                  icon: MdiIcons.weightLifter,
                  color: AppColors.primary,
                  isSelected: state.userProfile.leisureActivityLevel == LeisureActivityLevel.extraActive,
                  onTap: () => notifier.updateLeisureActivityLevel(LeisureActivityLevel.extraActive),
                ),
              ],
            ),
          ),
        ],
        
        KSizes.spacingVerticalL,
        
        // Information help text
        OnboardingHelpText(
          text: isLeisureActivityEnabled 
              ? 'Dit aktivitetsniveau kombineres med dit arbejde for det samlede kalorieforbrug.'
              : 'Du kan registrere aktiviteter dag for dag i appen.',
          icon: Icons.info_outline,
          color: AppColors.info,
        ),
      ],
    );
  }
} 