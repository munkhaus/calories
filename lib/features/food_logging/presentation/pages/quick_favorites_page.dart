import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/favorite_food_model.dart';
import '../../infrastructure/favorite_food_service.dart';
import '../../../dashboard/application/date_aware_providers.dart';
import '../../application/food_logging_notifier.dart';
import '../../application/pending_food_cubit.dart';
import './food_favorite_detail_page.dart';
import '../../domain/user_food_log_model.dart';
import './food_search_page.dart';

/// Page for quick selection and management of food favorites
class QuickFavoritesPage extends ConsumerStatefulWidget {
  final bool showAddButton; // Control whether to show the + button
  
  const QuickFavoritesPage({
    super.key,
    this.showAddButton = true, 
  });

  @override
  ConsumerState<QuickFavoritesPage> createState() => _QuickFavoritesPageState();
}

class _QuickFavoritesPageState extends ConsumerState<QuickFavoritesPage> {
  final FavoriteFoodService _foodService = FavoriteFoodService();
  
  List<FavoriteFoodModel> _foodFavorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load food favorites
      final foodResult = await _foodService.getAllFavorites();
      if (foodResult.isSuccess && mounted) {
        _foodFavorites = foodResult.success;
      }

      // Removed loading activity favorites
    } catch (e) {
      print('🔥 QuickFavoritesPage: Error loading favorites: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mad Favoritter'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      floatingActionButton: widget.showAddButton ? 
        FloatingActionButton(
                heroTag: "food_fab",
                onPressed: () => _createNewFoodFavorite(),
                backgroundColor: AppColors.primary,
                child: Icon(MdiIcons.plus),
                tooltip: 'Ny mad favorit',
              )
      : null, 
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildFoodFavorites(),
      ),
    );
  }

  Widget _buildFoodFavorites() {
    if (_foodFavorites.isEmpty) {
      return _buildEmptyState(
        icon: MdiIcons.silverwareForkKnife,
        title: 'Ingen mad-favoritter',
        subtitle: widget.showAddButton 
            ? 'Tryk på + knappen for at oprette din første favorit'
            : 'Du har ikke gemt nogen mad-favoritter endnu.\nGem favoritter når du kategoriserer mad.',
        color: AppColors.primary,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(KSizes.margin4x),
      itemCount: _foodFavorites.length,
      itemBuilder: (context, index) {
        final favorite = _foodFavorites[index];
        return _buildFoodFavoriteCard(favorite);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
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
          ],
        ),
      ),
    );
  }

  Widget _buildFoodFavoriteCard(FavoriteFoodModel favorite) {
    return Container(
      margin: const EdgeInsets.only(bottom: KSizes.margin3x),
      child: InkWell(
        onTap: () => _useFoodFavorite(favorite),
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        child: Container(
          padding: const EdgeInsets.all(KSizes.margin4x),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(KSizes.radiusL),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  MdiIcons.silverwareForkKnife,
                  color: AppColors.primary,
                  size: KSizes.iconL,
                ),
              ),
              
              SizedBox(width: KSizes.margin4x),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      favorite.foodName,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: KSizes.margin1x),
                    Text(
                      '${favorite.defaultServingCalories} kcal • ${_getMealTypeDisplayName(favorite.preferredMealType)}',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: KSizes.margin1x),
                    Text(
                      '${favorite.defaultQuantity} ${favorite.defaultServingUnit}',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Menu button with actions
              PopupMenuButton<String>(
                onSelected: (value) => _handleFoodFavoriteAction(value, favorite),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'use',
                    child: Row(
                      children: [
                        Icon(MdiIcons.plus, color: AppColors.primary, size: KSizes.iconS),
                        SizedBox(width: KSizes.margin2x),
                        Text('Spis nu'),
                      ],
                    ),
                  ),
                  if (widget.showAddButton) ...[
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(MdiIcons.pencil, color: AppColors.secondary, size: KSizes.iconS),
                          SizedBox(width: KSizes.margin2x),
                          Text('Rediger'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(MdiIcons.delete, color: AppColors.error, size: KSizes.iconS),
                          SizedBox(width: KSizes.margin2x),
                          Text('Slet'),
                        ],
                      ),
                    ),
                  ],
                ],
                child: Container(
                  padding: EdgeInsets.all(KSizes.margin2x),
                  child: Icon(
                    MdiIcons.dotsVertical,
                    color: AppColors.textSecondary,
                    size: KSizes.iconM,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to create new food favorite
  void _createNewFoodFavorite() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FoodFavoriteDetailPage(logOnSave: true),
      ),
    );
    
    if (result != null && result is FavoriteFoodModel) {
      await _useFoodFavorite(result);
      _refreshFavorites();
    } else if (result == true) {
      _refreshFavorites();
    }
  }

  /// Navigate to edit food favorite
  void _editFoodFavorite(FavoriteFoodModel favorite) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FoodFavoriteDetailPage(
          existingFavorite: favorite,
          logOnSave: false,
        ),
      ),
    );
    
    if (result != null && result is FavoriteFoodModel) {
      _refreshFavorites();
    } else if (result == true) {
      _refreshFavorites();
    }
  }

  /// Refresh favorites lists
  void _refreshFavorites() {
    _loadFavorites();
  }

  /// Use food favorite with better UX
  Future<void> _useFoodFavorite(FavoriteFoodModel favorite) async {
    try {
      // Convert favorite to UserFoodLogModel and log directly
      final foodLog = favorite.toUserFoodLog();

      // Log the food using the provider
      await ref.read(foodLoggingProvider.notifier).logFood(foodLog);
      
      // Update favorite usage
      final updatedFavorite = favorite.withUpdatedUsage();
      await _foodService.updateFavorite(updatedFavorite);
      
      // Refresh providers silently
      ref.read(foodLoggingProvider.notifier).refresh();
      await ref.read(pendingFoodProvider.notifier).loadPendingFoods();
      
      if (mounted) {
        // Show simple success message and navigate back to dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${favorite.foodName} tilføjet'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate back to dashboard
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _getMealTypeDisplayName(MealType mealType) {
    switch (mealType) {
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

  void _handleFoodFavoriteAction(String value, FavoriteFoodModel favorite) {
    if (value == 'use') {
      _useFoodFavorite(favorite);
    } else if (value == 'edit') {
      _editFoodFavorite(favorite);
    } else if (value == 'delete') {
      _deleteFoodFavorite(favorite);
    }
  }

  void _deleteFoodFavorite(FavoriteFoodModel favorite) async {
    final confirmed = await _showDeleteConfirmDialog(
      'Slet ${favorite.foodName}?',
      'Er du sikker på, at du vil slette denne mad-favorit?',
    );

    if (confirmed == true) {
      try {
        final result = await _foodService.removeFromFavorites(favorite.id);
        if (result.isSuccess) {
          _loadFavorites(); // Refresh the list
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${favorite.foodName} er slettet fra favoritter'),
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
  }

  Future<bool?> _showDeleteConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusL),
        ),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Nej'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text('Ja, slet'),
          ),
        ],
      ),
    );
  }
} 