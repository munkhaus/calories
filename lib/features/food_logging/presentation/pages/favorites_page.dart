import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/favorite_food_model.dart';
import '../../domain/user_food_log_model.dart';
import '../../infrastructure/favorite_food_service.dart';
import '../../application/food_logging_notifier.dart';

/// Page for managing favorites - view, add, edit, delete
class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
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
      final result = await _favoriteFoodService.getFavorites();
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
        title: Text('Mine Favoritter'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: KSizes.fontSizeL,
          fontWeight: KSizes.fontWeightBold,
        ),
        actions: [
          IconButton(
            onPressed: _showAddFavoriteDialog,
            icon: Icon(MdiIcons.plus),
            tooltip: 'Tilføj favorit',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: SafeArea(
          child: _buildBody(),
        ),
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
              size: 96,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: KSizes.margin4x),
            Text(
              'Ingen favoritter endnu',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: KSizes.fontSizeXL,
                fontWeight: KSizes.fontWeightBold,
              ),
            ),
            SizedBox(height: KSizes.margin2x),
            Text(
              'Tryk på + for at tilføje din første favorit',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: KSizes.fontSizeM,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: KSizes.margin6x),
            ElevatedButton.icon(
              onPressed: _showAddFavoriteDialog,
              icon: Icon(MdiIcons.plus),
              label: Text('Tilføj Favorit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: KSizes.margin6x,
                  vertical: KSizes.margin3x,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header stats
        Container(
          margin: EdgeInsets.all(KSizes.margin4x),
          padding: EdgeInsets.all(KSizes.margin4x),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(KSizes.radiusM),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                MdiIcons.star,
                color: AppColors.warning,
                size: KSizes.iconM,
              ),
              SizedBox(width: KSizes.margin2x),
              Expanded(
                child: Text(
                  '${_favorites.length} favoritter gemt',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    fontWeight: KSizes.fontWeightMedium,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                'Total: ${_favorites.fold<int>(0, (sum, fav) => sum + fav.usageCount)} anvendelser',
                style: TextStyle(
                  fontSize: KSizes.fontSizeS,
                  color: AppColors.textSecondary,
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
        child: Padding(
          padding: EdgeInsets.all(KSizes.margin4x),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with food name and actions
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(KSizes.margin2x),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(KSizes.radiusS),
                    ),
                    child: Icon(
                      MdiIcons.star,
                      color: AppColors.warning,
                      size: KSizes.iconS,
                    ),
                  ),
                  
                  SizedBox(width: KSizes.margin3x),
                  
                  Expanded(
                    child: Text(
                      favorite.foodName,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  
                  // Action buttons
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleFavoriteAction(value, favorite),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'log',
                        child: Row(
                          children: [
                            Icon(MdiIcons.foodForkDrink, size: KSizes.iconS),
                            SizedBox(width: KSizes.margin2x),
                            Text('Log mad'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(MdiIcons.pencil, size: KSizes.iconS),
                            SizedBox(width: KSizes.margin2x),
                            Text('Rediger'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(MdiIcons.delete, size: KSizes.iconS, color: AppColors.error),
                            SizedBox(width: KSizes.margin2x),
                            Text('Slet', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(
                      MdiIcons.dotsVertical,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: KSizes.margin3x),
              
              // Details
              Row(
                children: [
                  _buildDetailChip(
                    icon: MdiIcons.fire,
                    label: '${favorite.calories} kcal',
                    color: AppColors.primary,
                  ),
                  
                  SizedBox(width: KSizes.margin2x),
                  
                  _buildDetailChip(
                    icon: MdiIcons.clockOutline,
                    label: favorite.mealTypeDisplayName,
                    color: AppColors.secondary,
                  ),
                  
                  SizedBox(width: KSizes.margin2x),
                  
                  _buildDetailChip(
                    icon: MdiIcons.scaleBalance,
                    label: '${favorite.quantity} ${favorite.servingUnit}',
                    color: AppColors.info,
                  ),
                ],
              ),
              
              SizedBox(height: KSizes.margin2x),
              
              // Usage stats
              Row(
                children: [
                  Icon(
                    MdiIcons.chartLine,
                    size: KSizes.iconXS,
                    color: AppColors.textTertiary,
                  ),
                  SizedBox(width: KSizes.margin1x),
                  Text(
                    'Brugt ${favorite.usageCount} gange',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeS,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Sidst brugt: ${_formatLastUsed(favorite.lastUsed)}',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeS,
                      color: AppColors.textTertiary,
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

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: KSizes.margin2x,
        vertical: KSizes.margin1x,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusS),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: KSizes.iconXS, color: color),
          SizedBox(width: KSizes.margin1x),
          Text(
            label,
            style: TextStyle(
              fontSize: KSizes.fontSizeXS,
              color: color,
              fontWeight: KSizes.fontWeightMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _handleFavoriteAction(String action, FavoriteFoodModel favorite) {
    switch (action) {
      case 'log':
        _logFavorite(favorite);
        break;
      case 'edit':
        _showEditFavoriteDialog(favorite);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(favorite);
        break;
    }
  }

  Future<void> _logFavorite(FavoriteFoodModel favorite) async {
    try {
      // Convert to UserFoodLogModel and log it
      final foodLog = favorite.toUserFoodLog();
      await ref.read(foodLoggingProvider.notifier).logFood(foodLog);

      // Update favorite usage statistics
      final updatedFavorite = favorite.withUpdatedUsage();
      await _favoriteFoodService.updateFavorite(updatedFavorite);

      // Reload favorites to show updated stats
      _loadFavorites();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${favorite.foodName} blev logget!'),
            backgroundColor: AppColors.success,
          ),
        );
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

  void _showEditFavoriteDialog(FavoriteFoodModel favorite) {
    showDialog(
      context: context,
      builder: (context) => _FavoriteEditDialog(
        favorite: favorite,
        onSave: (updatedFavorite) => _saveFavoriteChanges(updatedFavorite),
      ),
    );
  }

  void _showAddFavoriteDialog() {
    final newFavorite = FavoriteFoodModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      lastUsed: DateTime.now(),
    );
    
    showDialog(
      context: context,
      builder: (context) => _FavoriteEditDialog(
        favorite: newFavorite,
        isNew: true,
        onSave: (newFavorite) => _addNewFavorite(newFavorite),
      ),
    );
  }

  Future<void> _saveFavoriteChanges(FavoriteFoodModel updatedFavorite) async {
    try {
      final result = await _favoriteFoodService.updateFavorite(updatedFavorite);
      if (result.isSuccess) {
        _loadFavorites();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Favorit opdateret!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kunne ikke opdatere favorit'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved opdatering: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _addNewFavorite(FavoriteFoodModel newFavorite) async {
    try {
      final result = await _favoriteFoodService.addToFavorites(newFavorite);
      if (result.isSuccess) {
        _loadFavorites();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Favorit tilføjet!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          String message = 'Kunne ikke tilføje favorit';
          if (result.failure.toString().contains('alreadyExists')) {
            message = 'En lignende favorit findes allerede';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved tilføjelse: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog(FavoriteFoodModel favorite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Slet favorit?'),
        content: Text('Er du sikker på, at du vil slette "${favorite.foodName}"?\n\nDenne handling kan ikke fortrydes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuller'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteFavorite(favorite);
            },
            child: Text(
              'Slet',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFavorite(FavoriteFoodModel favorite) async {
    try {
      final result = await _favoriteFoodService.removeFromFavorites(favorite.id);
      if (result.isSuccess) {
        _loadFavorites();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${favorite.foodName} blev slettet'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kunne ikke slette favorit'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved sletning: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _formatLastUsed(DateTime lastUsed) {
    final now = DateTime.now();
    final difference = now.difference(lastUsed);
    
    if (difference.inDays == 0) {
      return 'I dag';
    } else if (difference.inDays == 1) {
      return 'I går';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dage siden';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} uger siden';
    } else {
      return '${(difference.inDays / 30).floor()} måneder siden';
    }
  }
}

/// Dialog for editing or adding favorites
class _FavoriteEditDialog extends StatefulWidget {
  final FavoriteFoodModel favorite;
  final bool isNew;
  final Function(FavoriteFoodModel) onSave;

  const _FavoriteEditDialog({
    required this.favorite,
    this.isNew = false,
    required this.onSave,
  });

  @override
  State<_FavoriteEditDialog> createState() => _FavoriteEditDialogState();
}

class _FavoriteEditDialogState extends State<_FavoriteEditDialog> {
  late TextEditingController _foodNameController;
  late TextEditingController _caloriesController;
  late TextEditingController _quantityController;
  late TextEditingController _servingUnitController;
  late MealType _selectedMealType;

  @override
  void initState() {
    super.initState();
    _foodNameController = TextEditingController(text: widget.favorite.foodName);
    _caloriesController = TextEditingController(text: widget.isNew ? '' : widget.favorite.calories.toString());
    _quantityController = TextEditingController(text: widget.isNew ? '1' : widget.favorite.quantity.toString());
    _servingUnitController = TextEditingController(text: widget.favorite.servingUnit);
    _selectedMealType = widget.favorite.mealType;
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    _quantityController.dispose();
    _servingUnitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isNew ? 'Tilføj Favorit' : 'Rediger Favorit'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Food name
            TextField(
              controller: _foodNameController,
              decoration: InputDecoration(
                labelText: 'Navn på mad *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(MdiIcons.silverwareForkKnife),
              ),
            ),

            SizedBox(height: KSizes.margin3x),

            // Calories
            TextField(
              controller: _caloriesController,
              decoration: InputDecoration(
                labelText: 'Kalorier *',
                border: OutlineInputBorder(),
                suffixText: 'kcal',
                prefixIcon: Icon(MdiIcons.fire),
              ),
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: KSizes.margin3x),

            // Quantity and serving unit
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Mængde *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(MdiIcons.scaleBalance),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                
                SizedBox(width: KSizes.margin2x),
                
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _servingUnitController,
                    decoration: InputDecoration(
                      labelText: 'Enhed *',
                      border: OutlineInputBorder(),
                      hintText: 'f.eks. portion, g, stk',
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: KSizes.margin3x),

            // Meal type
            DropdownButtonFormField<MealType>(
              value: _selectedMealType,
              decoration: InputDecoration(
                labelText: 'Standard måltid',
                border: OutlineInputBorder(),
                prefixIcon: Icon(MdiIcons.clockOutline),
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
          child: Text(widget.isNew ? 'Tilføj' : 'Gem'),
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

    if (_servingUnitController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Angiv venligst enhed'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Create updated favorite
    final updatedFavorite = widget.favorite.copyWith(
      foodName: _foodNameController.text.trim(),
      calories: calories,
      quantity: quantity,
      servingUnit: _servingUnitController.text.trim(),
      mealType: _selectedMealType,
    );

    Navigator.of(context).pop();
    widget.onSave(updatedFavorite);
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