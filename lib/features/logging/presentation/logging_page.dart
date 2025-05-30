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
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(KSizes.margin4x),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildSectionHeader(context, 'Vælg måltidstype'),
                
                const SizedBox(height: KSizes.margin6x),
                
                // Meal type selection cards
                Expanded(
                  child: ListView(
                    children: MealType.values.map((mealType) {
                      return _buildMealTypeCard(context, mealType);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
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
    );
  }

  Widget _buildMealTypeCard(BuildContext context, MealType mealType) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.2),
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
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: KSizes.iconXL,
                height: KSizes.iconXL,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  _getIconForMealType(mealType),
                  color: AppColors.primary,
                  size: KSizes.iconL,
                ),
              ),
              SizedBox(width: KSizes.margin4x),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTitleForMealType(mealType),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: KSizes.margin1x),
                    Text(
                      _getSubtitleForMealType(mealType),
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

  IconData _getIconForMealType(MealType mealType) {
    switch (mealType) {
      case MealType.morgenmad:
        return MdiIcons.weatherSunny;
      case MealType.frokost:
        return MdiIcons.sunCompass;
      case MealType.aftensmad:
        return MdiIcons.weatherNight;
      case MealType.snack:
        return MdiIcons.star;
      default:
        throw Exception("Unknown meal type");
    }
  }

  String _getTitleForMealType(MealType mealType) {
    switch (mealType) {
      case MealType.morgenmad:
        return 'Morgenmad';
      case MealType.frokost:
        return 'Frokost';
      case MealType.aftensmad:
        return 'Aftensmad';
      case MealType.snack:
        return 'Snack';
      default:
        throw Exception("Unknown meal type");
    }
  }

  String _getSubtitleForMealType(MealType mealType) {
    switch (mealType) {
      case MealType.morgenmad:
        return 'Start dagen godt';
      case MealType.frokost:
        return 'Energi til resten af dagen';
      case MealType.aftensmad:
        return 'Afslut dagen lækkert';
      case MealType.snack:
        return 'Lille mellemmåltid';
      default:
        throw Exception("Unknown meal type");
    }
  }
} 