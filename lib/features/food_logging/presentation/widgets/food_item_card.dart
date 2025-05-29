import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/food_item_model.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItemModel foodItem;
  final VoidCallback? onTap;
  final bool showNutrition;

  const FoodItemCard({
    super.key,
    required this.foodItem,
    this.onTap,
    this.showNutrition = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shadowColor: AppColors.primary.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        child: Container(
          padding: EdgeInsets.all(KSizes.margin4x),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(KSizes.radiusM),
            border: Border.all(
              color: AppColors.border.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Food Icon
              Container(
                width: KSizes.iconL,
                height: KSizes.iconL,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                ),
                child: Icon(
                  _getFoodIcon(),
                  color: AppColors.primary,
                  size: KSizes.iconM,
                ),
              ),
              
              SizedBox(width: KSizes.margin3x),
              
              // Food Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      foodItem.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: KSizes.fontWeightMedium,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Brand (if available)
                    if (foodItem.brand.isNotEmpty) ...[
                      SizedBox(height: KSizes.margin1x),
                      Text(
                        foodItem.brand,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    // Nutrition Info
                    if (showNutrition) ...[
                      SizedBox(height: KSizes.margin2x),
                      Row(
                        children: [
                          _buildNutrientTag(
                            '${foodItem.caloriesPer100g.round()} kcal',
                            AppColors.primary,
                          ),
                          SizedBox(width: KSizes.margin2x),
                          _buildNutrientTag(
                            'P: ${foodItem.proteinPer100g.toStringAsFixed(1)}g',
                            AppColors.error,
                          ),
                          SizedBox(width: KSizes.margin2x),
                          _buildNutrientTag(
                            'K: ${foodItem.carbsPer100g.toStringAsFixed(1)}g',
                            AppColors.info,
                          ),
                        ],
                      ),
                    ],
                    
                    // Serving info
                    if (foodItem.servingSize > 0) ...[
                      SizedBox(height: KSizes.margin1x),
                      Text(
                        'Standard portion: ${foodItem.servingSize.round()}${foodItem.servingUnit}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Arrow
              Icon(
                MdiIcons.chevronRight,
                color: AppColors.textTertiary,
                size: KSizes.iconS,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: KSizes.margin2x,
        vertical: KSizes.margin1x,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusXS),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: KSizes.fontSizeXS,
          fontWeight: KSizes.fontWeightMedium,
          color: color,
        ),
      ),
    );
  }

  IconData _getFoodIcon() {
    final name = foodItem.name.toLowerCase();
    
    if (name.contains('banan') || name.contains('æble') || name.contains('frugt')) {
      return MdiIcons.food;
    } else if (name.contains('kylling') || name.contains('kød') || name.contains('laks')) {
      return MdiIcons.foodDrumstick;
    } else if (name.contains('ris') || name.contains('pasta') || name.contains('brød') || name.contains('gryn')) {
      return MdiIcons.grain;
    } else if (name.contains('grøntsag') || name.contains('broccoli') || name.contains('tomat')) {
      return MdiIcons.carrot;
    } else {
      return MdiIcons.food;
    }
  }
} 