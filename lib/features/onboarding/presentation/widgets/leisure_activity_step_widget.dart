import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/k_sizes.dart';
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
      title: 'Hvor aktiv er du i fritiden?',
      subtitle: 'Vælg dit normale aktivitetsniveau eller manuel registrering',
      children: [
        // Activity tracking preference section
        OnboardingSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OnboardingSectionHeader(
                title: 'Hvordan vil du tracke aktivitet?',
                subtitle: 'Fast niveau eller dag-for-dag registrering?',
              ),
              
              KSizes.spacingVerticalL,
              
              // Activity tracking toggle options - simplified
              OnboardingOptionCard(
                title: 'Fast aktivitetsniveau',
                description: 'Vælg dit normale aktivitetsniveau i fritiden',
                isSelected: isLeisureActivityEnabled,
                onTap: () {
                  notifier.updateActivityTrackingPreference(ActivityTrackingPreference.automatic);
                  // Set a default leisure activity level if none is selected
                  if (state.userProfile.leisureActivityLevel == null) {
                    notifier.updateLeisureActivityLevel(LeisureActivityLevel.lightlyActive);
                  }
                },
              ),
              
              OnboardingOptionCard(
                title: 'Manuel registrering',
                description: 'Jeg vil angive mine aktiviteter dag for dag',
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
                  title: 'Vælg dit aktivitetsniveau',
                  subtitle: 'Dit typiske niveau i en uge.',
                ),
                
                KSizes.spacingVerticalL,
                
                // Activity level cards - simplified without icons
                OnboardingOptionCard(
                  title: 'Ikke aktiv',
                  description: 'Sidder hovedsageligt ned, ingen motion',
                  isSelected: state.userProfile.leisureActivityLevel == LeisureActivityLevel.sedentary,
                  onTap: () => notifier.updateLeisureActivityLevel(LeisureActivityLevel.sedentary),
                ),
                
                OnboardingOptionCard(
                  title: 'Let aktiv',
                  description: 'Lettere motion 1-3 gange om ugen',
                  isSelected: state.userProfile.leisureActivityLevel == LeisureActivityLevel.lightlyActive,
                  onTap: () => notifier.updateLeisureActivityLevel(LeisureActivityLevel.lightlyActive),
                ),
                
                OnboardingOptionCard(
                  title: 'Moderat aktiv',
                  description: 'Moderat motion 3-5 gange om ugen',
                  isSelected: state.userProfile.leisureActivityLevel == LeisureActivityLevel.moderatelyActive,
                  onTap: () => notifier.updateLeisureActivityLevel(LeisureActivityLevel.moderatelyActive),
                ),
                
                OnboardingOptionCard(
                  title: 'Meget aktiv',
                  description: 'Intens træning 6-7 gange om ugen',
                  isSelected: state.userProfile.leisureActivityLevel == LeisureActivityLevel.veryActive,
                  onTap: () => notifier.updateLeisureActivityLevel(LeisureActivityLevel.veryActive),
                ),
                
                OnboardingOptionCard(
                  title: 'Ekstremt aktiv',
                  description: 'Daglig hård træning eller fysisk job + træning',
                  isSelected: state.userProfile.leisureActivityLevel == LeisureActivityLevel.extraActive,
                  onTap: () => notifier.updateLeisureActivityLevel(LeisureActivityLevel.extraActive),
                ),
              ],
            ),
          ),
        ],
        
        KSizes.spacingVerticalL,
        
        // Simplified information help text
        OnboardingHelpText(
          text: isLeisureActivityEnabled 
              ? 'Dit aktivitetsniveau kombineres med dit arbejde for det samlede kalorieforbrug.'
              : 'Du kan registrere aktiviteter dag for dag i appen.',
          type: OnboardingHelpType.neutral,
        ),
      ],
    );
  }
} 