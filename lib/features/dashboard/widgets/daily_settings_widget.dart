import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../onboarding/domain/user_profile_model.dart';

/// Compact widget for daily settings toggles
class DailySettingsWidget extends ConsumerWidget {
  const DailySettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final userProfile = onboardingState.userProfile;

    // Don't show if no new activity system
    if (userProfile.workActivityLevel == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin3x), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KSizes.radiusL), // Smaller radius
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.06), // Lighter shadow
            blurRadius: KSizes.blurRadiusM, // Smaller blur
            offset: const Offset(0, 2), // Smaller offset
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact header - just icon and title on one line
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin1x), // Much smaller padding
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1), // Simpler background
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                ),
                child: Icon(
                  MdiIcons.tune,
                  color: AppColors.info,
                  size: KSizes.iconS, // Smaller icon
                ),
              ),
              const SizedBox(width: KSizes.margin2x), // Less spacing
              Text(
                'Dagens indstillinger',
                style: TextStyle(
                  fontSize: KSizes.fontSizeL, // Smaller font
                  fontWeight: KSizes.fontWeightBold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: KSizes.margin3x), // Reduced spacing
          
          // Compact toggle sections
          Column(
            children: [
              _CompactWorkDayToggle(userProfile: userProfile),
              
              if (_shouldShowLeisureToggle(userProfile)) ...[
                const SizedBox(height: KSizes.margin2x), // Less spacing between toggles
                _CompactLeisureActivityToggle(userProfile: userProfile),
              ],
            ],
          ),
        ],
      ),
    );
  }

  bool _shouldShowLeisureToggle(UserProfileModel profile) {
    return profile.activityTrackingPreference != ActivityTrackingPreference.manual;
  }
}

/// Compact work day toggle
class _CompactWorkDayToggle extends ConsumerWidget {
  final UserProfileModel userProfile;

  const _CompactWorkDayToggle({required this.userProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingProvider.notifier);
    
    final isWorkDay = userProfile.useAutomaticWeekdayDetection 
        ? (DateTime.now().weekday >= 1 && DateTime.now().weekday <= 5)
        : userProfile.isCurrentlyWorkDay;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KSizes.margin3x,
        vertical: KSizes.margin2x, // Much less vertical padding
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.3), // Lighter background
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.border.withOpacity(0.15), // Lighter border
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Compact icon
          Icon(
            isWorkDay ? MdiIcons.briefcase : MdiIcons.home,
            color: isWorkDay ? AppColors.primary : AppColors.secondary,
            size: KSizes.iconS, // Smaller icon
          ),
          
          const SizedBox(width: KSizes.margin2x),
          
          // Compact text
          Expanded(
            child: Text(
              isWorkDay ? 'Arbejdsdag' : 'Hjemme/fridag',
              style: TextStyle(
                fontSize: KSizes.fontSizeM,
                fontWeight: KSizes.fontWeightSemiBold, // Slightly less bold
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          // Compact toggle switch
          GestureDetector(
            onTap: () {
              notifier.updateWeekdayDetection(false);
              notifier.updateCurrentWorkDayStatus(!isWorkDay);
            },
            child: Container(
              width: 40, // Smaller switch
              height: 24, // Smaller switch
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isWorkDay 
                    ? AppColors.primary 
                    : AppColors.border.withOpacity(0.4),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: isWorkDay ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20, // Smaller thumb
                  height: 20, // Smaller thumb
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact leisure activity toggle
class _CompactLeisureActivityToggle extends ConsumerWidget {
  final UserProfileModel userProfile;

  const _CompactLeisureActivityToggle({required this.userProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingProvider.notifier);
    final isLeisureEnabled = userProfile.isLeisureActivityEnabledToday;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KSizes.margin3x,
        vertical: KSizes.margin2x, // Much less vertical padding
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.3), // Lighter background
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.border.withOpacity(0.15), // Lighter border
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Compact icon
          Icon(
            isLeisureEnabled ? MdiIcons.run : MdiIcons.sleep,
            color: isLeisureEnabled ? AppColors.success : AppColors.textSecondary,
            size: KSizes.iconS, // Smaller icon
          ),
          
          const SizedBox(width: KSizes.margin2x),
          
          // Compact text
          Expanded(
            child: Text(
              isLeisureEnabled ? 'Fritidsaktivitet tæller' : 'Ingen fritidsaktivitet',
              style: TextStyle(
                fontSize: KSizes.fontSizeM,
                fontWeight: KSizes.fontWeightSemiBold, // Slightly less bold
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          // Compact toggle switch
          GestureDetector(
            onTap: () {
              notifier.updateLeisureActivityForToday(!isLeisureEnabled);
            },
            child: Container(
              width: 40, // Smaller switch
              height: 24, // Smaller switch
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isLeisureEnabled 
                    ? AppColors.success 
                    : AppColors.border.withOpacity(0.4),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: isLeisureEnabled ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20, // Smaller thumb
                  height: 20, // Smaller thumb
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 