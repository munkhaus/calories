import 'package:flutter/material.dart';
import '../../core/constants/k_sizes.dart';
import '../../core/theme/app_theme.dart';

/// Custom progress indicator widget for onboarding
class ProgressIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressIndicatorWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: KSizes.margin4x),
      child: Column(
        children: [
          Row(
            children: List.generate(
              totalSteps,
              (index) => Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: KSizes.margin1x),
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: index <= currentStep
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: KSizes.margin2x),
          Text(
            'Trin ${currentStep + 1} af $totalSteps',
            style: TextStyle(
              fontSize: KSizes.fontSizeS,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 