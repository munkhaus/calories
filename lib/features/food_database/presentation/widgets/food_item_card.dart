import 'package:flutter/material.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/food_record_model.dart';
import '../../domain/online_food_models.dart';

class FoodItemCard extends StatelessWidget {
  final FoodRecordModel food;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const FoodItemCard({
    super.key,
    required this.food,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = FoodImageHelper.getFoodEmoji(food.name);
    final sourceEmoji = _getSourceEmoji();
    
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: KSizes.margin3x,
        vertical: KSizes.margin1x,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusL),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        child: Padding(
          padding: EdgeInsets.all(KSizes.margin3x),
          child: Row(
            children: [
              // Food emoji/image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: TextStyle(fontSize: 28),
                  ),
                ),
              ),
              
              SizedBox(width: KSizes.margin3x),
              
              // Food info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Food name
                    Text(
                      food.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: KSizes.margin1x),
                    
                    // Tags row
                    Wrap(
                      spacing: KSizes.margin1x,
                      runSpacing: KSizes.margin1x / 2,
                      children: [
                        // Source badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: KSizes.margin2x,
                            vertical: KSizes.margin1x / 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getSourceColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(KSizes.radiusS),
                            border: Border.all(
                              color: _getSourceColor().withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                sourceEmoji,
                                style: TextStyle(fontSize: 10),
                              ),
                              SizedBox(width: KSizes.margin1x / 2),
                              Text(
                                _getSourceText(),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: _getSourceColor(),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Category badge if available
                        if (food.category != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: KSizes.margin2x,
                              vertical: KSizes.margin1x / 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(KSizes.radiusS),
                            ),
                            child: Text(
                              _getCategoryText(food.category!),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions
              if (showActions) ...[
                SizedBox(width: KSizes.margin2x),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        onPressed: onEdit,
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        padding: EdgeInsets.all(KSizes.margin1x),
                        constraints: BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    if (onDelete != null)
                      IconButton(
                        onPressed: onDelete,
                        icon: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: AppColors.error,
                        ),
                        padding: EdgeInsets.all(KSizes.margin1x),
                        constraints: BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getSourceEmoji() {
    switch (food.source) {
      case FoodSource.userCreated:
        return '👤';
      case FoodSource.onlineDatabase:
        return '🌐';
      case FoodSource.imported:
        return '📥';
    }
  }

  String _getSourceText() {
    switch (food.source) {
      case FoodSource.userCreated:
        return 'Bruger';
      case FoodSource.onlineDatabase:
        return food.sourceProvider ?? 'Online';
      case FoodSource.imported:
        return 'Importeret';
    }
  }

  Color _getSourceColor() {
    switch (food.source) {
      case FoodSource.userCreated:
        return AppColors.primary;
      case FoodSource.onlineDatabase:
        return AppColors.success;
      case FoodSource.imported:
        return AppColors.warning;
    }
  }

  String _getCategoryText(FoodCategory category) {
    switch (category) {
      case FoodCategory.breakfast:
        return 'Morgenmad';
      case FoodCategory.lunch:
        return 'Frokost';
      case FoodCategory.dinner:
        return 'Aftensmad';
      case FoodCategory.snack:
        return 'Snack';
      case FoodCategory.dessert:
        return 'Dessert';
      case FoodCategory.drink:
        return 'Drikkevare';
      case FoodCategory.other:
        return 'Andet';
    }
  }
} 