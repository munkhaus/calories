import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../application/food_database_cubit.dart';
import '../domain/food_record_model.dart';
import 'widgets/food_category_chips.dart';
import 'widgets/food_database_search_bar.dart';
import 'widgets/food_item_card.dart';
import 'widgets/food_edit_dialog.dart';

class FoodDatabasePage extends ConsumerStatefulWidget {
  const FoodDatabasePage({super.key});

  @override
  ConsumerState<FoodDatabasePage> createState() => _FoodDatabasePageState();
}

class _FoodDatabasePageState extends ConsumerState<FoodDatabasePage> {
  @override
  void initState() {
    super.initState();
    // Initialize when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(foodDatabaseProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foodDatabaseProvider);
    final cubit = ref.read(foodDatabaseProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mad Database'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: Icon(MdiIcons.refresh),
            onPressed: () => cubit.refresh(),
            tooltip: 'Opdater',
          ),
          IconButton(
            icon: Icon(MdiIcons.broom),
            onPressed: state.searchQuery.isNotEmpty || state.selectedCategory != null
                ? () => cubit.clearFilters()
                : null,
            tooltip: 'Ryd filtre',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "food_db_fab",
        onPressed: () => _showAddFoodDialog(context, cubit),
        backgroundColor: AppColors.primary,
        child: Icon(MdiIcons.plus),
        tooltip: 'Tilføj Mad',
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: Column(
          children: [
            // Search and filter section
            Container(
              margin: EdgeInsets.all(KSizes.margin4x),
              padding: EdgeInsets.all(KSizes.margin4x),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(KSizes.radiusL),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search bar
                  FoodDatabaseSearchBar(
                    value: state.searchQuery,
                    onChanged: cubit.setSearchQuery,
                  ),
                  SizedBox(height: KSizes.margin3x),
                  
                  // Category chips
                  FoodCategoryChips(
                    selectedCategory: state.selectedCategory,
                    onCategorySelected: cubit.setSelectedCategory,
                  ),
                ],
              ),
            ),

            // Content area
            Expanded(
              child: _buildContent(context, state, cubit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, state, FoodDatabaseCubit cubit) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.hasError) {
      return _buildEmptyState(
        icon: MdiIcons.databaseOff,
        title: 'Fejl ved indlæsning',
        subtitle: state.errorMessage.isNotEmpty ? state.errorMessage : 'Prøv igen senere',
        color: AppColors.error,
        actionText: 'Prøv igen',
        onAction: () => cubit.refresh(),
      );
    }

    final foods = state.filteredFoods;

    if (foods.isEmpty) {
      return _buildEmptyState(
        icon: state.searchQuery.isNotEmpty || state.selectedCategory != null
            ? MdiIcons.magnify
            : MdiIcons.foodOffOutline,
        title: state.searchQuery.isNotEmpty || state.selectedCategory != null
            ? 'Ingen mad fundet'
            : 'Ingen mad tilføjet endnu',
        subtitle: state.searchQuery.isNotEmpty || state.selectedCategory != null
            ? 'Prøv at justere dine søgetermer'
            : 'Tryk på + knappen for at tilføje din første mad',
        color: AppColors.primary,
        actionText: state.searchQuery.isNotEmpty || state.selectedCategory != null ? 'Ryd filtre' : null,
        onAction: state.searchQuery.isNotEmpty || state.selectedCategory != null 
            ? () => cubit.clearFilters() 
            : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(KSizes.margin4x),
      itemCount: foods.length,
      itemBuilder: (context, index) {
        final food = foods[index];
        return FoodItemCard(
          food: food,
          onTap: () => _showFoodDetails(context, food, cubit),
          onEdit: () => _showEditFoodDialog(context, food, cubit),
          onDelete: () => _showDeleteConfirmation(context, food, cubit),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin6x),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(KSizes.margin6x),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: color,
              ),
            ),
            SizedBox(height: KSizes.margin4x),
            Text(
              title,
              style: TextStyle(
                fontSize: KSizes.fontSizeL,
                color: AppColors.textPrimary,
                fontWeight: KSizes.fontWeightBold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: KSizes.margin2x),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: KSizes.fontSizeM,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              SizedBox(height: KSizes.margin4x),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
                child: Text(actionText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddFoodDialog(BuildContext context, FoodDatabaseCubit cubit) {
    cubit.startAddingFood();
    _showFoodEditDialog(context, cubit);
  }

  void _showEditFoodDialog(BuildContext context, FoodRecordModel food, FoodDatabaseCubit cubit) {
    cubit.startEditingFood(food);
    _showFoodEditDialog(context, cubit);
  }

  void _showFoodEditDialog(BuildContext context, FoodDatabaseCubit cubit) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FoodEditDialog(
        cubit: cubit,
        onSaved: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(cubit.state.isAddingFood ? 'Mad tilføjet!' : 'Mad opdateret!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
        onCancelled: () {
          cubit.cancelEditing();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showFoodDetails(BuildContext context, FoodRecordModel food, FoodDatabaseCubit cubit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusL),
        ),
        title: Row(
          children: [
            Text(food.category.emoji),
            SizedBox(width: KSizes.margin2x),
            Expanded(child: Text(food.name)),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (food.description.isNotEmpty) ...[
              Text(
                food.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: KSizes.margin4x),
            ],
            
            // Simple calories display
            Row(
              children: [
                Icon(MdiIcons.fire, color: Colors.orange, size: KSizes.iconM),
                SizedBox(width: KSizes.margin2x),
                Text(
                  '${food.caloriesPer100g} kalorier per 100g',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            if (food.servingSizes.isNotEmpty) ...[
              SizedBox(height: KSizes.margin4x),
              Text(
                'Portionsstørrelser:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: KSizes.margin2x),
              // Simple list format
              ...food.servingSizes.map((serving) => Padding(
                padding: EdgeInsets.only(bottom: KSizes.margin1x),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(serving.name),
                    Row(
                      children: [
                        Text('${serving.grams.toStringAsFixed(0)} g'),
                        if (serving.isDefault) ...[
                          SizedBox(width: KSizes.margin2x),
                          Text(
                            'Standard',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: KSizes.fontSizeXS,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Luk'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditFoodDialog(context, food, cubit);
            },
            child: const Text('Rediger'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showDeleteConfirmation(context, food, cubit);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Slet'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, FoodRecordModel food, FoodDatabaseCubit cubit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Slet mad'),
        content: Text('Er du sikker på at du vil slette "${food.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuller'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await cubit.deleteFood(food);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${food.name} slettet'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Slet'),
          ),
        ],
      ),
    );
  }
} 