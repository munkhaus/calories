import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/user_food_log_model.dart';

class MealTypeSelector extends StatelessWidget {
  final MealType selectedMealType;
  final Function(MealType) onMealTypeChanged;

  const MealTypeSelector({
    super.key,
    required this.selectedMealType,
    required this.onMealTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(KSizes.margin2x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: MealType.values.map((mealType) {
          final isSelected = mealType == selectedMealType;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: KSizes.margin1x),
              child: GestureDetector(
                onTap: () => onMealTypeChanged(mealType),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: KSizes.margin3x,
                    horizontal: KSizes.margin2x,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primary 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(KSizes.radiusS),
                    border: isSelected 
                        ? null
                        : Border.all(
                            color: AppColors.border.withOpacity(0.3),
                            width: 1,
                          ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getMealIcon(mealType),
                        color: isSelected 
                            ? AppColors.surface 
                            : AppColors.textSecondary,
                        size: KSizes.iconS,
                      ),
                      SizedBox(height: KSizes.margin1x),
                      Text(
                        _getMealDisplayName(mealType),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected 
                              ? AppColors.surface 
                              : AppColors.textSecondary,
                          fontWeight: isSelected 
                              ? KSizes.fontWeightMedium 
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getMealIcon(MealType mealType) {
    switch (mealType) {
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

  String _getMealDisplayName(MealType mealType) {
    switch (mealType) {
      case MealType.morgenmad:
        return 'Morgen';
      case MealType.frokost:
        return 'Frokost';
      case MealType.aftensmad:
        return 'Aften';
      case MealType.snack:
        return 'Snack';
    }
  }
} 