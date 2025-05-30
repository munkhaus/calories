import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../food_logging/application/food_logging_notifier.dart';
import '../../food_logging/domain/user_food_log_model.dart';

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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
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
                      'Dagens måltider 🍽️',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      meals.isEmpty 
                          ? 'Ingen måltider endnu'
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
              GestureDetector(
                onTap: () => ref.read(foodLoggingProvider.notifier).refresh(),
                child: Container(
                  padding: const EdgeInsets.all(KSizes.margin2x),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(KSizes.radiusS),
                  ),
                  child: Icon(
                    MdiIcons.refresh,
                    color: AppColors.primary,
                    size: KSizes.iconS,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          // Meals list
          if (meals.isEmpty)
            _buildEmptyState(context)
          else
            Column(
              children: [
                Column(
                  children: meals
                      .take(3) // Show only first 3 meals
                      .map((meal) => _buildMealCard(context, ref, meal))
                      .toList(),
                ),
                
                const SizedBox(height: KSizes.margin3x),
                
                // Summary footer
                _buildSummaryFooter(context, meals),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KSizes.margin6x),
      child: Column(
        children: [
          Icon(
            MdiIcons.foodOff,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: KSizes.margin3x),
          Text(
            'Ingen måltider logget endnu',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: KSizes.margin1x),
          Text(
            'Start med at logge dit første måltid!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, WidgetRef ref, UserFoodLogModel meal) {
    return Dismissible(
      key: Key('meal_${meal.logEntryId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: KSizes.margin3x),
        padding: const EdgeInsets.all(KSizes.margin3x),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(KSizes.radiusM),
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
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmDialog(context, meal) ?? false;
      },
      onDismissed: (direction) {
        ref.read(foodLoggingProvider.notifier).deleteFood(meal.logEntryId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${meal.foodName} er slettet'),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Fortryd',
              textColor: Colors.white,
              onPressed: () {
                // Re-add the meal (in real app this would be an undo operation)
                ref.read(foodLoggingProvider.notifier).logFood(meal);
              },
            ),
          ),
        );
      },
      child: GestureDetector(
        onLongPress: () => _showMealOptionsMenu(context, ref, meal),
        child: Container(
          margin: const EdgeInsets.only(bottom: KSizes.margin3x),
          padding: const EdgeInsets.all(KSizes.margin3x),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(KSizes.radiusM),
            border: Border.all(
              color: AppColors.border.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Meal type icon
              Container(
                padding: const EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  color: _getMealTypeColor(meal.mealType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                ),
                child: Icon(
                  _getMealTypeIcon(meal.mealType),
                  color: _getMealTypeColor(meal.mealType),
                  size: KSizes.iconS,
                ),
              ),
              
              const SizedBox(width: KSizes.margin3x),
              
              // Food info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.foodName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: KSizes.fontWeightMedium,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          meal.mealType.mealTypeDisplayName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(color: AppColors.textTertiary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${meal.quantity.toStringAsFixed(meal.quantity % 1 == 0 ? 0 : 1)} ${meal.servingUnit}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Calories and actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${meal.calories}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: KSizes.fontWeightBold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: KSizes.margin2x),
              
              // Options button
              IconButton(
                onPressed: () => _showMealOptionsMenu(context, ref, meal),
                icon: Icon(
                  MdiIcons.dotsVertical,
                  color: AppColors.textTertiary,
                  size: KSizes.iconS,
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: KSizes.iconM,
                  minHeight: KSizes.iconM,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMealTypeIcon(MealType mealType) {
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

  Color _getMealTypeColor(MealType mealType) {
    switch (mealType) {
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

  Future<bool?> _showDeleteConfirmDialog(BuildContext context, UserFoodLogModel meal) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Slet ${meal.foodName}?'),
          content: Text('Er du sikker på, at du vil slette dette måltid?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Nej'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Ja'),
            ),
          ],
        );
      },
    );
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
                  final shouldDelete = await _showDeleteConfirmDialog(context, meal);
                  if (shouldDelete == true) {
                    ref.read(foodLoggingProvider.notifier).deleteFood(meal.logEntryId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${meal.foodName} er slettet'),
                        backgroundColor: AppColors.error,
                      ),
                    );
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
    // For now, show a simple dialog - in a real app this would navigate to an edit page
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rediger ${meal.foodName}'),
          content: Text('Edit funktionalitet kommer snart!\n\nDu kan foreløbig slette måltider og tilføje nye.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryFooter(BuildContext context, List<UserFoodLogModel> meals) {
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
                MdiIcons.food,
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
} 