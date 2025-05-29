import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../food_logging/domain/user_food_log_model.dart';
import '../../food_logging/presentation/pages/food_search_page.dart';

/// Main food logging page with meal type selection
class LoggingPage extends ConsumerWidget {
  const LoggingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Log måltid',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: KSizes.fontWeightBold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(KSizes.margin4x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(KSizes.margin4x),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(KSizes.radiusL),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(KSizes.margin3x),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(KSizes.radiusM),
                    ),
                    child: Icon(
                      MdiIcons.silverwareForkKnife,
                      color: AppColors.surface,
                      size: KSizes.iconM,
                    ),
                  ),
                  SizedBox(width: KSizes.margin4x),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tid til at logge!',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: KSizes.fontWeightBold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: KSizes.margin1x),
                        Text(
                          'Vælg hvilken type måltid du vil logge',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: KSizes.margin6x),

            // Meal Type Cards
            Text(
              'Vælg måltidstype',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: KSizes.fontWeightBold,
                color: AppColors.textPrimary,
              ),
            ),
            
            SizedBox(height: KSizes.margin4x),
            
            _buildMealTypeCard(
              context,
              MealType.morgenmad,
              'Morgenmad',
              'Start dagen godt',
              MdiIcons.weatherSunny,
              AppColors.warning,
            ),
            
            SizedBox(height: KSizes.margin3x),
            
            _buildMealTypeCard(
              context,
              MealType.frokost,
              'Frokost',
              'Energi til resten af dagen',
              MdiIcons.sunCompass,
              AppColors.primary,
            ),
            
            SizedBox(height: KSizes.margin3x),
            
            _buildMealTypeCard(
              context,
              MealType.aftensmad,
              'Aftensmad',
              'Afslut dagen lækkert',
              MdiIcons.weatherNight,
              AppColors.secondary,
            ),
            
            SizedBox(height: KSizes.margin3x),
            
            _buildMealTypeCard(
              context,
              MealType.snack,
              'Snack',
              'Lille mellemmåltid',
              MdiIcons.star,
              AppColors.info,
            ),

            SizedBox(height: KSizes.margin6x),

            // Quick Actions
            Text(
              'Hurtige handlinger',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: KSizes.fontWeightBold,
                color: AppColors.textPrimary,
              ),
            ),
            
            SizedBox(height: KSizes.margin4x),
            
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    context,
                    'Tag foto',
                    'Scan din mad med kameraet',
                    MdiIcons.camera,
                    AppColors.success,
                    () {
                      // TODO: Implement camera functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Kamera-funktionen kommer snart'),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: KSizes.margin3x),
                Expanded(
                  child: _buildQuickActionCard(
                    context,
                    'Scan kode',
                    'Stregkode scanning',
                    MdiIcons.qrcodeScan,
                    AppColors.error,
                    () {
                      // TODO: Implement barcode scanning
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Stregkode-scanner kommer snart'),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeCard(
    BuildContext context,
    MealType mealType,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.2),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FoodSearchPage(initialMealType: mealType),
            ),
          );
        },
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        child: Container(
          padding: EdgeInsets.all(KSizes.margin4x),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(KSizes.radiusM),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: KSizes.iconXL,
                height: KSizes.iconXL,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: KSizes.iconL,
                ),
              ),
              SizedBox(width: KSizes.margin4x),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: KSizes.margin1x),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                MdiIcons.chevronRight,
                color: AppColors.textTertiary,
                size: KSizes.iconM,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        child: Container(
          padding: EdgeInsets.all(KSizes.margin4x),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(KSizes.radiusM),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: KSizes.iconXL,
                height: KSizes.iconXL,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: KSizes.iconL,
                ),
              ),
              SizedBox(height: KSizes.margin3x),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: KSizes.fontWeightBold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: KSizes.margin1x),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 