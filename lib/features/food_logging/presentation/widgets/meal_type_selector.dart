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
    // Get only real meal types (exclude 'none')
    final availableMealTypes = MealType.values.where((type) => type != MealType.none).toList();
    
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
      child: Column(
        children: [
          // Show current selection if it's 'none'
          if (selectedMealType == MealType.none) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(KSizes.margin3x),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(KSizes.radiusS),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    MdiIcons.alertCircle,
                    color: AppColors.warning,
                    size: KSizes.iconS,
                  ),
                  SizedBox(width: KSizes.margin2x),
                  Text(
                    'Vælg en måltidskategori',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontWeight: KSizes.fontWeightMedium,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: KSizes.margin2x),
          ],
          
          // Meal type buttons
          Row(
            children: availableMealTypes.map((mealType) {
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
        ],
      ),
    );
  }

  IconData _getMealIcon(MealType mealType) {
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

  String _getMealDisplayName(MealType mealType) {
    switch (mealType) {
      case MealType.none:
        return 'Ingen';
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