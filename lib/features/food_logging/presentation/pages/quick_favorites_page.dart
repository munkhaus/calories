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
import '../widgets/barcode_scanner_widget.dart';

/// Page for quick selection and management of food favorites with sections
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
  
  List<FavoriteFoodModel> _mealFavorites = [];
  List<FavoriteFoodModel> _ingredientFavorites = [];
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
      final foodResult = await _foodService.getAllFavorites();
      if (foodResult.isSuccess && mounted) {
        final allFavorites = foodResult.success;
        
        // Separate into meals and ingredients
        _mealFavorites = allFavorites.where((f) => f.foodType == FoodType.meal).toList();
        _ingredientFavorites = allFavorites.where((f) => f.foodType == FoodType.ingredient).toList();
        
        // Sort by usage and last used
        _mealFavorites.sort((a, b) => b.usageCount.compareTo(a.usageCount));
        _ingredientFavorites.sort((a, b) => b.usageCount.compareTo(a.usageCount));
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
        title: const Text('Mad Favoritter'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      floatingActionButton: widget.showAddButton ? 
        FloatingActionButton(
          heroTag: "food_fab",
          onPressed: () => _showAddFavoriteOptions(),
          backgroundColor: AppColors.primary,
          child: Icon(MdiIcons.plus),
          tooltip: 'Ny favorit',
        )
      : null, 
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildFavoritesContent(),
      ),
    );
  }

  Widget _buildFavoritesContent() {
    final hasAnyFavorites = _mealFavorites.isNotEmpty || _ingredientFavorites.isNotEmpty;
    
    if (!hasAnyFavorites) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(KSizes.margin4x),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meals section
          _buildSectionHeader(
            icon: FoodType.meal.emoji,
            title: FoodType.meal.displayName,
            subtitle: FoodType.meal.description,
            count: _mealFavorites.length,
          ),
          SizedBox(height: KSizes.margin3x),
          
          if (_mealFavorites.isEmpty)
            _buildEmptySection('Ingen retter gemt endnu')
          else
            ..._mealFavorites.map((f) => _buildFavoriteCard(f)).toList(),
          
          SizedBox(height: KSizes.margin6x),
          
          // Ingredients section
          _buildSectionHeader(
            icon: FoodType.ingredient.emoji,
            title: FoodType.ingredient.displayName,
            subtitle: FoodType.ingredient.description,
            count: _ingredientFavorites.length,
          ),
          SizedBox(height: KSizes.margin3x),
          
          if (_ingredientFavorites.isEmpty)
            _buildEmptySection('Ingen fødevarer gemt endnu\nScan en stregkode for at tilføje')
          else
            ..._ingredientFavorites.map((f) => _buildFavoriteCard(f)).toList(),
          
          SizedBox(height: KSizes.margin8x), // Extra space for FAB
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String icon,
    required String title,
    required String subtitle,
    required int count,
  }) {
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        gradient: AppDesign.primaryGradient.scale(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(KSizes.margin3x),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(KSizes.radiusM),
            ),
            child: Text(
              icon,
              style: TextStyle(fontSize: KSizes.fontSizeXL),
            ),
          ),
          SizedBox(width: KSizes.margin4x),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: KSizes.margin2x),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: KSizes.margin2x,
                        vertical: KSizes.margin1x,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeS,
                          fontWeight: KSizes.fontWeightMedium,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: KSizes.margin1x),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    color: AppColors.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: KSizes.fontSizeM,
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFavoriteCard(FavoriteFoodModel favorite) {
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
            border: Border.all(
              color: favorite.foodType == FoodType.meal 
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.secondary.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: (favorite.foodType == FoodType.meal 
                    ? AppColors.primary 
                    : AppColors.secondary).withOpacity(0.1),
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
                  color: (favorite.foodType == FoodType.meal 
                      ? AppColors.primary 
                      : AppColors.secondary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Text(
                  favorite.foodType.emoji,
                  style: TextStyle(fontSize: KSizes.fontSizeL),
                ),
              ),
              
              SizedBox(width: KSizes.margin4x),
              
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
                        if (favorite.source == FoodSource.barcode)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: KSizes.margin2x,
                              vertical: KSizes.margin1x,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(KSizes.radiusS),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  MdiIcons.barcode,
                                  size: KSizes.iconXS,
                                  color: AppColors.info,
                                ),
                                SizedBox(width: KSizes.margin1x),
                                Text(
                                  'Scannet',
                                  style: TextStyle(
                                    fontSize: KSizes.fontSizeXS,
                                    color: AppColors.info,
                                    fontWeight: KSizes.fontWeightMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: KSizes.margin1x),
                    Row(
                      children: [
                        Text(
                          '${favorite.defaultServingCalories} kcal',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeM,
                            color: AppColors.textSecondary,
                            fontWeight: KSizes.fontWeightMedium,
                          ),
                        ),
                        Text(' • ', style: TextStyle(color: AppColors.textTertiary)),
                        Text(
                          '${favorite.defaultQuantity} ${favorite.defaultServingUnit}',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeM,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (favorite.description.isNotEmpty) ...[
                      SizedBox(height: KSizes.margin1x),
                      Text(
                        favorite.description,
                        style: TextStyle(
                          fontSize: KSizes.fontSizeS,
                          color: AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Menu button with actions
              PopupMenuButton<String>(
                onSelected: (value) => _handleFavoriteAction(value, favorite),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'use',
                    child: Row(
                      children: [
                        Icon(MdiIcons.plus, color: AppColors.success, size: KSizes.iconS),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin6x),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(KSizes.margin6x),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                MdiIcons.silverwareForkKnife,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: KSizes.margin4x),
            Text(
              'Ingen favoritter endnu',
              style: TextStyle(
                fontSize: KSizes.fontSizeL,
                color: AppColors.textPrimary,
                fontWeight: KSizes.fontWeightBold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: KSizes.margin2x),
            Text(
              widget.showAddButton 
                  ? 'Tryk på + knappen for at tilføje retter eller scan fødevarer'
                  : 'Du kan gemme favoritter når du kategoriserer mad eller logger måltider.',
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

  void _showAddFavoriteOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: AppDesign.primaryGradient,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(KSizes.radiusXL),
            topRight: Radius.circular(KSizes.radiusXL),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: KSizes.margin4x),
              Text(
                'Tilføj ny favorit',
                style: TextStyle(
                  fontSize: KSizes.fontSizeXL,
                  fontWeight: KSizes.fontWeightBold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: KSizes.margin6x),
              
              // Meal option
              _buildAddOption(
                icon: FoodType.meal.emoji,
                title: 'Opret ${FoodType.meal.displayName}',
                subtitle: 'Komplette måltider og retter',
                onTap: () {
                  Navigator.of(context).pop();
                  _createNewMealFavorite();
                },
              ),
              
              SizedBox(height: KSizes.margin3x),
              
              // Ingredient option
              _buildAddOption(
                icon: FoodType.ingredient.emoji,
                title: 'Scan ${FoodType.ingredient.displayName}',
                subtitle: 'Scan stregkode for ernæringsdata',
                onTap: () {
                  Navigator.of(context).pop();
                  _showBarcodeScanner();
                },
              ),
              
              SizedBox(height: KSizes.margin6x),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddOption({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: KSizes.margin4x),
        padding: EdgeInsets.all(KSizes.margin4x),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(KSizes.radiusL),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(KSizes.margin3x),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(KSizes.radiusM),
              ),
              child: Text(
                icon,
                style: TextStyle(fontSize: KSizes.fontSizeL),
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
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: KSizes.margin1x),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: KSizes.fontSizeM,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              MdiIcons.chevronRight,
              color: Colors.white.withOpacity(0.8),
              size: KSizes.iconM,
            ),
          ],
        ),
      ),
    );
  }

  void _createNewMealFavorite() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FoodFavoriteDetailPage(
          logOnSave: true,
          forcedFoodType: FoodType.meal,
        ),
      ),
    );
    
    if (result != null) {
      if (result is FavoriteFoodModel) {
        await _useFoodFavorite(result);
      }
      _loadFavorites();
    }
  }

  void _showBarcodeScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          body: BarcodeScannerWidget(
            onFoodFound: (favorite) => _handleScannedFood(favorite),
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  void _handleScannedFood(FavoriteFoodModel scannedFood) async {
    Navigator.of(context).pop(); // Close scanner
    
    // Show portion selection dialog
    final portionInfo = await _showPortionSelectionDialog(scannedFood);
    if (portionInfo == null) return;
    
    try {
      // Create a copy with user's preferred portion
      final favoriteWithPortion = scannedFood.copyWith(
        defaultQuantity: portionInfo['grams'],
        defaultServingUnit: 'gram',
        defaultServingGrams: portionInfo['grams'],
        totalCaloriesForServing: ((scannedFood.caloriesPer100g * portionInfo['grams']) / 100).round(),
      );
      
      // Save to favorites only - no log prompt
      final result = await _foodService.addToFavorites(favoriteWithPortion);
      if (result.isSuccess) {
        _loadFavorites();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${favoriteWithPortion.foodName} tilføjet til favoritter'),
              backgroundColor: AppColors.success,
            ),
          );
        }
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

  Future<Map<String, dynamic>?> _showPortionSelectionDialog(FavoriteFoodModel food) async {
    final gramController = TextEditingController(text: '100');
    final pieceController = TextEditingController(text: '1');
    bool useGrams = true;
    
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Portionsstørrelse for ${food.foodName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hvor meget vil du typisk spise?',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              SizedBox(height: KSizes.margin4x),
              
              // Toggle between grams and pieces
              ToggleButtons(
                isSelected: [useGrams, !useGrams],
                onPressed: (index) => setState(() => useGrams = index == 0),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: KSizes.margin3x),
                    child: Text('Gram'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: KSizes.margin3x),
                    child: Text('Styk'),
                  ),
                ],
              ),
              
              SizedBox(height: KSizes.margin4x),
              
              if (useGrams)
                TextField(
                  controller: gramController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Gram',
                    suffix: Text('g'),
                    border: OutlineInputBorder(),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: pieceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Antal',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: KSizes.margin2x),
                    Text('styk à 100g'),
                  ],
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuller'),
            ),
            ElevatedButton(
              onPressed: () {
                final grams = useGrams 
                    ? double.tryParse(gramController.text) ?? 100.0
                    : (double.tryParse(pieceController.text) ?? 1.0) * 100.0;
                    
                Navigator.of(context).pop({
                  'grams': grams,
                  'useGrams': useGrams,
                });
              },
              child: Text('Gem'),
            ),
          ],
        ),
      ),
    );
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
    
    if (result != null) {
      _loadFavorites();
    }
  }

  /// Use food favorite with better UX
  Future<void> _useFoodFavorite(FavoriteFoodModel favorite) async {
    try {
      UserFoodLogModel foodLog;
      
      // If it's an ingredient, show gram selection dialog
      if (favorite.foodType == FoodType.ingredient) {
        final gramSelection = await _showGramSelectionDialog(favorite);
        if (gramSelection == null) return; // User cancelled
        
        // Create food log with custom gram amount
        foodLog = favorite.toUserFoodLog(
          quantity: gramSelection['grams'],
          servingUnit: 'gram',
        );
      } else {
        // For meals, use default portion
        foodLog = favorite.toUserFoodLog();
      }

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
        final portionText = favorite.foodType == FoodType.ingredient 
            ? '${foodLog.quantity.round()}g'
            : '1 portion';
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${favorite.foodName} ($portionText) tilføjet - ${foodLog.calories} kcal'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
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

  /// Show dialog for selecting gram amount for ingredients
  Future<Map<String, dynamic>?> _showGramSelectionDialog(FavoriteFoodModel favorite) {
    final gramController = TextEditingController(text: '100');
    
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusL),
        ),
        title: Row(
          children: [
            Icon(MdiIcons.scaleBalance, color: AppColors.secondary),
            SizedBox(width: KSizes.margin2x),
            Expanded(
              child: Text(
                'Hvor meget ${favorite.foodName}?',
                style: TextStyle(fontSize: KSizes.fontSizeL),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Angiv antal gram du vil spise:',
              style: TextStyle(
                fontSize: KSizes.fontSizeM,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: KSizes.margin4x),
            
            // Gram input
            TextField(
              controller: gramController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Gram',
                suffixText: 'g',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                helperText: '${favorite.caloriesPer100g} kcal per 100g',
              ),
              onChanged: (value) {
                // Update calories preview in real time if needed
              },
            ),
            
            SizedBox(height: KSizes.margin4x),
            
            // Calories preview
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: gramController,
              builder: (context, value, child) {
                final grams = double.tryParse(value.text) ?? 0.0;
                final calories = (favorite.caloriesPer100g * grams / 100).round();
                
                return Container(
                  padding: EdgeInsets.all(KSizes.margin3x),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(MdiIcons.calculator, color: AppColors.info, size: KSizes.iconS),
                      SizedBox(width: KSizes.margin2x),
                      Text(
                        '${grams.round()}g = $calories kcal',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeM,
                          fontWeight: KSizes.fontWeightMedium,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuller'),
          ),
          ElevatedButton(
            onPressed: () {
              final grams = double.tryParse(gramController.text) ?? 100.0;
              Navigator.of(context).pop({
                'grams': grams,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            child: Text('Spis nu'),
          ),
        ],
      ),
    );
  }

  void _handleFavoriteAction(String value, FavoriteFoodModel favorite) {
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
      'Er du sikker på, at du vil slette denne favorit?',
    );

    if (confirmed == true) {
      try {
        final result = await _foodService.removeFromFavorites(favorite.id);
        if (result.isSuccess) {
          _loadFavorites();
          
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
            child: Text('Annuller'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Slet'),
          ),
        ],
      ),
    );
  }
} 