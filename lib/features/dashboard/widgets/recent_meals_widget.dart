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
                          fontSize: KSizes.fontSizeXXL,
                          fontWeight: KSizes.fontWeightBold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: KSizes.margin1x),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KSizes.margin3x,
                          vertical: KSizes.margin1x,
                        ),
                        decoration: BoxDecoration(
                          color: meals.isEmpty 
                              ? AppColors.textTertiary.withOpacity(0.1)
                              : AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(KSizes.radiusL),
                          border: Border.all(
                            color: meals.isEmpty 
                                ? AppColors.textTertiary.withOpacity(0.2)
                                : AppColors.success.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          meals.isEmpty 
                              ? 'Ingen måltider endnu'
                              : '${meals.length} ${meals.length == 1 ? 'måltid' : 'måltider'} logget',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeS,
                            color: meals.isEmpty 
                                ? AppColors.textTertiary
                                : AppColors.success,
                            fontWeight: KSizes.fontWeightSemiBold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildControlButton(
                  icon: MdiIcons.refresh,
                  onTap: () => ref.read(foodLoggingProvider.notifier).refresh(),
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
                        .take(3) // Show only first 3 meals
                        .map((meal) => _buildModernMealCard(context, ref, meal))
                        .toList(),
                  ),
                  
                  SizedBox(height: KSizes.margin6x),
                  
                  // Modern summary footer
                  _buildModernSummaryFooter(context, meals),
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          color: isPrimary ? Colors.white : AppColors.primary,
        ),
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
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmDialog(context, meal) ?? false;
      },
      onDismissed: (direction) {
        ref.read(foodLoggingProvider.notifier).deleteFood(meal.logEntryId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${meal.foodName} er slettet'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'Fortryd',
              textColor: Colors.white,
              onPressed: () {
                ref.read(foodLoggingProvider.notifier).logFood(meal);
              },
            ),
          ),
        );
      },
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
                    children: [
                      Expanded(
                        child: Text(
                          meal.foodName,
                          style: TextStyle(
                            fontSize: KSizes.fontSizeM,
                            fontWeight: KSizes.fontWeightSemiBold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KSizes.margin2x,
                          vertical: KSizes.margin1x,
                        ),
                        decoration: BoxDecoration(
                          color: _getMealColor(meal.mealType),
                          borderRadius: BorderRadius.circular(KSizes.radiusS),
                        ),
                        child: Text(
                          '${meal.calories} kcal',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeXS,
                            fontWeight: KSizes.fontWeightBold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: KSizes.margin1x),
                  
                  Row(
                    children: [
                      Text(
                        meal.mealType.mealTypeDisplayName,
                        style: TextStyle(
                          fontSize: KSizes.fontSizeS,
                          color: _getMealColor(meal.mealType),
                          fontWeight: KSizes.fontWeightMedium,
                        ),
                      ),
                      Text(
                        ' • ${meal.quantity} ${meal.servingUnit}',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeS,
                          color: AppColors.textSecondary,
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
    );
  }

  Widget _buildModernSummaryFooter(BuildContext context, List<UserFoodLogModel> meals) {
    final totalCalories = meals.fold(0, (sum, meal) => sum + meal.calories);
    final totalProtein = meals.fold(0.0, (sum, meal) => sum + meal.protein);
    
    return Container(
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Total kalorier',
              '$totalCalories kcal',
              MdiIcons.fire,
              AppColors.primary,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.border.withOpacity(0.3),
          ),
          Expanded(
            child: _buildSummaryItem(
              'Protein',
              '${totalProtein.toStringAsFixed(1)}g',
              MdiIcons.dumbbell,
              AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KSizes.margin3x),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin1x),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: KSizes.iconXS,
                ),
              ),
              const SizedBox(width: KSizes.margin2x),
              Text(
                value,
                style: TextStyle(
                  fontSize: KSizes.fontSizeL,
                  fontWeight: KSizes.fontWeightBold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: KSizes.margin1x),
          Text(
            label,
            style: TextStyle(
              fontSize: KSizes.fontSizeXS,
              color: AppColors.textSecondary,
              fontWeight: KSizes.fontWeightMedium,
            ),
            textAlign: TextAlign.center,
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
} 