import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_page_header.dart';  // Added for StandardPageHeader
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
import '../widgets/barcode_scanner_widget.dart'; // Added for barcode scanning
import '../widgets/smart_portion_selection_dialog.dart'; // Added for portion selection

/// Page for managing food and activity favorites
class FavoritesPage extends ConsumerStatefulWidget {
  final FoodType? initialFilter; // Add initial filter parameter
  
  const FavoritesPage({
    super.key,
    this.initialFilter,
  });

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
  
  // Filter state for food favorites
  FoodType? _selectedFoodFilter; // null means show all

  @override
  void initState() {
    super.initState();
    
    // Set tab count based on whether we have an initial filter
    final int tabCount = widget.initialFilter != null ? 1 : 2;
    _tabController = TabController(length: tabCount, vsync: this);
    
    // Add listener to update UI when tab changes
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          // This will trigger a rebuild to update tab appearances
        });
      }
    });
    
    // Set initial filter based on widget parameter
    _selectedFoodFilter = widget.initialFilter;
    
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
    final bool showOnlyFoodTab = widget.initialFilter != null;
    final int tabCount = showOnlyFoodTab ? 1 : 2;
    
    return DefaultTabController(
      length: tabCount,
      child: Scaffold(
        backgroundColor: AppColors.background,
        // Hide floating action button when opened from home page (for selection)
        floatingActionButton: showOnlyFoodTab ? null : FloatingActionButton(
          heroTag: "favorites_fab",
          onPressed: () {
            if (showOnlyFoodTab || _tabController.index == 0) {
              _createNewFoodFavorite();
            } else {
              _createNewActivityFavorite();
            }
          },
          backgroundColor: AppColors.primary,
          child: Icon(MdiIcons.plus),
          tooltip: (showOnlyFoodTab || _tabController.index == 0) ? 'Ny mad favorit' : 'Ny aktivitet favorit',
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: AppDesign.backgroundGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header section
                Padding(
                  padding: const EdgeInsets.all(KSizes.margin4x),
                  child: Row(
                    children: [
                      // Back button when opened from home page
                      if (showOnlyFoodTab) ...[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(KSizes.radiusL),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              MdiIcons.arrowLeft,
                              color: AppColors.textPrimary,
                              size: KSizes.iconM,
                            ),
                          ),
                        ),
                        const SizedBox(width: KSizes.margin4x),
                      ],
                      // Header content
                      Expanded(
                        child: StandardPageHeader(
                          title: showOnlyFoodTab 
                              ? 'Vælg ${widget.initialFilter!.displayName}'
                              : 'Favoritter',
                          subtitle: showOnlyFoodTab 
                              ? 'Tryk på en favorit for at registrere den'
                              : 'Administrer dine gemte mad og aktiviteter',
                          icon: showOnlyFoodTab ? MdiIcons.foodApple : MdiIcons.heart,
                          iconColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Tab bar section (only if not filtered)
                if (!showOnlyFoodTab) 
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: KSizes.margin4x),
                    padding: EdgeInsets.all(KSizes.margin1x),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(KSizes.radiusL),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _tabController.animateTo(0),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: KSizes.margin3x),
                              decoration: BoxDecoration(
                                color: _tabController.index == 0 
                                    ? AppColors.primary 
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(KSizes.radiusM),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    MdiIcons.silverwareForkKnife,
                                    size: KSizes.iconS,
                                    color: _tabController.index == 0 
                                        ? Colors.white 
                                        : AppColors.textSecondary,
                                  ),
                                  SizedBox(width: KSizes.margin2x),
                                  Text(
                                    'Mad',
                                    style: TextStyle(
                                      fontSize: KSizes.fontSizeL,
                                      fontWeight: _tabController.index == 0 
                                          ? KSizes.fontWeightBold 
                                          : KSizes.fontWeightMedium,
                                      color: _tabController.index == 0 
                                          ? Colors.white 
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _tabController.animateTo(1),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: KSizes.margin3x),
                              decoration: BoxDecoration(
                                color: _tabController.index == 1 
                                    ? AppColors.primary 
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(KSizes.radiusM),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    MdiIcons.runFast,
                                    size: KSizes.iconS,
                                    color: _tabController.index == 1 
                                        ? Colors.white 
                                        : AppColors.textSecondary,
                                  ),
                                  SizedBox(width: KSizes.margin2x),
                                  Text(
                                    'Aktiviteter',
                                    style: TextStyle(
                                      fontSize: KSizes.fontSizeL,
                                      fontWeight: _tabController.index == 1 
                                          ? KSizes.fontWeightBold 
                                          : KSizes.fontWeightMedium,
                                      color: _tabController.index == 1 
                                          ? Colors.white 
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                SizedBox(height: KSizes.margin4x),
                
                // Content section
                Expanded(
                  child: showOnlyFoodTab 
                      ? // Show only food content when filtered
                        _isLoadingFood
                            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                            : _foodError != null
                                ? _buildErrorState(_foodError!, _loadAllFavorites)
                                : _buildFoodFavoritesTab()
                      : // Show both tabs when not filtered
                        TabBarView(
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
              ],
            ),
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
      // Different empty state for selection mode vs management mode
      if (widget.initialFilter != null) {
        return _buildSelectionEmptyState(
          icon: MdiIcons.silverwareForkKnife,
          title: 'Ingen ${widget.initialFilter!.displayName.toLowerCase()} favoritter endnu',
          subtitle: 'Du skal først tilføje ${widget.initialFilter!.displayName.toLowerCase()} favoritter før du kan vælge dem her.',
        );
      } else {
        return _buildEmptyState(
          icon: MdiIcons.silverwareForkKnife,
          title: 'Ingen mad-favoritter endnu',
          subtitle: 'Tilføj favoritter ved at markere måltider som favoritter når du kategoriserer dem, eller opret dem manuelt.',
          onAdd: _createNewFoodFavorite,
          addLabel: 'Opret Mad Favorit'
        );
      }
    }

    // Apply filtering
    List<FavoriteFoodModel> filteredFavorites = _selectedFoodFilter == null 
        ? _foodFavorites 
        : _foodFavorites.where((f) => f.foodType == _selectedFoodFilter).toList();

    // Separate filtered favorites by food type
    final meals = filteredFavorites.where((f) => f.foodType == FoodType.meal).toList();
    final ingredients = filteredFavorites.where((f) => f.foodType == FoodType.ingredient).toList();

    return RefreshIndicator(
      onRefresh: _loadAllFavorites,
      child: Column(
        children: [
          // Filter segmented control - only show if no initial filter is set
          if (widget.initialFilter == null) ...[
            Container(
              padding: EdgeInsets.all(KSizes.margin4x),
              child: _buildFoodTypeFilter(),
            ),
          ],
          
          // Favorites list
          Expanded(
            child: filteredFavorites.isEmpty 
                ? _buildNoFilterResultsState()
                : ListView(
                    padding: EdgeInsets.symmetric(horizontal: KSizes.margin4x),
                    children: [
                      // Show sections based on what's available and filter
                      if (_selectedFoodFilter == null || _selectedFoodFilter == FoodType.meal)
                        _buildFoodSection(
                          title: 'Retter 🍽️',
                          subtitle: 'Komplette måltider og retter',
                          count: meals.length,
                          favorites: meals,
                          color: AppColors.primary,
                        ),
                      
                      if ((_selectedFoodFilter == null || _selectedFoodFilter == FoodType.ingredient) && 
                          (meals.isNotEmpty && ingredients.isNotEmpty && _selectedFoodFilter == null))
                        SizedBox(height: KSizes.margin4x),
                      
                      if (_selectedFoodFilter == null || _selectedFoodFilter == FoodType.ingredient)
                        _buildFoodSection(
                          title: 'Fødevarer 🥕',
                          subtitle: 'Individuelle ingredienser og fødevarer',
                          count: ingredients.length,
                          favorites: ingredients,
                          color: AppColors.secondary,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodTypeFilter() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(color: AppColors.border.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _buildFilterButton(
            label: 'Alle',
            isSelected: _selectedFoodFilter == null,
            onTap: () => setState(() => _selectedFoodFilter = null),
            emoji: '🍽️',
          ),
          _buildFilterButton(
            label: 'Retter',
            isSelected: _selectedFoodFilter == FoodType.meal,
            onTap: () => setState(() => _selectedFoodFilter = FoodType.meal),
            emoji: FoodType.meal.emoji,
          ),
          _buildFilterButton(
            label: 'Fødevarer',
            isSelected: _selectedFoodFilter == FoodType.ingredient,
            onTap: () => setState(() => _selectedFoodFilter = FoodType.ingredient),
            emoji: FoodType.ingredient.emoji,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required String emoji,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: KSizes.margin3x,
            horizontal: KSizes.margin2x,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(KSizes.radiusL),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: TextStyle(fontSize: KSizes.fontSizeM),
              ),
              SizedBox(width: KSizes.margin1x),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: KSizes.fontSizeS,
                    fontWeight: isSelected ? KSizes.fontWeightBold : KSizes.fontWeightMedium,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoFilterResultsState() {
    final filterName = _selectedFoodFilter?.displayName ?? 'Alle';
    final isFromHomePage = widget.initialFilter != null;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(KSizes.margin6x),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(KSizes.margin6x),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                _selectedFoodFilter?.emoji ?? '🔍',
                style: TextStyle(fontSize: 64),
              ),
            ),
            
            SizedBox(height: KSizes.margin4x),
            
            Text(
              isFromHomePage 
                ? 'Ingen ${filterName.toLowerCase()} favoritter endnu'
                : 'Ingen ${filterName.toLowerCase()} favoritter',
              style: TextStyle(
                fontSize: KSizes.fontSizeL,
                fontWeight: KSizes.fontWeightBold,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: KSizes.margin2x),
            
            Text(
              isFromHomePage
                ? 'Tilføj ${filterName.toLowerCase()} favoritter for nemt at finde dem her'
                : 'Prøv at vælge en anden kategori eller tilføj nye favoritter',
              style: TextStyle(
                fontSize: KSizes.fontSizeM,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodSection({
    required String title,
    required String subtitle,
    required int count,
    required List<FavoriteFoodModel> favorites,
    required Color color,
  }) {
    if (favorites.isEmpty) return SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Container(
          padding: EdgeInsets.all(KSizes.margin4x),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(KSizes.radiusM),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                ),
                child: Icon(
                  title.contains('Retter') ? MdiIcons.silverwareForkKnife : MdiIcons.carrot,
                  color: Colors.white,
                  size: KSizes.iconM,
                ),
              ),
              SizedBox(width: KSizes.margin3x),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$title ($count)',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: KSizes.margin3x),
        
        // Favorites list
        ...favorites.map((favorite) => Padding(
          padding: EdgeInsets.only(bottom: KSizes.margin3x),
          child: _buildFoodFavoriteCard(favorite),
        )),
      ],
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

  Widget _buildSelectionEmptyState({
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
    // Get color based on food type
    final cardColor = favorite.foodType == FoodType.ingredient 
        ? AppColors.secondary 
        : _getMealColor(favorite.preferredMealType);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: KSizes.margin3x),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        side: BorderSide(color: AppColors.border.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: () => widget.initialFilter != null 
            ? _handleFavoriteFromHomePage(favorite) // Different behavior for meals vs ingredients
            : _editFoodFavorite(favorite), // Edit mode when from favorites tab
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
                  color: cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                ),
                child: Icon(
                  favorite.foodType == FoodType.ingredient 
                      ? MdiIcons.carrot 
                      : _getMealIcon(favorite.preferredMealType),
                  color: cardColor,
                  size: KSizes.iconM,
                ),
              ),
              SizedBox(width: KSizes.margin3x),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
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
                        // Scannet badge for barcode items
                        if (favorite.barcodeData?.isNotEmpty == true) ...[
                          SizedBox(width: KSizes.margin2x),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: KSizes.margin2x,
                              vertical: KSizes.margin1x,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.info,
                              borderRadius: BorderRadius.circular(KSizes.radiusXS),
                            ),
                            child: Text(
                              'Scannet',
                              style: TextStyle(
                                fontSize: KSizes.fontSizeXS,
                                color: Colors.white,
                                fontWeight: KSizes.fontWeightMedium,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: KSizes.margin1x),
                    Text(
                      favorite.foodType == FoodType.meal
                          ? '${favorite.mealTypeDisplayName} • ${favorite.defaultServingCalories} kcal'
                          : '${favorite.foodType.description} • ${favorite.defaultServingCalories} kcal',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Only show popup menu when NOT coming from home page
              if (widget.initialFilter == null)
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
              // Add brand info chip for scanned items
              if (favorite.tags.isNotEmpty) ...[
                SizedBox(width: KSizes.margin2x),
                _buildInfoChip(favorite.tags.first, MdiIcons.tag),
              ],
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
    _showAddFavoriteOptions();
  }

  void _showAddFavoriteOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(KSizes.margin4x),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(KSizes.radiusXL),
            topRight: Radius.circular(KSizes.radiusXL),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: KSizes.margin4x),
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Text(
              'Tilføj Mad Favorit',
              style: TextStyle(
                fontSize: KSizes.fontSizeXL,
                fontWeight: KSizes.fontWeightBold,
                color: AppColors.textPrimary,
              ),
            ),
            
            SizedBox(height: KSizes.margin2x),
            
            Text(
              'Vælg hvordan du vil tilføje din favorit',
              style: TextStyle(
                fontSize: KSizes.fontSizeM,
                color: AppColors.textSecondary,
              ),
            ),
            
            SizedBox(height: KSizes.margin6x),
            
            // Create meal option
            _buildOptionCard(
              icon: MdiIcons.silverwareForkKnife,
              title: 'Opret Ret',
              subtitle: 'Tilføj en ret eller måltid manuelt',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                _navigateToCreateMeal();
              },
            ),
            
            SizedBox(height: KSizes.margin3x),
            
            // Scan ingredient option
            _buildOptionCard(
              icon: MdiIcons.barcodeScan,
              title: 'Scan Fødevare',
              subtitle: 'Scan stregkode på fødevarer (automatisk portionsberegning)',
              color: AppColors.secondary,
              onTap: () {
                Navigator.pop(context);
                _navigateToBarcodeScan();
              },
            ),
            
            SizedBox(height: KSizes.margin6x),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        child: Container(
          padding: EdgeInsets.all(KSizes.margin4x),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(KSizes.radiusL),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: KSizes.iconL,
                ),
              ),
              
              SizedBox(width: KSizes.margin4x),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: KSizes.margin1x),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              
              Icon(
                MdiIcons.chevronRight,
                color: AppColors.textTertiary,
                size: KSizes.iconM,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToCreateMeal() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FoodFavoriteDetailPage(
          logOnSave: false,
          forcedFoodType: FoodType.meal,
        ),
      ),
    );
    if (result != null && result is FavoriteFoodModel || result == true) { 
      _loadAllFavorites();
    }
  }

  Future<void> _navigateToBarcodeScan() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BarcodeScannerWidget(
          onFoodFound: (favorite) {
            // Return the favorite and close the scanner
            Navigator.of(context).pop(favorite);
          },
          onClose: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
    
    if (result != null && result is FavoriteFoodModel) {
      try {
        // Save the scanned food as a favorite
        final saveResult = await _foodService.addToFavorites(result);
        
        if (saveResult.isSuccess) {
          // Show success message only - no log prompt
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result.foodName} tilføjet til favoritter!'),
              backgroundColor: AppColors.success,
            ),
          );
          
          _loadAllFavorites();
        } else {
          // Show error if save failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kunne ikke gemme ${result.foodName} som favorit'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved gemning af favorit: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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

  void _handleFavoriteFromHomePage(FavoriteFoodModel favorite) async {
    if (favorite.foodType == FoodType.meal) {
      // Retter: Log direkte med standard portionsstørrelse
      _logFavoriteDirectly(favorite);
    } else {
      // Fødevarer: Vis portions popup
      _selectPortionForFavorite(favorite);
    }
  }
  
  void _logFavoriteDirectly(FavoriteFoodModel favorite) async {
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
        
        // Navigate back to home page
        Navigator.of(context).pop();
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
  
  void _selectPortionForFavorite(FavoriteFoodModel favorite) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => SmartPortionSelectionDialog(
        food: favorite,
        onPortionSelected: (double grams, String unitName, String displayName) async {
          try {
            // Create food log with selected portion
            final foodLog = UserFoodLogModel(
              foodName: favorite.foodName,
              quantity: grams / 100, // Convert to appropriate quantity
              servingUnit: unitName,
              calories: (favorite.caloriesPer100g * grams / 100).round(),
              protein: favorite.proteinPer100g * grams / 100,
              fat: favorite.fatPer100g * grams / 100,
              carbs: favorite.carbsPer100g * grams / 100,
              mealType: _getCurrentMealType(),
              loggedAt: DateTime.now().toIso8601String(),
              foodItemSourceType: FoodItemSourceType.custom,
            );
            
            // Log the food
            await ref.read(foodLoggingProvider.notifier).logFood(foodLog);
            
            // Update favorite usage count
            final updatedFavorite = favorite.withUpdatedUsage();
            await _foodService.updateFavorite(updatedFavorite);
            
            // Close dialog first
            Navigator.of(context).pop(true);
            
          } catch (e) {
            // Close dialog and show error
            Navigator.of(context).pop(false);
          }
        },
      ),
    );
    
    // Handle result after dialog is closed
    if (mounted) {
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${favorite.foodName} er tilføjet som måltid!'),
            backgroundColor: AppColors.success,
          ),
        );
        // Navigate back to home page
        Navigator.of(context).pop();
      } else if (result == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved tilføjelse af måltid'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  MealType _getCurrentMealType() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 10) return MealType.morgenmad;
    if (hour >= 10 && hour < 14) return MealType.frokost;
    if (hour >= 14 && hour < 18) return MealType.snack;
    return MealType.aftensmad;
  }
} 