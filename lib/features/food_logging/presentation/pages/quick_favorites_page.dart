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

/// Quick page for selecting and logging favorites from FAB
class QuickFavoritesPage extends ConsumerStatefulWidget {
  final int initialTab;
  
  const QuickFavoritesPage({
    super.key,
    this.initialTab = 0,
  });

  @override
  ConsumerState<QuickFavoritesPage> createState() => _QuickFavoritesPageState();
}

class _QuickFavoritesPageState extends ConsumerState<QuickFavoritesPage> with TickerProviderStateMixin {
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
    _tabController = TabController(
      length: 2, 
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
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
        title: Text('Hurtig Favoritter'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: KSizes.fontSizeXL,
          fontWeight: KSizes.fontWeightBold,
        ),
        leading: IconButton(
          icon: Icon(MdiIcons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(MdiIcons.silverwareForkKnife),
                  SizedBox(width: KSizes.margin1x),
                  Text('Mad'),
                  if (_foodFavorites.isNotEmpty) ...[
                    SizedBox(width: KSizes.margin1x),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_foodFavorites.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(MdiIcons.runFast),
                  SizedBox(width: KSizes.margin1x),
                  Text('Aktiviteter'),
                  if (_activityFavorites.isNotEmpty) ...[
                    SizedBox(width: KSizes.margin1x),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_activityFavorites.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
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
        title: 'Ingen mad-favoritter',
        subtitle: 'Tilføj favoritter ved at markere måltider som favoritter når du kategoriserer dem',
        color: AppColors.primary,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(KSizes.margin4x),
      itemCount: _foodFavorites.length,
      itemBuilder: (context, index) {
        final favorite = _foodFavorites[index];
        return _buildFoodFavoriteQuickCard(favorite);
      },
    );
  }

  Widget _buildActivityFavoritesTab() {
    if (_activityFavorites.isEmpty) {
      return _buildEmptyState(
        icon: MdiIcons.runFast,
        title: 'Ingen aktivitets-favoritter',
        subtitle: 'Tilføj favoritter ved at markere aktiviteter som favoritter når du logger dem',
        color: AppColors.secondary,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(KSizes.margin4x),
      itemCount: _activityFavorites.length,
      itemBuilder: (context, index) {
        final favorite = _activityFavorites[index];
        return _buildActivityFavoriteQuickCard(favorite);
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

  Widget _buildFoodFavoriteQuickCard(FavoriteFoodModel favorite) {
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
              
              Icon(
                MdiIcons.plus,
                color: AppColors.primary,
                size: KSizes.iconM,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityFavoriteQuickCard(FavoriteActivityModel favorite) {
    return Container(
      margin: const EdgeInsets.only(bottom: KSizes.margin3x),
      child: InkWell(
        onTap: () => _useActivityFavorite(favorite),
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
              
              Icon(
                MdiIcons.plus,
                color: AppColors.secondary,
                size: KSizes.iconM,
              ),
            ],
          ),
        ),
      ),
    );
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
            content: Row(
              children: [
                Icon(MdiIcons.check, color: Colors.white),
                SizedBox(width: KSizes.margin2x),
                Expanded(child: Text('${favorite.foodName} er tilføjet som måltid!')),
              ],
            ),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'Luk',
              textColor: Colors.white,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        );
        
        // Close the page after successful logging
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) Navigator.of(context).pop();
        });
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
      // Convert favorite to UserActivityLogModel and log directly
      final activityLog = favorite.toUserActivityLog();

      // Create an ActivityNotifier instance to log the activity
      final activityNotifier = ActivityNotifier();
      final success = await activityNotifier.logActivity(activityLog);

      if (success) {
        // Update favorite usage
        final updatedFavorite = favorite.withUpdatedUsage();
        await _activityService.updateFavorite(updatedFavorite);

        // Refresh all ActivityNotifier instances globally
        await ActivityNotifier.refreshAllInstances();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(MdiIcons.check, color: Colors.white),
                  SizedBox(width: KSizes.margin2x),
                  Expanded(child: Text('${favorite.activityName} er tilføjet som aktivitet!')),
                ],
              ),
              backgroundColor: AppColors.success,
              action: SnackBarAction(
                label: 'Luk',
                textColor: Colors.white,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          );
          
          // Close the page after successful logging
          Future.delayed(Duration(seconds: 2), () {
            if (mounted) Navigator.of(context).pop();
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kunne ikke tilføje aktivitet'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
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
      case MealType.morgenmad:
        return 'Morgenmad';
      case MealType.frokost:
        return 'Frokost';
      case MealType.aftensmad:
        return 'Aftensmad';
      case MealType.snack:
        return 'Snack';
      default:
        return 'Ukendt';
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
    if (favorite.inputType == ActivityInputType.varighed && favorite.durationMinutes > 0) {
      return '${favorite.durationMinutes.round()} minutter';
    } else if (favorite.inputType == ActivityInputType.distance && favorite.distanceKm > 0) {
      return '${favorite.distanceKm} km';
    }
    return 'Ingen specifik varighed';
  }
} 