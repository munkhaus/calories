import 'package:flutter/material.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';

class TodaysActivitiesWidget extends StatelessWidget {
  const TodaysActivitiesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dagens Aktiviteter',
            style: TextStyle(
              fontSize: KSizes.fontSizeL,
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: KSizes.margin2x),
          Text(
            'Her vil dagens aktiviteter blive vist',
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
} 