import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/favorite_food_model.dart';
import '../../domain/user_food_log_model.dart';
import '../../infrastructure/favorite_food_service.dart';
import '../../application/food_logging_notifier.dart';

/// Page for selecting and editing favorites before logging them
class SelectFavoritePage extends ConsumerStatefulWidget {
  const SelectFavoritePage({super.key});

  @override
  ConsumerState<SelectFavoritePage> createState() => _SelectFavoritePageState();
}

class _SelectFavoritePageState extends ConsumerState<SelectFavoritePage> {
  final FavoriteFoodService _favoriteFoodService = FavoriteFoodService();
  List<FavoriteFoodModel> _favorites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _favoriteFoodService.getAllFavorites();
      if (result.isSuccess) {
        setState(() {
          _favorites = result.success;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Kunne ikke indlæse favoritter';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Der opstod en fejl: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Vælg Favorit'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: KSizes.fontSizeL,
          fontWeight: KSizes.fontWeightBold,
        ),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: KSizes.margin4x),
            Text(
              'Indlæser favoritter...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: KSizes.fontSizeM,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MdiIcons.alertCircle,
              size: 64,
              color: AppColors.error,
            ),
            SizedBox(height: KSizes.margin4x),
            Text(
              _error!,
              style: TextStyle(
                color: AppColors.error,
                fontSize: KSizes.fontSizeM,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: KSizes.margin4x),
            ElevatedButton(
              onPressed: _loadFavorites,
              child: Text('Prøv igen'),
            ),
          ],
        ),
      );
    }

    if (_favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MdiIcons.starOutline,
              size: 64,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: KSizes.margin4x),
            Text(
              'Ingen favoritter endnu',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: KSizes.fontSizeL,
                fontWeight: KSizes.fontWeightBold,
              ),
            ),
            SizedBox(height: KSizes.margin2x),
            Text(
              'Gem noget mad som favorit først ved at markere "Gem som favorit" checkbox når du kategoriserer mad.',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: KSizes.fontSizeM,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header info
        Container(
          margin: EdgeInsets.all(KSizes.margin4x),
          padding: EdgeInsets.all(KSizes.margin4x),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(KSizes.radiusM),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                MdiIcons.informationOutline,
                color: AppColors.info,
              ),
              SizedBox(width: KSizes.margin2x),
              Expanded(
                child: Text(
                  'Vælg en favorit for at redigere og logge den',
                  style: TextStyle(
                    color: AppColors.info,
                    fontSize: KSizes.fontSizeS,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Favorites list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: KSizes.margin4x),
            itemCount: _favorites.length,
            itemBuilder: (context, index) {
              final favorite = _favorites[index];
              return _buildFavoriteCard(favorite);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteCard(FavoriteFoodModel favorite) {
    return Container(
      margin: EdgeInsets.only(bottom: KSizes.margin3x),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusM),
        ),
        child: InkWell(
          onTap: () => _selectFavorite(favorite),
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          child: Padding(
            padding: EdgeInsets.all(KSizes.margin4x),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(KSizes.margin3x),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(KSizes.radiusS),
                  ),
                  child: Icon(
                    MdiIcons.star,
                    color: AppColors.warning,
                    size: KSizes.iconM,
                  ),
                ),

                SizedBox(width: KSizes.margin3x),

                // Food details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        favorite.foodName,
                        style: TextStyle(
                          fontSize: KSizes.fontSizeM,
                          fontWeight: KSizes.fontWeightBold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: KSizes.margin1x),
                      Row(
                        children: [
                          Text(
                            '${favorite.defaultServingCalories} kcal',
                            style: TextStyle(
                              fontSize: KSizes.fontSizeS,
                              color: AppColors.primary,
                              fontWeight: KSizes.fontWeightMedium,
                            ),
                          ),
                          Text(
                            ' • ',
                            style: TextStyle(color: AppColors.textTertiary),
                          ),
                          Text(
                            favorite.mealTypeDisplayName,
                            style: TextStyle(
                              fontSize: KSizes.fontSizeS,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: KSizes.margin1x),
                      Text(
                        '${favorite.defaultQuantity} ${favorite.defaultServingUnit} • Brugt ${favorite.usageCount} gange',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeXS,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Icon(
                  MdiIcons.chevronRight,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectFavorite(FavoriteFoodModel favorite) {
    // Navigate to edit page or show edit dialog
    _showEditFavoriteDialog(favorite);
  }

  void _showEditFavoriteDialog(FavoriteFoodModel favorite) {
    showDialog(
      context: context,
      builder: (context) => _EditFavoriteDialog(
        favorite: favorite,
        onConfirm: (editedFavorite) => _logFavorite(editedFavorite),
      ),
    );
  }

  Future<void> _logFavorite(FavoriteFoodModel favorite) async {
    try {
      // Convert to UserFoodLogModel and log it
      final foodLog = favorite.toUserFoodLog();
      await ref.read(foodLoggingProvider.notifier).logFood(foodLog);

      // Update favorite usage statistics
      final updatedFavorite = favorite.withUpdatedUsage();
      await _favoriteFoodService.updateFavorite(updatedFavorite);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${favorite.foodName} blev logget!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(); // Go back to home page
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved logging: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Dialog for editing a favorite before logging
class _EditFavoriteDialog extends StatefulWidget {
  final FavoriteFoodModel favorite;
  final Function(FavoriteFoodModel) onConfirm;

  const _EditFavoriteDialog({
    required this.favorite,
    required this.onConfirm,
  });

  @override
  State<_EditFavoriteDialog> createState() => _EditFavoriteDialogState();
}

class _EditFavoriteDialogState extends State<_EditFavoriteDialog> {
  late TextEditingController _foodNameController;
  late TextEditingController _caloriesController;
  late TextEditingController _quantityController;
  late MealType _selectedMealType;

  @override
  void initState() {
    super.initState();
    _foodNameController = TextEditingController(text: widget.favorite.foodName);
    _caloriesController = TextEditingController(text: widget.favorite.defaultServingCalories.toString());
    _quantityController = TextEditingController(text: widget.favorite.defaultQuantity.toString());
    _selectedMealType = widget.favorite.preferredMealType;
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rediger ${widget.favorite.foodName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Food name
            TextField(
              controller: _foodNameController,
              decoration: InputDecoration(
                labelText: 'Navn på mad',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: KSizes.margin3x),

            // Calories
            TextField(
              controller: _caloriesController,
              decoration: InputDecoration(
                labelText: 'Kalorier',
                border: OutlineInputBorder(),
                suffixText: 'kcal',
              ),
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: KSizes.margin3x),

            // Quantity
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Mængde',
                border: OutlineInputBorder(),
                suffixText: widget.favorite.defaultServingUnit,
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),

            SizedBox(height: KSizes.margin3x),

            // Meal type
            DropdownButtonFormField<MealType>(
              value: _selectedMealType,
              decoration: InputDecoration(
                labelText: 'Måltid',
                border: OutlineInputBorder(),
              ),
              items: MealType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getMealTypeDisplayName(type)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMealType = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Annuller'),
        ),
        ElevatedButton(
          onPressed: _saveChanges,
          child: Text('Log Mad'),
        ),
      ],
    );
  }

  void _saveChanges() {
    final calories = int.tryParse(_caloriesController.text.trim());
    final quantity = double.tryParse(_quantityController.text.trim());

    if (_foodNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Angiv venligst navn på maden'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (calories == null || calories < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Angiv venligst gyldige kalorier'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Angiv venligst gyldig mængde'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Create updated favorite
    final caloriesPer100g = (calories * 100 / widget.favorite.defaultServingGrams).round();
    final updatedFavorite = widget.favorite.copyWith(
      foodName: _foodNameController.text.trim(),
      caloriesPer100g: caloriesPer100g,
      defaultQuantity: quantity,
      preferredMealType: _selectedMealType,
    );

    Navigator.of(context).pop();
    widget.onConfirm(updatedFavorite);
  }

  String _getMealTypeDisplayName(MealType type) {
    switch (type) {
      case MealType.none:
        return 'Ingen kategori';
      case MealType.morgenmad:
        return 'Morgenmad';
      case MealType.frokost:
        return 'Frokost';
      case MealType.aftensmad:
        return 'Aftensmad';
      case MealType.snack:
        return 'Snack';
    }
  }
} 