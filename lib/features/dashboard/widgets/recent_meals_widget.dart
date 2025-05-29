import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';

/// Widget showing recent meals with macro breakdown
class RecentMealsWidget extends ConsumerWidget {
  const RecentMealsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sample meal data matching the image exactly
    final meals = [
      _MealData(
        name: 'Havregrød med bær',
        mealType: 'Morgenmad',
        calories: 285,
        time: '08:30',
        protein: 12,
        carbs: 45,
        fat: 8,
        icon: MdiIcons.bowlMix,
        color: AppColors.success, // Green for breakfast
      ),
      _MealData(
        name: 'Kylling salat',
        mealType: 'Frokost',
        calories: 420,
        time: '12:15',
        protein: 35,
        carbs: 15,
        fat: 28,
        icon: MdiIcons.foodVariant,
        color: AppColors.info, // Teal for lunch
      ),
      _MealData(
        name: 'Æble',
        mealType: 'Snack',
        calories: 82,
        time: '15:30',
        protein: 0,
        carbs: 22,
        fat: 0,
        icon: MdiIcons.food,
        color: AppColors.warning, // Orange for snack
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin4x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                      ),
                      child: Icon(
                        MdiIcons.silverwareForkKnife,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Dagens måltider',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Se alle',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    color: AppColors.primary,
                    fontWeight: KSizes.fontWeightSemiBold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: KSizes.margin4x),
            
            // Meals list - Individual meal cards within the main container
            ...meals.asMap().entries.map((entry) {
              final index = entry.key;
              final meal = entry.value;
              return Column(
                children: [
                  _MealCard(meal: meal),
                  if (index < meals.length - 1) const SizedBox(height: KSizes.margin3x),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final _MealData meal;

  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KSizes.margin3x),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Main meal info
          Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: meal.color,
                  borderRadius: BorderRadius.circular(KSizes.radiusL),
                ),
                child: Icon(
                  meal.icon,
                  color: Colors.white,
                  size: KSizes.iconM,
                ),
              ),
              
              const SizedBox(width: KSizes.margin3x),
              
              // Meal details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          meal.mealType,
                          style: TextStyle(
                            fontSize: KSizes.fontSizeS,
                            color: meal.color,
                            fontWeight: KSizes.fontWeightSemiBold,
                          ),
                        ),
                        const SizedBox(width: KSizes.margin2x),
                        Text(
                          meal.time,
                          style: TextStyle(
                            fontSize: KSizes.fontSizeS,
                            color: AppColors.textSecondary,
                            fontWeight: KSizes.fontWeightMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meal.name,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Calories
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${meal.calories}',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeXL,
                      fontWeight: KSizes.fontWeightBold,
                      color: meal.color,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeS,
                      color: AppColors.textSecondary,
                      fontWeight: KSizes.fontWeightMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: KSizes.margin3x),
          
          // Macro cards
          Row(
            children: [
              Expanded(
                child: _MacroCard(
                  label: 'Protein',
                  value: '${meal.protein}g',
                  color: const Color(0xFFE8B4B8), // Light red/pink
                ),
              ),
              const SizedBox(width: KSizes.margin2x),
              Expanded(
                child: _MacroCard(
                  label: 'Kulhydrater',
                  value: '${meal.carbs}g',
                  color: const Color(0xFFF5E6A3), // Light yellow
                ),
              ),
              const SizedBox(width: KSizes.margin2x),
              Expanded(
                child: _MacroCard(
                  label: 'Fedt',
                  value: '${meal.fat}g',
                  color: const Color(0xFFB8D4E3), // Light blue
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: KSizes.margin2x,
        horizontal: KSizes.margin3x,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MealData {
  final String name;
  final String mealType;
  final int calories;
  final String time;
  final int protein;
  final int carbs;
  final int fat;
  final IconData icon;
  final Color color;

  _MealData({
    required this.name,
    required this.mealType,
    required this.calories,
    required this.time,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.icon,
    required this.color,
  });
} 