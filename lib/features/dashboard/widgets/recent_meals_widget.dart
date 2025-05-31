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
                
                // Pending foods indicator
                Consumer(
                  builder: (context, ref, child) {
                    final pendingState = ref.watch(pendingFoodProvider);
                    final pendingCount = pendingState.pendingFoodsState.data?.length ?? 0;
                    
                    if (pendingCount == 0) return const SizedBox.shrink();
                    
                    return _buildControlButton(
                      icon: MdiIcons.clockOutline,
                      onTap: () => _navigateToPendingFoods(context, ref),
                      isPrimary: false,
                      count: pendingCount,
                    );
                  },
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
      child: GestureDetector(
        onLongPress: () => _showMealOptionsMenu(context, ref, meal),
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMealPage(meal: meal),
      ),
    );
  }

  void _navigateToPendingFoods(BuildContext context, WidgetRef ref) {
    try {
      final pendingFoods = ref.read(pendingFoodProvider).pendingFoodsState.data ?? [];
      print('🍎 RecentMealsWidget: Found ${pendingFoods.length} pending foods');
      
      if (pendingFoods.isEmpty) {
        print('🍎 RecentMealsWidget: No pending foods to show');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ingen ventende registreringer fundet'),
            backgroundColor: AppColors.info,
          ),
        );
        return;
      }
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Consumer(
          builder: (context, ref, child) {
            final pendingState = ref.watch(pendingFoodProvider);
            final currentPendingFoods = pendingState.pendingFoodsState.data ?? [];
            
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(KSizes.radiusXL),
                  topRight: Radius.circular(KSizes.radiusXL),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.symmetric(vertical: KSizes.margin3x),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: KSizes.margin4x),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(KSizes.radiusM),
                          ),
                          child: Icon(
                            MdiIcons.camera,
                            color: Colors.white,
                            size: KSizes.iconM,
                          ),
                        ),
                        SizedBox(width: KSizes.margin3x),
                        Expanded(
                          child: Text(
                            'Ventende mad-billeder',
                            style: TextStyle(
                              fontSize: KSizes.fontSizeXL,
                              fontWeight: KSizes.fontWeightBold,
                            ),
                          ),
                        ),
                        if (currentPendingFoods.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: KSizes.margin3x,
                              vertical: KSizes.margin2x,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(KSizes.radiusM),
                            ),
                            child: Text(
                              '${currentPendingFoods.length}',
                              style: TextStyle(
                                color: AppColors.warning,
                                fontWeight: KSizes.fontWeightBold,
                                fontSize: KSizes.fontSizeM,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: KSizes.margin4x),
                  
                  // Content
                  Expanded(
                    child: pendingState.isLoadingPendingFoods
                        ? _buildPopupLoadingState()
                        : pendingState.hasPendingFoodsError
                            ? _buildPopupErrorState(context, ref)
                            : currentPendingFoods.isEmpty
                                ? _buildPopupEmptyState()
                                : _buildPopupPendingFoodsList(context, ref, currentPendingFoods),
                  ),
                  
                  // Actions
                  if (currentPendingFoods.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(KSizes.margin4x),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.5),
                        border: Border(
                          top: BorderSide(
                            color: AppColors.border.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: KSizes.margin3x),
                              ),
                              child: Text('Luk'),
                            ),
                          ),
                          SizedBox(width: KSizes.margin3x),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CategorizeFoodPage(
                                      pendingFood: currentPendingFoods.first,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.warning,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: KSizes.margin3x),
                              ),
                              child: Text('Kategoriser alle'),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      );
    } catch (e) {
      print('🍎 RecentMealsWidget: Error in _navigateToPendingFoods: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fejl ved åbning af ventende registreringer'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildPopupLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin8x),
        child: CircularProgressIndicator(
          color: AppColors.warning,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildPopupErrorState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(KSizes.margin4x),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          border: Border.all(
            color: AppColors.error.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              MdiIcons.alertCircle,
              color: AppColors.error,
              size: KSizes.iconL,
            ),
            SizedBox(height: KSizes.margin2x),
            Text(
              'Kunne ikke indlæse afventende billeder',
              style: TextStyle(
                color: AppColors.error,
                fontSize: KSizes.fontSizeM,
                fontWeight: KSizes.fontWeightMedium,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: KSizes.margin3x),
            ElevatedButton(
              onPressed: () => ref.read(pendingFoodProvider.notifier).retryLoadPendingFoods(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: Text('Prøv igen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin6x),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              MdiIcons.cameraOutline,
              size: KSizes.iconXXL,
              color: AppColors.warning,
            ),
            SizedBox(height: KSizes.margin4x),
            Text(
              'Ingen afventende billeder',
              style: TextStyle(
                fontSize: KSizes.fontSizeXL,
                fontWeight: KSizes.fontWeightBold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: KSizes.margin2x),
            Text(
              'Tag et billede af din mad og kategoriser det senere når du har tid',
              style: TextStyle(
                fontSize: KSizes.fontSizeM,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupPendingFoodsList(BuildContext context, WidgetRef ref, List<PendingFoodModel> pendingFoods) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: KSizes.margin4x),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: pendingFoods.length,
        itemBuilder: (context, index) {
          final food = pendingFoods[index];
          return _buildPopupPendingFoodCard(context, ref, food);
        },
      ),
    );
  }

  Widget _buildPopupPendingFoodCard(BuildContext context, WidgetRef ref, PendingFoodModel food) {
    return Container(
      margin: const EdgeInsets.only(bottom: KSizes.margin3x),
      padding: const EdgeInsets.all(KSizes.margin3x),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image placeholder with image count indicator
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                  border: Border.all(
                    color: AppColors.border.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: food.hasValidImage && !food.primaryImagePath.startsWith('mock_')
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(KSizes.radiusS),
                        child: Image.file(
                          File(food.primaryImagePath),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              MdiIcons.imageOff,
                              color: AppColors.textSecondary,
                              size: KSizes.iconM,
                            );
                          },
                        ),
                      )
                    : Icon(
                        MdiIcons.image,
                        color: AppColors.textSecondary,
                        size: KSizes.iconM,
                      ),
              ),
              
              // Image count indicator
              if (food.imageCount > 1)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        '${food.imageCount}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          SizedBox(width: KSizes.margin3x),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.imageCount > 1 ? 'Måltid (${food.imageCount} billeder)' : 'Mad-billede',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    fontWeight: KSizes.fontWeightMedium,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: KSizes.margin1x),
                Text(
                  food.displayTime,
                  style: TextStyle(
                    fontSize: KSizes.fontSizeS,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Categorize button
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close popup first
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CategorizeFoodPage(pendingFood: food),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: KSizes.margin3x,
                vertical: KSizes.margin2x,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KSizes.radiusM),
              ),
            ),
            child: Text(
              'Kategoriser',
              style: TextStyle(
                fontSize: KSizes.fontSizeS,
                fontWeight: KSizes.fontWeightMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 