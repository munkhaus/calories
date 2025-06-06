import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../food_logging/application/food_logging_notifier.dart';
import '../../food_logging/application/pending_food_cubit.dart';
import '../../food_logging/domain/pending_food_model.dart';
import '../../food_logging/domain/user_food_log_model.dart';
import '../../food_logging/presentation/pages/edit_meal_page.dart';
import '../../food_logging/presentation/pages/categorize_food_page.dart';
import '../../food_logging/presentation/pages/pending_food_selection_page.dart';
import '../../food_logging/presentation/pages/food_search_page.dart';
import '../../food_logging/presentation/pages/favorites_page.dart';
import 'dart:io';

/// Widget showing today's logged meals
class RecentMealsWidget extends ConsumerWidget {
  const RecentMealsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(todaysMealsProvider);
    final isLoading = ref.watch(isLoadingMealsProvider);
    final error = ref.watch(mealsErrorProvider);

    if (isLoading) {
      return _buildLoadingCard();
    }

    if (error != null) {
      return _buildErrorCard(context, ref, error);
    }

    return _buildMealsCard(context, ref, meals);
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 200,
      decoration: AppDesign.sectionDecoration,
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, WidgetRef ref, String error) {
    return Container(
      decoration: AppDesign.sectionDecoration,
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin4x),
        child: Column(
          children: [
            Icon(
              MdiIcons.alertCircle,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: KSizes.margin3x),
            Text(
              'Fejl ved indlæsning af måltider',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: KSizes.margin2x),
            ElevatedButton(
              onPressed: () => ref.read(foodLoggingProvider.notifier).refresh(),
              child: Text('Prøv igen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealsCard(BuildContext context, WidgetRef ref, List<UserFoodLogModel> meals) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: KSizes.blurRadiusXL,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin6x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modern header
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.secondary,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: KSizes.blurRadiusL,
                        offset: KSizes.shadowOffsetM,
                      ),
                    ],
                  ),
                  child: Icon(
                    MdiIcons.silverwareForkKnife,
                    color: Colors.white,
                    size: KSizes.iconL,
                  ),
                ),
                const SizedBox(width: KSizes.margin4x),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dagens måltider',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeXL,
                          fontWeight: KSizes.fontWeightBold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: KSizes.margin1x),
                      Text(
                        meals.isEmpty 
                            ? 'Klik på et måltid for at redigere'
                            : '${meals.length} ${meals.length == 1 ? 'måltid' : 'måltider'} logget',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeM,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: KSizes.margin8x),
            
            // Meals content
            if (meals.isEmpty)
              _buildEmptyState(context)
            else
              Column(
                children: [
                  Column(
                    children: meals
                        .map((meal) => _buildModernMealCard(context, ref, meal))
                        .toList(),
                  ),
                  
                  SizedBox(height: KSizes.margin6x),
                  
                  // Simple total footer like activities
                  _buildTotalSummaryFooter(context, meals),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
    int? count,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: isPrimary 
                  ? LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    )
                  : null,
              color: isPrimary ? null : AppColors.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(KSizes.radiusM),
              border: Border.all(
                color: isPrimary 
                    ? Colors.transparent 
                    : AppColors.border.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: isPrimary ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Icon(
              icon,
              size: KSizes.iconS,
              color: isPrimary ? Colors.white : AppColors.warning,
            ),
          ),
          if (count != null && count > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                constraints: BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KSizes.margin8x),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              MdiIcons.foodOff,
              size: 40,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: KSizes.margin4x),
          Text(
            'Ingen måltider logget endnu',
            style: TextStyle(
              fontSize: KSizes.fontSizeL,
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: KSizes.margin2x),
          Text(
            'Start med at logge dit første måltid for at se fremgang her!',
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              color: AppColors.textTertiary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernMealCard(BuildContext context, WidgetRef ref, UserFoodLogModel meal) {
    return Dismissible(
      key: Key('meal_${meal.logEntryId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: KSizes.margin3x),
        padding: const EdgeInsets.all(KSizes.margin4x),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.error.withOpacity(0.8), AppColors.error],
          ),
          borderRadius: BorderRadius.circular(KSizes.radiusL),
        ),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              MdiIcons.delete,
              color: Colors.white,
              size: KSizes.iconM,
            ),
            const SizedBox(width: KSizes.margin2x),
            Text(
              'Slet',
              style: TextStyle(
                color: Colors.white,
                fontSize: KSizes.fontSizeM,
                fontWeight: KSizes.fontWeightBold,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        ref.read(foodLoggingProvider.notifier).deleteFood(meal.logEntryId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${meal.foodName} er slettet'),
            backgroundColor: AppColors.success,
          ),
        );
      },
      child: GestureDetector(
        onLongPress: () => _showMealOptionsMenu(context, ref, meal),
        onTap: () => _showMealOptionsMenu(context, ref, meal),
        child: Container(
          margin: const EdgeInsets.only(bottom: KSizes.margin3x),
          padding: const EdgeInsets.all(KSizes.margin4x),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getMealColor(meal.mealType).withOpacity(0.05),
                _getMealColor(meal.mealType).withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(KSizes.radiusL),
            border: Border.all(
              color: _getMealColor(meal.mealType).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Meal type icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getMealColor(meal.mealType),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  _getMealIcon(meal.mealType),
                  color: Colors.white,
                  size: KSizes.iconM,
                ),
              ),
              
              const SizedBox(width: KSizes.margin4x),
              
              // Meal info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            meal.foodName,
                            style: TextStyle(
                              fontSize: KSizes.fontSizeM,
                              fontWeight: KSizes.fontWeightMedium,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: KSizes.margin2x),
                        Flexible(
                          flex: 2,
                          child: Text(
                            '${meal.calories.round()} kcal',
                            style: TextStyle(
                              fontSize: KSizes.fontSizeM,
                              fontWeight: KSizes.fontWeightBold,
                              color: AppColors.primary,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: KSizes.margin1x),
                    
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                          meal.mealType.mealTypeDisplayName,
                          style: TextStyle(
                            fontSize: KSizes.fontSizeS,
                            color: _getMealColor(meal.mealType),
                            fontWeight: KSizes.fontWeightMedium,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                          ' • ${meal.quantity} ${meal.servingUnit}',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeS,
                            color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalSummaryFooter(BuildContext context, List<UserFoodLogModel> meals) {
    final totalCalories = meals.fold(0, (sum, meal) => sum + meal.calories);
    
    return Container(
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                MdiIcons.fire,
                color: AppColors.primary,
                size: KSizes.iconM,
              ),
              const SizedBox(width: KSizes.margin2x),
              Text(
                'Total spist i dag',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: KSizes.fontWeightBold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            '$totalCalories kcal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMealColor(MealType mealType) {
    switch (mealType) {
      case MealType.morgenmad:
        return AppColors.warning;
      case MealType.frokost:
        return AppColors.primary;
      case MealType.aftensmad:
        return AppColors.secondary;
      case MealType.snack:
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  IconData _getMealIcon(MealType mealType) {
    switch (mealType) {
      case MealType.morgenmad:
        return MdiIcons.weatherSunny;
      case MealType.frokost:
        return MdiIcons.weatherPartlyCloudy;
      case MealType.aftensmad:
        return MdiIcons.weatherNight;
      case MealType.snack:
        return MdiIcons.cookie;
      default:
        return MdiIcons.silverwareForkKnife;
    }
  }

  void _showMealOptionsMenu(BuildContext context, WidgetRef ref, UserFoodLogModel meal) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KSizes.radiusL)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(KSizes.margin4x),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Text(
                meal.foodName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: KSizes.margin4x),
              
              // Edit option
              ListTile(
                leading: Icon(MdiIcons.pencil, color: AppColors.primary),
                title: Text('Rediger måltid'),
                subtitle: Text('Ændre mængde eller måltidstype'),
                onTap: () {
                  Navigator.pop(context);
                  _editMeal(context, ref, meal);
                },
              ),
              
              // Delete option  
              ListTile(
                leading: Icon(MdiIcons.delete, color: AppColors.error),
                title: Text('Slet måltid'),
                subtitle: Text('Fjern måltid fra dagens log'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    ref.read(foodLoggingProvider.notifier).deleteFood(meal.logEntryId);
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(MdiIcons.check, color: Colors.white),
                              SizedBox(width: KSizes.margin2x),
                              Expanded(
                                child: Text('${meal.foodName} slettet!'),
                              ),
                            ],
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(MdiIcons.alertCircle, color: Colors.white),
                              SizedBox(width: KSizes.margin2x),
                              Expanded(
                                child: Text('Fejl ved sletning af måltid'),
                              ),
                            ],
                          ),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
              ),
              
              // Cancel
              const SizedBox(height: KSizes.margin2x),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Annuller'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editMeal(BuildContext context, WidgetRef ref, UserFoodLogModel meal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMealPage(meal: meal),
      ),
    );
  }

  void _navigateToPendingFoods(BuildContext context, WidgetRef ref) async {
    print('🍎 RecentMealsWidget: _navigateToPendingFoods called');
    
    final pendingState = ref.read(pendingFoodProvider);
    final pendingFoods = pendingState.pendingFoods;
    print('🍎 RecentMealsWidget: Found ${pendingFoods.length} pending foods');
    
    if (pendingFoods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ingen ventende registreringer fundet'),
          backgroundColor: AppColors.info,
        ),
      );
      return;
    }
    
    try {
      // If only one pending food, go directly to categorization
      if (pendingFoods.length == 1) {
        final selectedFood = pendingFoods.first;
        print('🍎 RecentMealsWidget: Only one pending food, navigating directly to CategorizeFoodPage');
        
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CategorizeFoodPage(
              pendingFood: selectedFood,
            ),
          ),
        );
        
        // Refresh data after categorization
        await ref.read(pendingFoodProvider.notifier).loadPendingFoods();
        return;
      }
      
      // Multiple pending foods - navigate to selection page (NOT dialog!)
      print('🍎 RecentMealsWidget: Multiple pending foods, navigating to PendingFoodSelectionPage');
      
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PendingFoodSelectionPage(
            pendingFoods: pendingFoods,
          ),
        ),
      );
      
      print('🍎 RecentMealsWidget: Returned from PendingFoodSelectionPage');
      
      // Refresh data after categorization
      await ref.read(pendingFoodProvider.notifier).loadPendingFoods();
      
    } catch (e) {
      print('🍎 RecentMealsWidget: Error in _navigateToPendingFoods: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fejl ved åbning af kategorisering: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _captureQuickFood(BuildContext context, WidgetRef ref) async {
    try {
      // Use existing capture logic from dashboard
      // This would open camera and create pending food item
      print('🍎 Quick food capture initiated');
      // You would implement camera capture here
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fejl ved billede optagelse: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
} 