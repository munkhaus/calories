import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/app_option_card.dart';
import '../../food_logging/domain/user_food_log_model.dart';
import '../../food_logging/presentation/pages/food_search_page.dart';
import '../../info/presentation/info_page.dart';

/// Main food logging page with meal type selection
class LoggingPage extends ConsumerWidget {
  const LoggingPage({super.key});

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
                    title: 'Tid til at logge! 🍽️',
                    subtitle: 'Vælg hvilken type måltid du vil registrere',
                    icon: MdiIcons.silverwareForkKnife,
                    iconColor: AppColors.primary,
                    onInfoTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const InfoPage(),
                        ),
                      );
                    },
                  ),
                  
                  KSizes.spacingVerticalXL,
                  
                  // Meal type selection with new design
                  Container(
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
                        // Section header
                        Text(
                          'Vælg måltidstype',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeXL,
                            fontWeight: KSizes.fontWeightBold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        
                        const SizedBox(height: KSizes.margin2x),
                        
                        Text(
                          'Hvilken type måltid vil du registrere i dag?',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeM,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                        
                        const SizedBox(height: KSizes.margin6x),
                        
                        // Meal type cards
                        ...MealType.values.map((mealType) {
                          return AppOptionCard(
                            title: _getTitleForMealType(mealType),
                            subtitle: _getSubtitleForMealType(mealType),
                            icon: _getIconForMealType(mealType),
                            iconColor: _getColorForMealType(mealType),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AddFoodPage(initialMealType: mealType),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  
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

  IconData _getIconForMealType(MealType mealType) {
    switch (mealType) {
      case MealType.none:
        return MdiIcons.help;
      case MealType.morgenmad:
        return MdiIcons.weatherSunny;
      case MealType.frokost:
        return MdiIcons.sunCompass;
      case MealType.aftensmad:
        return MdiIcons.weatherNight;
      case MealType.snack:
        return MdiIcons.star;
    }
  }

  Color _getColorForMealType(MealType mealType) {
    switch (mealType) {
      case MealType.none:
        return AppColors.textSecondary;
      case MealType.morgenmad:
        return AppColors.warning;
      case MealType.frokost:
        return AppColors.primary;
      case MealType.aftensmad:
        return AppColors.secondary;
      case MealType.snack:
        return AppColors.info;
    }
  }

  String _getTitleForMealType(MealType mealType) {
    switch (mealType) {
      case MealType.none:
        return 'Ingen kategori';
      case MealType.morgenmad:
        return 'Morgenmad';
      case MealType.frokost:
        return 'Frokost';
      case MealType.aftensmad:
        return 'Aftensmad';
      case MealType.snack:
        return 'Snack';
    }
  }

  String _getSubtitleForMealType(MealType mealType) {
    switch (mealType) {
      case MealType.none:
        return 'Vælg en kategori senere';
      case MealType.morgenmad:
        return 'Start dagen godt med en nærrende morgenmad';
      case MealType.frokost:
        return 'Energi til resten af dagen';
      case MealType.aftensmad:
        return 'Afslut dagen med et godt måltid';
      case MealType.snack:
        return 'Lille bid mellem måltiderne';
    }
  }
} 