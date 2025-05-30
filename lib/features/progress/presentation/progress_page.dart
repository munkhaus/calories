import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../info/presentation/info_page.dart';

/// Progress page showing user's development over time
class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(KSizes.margin4x),
              child: Column(
                children: [
                  // Header with new design
                  StandardPageHeader(
                    title: 'Din udvikling 📈',
                    subtitle: 'Hold styr på dine fremskridt og mål over tid',
                    icon: MdiIcons.chartLine,
                    iconColor: AppColors.info,
                    onInfoTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const InfoPage(),
                        ),
                      );
                    },
                  ),
                  
                  KSizes.spacingVerticalXL,
                  
                  // Coming soon section
                  _buildComingSoonSection(context),
                  
                  KSizes.spacingVerticalXL,
                  
                  // Feature preview section
                  _buildFeaturePreviewSection(context),
                  
                  // Bottom padding
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComingSoonSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin6x),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: KSizes.blurRadiusL,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Large icon
          Container(
            padding: const EdgeInsets.all(KSizes.margin6x),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.info,
                  AppColors.info.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(KSizes.radiusXL),
              boxShadow: [
                BoxShadow(
                  color: AppColors.info.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              MdiIcons.chartLineVariant,
              size: 60,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          Text(
            'Fremgangsvisning kommer snart',
            style: TextStyle(
              fontSize: KSizes.fontSizeXXL,
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: KSizes.margin4x),
          
          Text(
            'Vi arbejder på at udvikle omfattende fremgangsrapporter, så du kan følge din udvikling over tid.',
            style: TextStyle(
              fontSize: KSizes.fontSizeL,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePreviewSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: KSizes.blurRadiusL,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary,
                      AppColors.secondary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  MdiIcons.lightbulbOnOutline,
                  color: Colors.white,
                  size: KSizes.iconL,
                ),
              ),
              const SizedBox(width: KSizes.margin4x),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kommende funktioner',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Disse features er planlagt til fremtidige opdateringer',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          // Feature list
          ..._featureList.map((feature) => _buildFeatureItem(feature)).toList(),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(_FeatureItem feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KSizes.margin4x),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(KSizes.margin2x),
            decoration: BoxDecoration(
              color: feature.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(KSizes.radiusS),
            ),
            child: Icon(
              feature.icon,
              color: feature.color,
              size: KSizes.iconM,
            ),
          ),
          const SizedBox(width: KSizes.margin3x),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    fontWeight: KSizes.fontWeightMedium,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  feature.description,
                  style: TextStyle(
                    fontSize: KSizes.fontSizeS,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static final List<_FeatureItem> _featureList = [
    _FeatureItem(
      icon: MdiIcons.chartLine,
      title: 'Vægtudvikling',
      description: 'Visualiser din vægtudvikling over tid med interaktive grafer',
      color: AppColors.primary,
    ),
    _FeatureItem(
      icon: MdiIcons.fire,
      title: 'Kalorie tendenser',
      description: 'Se mønstre i dit kalorie indtag og forbrug',
      color: AppColors.warning,
    ),
    _FeatureItem(
      icon: MdiIcons.runFast,
      title: 'Aktivitets statistik',
      description: 'Analysér dine trænings- og aktivitetsmønstre',
      color: AppColors.secondary,
    ),
    _FeatureItem(
      icon: MdiIcons.target,
      title: 'Mål opfølgning',
      description: 'Følg din fremgang mod dine personlige mål',
      color: AppColors.success,
    ),
    _FeatureItem(
      icon: MdiIcons.trendingUp,
      title: 'Fremskridt indsigter',
      description: 'Få personlige anbefalinger baseret på dine data',
      color: AppColors.info,
    ),
  ];
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
} 