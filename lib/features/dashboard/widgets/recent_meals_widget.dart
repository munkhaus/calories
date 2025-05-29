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
        color: Colors.white,
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                        fontWeight: FontWeight.w700,
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: KSizes.margin4x),
            
            // Meals list - Fixed height for exactly 3 rows
            ...meals.map((meal) => Padding(
              padding: const EdgeInsets.only(bottom: KSizes.margin3x),
              child: _MealCard(meal: meal),
            )).toList(),
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
        color: AppColors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(
          color: AppColors.surface.withOpacity(0.5),
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: meal.color,
                  borderRadius: BorderRadius.circular(KSizes.radiusL),
                ),
                child: Icon(
                  meal.icon,
                  color: Colors.white,
                  size: 28,
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: KSizes.margin2x),
                        Text(
                          meal.time,
                          style: TextStyle(
                            fontSize: KSizes.fontSizeS,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meal.name,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: FontWeight.w700,
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
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeS,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
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
                  label: 'P',
                  value: '${meal.protein}g',
                  color: const Color(0xFFE8B4B8), // Light red/pink
                ),
              ),
              const SizedBox(width: KSizes.margin2x),
              Expanded(
                child: _MacroCard(
                  label: 'K',
                  value: '${meal.carbs}g',
                  color: const Color(0xFFF5E6A3), // Light yellow
                ),
              ),
              const SizedBox(width: KSizes.margin2x),
              Expanded(
                child: _MacroCard(
                  label: 'F',
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: KSizes.fontSizeS,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              fontWeight: FontWeight.w700,
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