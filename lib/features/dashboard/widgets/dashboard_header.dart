import 'package:flutter/material.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';

class DashboardHeader extends StatelessWidget {
  final String greeting;
  final String userName;
  final VoidCallback onInfoTap;
  final VoidCallback onRegistrationTap;

  const DashboardHeader({
    super.key,
    required this.greeting,
    required this.userName,
    required this.onInfoTap,
    required this.onRegistrationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusL),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $userName!',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeL,
                    fontWeight: KSizes.fontWeightBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: KSizes.margin1x),
                Text(
                  'Lad os spore din dag',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onInfoTap,
            icon: Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
} 