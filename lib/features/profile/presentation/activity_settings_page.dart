import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../onboarding/domain/user_profile_model.dart';
import '../../onboarding/presentation/widgets/work_activity_step_widget.dart';
import '../../onboarding/presentation/widgets/leisure_activity_step_widget.dart';

/// Activity settings page using the same widgets as onboarding
class ActivitySettingsPage extends ConsumerStatefulWidget {
  const ActivitySettingsPage({super.key});

  @override
  ConsumerState<ActivitySettingsPage> createState() => _ActivitySettingsPageState();
}

class _ActivitySettingsPageState extends ConsumerState<ActivitySettingsPage> {
  int _currentStep = 0; // 0 = work activity, 1 = leisure activity

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final userProfile = state.userProfile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _currentStep == 0 ? 'Dit arbejde' : 'Din fritidsaktivitet',
          style: TextStyle(
            fontSize: KSizes.fontSizeXL,
            fontWeight: KSizes.fontWeightBold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        actions: [
          // Show step indicator
          Container(
            margin: EdgeInsets.only(right: KSizes.margin4x),
            child: Row(
              children: [
                // Step 1 indicator
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentStep == 0 ? AppColors.primary : AppColors.primary.withOpacity(0.3),
                  ),
                ),
                SizedBox(width: KSizes.margin1x),
                // Step 2 indicator
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentStep == 1 ? AppColors.primary : AppColors.primary.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / 2,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(KSizes.margin4x),
              child: _currentStep == 0 
                  ? const WorkActivityStepWidget()
                  : const LeisureActivityStepWidget(),
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: EdgeInsets.all(KSizes.margin4x),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Previous button
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _currentStep = 0;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: KSizes.margin4x),
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(KSizes.radiusM),
                        ),
                      ),
                      child: Text(
                        'Arbejde',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeM,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                
                if (_currentStep > 0) SizedBox(width: KSizes.margin4x),
                
                // Next button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentStep == 0) {
                        setState(() {
                          _currentStep = 1;
                        });
                      } else {
                        // Go back to profile page
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: KSizes.margin4x),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                      ),
                    ),
                    child: Text(
                      _currentStep == 0 ? 'Fritid' : 'Færdig',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        color: AppColors.background,
                        fontWeight: KSizes.fontWeightMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 