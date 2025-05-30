import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/onboarding_notifier.dart';
import '../../domain/user_profile_model.dart';

/// Step for selecting leisure activity level
class LeisureActivityStepWidget extends ConsumerWidget {
  const LeisureActivityStepWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    
    // Determine if leisure activity is enabled
    final bool isLeisureActivityEnabled = state.userProfile.activityTrackingPreference != ActivityTrackingPreference.manual;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Din fritidsaktivitet',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: KSizes.fontWeightBold,
            color: AppColors.textPrimary,
          ),
        ),
        
        SizedBox(height: KSizes.margin2x),
        
        Text(
          'Vil du angive et fast fritidsaktivitetsniveau?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        
        SizedBox(height: KSizes.margin6x),
        
        // Main toggle for leisure activity
        _buildToggleOption(
          context,
          notifier,
          isLeisureActivityEnabled,
          true, // This is the "Yes" option
          'Ja, jeg vil angive et fast niveau',
          'Vælg dit normale aktivitetsniveau i fritiden',
          MdiIcons.checkCircle,
          AppColors.primary,
        ),
        
        SizedBox(height: KSizes.margin4x),
        
        _buildToggleOption(
          context,
          notifier,
          isLeisureActivityEnabled,
          false, // This is the "No" option
          'Nej, jeg angiver selv aktiviteter manuelt',
          'Jeg vil angive mine aktiviteter dag for dag',
          MdiIcons.pencilOutline,
          AppColors.secondary,
        ),
        
        SizedBox(height: KSizes.margin8x),
        
        // Activity level options (disabled if leisure activity is turned off)
        if (isLeisureActivityEnabled) ...[
          Text(
            'Vælg dit fritidsaktivitetsniveau:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: KSizes.fontWeightSemiBold,
              color: AppColors.textPrimary,
            ),
          ),
          
          SizedBox(height: KSizes.margin6x),
        ],
        
        _buildActivityOption(
          context,
          notifier,
          state.userProfile.leisureActivityLevel,
          LeisureActivityLevel.sedentary,
          'Ikke aktiv',
          'Sidder hovedsageligt ned, ingen motion',
          MdiIcons.televisionClassic,
          AppColors.textSecondary,
          isLeisureActivityEnabled,
        ),
        
        SizedBox(height: KSizes.margin4x),
        
        _buildActivityOption(
          context,
          notifier,
          state.userProfile.leisureActivityLevel,
          LeisureActivityLevel.lightlyActive,
          'Let aktiv',
          'Lettere motion 1-3 gange om ugen',
          MdiIcons.walk,
          AppColors.primary,
          isLeisureActivityEnabled,
        ),
        
        SizedBox(height: KSizes.margin4x),
        
        _buildActivityOption(
          context,
          notifier,
          state.userProfile.leisureActivityLevel,
          LeisureActivityLevel.moderatelyActive,
          'Moderat aktiv',
          'Moderat motion 3-5 gange om ugen',
          MdiIcons.bike,
          AppColors.info,
          isLeisureActivityEnabled,
        ),
        
        SizedBox(height: KSizes.margin4x),
        
        _buildActivityOption(
          context,
          notifier,
          state.userProfile.leisureActivityLevel,
          LeisureActivityLevel.veryActive,
          'Meget aktiv',
          'Intens træning 6-7 gange om ugen',
          MdiIcons.dumbbell,
          AppColors.warning,
          isLeisureActivityEnabled,
        ),
        
        SizedBox(height: KSizes.margin4x),
        
        _buildActivityOption(
          context,
          notifier,
          state.userProfile.leisureActivityLevel,
          LeisureActivityLevel.extraActive,
          'Ekstremt aktiv',
          'Daglig hård træning eller fysisk job + træning',
          MdiIcons.weightLifter,
          AppColors.error,
          isLeisureActivityEnabled,
        ),
      ],
    );
  }

  Widget _buildToggleOption(
    BuildContext context,
    OnboardingNotifier notifier,
    bool currentEnabled,
    bool optionEnabled,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final bool isSelected = currentEnabled == optionEnabled;
    
    return GestureDetector(
      onTap: () {
        if (optionEnabled) {
          // Enable leisure activity - set to automatic tracking with default level
          notifier.updateActivityTrackingPreference(ActivityTrackingPreference.automatic);
          // Set a default leisure activity level if none is selected
          if (notifier.state.userProfile.leisureActivityLevel == null) {
            notifier.updateLeisureActivityLevel(LeisureActivityLevel.lightlyActive);
          }
        } else {
          // Disable leisure activity - set to manual tracking
          notifier.updateActivityTrackingPreference(ActivityTrackingPreference.manual);
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(KSizes.margin4x),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : AppColors.background,
                borderRadius: BorderRadius.circular(KSizes.radiusM),
              ),
              child: Icon(
                icon,
                color: isSelected ? color : AppColors.textSecondary,
                size: KSizes.iconM,
              ),
            ),
            
            SizedBox(width: KSizes.margin4x),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: KSizes.fontSizeM,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: KSizes.margin1x),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: KSizes.fontSizeS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              Icon(
                MdiIcons.checkCircle,
                color: color,
                size: KSizes.iconM,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityOption(
    BuildContext context,
    OnboardingNotifier notifier,
    LeisureActivityLevel? currentLevel,
    LeisureActivityLevel level,
    String title,
    String description,
    IconData icon,
    Color color,
    bool isEnabled,
  ) {
    final bool isSelected = currentLevel == level && isEnabled;
    final Color effectiveColor = isEnabled ? color : AppColors.textSecondary.withOpacity(0.5);
    final Color backgroundColor = isEnabled ? AppColors.surface : AppColors.background;
    final Color borderColor = isSelected ? effectiveColor : AppColors.border.withOpacity(isEnabled ? 1.0 : 0.5);
    
    return GestureDetector(
      onTap: isEnabled ? () {
        notifier.updateLeisureActivityLevel(level);
      } : null,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(KSizes.margin4x),
        decoration: BoxDecoration(
          color: isSelected ? effectiveColor.withOpacity(0.1) : backgroundColor,
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? effectiveColor.withOpacity(0.2) : AppColors.background,
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? effectiveColor : AppColors.textSecondary,
                  size: KSizes.iconM,
                ),
              ),
              
              SizedBox(width: KSizes.margin4x),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? effectiveColor : AppColors.textPrimary.withOpacity(isEnabled ? 1.0 : 0.5),
                      ),
                    ),
                    SizedBox(height: KSizes.margin1x),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS,
                        color: AppColors.textSecondary.withOpacity(isEnabled ? 1.0 : 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              
              if (isSelected && isEnabled)
                Icon(
                  MdiIcons.checkCircle,
                  color: effectiveColor,
                  size: KSizes.iconM,
                ),
            ],
          ),
        ),
      ),
    );
  }
} 