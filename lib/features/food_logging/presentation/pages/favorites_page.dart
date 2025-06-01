import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/food_logging_notifier.dart';
import '../../domain/favorite_food_model.dart';
import '../../infrastructure/favorite_food_service.dart';
import '../../../activity/domain/favorite_activity_model.dart';
import '../../../activity/infrastructure/favorite_activity_service.dart';
import '../../../activity/presentation/pages/activity_favorite_detail_page.dart';
import '../../domain/user_food_log_model.dart';
import '../../../activity/domain/user_activity_log_model.dart';
import '../../presentation/pages/food_favorite_detail_page.dart';
import '../../../activity/application/activity_notifier.dart'; // For logging activity
import '../../../dashboard/application/date_aware_providers.dart'; // Added import

/// Page for managing food and activity favorites
class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final FavoriteFoodService _foodService = FavoriteFoodService();
  final FavoriteActivityService _activityService = FavoriteActivityService();
  
  List<FavoriteFoodModel> _foodFavorites = [];
  List<FavoriteActivityModel> _activityFavorites = [];
  
  bool _isLoadingFood = true;
  bool _isLoadingActivities = true;
  String? _foodError;
  String? _activityError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllFavorites(); // Initial load
  }

  @override
  void dispose() {
    // The TabController's animation listener is automatically removed when the TabController is disposed.
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllFavorites() async {
    setState(() {
      _isLoadingFood = true;
      _isLoadingActivities = true;
      _foodError = null;
      _activityError = null;
    });

    try {
      // Load food favorites
      final foodResult = await _foodService.getAllFavorites();
      if (foodResult.isSuccess) {
        _foodFavorites = foodResult.success;
      } else {
        _foodError = 'Fejl ved indlæsning af mad-favoritter';
      }

      // Load activity favorites
      final activityResult = await _activityService.getFavorites();
       if (activityResult.isSuccess) {
        _activityFavorites = activityResult.success;
      } else {
        _activityError = 'Fejl ved indlæsning af aktivitet-favoritter';
      }

      // Important: Check if mounted before calling setState
      if (mounted) {
        setState(() {
          _isLoadingFood = false;
          _isLoadingActivities = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFood = false;
          _isLoadingActivities = false;
          _foodError = 'Fejl ved indlæsning af favoritter';
          _activityError = 'Fejl ved indlæsning af favoritter';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Favoritter'),
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
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: 'Mad'),
              Tab(text: 'Aktiviteter'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
                heroTag: "favorites_fab",
                onPressed: () {
                  if (_tabController.index == 0) {
                    _createNewFoodFavorite();
                  } else {
                    _createNewActivityFavorite();
                  }
                },
                backgroundColor: AppColors.primary,
                child: Icon(MdiIcons.plus),
                tooltip: _tabController.index == 0 ? 'Ny mad favorit' : 'Ny aktivitet favorit',
              ),
        body: Container(
          decoration: BoxDecoration(
            gradient: AppDesign.backgroundGradient,
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
              _isLoadingFood
                  ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _foodError != null
                      ? _buildErrorState(_foodError!, _loadAllFavorites)
                      : _buildFoodFavoritesTab(),
              _isLoadingActivities
                  ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _activityError != null
                      ? _buildErrorState(_activityError!, _loadAllFavorites)
                      : _buildActivityFavoritesTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMsg, VoidCallback onRetry) {
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
              errorMsg,
              style: TextStyle(
                fontSize: KSizes.fontSizeL,
                color: AppColors.error,
                fontWeight: KSizes.fontWeightBold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: KSizes.margin4x),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Prøv igen'),
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
        subtitle: 'Tilføj favoritter ved at markere måltider som favoritter når du kategoriserer dem, eller opret dem manuelt.',
        onAdd: _createNewFoodFavorite,
        addLabel: 'Opret Mad Favorit'
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllFavorites,
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
        title: 'Ingen aktivitet-favoritter endnu',
        subtitle: 'Tilføj favoritter ved at markere aktiviteter som favoritter når du logger dem, eller opret dem manuelt.',
        onAdd: _createNewActivityFavorite,
        addLabel: 'Opret Aktivitet Favorit'
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllFavorites,
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
    required VoidCallback onAdd,
    required String addLabel,
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
            SizedBox(height: KSizes.margin6x),
            ElevatedButton.icon(
              icon: Icon(MdiIcons.plus),
              label: Text(addLabel),
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: KSizes.margin6x, vertical: KSizes.margin3x)
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFoodFavoriteCard(FavoriteFoodModel favorite) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: KSizes.margin3x),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        side: BorderSide(color: AppColors.border.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: () => _editFoodFavorite(favorite), // Tap card to edit
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(KSizes.margin4x),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(KSizes.margin2x),
                    decoration: BoxDecoration(
                      color: _getMealColor(favorite.preferredMealType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(KSizes.radiusS),
                    ),
                    child: Icon(
                      _getMealIcon(favorite.preferredMealType),
                      color: _getMealColor(favorite.preferredMealType),
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
                          '${favorite.mealTypeDisplayName} • ${favorite.defaultServingCalories} kcal',
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
                            Icon(MdiIcons.plusCircleOutline, color: AppColors.primary),
                            SizedBox(width: KSizes.margin2x),
                            const Text('Log til i dag'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(MdiIcons.pencil, color: AppColors.secondary),
                            SizedBox(width: KSizes.margin2x),
                            const Text('Rediger'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(MdiIcons.delete, color: AppColors.error),
                            SizedBox(width: KSizes.margin2x),
                            const Text('Slet'),
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
                  _buildInfoChip('${favorite.defaultQuantity} ${favorite.defaultServingUnit}', MdiIcons.scaleBalance),
                  SizedBox(width: KSizes.margin2x),
                  _buildInfoChip('Brugt ${favorite.usageCount} gange', MdiIcons.heart),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityFavoriteCard(FavoriteActivityModel favorite) {
     return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: KSizes.margin3x),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        side: BorderSide(color: AppColors.border.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: () => _editActivityFavorite(favorite), // Tap card to edit
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(KSizes.margin4x),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(KSizes.margin2x),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(KSizes.radiusS),
                    ),
                    child: Icon(
                      MdiIcons.run,
                      color: AppColors.secondary,
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
                          '${favorite.caloriesBurned} kcal • ${favorite.durationMinutes} min',
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
                            Icon(MdiIcons.plusCircleOutline, color: AppColors.primary),
                            SizedBox(width: KSizes.margin2x),
                            Text('Log til i dag'),
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
              _buildInfoChip('Brugt ${favorite.usageCount} gange', MdiIcons.heart),
            ],
          ),
        ),
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
      final foodLog = favorite.toUserFoodLog();
      await ref.read(foodLoggingProvider.notifier).logFood(foodLog);
      final updatedFavorite = favorite.withUpdatedUsage();
      await _foodService.updateFavorite(updatedFavorite);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${favorite.foodName} er tilføjet som måltid!'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadAllFavorites();
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
      final activityLog = favorite.toUserActivityLog();
      await ref.read(activityNotifierProvider.notifier).logActivity(activityLog);
      final updatedFavorite = favorite.withUpdatedUsage();
      await _activityService.updateFavorite(updatedFavorite);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${favorite.activityName} er logget!'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadAllFavorites();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved logning af aktivitet: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _editFoodFavorite(FavoriteFoodModel favorite) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FoodFavoriteDetailPage(
          existingFavorite: favorite,
          logOnSave: false, // Ensure edit mode
        ),
      ),
    );

    if (result != null && result is FavoriteFoodModel || result == true) { 
      _loadAllFavorites();
    }
  }

  Future<void> _editActivityFavorite(FavoriteActivityModel favorite) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActivityFavoriteDetailPage(
          existingFavorite: favorite,
        ),
      ),
    );

    if (result != null && result is FavoriteActivityModel || result == true) { 
      _loadAllFavorites();
    }
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
              content: const Text('Kunne ikke slette favorit'),
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
      'Er du sikker på, at du vil slette denne aktivitet-favorit?',
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
              content: const Text('Kunne ikke slette favorit'),
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
            child: const Text('Nej'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ja'),
          ),
        ],
      ),
    );
  }

  Color _getMealColor(MealType mealType) {
    switch (mealType) {
      case MealType.morgenmad: return AppColors.warning;
      case MealType.frokost: return AppColors.primary;
      case MealType.aftensmad: return AppColors.secondary;
      case MealType.snack: return AppColors.info;
      default: return AppColors.primary;
    }
  }

  IconData _getMealIcon(MealType mealType) {
    switch (mealType) {
      case MealType.morgenmad: return MdiIcons.weatherSunny;
      case MealType.frokost: return MdiIcons.weatherPartlyCloudy;
      case MealType.aftensmad: return MdiIcons.weatherNight;
      case MealType.snack: return MdiIcons.cookie;
      default: return MdiIcons.silverwareForkKnife;
    }
  }

  void _createNewFoodFavorite() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FoodFavoriteDetailPage(logOnSave: false), // Edit mode for new
      ),
    );
    if (result != null && result is FavoriteFoodModel || result == true) { 
      _loadAllFavorites();
    }
  }

  void _createNewActivityFavorite() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActivityFavoriteDetailPage(), // Edit mode for new
      ),
    );
     if (result != null && result is FavoriteActivityModel || result == true) { 
      _loadAllFavorites();
    }
  }
}