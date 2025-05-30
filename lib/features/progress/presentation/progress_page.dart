import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../info/presentation/info_page.dart';

/// Placeholder progress page
class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fremgang'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const InfoPage(),
                ),
              );
            },
            icon: Icon(
              MdiIcons.informationOutline,
              color: AppColors.info,
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(KSizes.margin6x),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                MdiIcons.chartLine,
                size: 80,
                color: AppColors.textTertiary,
              ),
              KSizes.spacingVerticalL,
              Text(
                'Fremgangsvisning kommer snart',
                style: TextStyle(
                  fontSize: KSizes.fontSizeXL,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              KSizes.spacingVerticalM,
              Text(
                'Her vil du kunne se din udvikling over tid med grafer og indsigter.',
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