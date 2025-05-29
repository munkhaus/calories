import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';

/// Placeholder logging page
class LoggingPage extends ConsumerWidget {
  const LoggingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Log mad'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(KSizes.margin6x),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                MdiIcons.plus,
                size: 80,
                color: AppColors.textTertiary,
              ),
              KSizes.spacingVerticalL,
              Text(
                'Mad-logning kommer snart',
                style: TextStyle(
                  fontSize: KSizes.fontSizeXL,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              KSizes.spacingVerticalM,
              Text(
                'Her vil du kunne logge dine måltider via søgning, stregkodescanning eller kamera.',
                style: TextStyle(
                  fontSize: KSizes.fontSizeM,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 