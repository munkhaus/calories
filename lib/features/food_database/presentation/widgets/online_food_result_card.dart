import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/online_food_models.dart';

class OnlineFoodResultCard extends StatelessWidget {
  final OnlineFoodResult foodResult;
  final VoidCallback? onTap;
  final bool isSelected;
  final VoidCallback? onSelectionToggle;
  final bool showSelection;

  const OnlineFoodResultCard({
    super.key,
    required this.foodResult,
    this.onTap,
    this.isSelected = false,
    this.onSelectionToggle,
    this.showSelection = false,
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
              color: isSelected 
                  ? AppColors.primary 
                  : AppColors.border.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
            color: isSelected 
                ? AppColors.primary.withOpacity(0.05) 
                : null,
          ),
          child: Row(
            children: [
              // Selection checkbox (if enabled)
              if (showSelection) ...[
                Container(
                  width: 20,
                  height: 20,
                  margin: EdgeInsets.only(right: KSizes.margin3x),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: isSelected
                      ? Icon(
                          MdiIcons.check,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
                ),
              ],
              
              // Food Icon
              Container(
                width: KSizes.iconXL,
                height: KSizes.iconXL,
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
                      foodResult.name,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: KSizes.margin1x),
                    
                    // Description
                    Text(
                      foodResult.description,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: KSizes.margin2x),
                    
                    // Search mode indicator and calories
                    Row(
                      children: [
                        // Search mode indicator
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: KSizes.margin2x,
                            vertical: KSizes.margin1x,
                          ),
                          decoration: BoxDecoration(
                            color: _getSearchModeColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(KSizes.radiusS),
                            border: Border.all(
                              color: _getSearchModeColor().withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getSearchModeIcon(),
                                size: KSizes.iconXS,
                                color: _getSearchModeColor(),
                              ),
                              SizedBox(width: KSizes.margin1x),
                              Text(
                                _getSearchModeText(),
                                style: TextStyle(
                                  fontSize: KSizes.fontSizeXS,
                                  fontWeight: FontWeight.w600,
                                  color: _getSearchModeColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(width: KSizes.margin2x),
                        
                        // Estimated calories (if available)
                        if (foodResult.estimatedCalories > 0)
                          _buildNutrientTag(
                            '${foodResult.estimatedCalories.round()} kcal',
                            AppColors.primary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Arrow (only if not in selection mode)
              if (!showSelection) ...[
                SizedBox(width: KSizes.margin2x),
                Icon(
                  MdiIcons.chevronRight,
                  color: AppColors.textTertiary,
                  size: KSizes.iconS,
                ),
              ],
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

  Widget _buildFoodTypeTag(FoodType type) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: KSizes.margin2x,
        vertical: KSizes.margin1x,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusXS),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            type.emoji,
            style: TextStyle(fontSize: KSizes.fontSizeXS),
          ),
          SizedBox(width: KSizes.margin1x),
          Text(
            type.displayName,
            style: TextStyle(
              fontSize: KSizes.fontSizeXS,
              fontWeight: KSizes.fontWeightMedium,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFoodIcon() {
    final name = foodResult.name.toLowerCase();
    
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

  Color _getSearchModeColor() {
    switch (foodResult.searchMode) {
      case SearchMode.dishes:
        return Colors.orange;
      case SearchMode.ingredients:
        return Colors.green;
    }
  }

  IconData _getSearchModeIcon() {
    switch (foodResult.searchMode) {
      case SearchMode.dishes:
        return MdiIcons.food;
      case SearchMode.ingredients:
        return MdiIcons.carrot;
    }
  }

  String _getSearchModeText() {
    switch (foodResult.searchMode) {
      case SearchMode.dishes:
        return 'Ret';
      case SearchMode.ingredients:
        return 'Fødevare';
    }
  }
} 