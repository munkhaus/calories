import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/favorite_food_model.dart';
import '../../infrastructure/favorite_food_service.dart';
import '../../../activity/domain/favorite_activity_model.dart';
import '../../../activity/infrastructure/favorite_activity_service.dart';
import '../../../dashboard/application/date_aware_providers.dart';
import '../../application/food_logging_notifier.dart';
import '../../application/pending_food_cubit.dart';
import './food_favorite_detail_page.dart';
import '../../../activity/presentation/pages/activity_favorite_detail_page.dart';
import '../../domain/user_food_log_model.dart';
import '../../../activity/domain/user_activity_log_model.dart';

/// Page for quick selection and management of food and activity favorites
class QuickFavoritesPage extends ConsumerStatefulWidget {
  final int initialTab;
  
  const QuickFavoritesPage({
    super.key,
    this.initialTab = 0,
  });

  @override
  ConsumerState<QuickFavoritesPage> createState() => _QuickFavoritesPageState();
}

class _QuickFavoritesPageState extends ConsumerState<QuickFavoritesPage>
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  final FavoriteFoodService _foodService = FavoriteFoodService();
  final FavoriteActivityService _activityService = FavoriteActivityService();
  
  List<FavoriteFoodModel> _foodFavorites = [];
  List<FavoriteActivityModel> _activityFavorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
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
    });

    try {
      // Load food favorites
      final foodResult = await _foodService.getFavorites();
      if (foodResult.isSuccess && mounted) {
        _foodFavorites = foodResult.success;
      }

      // Load activity favorites
      final activityResult = await _activityService.getFavorites();
      if (activityResult.isSuccess && mounted) {
        _activityFavorites = activityResult.success;
      }
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
        title: const Text('Favoritter'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(
              icon: Icon(MdiIcons.silverwareForkKnife),
              text: 'Mad',
            ),
            Tab(
              icon: Icon(MdiIcons.runFast),
              text: 'Aktivitet',
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Create new food favorite
          FloatingActionButton(
            heroTag: "food_fab",
            onPressed: () => _createNewFoodFavorite(),
            backgroundColor: AppColors.primary,
            child: Icon(MdiIcons.plus),
            tooltip: 'Ny mad favorit',
          ),
          SizedBox(height: KSizes.margin2x),
          // Create new activity favorite
          FloatingActionButton(
            heroTag: "activity_fab",
            onPressed: () => _createNewActivityFavorite(),
            backgroundColor: AppColors.secondary,
            child: Icon(MdiIcons.runFast),
            tooltip: 'Ny aktivitet favorit',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildFoodFavorites(),
                  _buildActivityFavorites(),
                ],
              ),
      ),
    );
  }

  Widget _buildFoodFavorites() {
    if (_foodFavorites.isEmpty) {
      return _buildEmptyState(
        icon: MdiIcons.silverwareForkKnife,
        title: 'Ingen mad-favoritter',
        subtitle: 'Tryk på + knappen for at oprette din første favorit',
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

  Widget _buildActivityFavorites() {
    if (_activityFavorites.isEmpty) {
      return _buildEmptyState(
        icon: MdiIcons.runFast,
        title: 'Ingen aktivitets-favoritter',
        subtitle: 'Tryk på + knappen for at oprette din første favorit',
        color: AppColors.secondary,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(KSizes.margin4x),
      itemCount: _activityFavorites.length,
      itemBuilder: (context, index) {
        final favorite = _activityFavorites[index];
        return _buildActivityFavoriteCard(favorite);
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
        onLongPress: () => _editFoodFavorite(favorite),
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
                      '${favorite.calories} kcal • ${_getMealTypeDisplayName(favorite.mealType)}',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: KSizes.margin1x),
                    Text(
                      '${favorite.quantity} ${favorite.servingUnit}',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              
              Column(
                children: [
                  Icon(
                    MdiIcons.plus,
                    color: AppColors.primary,
                    size: KSizes.iconM,
                  ),
                  SizedBox(height: KSizes.margin1x),
                  Text(
                    'Tryk: brug\nHold: rediger',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeXS,
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityFavoriteCard(FavoriteActivityModel favorite) {
    return Container(
      margin: const EdgeInsets.only(bottom: KSizes.margin3x),
      child: InkWell(
        onTap: () => _useActivityFavorite(favorite),
        onLongPress: () => _editActivityFavorite(favorite),
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        child: Container(
          padding: const EdgeInsets.all(KSizes.margin4x),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(KSizes.radiusL),
            border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.1),
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
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  MdiIcons.runFast,
                  color: AppColors.secondary,
                  size: KSizes.iconL,
                ),
              ),
              
              SizedBox(width: KSizes.margin4x),
              
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
                      '${favorite.caloriesBurned} kcal • ${_getIntensityDisplayName(favorite.intensity)}',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: KSizes.margin1x),
                    Text(
                      _getActivityDurationText(favorite),
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              
              Column(
                children: [
                  Icon(
                    MdiIcons.plus,
                    color: AppColors.secondary,
                    size: KSizes.iconM,
                  ),
                  SizedBox(height: KSizes.margin1x),
                  Text(
                    'Tryk: brug\nHold: rediger',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeXS,
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
        builder: (context) => const FoodFavoriteDetailPage(),
      ),
    );
    
    if (result == true) {
      _refreshFavorites();
    }
  }

  /// Navigate to create new activity favorite
  void _createNewActivityFavorite() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ActivityFavoriteDetailPage(),
      ),
    );
    
    if (result == true) {
      _refreshFavorites();
    }
  }

  /// Navigate to edit food favorite
  void _editFoodFavorite(FavoriteFoodModel favorite) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FoodFavoriteDetailPage(existingFavorite: favorite),
      ),
    );
    
    if (result == true) {
      _refreshFavorites();
    }
  }

  /// Navigate to edit activity favorite
  void _editActivityFavorite(FavoriteActivityModel favorite) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActivityFavoriteDetailPage(existingFavorite: favorite),
      ),
    );
    
    if (result == true) {
      _refreshFavorites();
    }
  }

  /// Refresh favorites lists
  void _refreshFavorites() {
    _loadFavorites();
  }

  /// Use food favorite
  Future<void> _useFoodFavorite(FavoriteFoodModel favorite) async {
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
                Flexible(child: Text('Tilføjer ${favorite.foodName}...')),
              ],
            ),
            backgroundColor: AppColors.info,
            duration: Duration(milliseconds: 1500),
          ),
        );
        
        // Convert favorite to UserFoodLogModel and log directly
        final foodLog = UserFoodLogModel(
          userId: 1,
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

        // Log the food using the provider
        await ref.read(foodLoggingProvider.notifier).logFood(foodLog);
        
        // Update favorite usage
        final updatedFavorite = favorite.withUpdatedUsage();
        await _foodService.updateFavorite(updatedFavorite);
        
        print('⭐ FavoriteFoodService: Updated favorite: ${favorite.foodName}');
        
        // Refresh all providers to update home tab data
        ref.read(foodLoggingProvider.notifier).refresh();
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
                Flexible(child: Text('${favorite.foodName} er tilføjet som måltid!')),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: Duration(milliseconds: 1500),
          ),
        );
        
        // Navigate back after a short delay
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
            content: Text('Fejl ved tilføjelse af måltid: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Use activity favorite
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
        
        // Refresh all providers to update home tab data
        ref.read(foodLoggingProvider.notifier).refresh();
        await ref.read(pendingFoodProvider.notifier).loadPendingFoods();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(MdiIcons.check, color: Colors.white),
                SizedBox(width: KSizes.margin2x),
                Flexible(child: Text('${favorite.activityName} er tilføjet som aktivitet!')),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: Duration(milliseconds: 1500),
          ),
        );
        
        // Navigate back after a short delay
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

  String _getActivityDurationText(FavoriteActivityModel favorite) {
    if (favorite.inputType == ActivityInputType.varighed) {
      return '${favorite.durationMinutes.toInt()} minutter';
    } else {
      return '${favorite.distanceKm} km';
    }
  }
} 