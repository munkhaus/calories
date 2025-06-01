import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../widgets/meal_type_selector.dart';
import '../../domain/user_food_log_model.dart';
import '../../domain/favorite_food_model.dart';
import '../../application/food_search_cubit.dart';
import '../../application/food_search_state.dart';
import '../../application/food_logging_notifier.dart';
import '../../../food_database/domain/online_food_models.dart';

/// Smart food addition page that combines search and actions
class AddFoodPage extends ConsumerStatefulWidget {
  final MealType? initialMealType;

  const AddFoodPage({
    super.key,
    this.initialMealType,
  });

  @override
  ConsumerState<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends ConsumerState<AddFoodPage> {
  final TextEditingController _searchController = TextEditingController();
  MealType _selectedMealType = MealType.morgenmad;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.initialMealType ?? MealType.none;
    
    // Initialize the search cubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🍽️ AddFoodPage: Initializing FoodSearchCubit');
      ref.read(foodSearchProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    print('🍽️ AddFoodPage: Searching for: "$query"');
    if (query.trim().isEmpty) {
      ref.read(foodSearchProvider.notifier).loadFavoritesByMealType(_selectedMealType);
    } else {
      ref.read(foodSearchProvider.notifier).searchFood(query.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(foodSearchProvider);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button and header
              Padding(
                padding: const EdgeInsets.all(KSizes.margin4x),
                child: Row(
                  children: [
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
                    Expanded(
                      child: StandardPageHeader(
                        title: 'Tilføj Mad 🍽️',
                        subtitle: 'Søg, spis nu eller gem som favorit',
                        icon: MdiIcons.plus,
                        iconColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: KSizes.margin4x),
                  child: Column(
                    children: [
                      // Meal Type Selector
                      Container(
                        padding: EdgeInsets.all(KSizes.margin4x),
                        child: MealTypeSelector(
                          selectedMealType: _selectedMealType,
                          onMealTypeChanged: (mealType) {
                            setState(() => _selectedMealType = mealType);
                            if (_searchController.text.trim().isEmpty) {
                              ref.read(foodSearchProvider.notifier).loadFavoritesByMealType(mealType);
                            }
                          },
                        ),
                      ),
                      
                      // Search Bar
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: KSizes.margin4x),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Søg efter mad...',
                            prefixIcon: Icon(
                              MdiIcons.magnify,
                              color: AppColors.textSecondary,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(MdiIcons.close),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(KSizes.radiusL),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: _onSearchChanged,
                        ),
                      ),
                      
                      SizedBox(height: KSizes.margin4x),
                      
                      // Search Results
                      Expanded(
                        child: _buildSearchResults(searchState),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(FoodSearchState state) {
    if (state.isLoading || state.isSearchingFavorites || state.isSearchingOnline) {
      return _buildLoadingState(state);
    }

    if (state.searchQuery.isEmpty) {
      return _buildQuickSuggestions(state);
    }

    return _buildCombinedResults(state);
  }

  Widget _buildLoadingState(FoodSearchState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: KSizes.margin4x),
          Text(
            state.isSearchingFavorites 
                ? 'Søger i favoritter...'
                : state.isSearchingOnline 
                    ? 'Søger online...'
                    : 'Indlæser...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: KSizes.fontSizeM,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions(FoodSearchState state) {
    if (state.quickSuggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MdiIcons.silverwareForkKnife,
              size: 64,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: KSizes.margin4x),
            Text(
              'Søg efter mad',
              style: TextStyle(
                fontSize: KSizes.fontSizeL,
                fontWeight: KSizes.fontWeightBold,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: KSizes.margin2x),
            Text(
              'Skriv madnavn for at finde og tilføje mad',
              style: TextStyle(
                fontSize: KSizes.fontSizeM,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: KSizes.margin4x),
          child: Text(
            'Hurtige forslag',
            style: TextStyle(
              fontSize: KSizes.fontSizeL,
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(height: KSizes.margin3x),
        Expanded(
          child: ListView.builder(
            itemCount: state.quickSuggestions.length,
            itemBuilder: (context, index) {
              final favorite = state.quickSuggestions[index];
              return _buildFavoriteCard(favorite);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCombinedResults(FoodSearchState state) {
    final hasResults = state.favoriteResults.isNotEmpty || state.onlineResults.isNotEmpty;
    
    print('🍽️ AddFoodPage: Found ${state.favoriteResults.length} favorites, ${state.onlineResults.length} online results');
    
    if (!hasResults) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MdiIcons.magnify,
              size: 64,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: KSizes.margin4x),
            Text(
              'Ingen resultater',
              style: TextStyle(
                fontSize: KSizes.fontSizeL,
                fontWeight: KSizes.fontWeightBold,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: KSizes.margin2x),
            Text(
              'Prøv en anden søgning',
              style: TextStyle(
                fontSize: KSizes.fontSizeM,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        // Favorite Results Section
        if (state.favoriteResults.isNotEmpty) ...[
          _buildSectionHeader('Mine Favoritter', MdiIcons.star, AppColors.warning),
          SizedBox(height: KSizes.margin2x),
          ...state.favoriteResults.map((favorite) => _buildFavoriteCard(favorite)).toList(),
          SizedBox(height: KSizes.margin4x),
        ],
        
        // Online Results Section
        if (state.onlineResults.isNotEmpty) ...[
          _buildSectionHeader('Online Søgning', MdiIcons.web, AppColors.info),
          SizedBox(height: KSizes.margin2x),
          ...state.onlineResults.map((result) => _buildOnlineResultCard(result)).toList(),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: KSizes.margin4x),
      child: Row(
        children: [
          Icon(icon, color: color, size: KSizes.iconM),
          SizedBox(width: KSizes.margin2x),
          Text(
            title,
            style: TextStyle(
              fontSize: KSizes.fontSizeL,
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(FavoriteFoodModel favorite) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: KSizes.margin4x,
        vertical: KSizes.margin2x,
      ),
      child: Container(
        padding: EdgeInsets.all(KSizes.margin4x),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(KSizes.radiusL),
          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.warning.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food info header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(KSizes.margin3x),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                  ),
                  child: Icon(
                    MdiIcons.star,
                    color: AppColors.warning,
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
                        '${favorite.defaultServingCalories} kcal • ${favorite.mealTypeDisplayName}',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeM,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: KSizes.margin4x),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              height: KSizes.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: () => _useNow(favorite),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                  ),
                  elevation: 2,
                ),
                icon: Icon(MdiIcons.silverwareForkKnife, size: KSizes.iconS),
                label: Text(
                  'Spis Nu',
                  style: TextStyle(
                    fontWeight: KSizes.fontWeightBold,
                    fontSize: KSizes.fontSizeM,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineResultCard(OnlineFoodResult result) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: KSizes.margin4x,
        vertical: KSizes.margin2x,
      ),
      child: Container(
        padding: EdgeInsets.all(KSizes.margin4x),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(KSizes.radiusL),
          border: Border.all(color: AppColors.info.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.info.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food info header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(KSizes.margin3x),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                  ),
                  child: Icon(
                    MdiIcons.web,
                    color: AppColors.info,
                    size: KSizes.iconM,
                  ),
                ),
                SizedBox(width: KSizes.margin3x),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.name,
                        style: TextStyle(
                          fontSize: KSizes.fontSizeL,
                          fontWeight: KSizes.fontWeightBold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: KSizes.margin1x),
                      Text(
                        result.description,
                        style: TextStyle(
                          fontSize: KSizes.fontSizeM,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: KSizes.margin4x),
            
            // Action Buttons Row
            Row(
              children: [
                // Use Now Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _useOnlineNow(result),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                      ),
                      padding: EdgeInsets.symmetric(vertical: KSizes.margin3x),
                    ),
                    icon: Icon(MdiIcons.silverwareForkKnife, size: KSizes.iconXS),
                    label: Text(
                      'Spis Nu',
                      style: TextStyle(
                        fontWeight: KSizes.fontWeightMedium,
                        fontSize: KSizes.fontSizeS,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: KSizes.margin2x),
                
                // Save Favorite Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _saveFavorite(result),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                      ),
                      padding: EdgeInsets.symmetric(vertical: KSizes.margin3x),
                    ),
                    icon: Icon(MdiIcons.star, size: KSizes.iconXS),
                    label: Text(
                      'Gem',
                      style: TextStyle(
                        fontWeight: KSizes.fontWeightMedium,
                        fontSize: KSizes.fontSizeS,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: KSizes.margin2x),
                
                // Both Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _useAndSave(result),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                      ),
                      padding: EdgeInsets.symmetric(vertical: KSizes.margin3x),
                    ),
                    icon: Icon(MdiIcons.heartPlus, size: KSizes.iconXS),
                    label: Text(
                      'Begge',
                      style: TextStyle(
                        fontWeight: KSizes.fontWeightMedium,
                        fontSize: KSizes.fontSizeS,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _useFavorite(FavoriteFoodModel favorite) async {
    try {
      await ref.read(foodSearchProvider.notifier).useFavoriteFood(favorite);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${favorite.foodName} tilføjet til dagbog'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
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

  Future<void> _useOnlineResult(OnlineFoodResult result) async {
    try {
      // First get details for the online food
      await ref.read(foodSearchProvider.notifier).getOnlineFoodDetails(result.id);
      
      final searchState = ref.read(foodSearchProvider);
      if (searchState.selectedOnlineFoodDetails != null) {
        // Add to favorites with the selected meal type
        await ref.read(foodSearchProvider.notifier).addOnlineFoodToFavorites(
          searchState.selectedOnlineFoodDetails!,
          preferredMealType: _selectedMealType,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result.name} tilføjet til favoritter'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        throw Exception('Kunne ikke hente maddetaljer');
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

  Future<void> _useNow(FavoriteFoodModel favorite) async {
    try {
      await ref.read(foodSearchProvider.notifier).useFavoriteFood(favorite);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${favorite.foodName} tilføjet til dagbog'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
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

  Future<void> _useOnlineNow(OnlineFoodResult result) async {
    try {
      await ref.read(foodSearchProvider.notifier).useOnlineFoodNow(result.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.name} tilføjet til dagbog'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
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

  Future<void> _saveFavorite(OnlineFoodResult result) async {
    try {
      await ref.read(foodSearchProvider.notifier).saveFavoriteFood(result.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.name} tilføjet til favoritter'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
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

  Future<void> _useAndSave(OnlineFoodResult result) async {
    try {
      await ref.read(foodSearchProvider.notifier).useOnlineFoodAndSave(result.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.name} tilføjet til favoritter'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
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
} 