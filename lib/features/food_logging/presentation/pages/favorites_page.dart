import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/favorite_food_model.dart';
import '../../domain/user_food_log_model.dart';
import '../../infrastructure/favorite_food_service.dart';
import '../../application/food_logging_notifier.dart';
import '../../../activity/domain/favorite_activity_model.dart';
import '../../../activity/domain/user_activity_log_model.dart';
import '../../../activity/infrastructure/favorite_activity_service.dart';
import '../../../activity/application/activity_notifier.dart';
import '../../../dashboard/application/date_aware_providers.dart';
import '../../application/pending_food_cubit.dart';
import './food_favorite_detail_page.dart';
import '../../../activity/presentation/pages/activity_favorite_detail_page.dart';

/// Page for managing both food and activity favorites with tabs
class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> with TickerProviderStateMixin {
  final FavoriteFoodService _foodService = FavoriteFoodService();
  final FavoriteActivityService _activityService = FavoriteActivityService();
  late TabController _tabController;
  
  List<FavoriteFoodModel> _foodFavorites = [];
  List<FavoriteActivityModel> _activityFavorites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load food favorites
      final foodResult = await _foodService.getFavorites();
      if (foodResult.isSuccess) {
        _foodFavorites = foodResult.success;
      }

      // Load activity favorites
      final activityResult = await _activityService.getFavorites();
      if (activityResult.isSuccess) {
        _activityFavorites = activityResult.success;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Fejl ved indlæsning af favoritter';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Favoritter'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: KSizes.fontSizeXL,
          fontWeight: KSizes.fontWeightBold,
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(MdiIcons.silverwareForkKnife),
              text: 'Mad',
            ),
            Tab(
              icon: Icon(MdiIcons.runFast),
              text: 'Aktiviteter',
            ),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : _error != null
                ? _buildErrorState()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFoodFavoritesTab(),
                      _buildActivityFavoritesTab(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin6x),
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
                fontSize: KSizes.fontSizeL,
                color: AppColors.error,
                fontWeight: KSizes.fontWeightBold,
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
      ),
    );
  }

  Widget _buildFoodFavoritesTab() {
    if (_foodFavorites.isEmpty) {
      return _buildEmptyState(
        icon: MdiIcons.silverwareForkKnife,
        title: 'Ingen mad-favoritter endnu',
        subtitle: 'Tilføj favoritter ved at markere måltider som favoritter når du kategoriserer dem',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.all(KSizes.margin4x),
        itemCount: _foodFavorites.length,
        itemBuilder: (context, index) {
          final favorite = _foodFavorites[index];
          return _buildFoodFavoriteCard(favorite);
        },
      ),
    );
  }

  Widget _buildActivityFavoritesTab() {
    if (_activityFavorites.isEmpty) {
      return _buildEmptyState(
        icon: MdiIcons.runFast,
        title: 'Ingen aktivitets-favoritter endnu',
        subtitle: 'Tilføj favoritter ved at markere aktiviteter som favoritter når du logger dem',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.all(KSizes.margin4x),
        itemCount: _activityFavorites.length,
        itemBuilder: (context, index) {
          final favorite = _activityFavorites[index];
          return _buildActivityFavoriteCard(favorite);
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin6x),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: KSizes.margin4x),
            Text(
              title,
              style: TextStyle(
                fontSize: KSizes.fontSizeL,
                color: AppColors.textSecondary,
                fontWeight: KSizes.fontWeightBold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: KSizes.margin2x),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: KSizes.fontSizeM,
                color: AppColors.textTertiary,
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
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  color: _getMealColor(favorite.mealType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                ),
                child: Icon(
                  _getMealIcon(favorite.mealType),
                  color: _getMealColor(favorite.mealType),
                  size: KSizes.iconM,
                ),
              ),
              
              SizedBox(width: KSizes.margin3x),
              
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
                      '${favorite.mealType.mealTypeDisplayName} • ${favorite.calories} kcal',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              PopupMenuButton<String>(
                onSelected: (value) => _handleFoodFavoriteAction(value, favorite),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'use',
                    child: Row(
                      children: [
                        Icon(MdiIcons.plus, color: AppColors.primary),
                        SizedBox(width: KSizes.margin2x),
                        Text('Tilføj som måltid'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(MdiIcons.pencil, color: AppColors.secondary),
                        SizedBox(width: KSizes.margin2x),
                        Text('Rediger'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(MdiIcons.delete, color: AppColors.error),
                        SizedBox(width: KSizes.margin2x),
                        Text('Slet'),
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
          
          Row(
            children: [
              _buildInfoChip('${favorite.quantity} ${favorite.servingUnit}', MdiIcons.scaleBalance),
              SizedBox(width: KSizes.margin2x),
              _buildInfoChip('Brugt ${favorite.usageCount} gange', MdiIcons.heart),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityFavoriteCard(FavoriteActivityModel favorite) {
    return Container(
      margin: const EdgeInsets.only(bottom: KSizes.margin3x),
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  color: _getIntensityColor(favorite.intensity).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                ),
                child: Icon(
                  _getActivityIcon(favorite.activityName),
                  color: _getIntensityColor(favorite.intensity),
                  size: KSizes.iconM,
                ),
              ),
              
              SizedBox(width: KSizes.margin3x),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      favorite.activityName,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: KSizes.margin1x),
                    Text(
                      '${_getIntensityDisplayName(favorite.intensity)} • ${favorite.caloriesBurned} kcal',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              PopupMenuButton<String>(
                onSelected: (value) => _handleActivityFavoriteAction(value, favorite),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'use',
                    child: Row(
                      children: [
                        Icon(MdiIcons.plus, color: AppColors.primary),
                        SizedBox(width: KSizes.margin2x),
                        Text('Tilføj som aktivitet'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(MdiIcons.pencil, color: AppColors.secondary),
                        SizedBox(width: KSizes.margin2x),
                        Text('Rediger'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(MdiIcons.delete, color: AppColors.error),
                        SizedBox(width: KSizes.margin2x),
                        Text('Slet'),
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
          
          Row(
            children: [
              if (favorite.inputType == ActivityInputType.varighed && favorite.durationMinutes > 0)
                _buildInfoChip('${favorite.durationMinutes.round()} min', MdiIcons.clock)
              else if (favorite.inputType == ActivityInputType.distance && favorite.distanceKm > 0)
                _buildInfoChip('${favorite.distanceKm} km', MdiIcons.mapMarker),
              SizedBox(width: KSizes.margin2x),
              _buildInfoChip('Brugt ${favorite.usageCount} gange', MdiIcons.heart),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KSizes.margin2x,
        vertical: KSizes.margin1x,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: KSizes.iconXS,
            color: AppColors.primary,
          ),
          SizedBox(width: KSizes.margin1x),
          Text(
            text,
            style: TextStyle(
              fontSize: KSizes.fontSizeXS,
              color: AppColors.primary,
              fontWeight: KSizes.fontWeightMedium,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleFoodFavoriteAction(String action, FavoriteFoodModel favorite) async {
    switch (action) {
      case 'use':
        await _useFoodFavorite(favorite);
        break;
      case 'edit':
        await _editFoodFavorite(favorite);
        break;
      case 'delete':
        await _deleteFoodFavorite(favorite);
        break;
    }
  }

  Future<void> _handleActivityFavoriteAction(String action, FavoriteActivityModel favorite) async {
    switch (action) {
      case 'use':
        await _useActivityFavorite(favorite);
        break;
      case 'edit':
        await _editActivityFavorite(favorite);
        break;
      case 'delete':
        await _deleteActivityFavorite(favorite);
        break;
    }
  }

  Future<void> _useFoodFavorite(FavoriteFoodModel favorite) async {
    try {
      // Convert favorite to UserFoodLogModel and log directly
      final foodLog = UserFoodLogModel(
        userId: 1, // TODO: Get real user ID
        foodName: favorite.foodName,
        mealType: favorite.mealType,
        quantity: favorite.quantity,
        servingUnit: favorite.servingUnit,
        calories: favorite.calories,
        protein: favorite.protein,
        fat: favorite.fat,
        carbs: favorite.carbs,
        loggedAt: DateTime.now().toIso8601String(),
      );

      // Log the food
      await ref.read(foodLoggingProvider.notifier).logFood(foodLog);

      // Update favorite usage
      final updatedFavorite = favorite.withUpdatedUsage();
      await _foodService.updateFavorite(updatedFavorite);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${favorite.foodName} er tilføjet som måltid!'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Refresh favorites to show updated usage
        _loadFavorites();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved tilføjelse af måltid: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _useActivityFavorite(FavoriteActivityModel favorite) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: KSizes.margin2x),
                Flexible(child: Text('Tilføjer ${favorite.activityName}...')),
              ],
            ),
            backgroundColor: AppColors.info,
            duration: Duration(milliseconds: 1500),
          ),
        );
        
        // Convert favorite to UserActivityLogModel and log directly
        final activityLog = favorite.toUserActivityLog();

        // Create an ActivityNotifier instance to log the activity
        final activityNotifier = ref.read(activityNotifierProvider);
        await activityNotifier.logActivity(activityLog);

        // Update favorite usage
        final updatedFavorite = favorite.withUpdatedUsage();
        await _activityService.updateFavorite(updatedFavorite);

        print('⭐ FavoriteActivityService: Updated favorite: ${favorite.activityName}');
        
        // Use the new centralized refresh function
        refreshActivityCalories(ref);
        
        // Also refresh pending foods
        await ref.read(pendingFoodProvider.notifier).loadPendingFoods();
      }
      
      if (mounted) {
        // Clear any existing snackbars
        ScaffoldMessenger.of(context).clearSnackBars();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(MdiIcons.check, color: Colors.white),
                SizedBox(width: KSizes.margin2x),
                Flexible(child: Text('${favorite.activityName} er tilføjet!')),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: Duration(milliseconds: 1500),
          ),
        );
        
        // Navigate back to dashboard after a short delay
        Future.delayed(Duration(milliseconds: 800), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved tilføjelse af aktivitet: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _editFoodFavorite(FavoriteFoodModel favorite) async {
    // TODO: Implement food favorite editing dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Redigering af mad-favoritter kommer snart'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  Future<void> _editActivityFavorite(FavoriteActivityModel favorite) async {
    // TODO: Implement activity favorite editing dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Redigering af aktivitets-favoritter kommer snart'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  Future<void> _deleteFoodFavorite(FavoriteFoodModel favorite) async {
    final confirmed = await _showDeleteConfirmDialog(
      'Slet ${favorite.foodName}?',
      'Er du sikker på, at du vil slette denne mad-favorit?',
    );

    if (confirmed == true) {
      final result = await _foodService.removeFromFavorites(favorite.id);
      if (result.isSuccess) {
        setState(() {
          _foodFavorites.removeWhere((f) => f.id == favorite.id);
        });
        
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
    }
  }

  Future<void> _deleteActivityFavorite(FavoriteActivityModel favorite) async {
    final confirmed = await _showDeleteConfirmDialog(
      'Slet ${favorite.activityName}?',
      'Er du sikker på, at du vil slette denne aktivitets-favorit?',
    );

    if (confirmed == true) {
      final result = await _activityService.removeFromFavorites(favorite.id);
      if (result.isSuccess) {
        setState(() {
          _activityFavorites.removeWhere((f) => f.id == favorite.id);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${favorite.activityName} er slettet fra favoritter'),
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
    }
  }

  Future<bool?> _showDeleteConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
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
      ),
    );
  }

  // Helper methods for UI
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

  Color _getIntensityColor(ActivityIntensity intensity) {
    switch (intensity) {
      case ActivityIntensity.let:
        return AppColors.success;
      case ActivityIntensity.moderat:
        return AppColors.warning;
      case ActivityIntensity.haardt:
        return AppColors.error;
    }
  }

  String _getIntensityDisplayName(ActivityIntensity intensity) {
    switch (intensity) {
      case ActivityIntensity.let:
        return 'Let';
      case ActivityIntensity.moderat:
        return 'Moderat';
      case ActivityIntensity.haardt:
        return 'Hård';
    }
  }

  IconData _getActivityIcon(String activityName) {
    final name = activityName.toLowerCase();
    if (name.contains('løb')) return MdiIcons.run;
    if (name.contains('gå') || name.contains('tur')) return MdiIcons.walk;
    if (name.contains('cykel')) return MdiIcons.bike;
    if (name.contains('svøm')) return MdiIcons.swim;
    if (name.contains('styrke') || name.contains('vægt')) return MdiIcons.dumbbell;
    if (name.contains('yoga')) return MdiIcons.yoga;
    if (name.contains('tennis')) return MdiIcons.tennis;
    if (name.contains('fodbold')) return MdiIcons.soccer;
    return MdiIcons.runFast;
  }
} 