import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/online_food_models.dart';

class OnlineFoodDetailView extends StatelessWidget {
  final OnlineFoodDetails foodDetails;
  final VoidCallback? onAddToDatabase;
  final VoidCallback? onClose;
  final bool isLoading;

  const OnlineFoodDetailView({
    super.key,
    required this.foodDetails,
    this.onAddToDatabase,
    this.onClose,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppDesign.primaryGradient,
        borderRadius: BorderRadius.circular(KSizes.radiusL),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        child: Padding(
          padding: EdgeInsets.all(KSizes.margin4x),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and close button
              Row(
                children: [
                  Icon(
                    MdiIcons.foodApple,
                    color: Colors.white,
                    size: KSizes.iconM,
                  ),
                  SizedBox(width: KSizes.margin2x),
                  Expanded(
                    child: Text(
                      'Madvareinformation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: KSizes.fontSizeL,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: Icon(
                      Icons.close,
                      color: Colors.white.withOpacity(0.8),
                      size: KSizes.iconM,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: KSizes.margin3x),
              
              // Food name only
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(KSizes.margin4x),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food icon and name
                    Row(
                      children: [
                        Icon(
                          MdiIcons.silverwareForkKnife,
                          color: Colors.white,
                          size: KSizes.iconL,
                        ),
                        SizedBox(width: KSizes.margin2x),
                        Expanded(
                          child: Text(
                            foodDetails.basicInfo.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: KSizes.fontSizeXL,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    if (foodDetails.basicInfo.description.isNotEmpty) ...[
                      SizedBox(height: KSizes.margin1x),
                      Text(
                        foodDetails.basicInfo.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: KSizes.fontSizeS,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    
                    SizedBox(height: KSizes.margin3x),
                    
                    // Calories per 100g
                    Row(
                      children: [
                        Icon(
                          MdiIcons.fire,
                          color: Colors.orange,
                          size: KSizes.iconM,
                        ),
                        SizedBox(width: KSizes.margin1x),
                        Text(
                          '${foodDetails.nutrition.calories.round()} kalorier per 100g',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: KSizes.fontSizeL,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    
                    if (foodDetails.servingSizes.isNotEmpty) ...[
                      SizedBox(height: KSizes.margin4x),
                      
                      // Portion sizes title
                      Text(
                        'Portionsstørrelser:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: KSizes.fontSizeL,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      SizedBox(height: KSizes.margin2x),
                      
                      // Portion sizes list
                      ...foodDetails.servingSizes.map((serving) {
                        final calories = ((serving.grams / 100) * foodDetails.nutrition.calories).round();
                        return Padding(
                          padding: EdgeInsets.only(bottom: KSizes.margin1x),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  serving.name,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: KSizes.fontSizeM,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                '${serving.grams.round()} g',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: KSizes.fontSizeM,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (serving.isDefault) ...[
                                SizedBox(width: KSizes.margin1x),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: KSizes.margin1x,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(KSizes.radiusS),
                                  ),
                                  child: Text(
                                    'Standard',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: KSizes.fontSizeXS,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
              
              SizedBox(height: KSizes.margin4x),
              
              // Action buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onClose,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        padding: EdgeInsets.symmetric(vertical: KSizes.margin3x),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(KSizes.radiusM),
                        ),
                      ),
                      child: Text(
                        'Annuller',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeM,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: KSizes.margin3x),
                  
                  // Add button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onAddToDatabase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: KSizes.margin3x),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(KSizes.radiusM),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  MdiIcons.plus,
                                  size: KSizes.iconS,
                                ),
                                SizedBox(width: KSizes.margin1x),
                                Text(
                                  'Tilføj til favoritter',
                                  style: TextStyle(
                                    fontSize: KSizes.fontSizeM,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 