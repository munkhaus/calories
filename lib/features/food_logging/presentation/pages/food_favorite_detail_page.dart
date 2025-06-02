import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/favorite_food_model.dart';
import '../../domain/user_food_log_model.dart';
import '../../infrastructure/favorite_food_service.dart';
import '../../../food_database/infrastructure/llm_food_service.dart' as llm_service;
import '../../../food_database/domain/online_food_models.dart' as online_models;
import '../../../food_database/application/online_food_cubit.dart';

/// Detailed page for creating and editing food favorites
class FoodFavoriteDetailPage extends ConsumerStatefulWidget {
  final FavoriteFoodModel? existingFavorite;
  final bool logOnSave; // New parameter
  final FoodType? forcedFoodType; // Force a specific food type
  
  FoodFavoriteDetailPage({
    super.key,
    this.existingFavorite,
    this.logOnSave = false, // Default to false
    this.forcedFoodType, // Optional parameter to force food type
  });

  @override
  ConsumerState<FoodFavoriteDetailPage> createState() => _FoodFavoriteDetailPageState();
}

class _FoodFavoriteDetailPageState extends ConsumerState<FoodFavoriteDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController(); // This will hold TOTAL calories (read-only)
  final _notesController = TextEditingController();

  // Calculator controllers (always used)
  final _caloriesPer100gController = TextEditingController();
  final _portionGramsController = TextEditingController();
  
  MealType _selectedMealType = MealType.none;
  bool _isLoading = false;
  bool _isEditing = false;
  online_models.OnlineFoodDetails? _currentAiFoodDetails; // To store fetched AI result details for saving
  late bool _logOnSave; // State variable

  @override
  void initState() {
    super.initState();
    _isEditing = widget.existingFavorite != null;
    _logOnSave = widget.logOnSave; // Initialize from widget

    // Use selectedFoodDetails from the provider if available for a new favorite
    _currentAiFoodDetails = ref.read(onlineFoodProvider).selectedFoodDetails;
    
    if (_isEditing) {
      final favorite = widget.existingFavorite!;
      _nameController.text = favorite.foodName;
      _notesController.text = favorite.description;
      _selectedMealType = favorite.preferredMealType;

      _caloriesPer100gController.text = favorite.caloriesPer100g > 0 
                                          ? favorite.caloriesPer100g.toStringAsFixed(0) 
                                          : '0';
      _portionGramsController.text = favorite.defaultServingGrams > 0
                                        ? favorite.defaultServingGrams.toStringAsFixed(0)
                                        : (favorite.defaultQuantity > 0 && favorite.defaultServingUnit == 'gram' 
                                            ? favorite.defaultQuantity.toStringAsFixed(0) 
                                            : '100');
      _calculateTotalCalories();
    } else if (_currentAiFoodDetails != null) {
      // New favorite from AI search (using full details)
      _nameController.text = _currentAiFoodDetails!.basicInfo.name;
      _notesController.text = _currentAiFoodDetails!.basicInfo.description;
      
      _caloriesPer100gController.text = _currentAiFoodDetails!.nutrition.calories > 0 
                                          ? _currentAiFoodDetails!.nutrition.calories.toStringAsFixed(0)
                                          : '0';

      final defaultServing = _currentAiFoodDetails!.servingSizes.firstWhere(
        (s) => s.isDefault || s.name.toLowerCase().contains('standard') || s.name.toLowerCase().contains('portion'),
        orElse: () => _currentAiFoodDetails!.servingSizes.isNotEmpty 
                      ? _currentAiFoodDetails!.servingSizes.first 
                      : const online_models.OnlineServingSize(name: '100 gram', grams: 100, isDefault: true),
      );
      _portionGramsController.text = defaultServing.grams > 0 ? defaultServing.grams.toStringAsFixed(0) : '100';
      
      _calculateTotalCalories();
    } else {
      // Defaults for new favorite (manual creation without AI search prior)
      _nameController.text = '';
      _notesController.text = '';
      _selectedMealType = MealType.none;
      _caloriesPer100gController.text = '0';
      _portionGramsController.text = '100'; 
      _calculateTotalCalories();
    }

    _caloriesPer100gController.addListener(_calculateTotalCalories);
    _portionGramsController.addListener(_calculateTotalCalories);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    
    _caloriesPer100gController.removeListener(_calculateTotalCalories);
    _portionGramsController.removeListener(_calculateTotalCalories);
    _caloriesPer100gController.dispose();
    _portionGramsController.dispose();
    super.dispose();
  }

  void _calculateTotalCalories() {
    // Only calculate for ingredients, not for meals
    if (_getFoodType() == FoodType.ingredient) {
      final calories100 = double.tryParse(_caloriesPer100gController.text);
      final grams = double.tryParse(_portionGramsController.text);

      if (calories100 != null && calories100 >= 0 && grams != null && grams >= 0) {
        final totalCalories = (calories100 / 100.0) * grams;
        if (_caloriesController.text != totalCalories.round().toString()){
          _caloriesController.text = totalCalories.round().toString();
        }
      } else {
         if (_caloriesController.text != '0'){
           _caloriesController.text = '0';
         }
      }
    }
    // For meals, we don't calculate anything since they enter total calories directly
  }

  FoodType _getFoodType() {
    // Use forced food type if provided
    if (widget.forcedFoodType != null) {
      return widget.forcedFoodType!;
    }
    
    // If editing existing favorite, use its food type
    if (_isEditing && widget.existingFavorite != null) {
      return widget.existingFavorite!.foodType;
    }
    
    // For new favorites, default to meal
    return FoodType.meal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Rediger Mad Favorit' : 'Ny Mad Favorit'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveFavorite,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : Text(
                    'Gem',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: KSizes.fontWeightBold,
                    ),
                  ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(KSizes.margin4x),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  _isEditing ? 'Rediger din mad favorit' : 'Opret en ny mad favorit',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeXL,
                    fontWeight: KSizes.fontWeightBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                SizedBox(height: KSizes.margin2x),
                
                Text(
                  'Indtast de vigtigste oplysninger om din favorit mad',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    color: AppColors.textSecondary,
                  ),
                ),
                
                SizedBox(height: KSizes.margin6x),
                
                // Food name with AI search button
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _nameController,
                        label: 'Navn på mad',
                        hint: 'f.eks. Havregrød med frugt',
                        icon: MdiIcons.silverwareForkKnife,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Indtast navn på mad';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    SizedBox(width: KSizes.margin2x),
                    
                    // AI Search Button
                    Container(
                      height: 56, // Match text field height
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: IconButton(
                        onPressed: () {
                          final nameText = _nameController.text.trim();
                          if (nameText.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Skriv først et navn på maden'),
                                backgroundColor: AppColors.warning,
                              ),
                            );
                            return;
                          }
                          
                          _showAiSearchDialog(nameText);
                        },
                        icon: Icon(
                          MdiIcons.robot,
                          color: AppColors.primary,
                        ),
                        tooltip: 'Søg med AI',
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: KSizes.margin4x),
                
                // Meal type dropdown (always visible)
                _buildMealTypeDropdown(),
                
                SizedBox(height: KSizes.margin4x),
                
                // ALWAYS SHOWN: Calories per 100g for ingredients, total calories for meals
                _buildTextField(
                  controller: _caloriesPer100gController,
                  label: _getFoodType() == FoodType.meal 
                      ? 'Total kalorier for retten'
                      : 'Kalorier pr. 100 gram',
                  hint: _getFoodType() == FoodType.meal 
                      ? 'f.eks. 450' 
                      : 'f.eks. 150',
                  icon: MdiIcons.fire,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                    if (value == null || value.isEmpty) {
                      return _getFoodType() == FoodType.meal 
                          ? 'Indtast total kalorier for retten'
                          : 'Indtast kalorier pr. 100g';
                    }
                    if (double.tryParse(value) == null) return 'Ugyldigt tal';
                    if (double.parse(value) < 0) return 'Kalorier kan ikke være negative';
                          return null;
                        },
                      ),
                SizedBox(height: KSizes.margin4x),

                // Only show portion fields for meals, not for ingredients
                if (_getFoodType() == FoodType.meal) ...[
                  _buildTextField(
                    controller: _portionGramsController,
                    label: 'Portionsstørrelse (gram)',
                    hint: 'f.eks. 350 (vægten af hele retten)',
                    icon: MdiIcons.weightGram,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Indtast portionsstørrelse';
                      }
                      if (double.tryParse(value) == null) return 'Ugyldigt tal';
                      if (double.parse(value) <= 0) return 'Portion skal være mere end 0';
                      return null;
                    },
                  ),
                  SizedBox(height: KSizes.margin4x),
                ],
                
                // No calculated calories field for ingredients since no reference portion is set
                
                SizedBox(height: KSizes.margin4x),
                
                // Notes
                _buildTextField(
                  controller: _notesController,
                  label: 'Noter (valgfrit)',
                  hint: 'Eventuelle kommentarer...',
                  icon: MdiIcons.noteText,
                  maxLines: 3,
                ),
                
                SizedBox(height: KSizes.margin8x),
                
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveFavorite,
                    icon: _isLoading 
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(_isEditing ? MdiIcons.check : MdiIcons.plus),
                    label: Text(_isLoading 
                        ? 'Gemmer...' 
                        : _isEditing ? 'Opdater Favorit' : 'Opret Favorit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.all(KSizes.margin4x),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusL),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      style: TextStyle(color: AppColors.textPrimary, fontSize: KSizes.fontSizeM),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusM),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildMealTypeDropdown() {
    return DropdownButtonFormField<MealType>(
      value: _selectedMealType,
      decoration: InputDecoration(
        labelText: 'Måltidstype',
        prefixIcon: Icon(MdiIcons.clockTimeThree, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusM),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      items: MealType.values.map((mealType) {
        return DropdownMenuItem(
          value: mealType,
          child: Text(_getMealTypeDisplayName(mealType)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedMealType = value!;
        });
      },
    );
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

  Future<void> _saveFavorite() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    double caloriesPer100g;
    double totalCaloriesForServing;
    final portionGrams = double.tryParse(_portionGramsController.text) ?? 100.0;
    final inputCalories = double.tryParse(_caloriesPer100gController.text) ?? 0.0;
    
    if (_getFoodType() == FoodType.meal) {
      // For meals: input is total calories, calculate calories per 100g
      totalCaloriesForServing = inputCalories;
      caloriesPer100g = portionGrams > 0 ? (inputCalories / portionGrams) * 100.0 : 0.0;
    } else {
      // For ingredients: input is calories per 100g, calculate total calories
      caloriesPer100g = inputCalories;
      totalCaloriesForServing = (caloriesPer100g / 100.0) * portionGrams;
    }

    // Ensure servingSizes is initialized, possibly from _currentAiFoodDetails if available
    List<FavoriteServingSize> servingSizes = [];
    if (_currentAiFoodDetails != null) {
      servingSizes = _currentAiFoodDetails!.servingSizes.map((s) => FavoriteServingSize.fromOnlineServingInfo(s)).toList();
    } else if (_isEditing && widget.existingFavorite!.servingSizes.isNotEmpty) {
      servingSizes = List<FavoriteServingSize>.from(widget.existingFavorite!.servingSizes);
    }
    
    // Add a default 100g serving if none exist or if it's a manual entry without AI details
    if (servingSizes.where((s) => s.grams == 100.0).isEmpty) {
        servingSizes.add(const FavoriteServingSize(name: '100 gram', grams: 100.0, isDefault: true));
    }
    // Ensure there is at least one default serving
    if (servingSizes.where((s) => s.isDefault).isEmpty && servingSizes.isNotEmpty) {
        servingSizes[0] = servingSizes[0].copyWith(isDefault: true);
    }
    if (servingSizes.isEmpty) { // Fallback if still empty (e.g. manual new entry)
        servingSizes.add(const FavoriteServingSize(name: 'Standard', grams: 100.0, isDefault: true));
    }
    
    DateTime lastUsedDate;
    int usageCountValue;
        
        if (_isEditing) {
      if (_logOnSave) {
        lastUsedDate = DateTime.now();
        usageCountValue = widget.existingFavorite!.usageCount + 1;
      } else {
        lastUsedDate = widget.existingFavorite!.lastUsed;
        usageCountValue = widget.existingFavorite!.usageCount;
      }
    } else { // New favorite
        lastUsedDate = DateTime.now(); // Always new date for new fav
        usageCountValue = _logOnSave ? 1 : 0; // Usage is 1 if logging, 0 if just creating
    }

    final favorite = FavoriteFoodModel(
      id: _isEditing ? widget.existingFavorite!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      foodName: _nameController.text.trim(),
      description: _notesController.text.trim(),
      foodType: _getFoodType(), // Set the correct food type
      caloriesPer100g: caloriesPer100g.round(),
      defaultServingGrams: portionGrams,
      totalCaloriesForServing: totalCaloriesForServing.round(),
            preferredMealType: _selectedMealType,
      servingSizes: servingSizes.toSet().toList(), // Use the populated and potentially modified servingSizes
      isAiGenerated: _currentAiFoodDetails != null,
      aiSearchQuery: _currentAiFoodDetails?.basicInfo.id,
      sourceProvider: _currentAiFoodDetails?.basicInfo.provider ?? (_isEditing ? widget.existingFavorite!.sourceProvider : FavoriteFoodModel.manualProvider),
      createdAt: _isEditing ? widget.existingFavorite!.createdAt : DateTime.now(),
      lastUsed: lastUsedDate,
      usageCount: usageCountValue,
      // Ensure other nutrition fields are populated if necessary, defaulting to 0
      proteinPer100g: _currentAiFoodDetails?.nutrition.protein ?? (_isEditing ? widget.existingFavorite!.proteinPer100g : 0.0),
      fatPer100g: _currentAiFoodDetails?.nutrition.fat ?? (_isEditing ? widget.existingFavorite!.fatPer100g : 0.0),
      carbsPer100g: _currentAiFoodDetails?.nutrition.carbs ?? (_isEditing ? widget.existingFavorite!.carbsPer100g : 0.0),
      fiberPer100g: _currentAiFoodDetails?.nutrition.fiber ?? (_isEditing ? widget.existingFavorite!.fiberPer100g : 0.0),
      sugarPer100g: _currentAiFoodDetails?.nutrition.sugar ?? (_isEditing ? widget.existingFavorite!.sugarPer100g : 0.0),
      tags: _currentAiFoodDetails != null 
          ? FavoriteFoodModel.extractTagsFromFoodTags(_currentAiFoodDetails!.basicInfo.tags) 
          : (_isEditing ? widget.existingFavorite!.tags : []),
      ingredients: _currentAiFoodDetails?.ingredients ?? (_isEditing ? widget.existingFavorite!.ingredients : ''),
    );

    try {
      final favoriteService = FavoriteFoodService();
      if (_isEditing) {
        // No need to call incrementFavoriteUsage if _logOnSave is false, as usageCount and lastUsed are already set.
        await favoriteService.updateFavorite(favorite);
            ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Favorit opdateret: ${favorite.foodName}'), backgroundColor: AppColors.success),
            );
      } else {
        await favoriteService.addToFavorites(favorite);
            ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Favorit tilføjet: ${favorite.foodName}'), backgroundColor: AppColors.success),
            );
          }

      // If this save action is also meant to log the food, we would do it here.
      // For now, this is handled by the page that PUSHED FoodFavoriteDetailPage with logOnSave = true.
      // However, if this page is popped with a result, the calling page can use that.

      setState(() => _isLoading = false);
      if (mounted) {
        if (_currentAiFoodDetails != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(onlineFoodProvider.notifier).clearResults(); // Use clearResults() from OnlineFoodCubit
          });
        }
        Navigator.of(context).pop(favorite); // Return the saved/updated favorite
        }
      } catch (e) {
      setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fejl ved gemning: $e'), backgroundColor: AppColors.error),
          );
        }
    }
  }

  Future<void> _showAiSearchDialog(String query) async {
    // Get the LLM service from the provider using the alias
    final llmServiceInstance = ref.read(llm_service.llmFoodServiceProvider);

    final online_models.OnlineFoodDetails? selectedFoodDetails = await showDialog<online_models.OnlineFoodDetails>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AiSearchDialog(
        initialQuery: query,
          llmFoodService: llmServiceInstance, // Pass the instance from provider
          onFoodDetailsSelected: (details) { 
             Navigator.of(dialogContext).pop(details);
          }
        );
      },
    );

    if (selectedFoodDetails != null) {
      setState(() {
        _currentAiFoodDetails = selectedFoodDetails; 
        _populateFormFromAiDetails(selectedFoodDetails); 
      });
    }
  }

  // New method to populate form fields from OnlineFoodDetails
  void _populateFormFromAiDetails(online_models.OnlineFoodDetails details) {
    _nameController.text = details.basicInfo.name;
    _notesController.text = details.basicInfo.description;
    _selectedMealType = MealType.none; 

    _caloriesPer100gController.text = details.nutrition.calories > 0 
                                        ? details.nutrition.calories.toStringAsFixed(0) 
                                        : '0';
        
    final online_models.OnlineServingSize defaultServing = details.servingSizes.firstWhere(
      (s) => s.isDefault || s.name.toLowerCase().contains('standard') || s.name.toLowerCase().contains('portion'),
          orElse: () => details.servingSizes.isNotEmpty 
              ? details.servingSizes.first 
                    : const online_models.OnlineServingSize(name: '100 gram', grams: 100, isDefault: true), // Ensure this returns OnlineServingSize
    );
    _portionGramsController.text = defaultServing.grams > 0 ? defaultServing.grams.toStringAsFixed(0) : '100';
    
    _calculateTotalCalories();
    }
  }

class AiSearchDialog extends ConsumerStatefulWidget {
  final String initialQuery;
  final llm_service.LLMFoodService llmFoodService; // Use aliased type
  final ValueChanged<online_models.OnlineFoodDetails> onFoodDetailsSelected;

  const AiSearchDialog({
    super.key,
    required this.initialQuery,
    required this.llmFoodService,
    required this.onFoodDetailsSelected,
  });

  @override
  ConsumerState<AiSearchDialog> createState() => _AiSearchDialogState();
}

class _AiSearchDialogState extends ConsumerState<AiSearchDialog> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isFetchingDetails = false;
  online_models.OnlineFoodError? _error;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    if (widget.initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Check if a search isn't already in progress from the cubit
        if (!ref.read(onlineFoodProvider).isLoading) {
      _searchFood();
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchFood() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _error = null;
    });
    await ref.read(onlineFoodProvider.notifier).searchFoods(query);
    if (mounted) {
        setState(() {
            _isSearching = false;
        });
    }
  }

  Future<void> _fetchAndSelectDetails(online_models.OnlineFoodResult shortResult) async {
    setState(() {
      _isFetchingDetails = true;
      _error = null;
    });
    try {
      // Call getFoodDetails with only the ID, as per interface
      // Use the llmFoodService instance passed via constructor (from provider)
      final detailsResult = await widget.llmFoodService.getFoodDetails(shortResult.id);

      if (mounted) {
        if (detailsResult.isSuccess) {
          final details = detailsResult.success;
          widget.onFoodDetailsSelected(details);
        } else {
          final error = detailsResult.failure; // This is OnlineFoodError
          setState(() {
            _error = error;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = online_models.OnlineFoodError.unknown; 
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingDetails = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final onlineFoodState = ref.watch(onlineFoodProvider);
    final searchResults = onlineFoodState.searchResults;
    final cubitError = onlineFoodState.hasError ? onlineFoodState.errorMessage : null;
    final isLoadingFromCubit = onlineFoodState.isLoading;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KSizes.radiusL)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(KSizes.margin4x),
        child: Column(
          children: [
            Row(
              children: [
                Icon(MdiIcons.robotOutline, color: AppColors.primary, size: KSizes.iconL),
                SizedBox(width: KSizes.margin2x),
                Expanded(
                  child: Text('AI Mad Søgning', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.textPrimary)),
                ),
                IconButton(icon: Icon(MdiIcons.close, color: AppColors.textSecondary), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            SizedBox(height: KSizes.margin3x),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Søg efter fødevare...',
                hintText: 'f.eks. kylling med ris',
                prefixIcon: Icon(MdiIcons.magnify, color: AppColors.textSecondary),
                suffixIcon: (_isSearching || isLoadingFromCubit)
                    ? SizedBox(width: 20, height: 20, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)))
                    : IconButton(icon: Icon(MdiIcons.arrowRightCircleOutline, color: AppColors.primary), onPressed: _searchFood),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(KSizes.radiusM)),
              ),
              onSubmitted: (_) => _searchFood(),
            ),
            SizedBox(height: KSizes.margin3x),
            Expanded(
              child: (_isSearching || isLoadingFromCubit)
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(color: AppColors.primary), SizedBox(height: KSizes.margin2x), Text('Søger...')]))
                  : _error != null 
                      ? Center(child: Text('Fejl ved hentning af detaljer: ${_error!.message}', style: TextStyle(color: AppColors.error, fontSize: KSizes.fontSizeM)))
                      : cubitError != null 
                          ? Center(child: Text('Søgningsfejl: $cubitError', style: TextStyle(color: AppColors.error, fontSize: KSizes.fontSizeM)))
                          : searchResults.isEmpty
                              ? Center(child: Text('Ingen resultater fundet.', style: TextStyle(color: AppColors.textSecondary, fontSize: KSizes.fontSizeM)))
                              : ListView.builder(
                                  itemCount: searchResults.length,
      itemBuilder: (context, index) {
                                    final result = searchResults[index];
                                    final bool isFetchingThisItem = _isFetchingDetails && onlineFoodState.selectedFoodDetails?.basicInfo.id == result.id;
        return Card(
                                      elevation: 1,
                                      margin: EdgeInsets.symmetric(vertical: KSizes.margin1x),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KSizes.radiusS)),
                                      child: ListTile(
                                        leading: result.imageUrl.isNotEmpty 
                                            ? Image.network(result.imageUrl, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (c, o, s) => Icon(MdiIcons.foodOutline, color: AppColors.primary)) 
                                            : Icon(MdiIcons.foodOutline, color: AppColors.primary),
                                        title: Text(result.name, style: TextStyle(fontWeight: KSizes.fontWeightMedium, fontSize: KSizes.fontSizeM, color: AppColors.textPrimary)),
                                        subtitle: Text(
                                          '${result.estimatedCalories.toStringAsFixed(0)} kcal pr. 100g (${result.searchMode.displayName})\n${result.description}',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: KSizes.fontSizeS, color: AppColors.textSecondary),
                                        ),
                                        trailing: isFetchingThisItem 
                                            ? SizedBox(width: 20, height: 20, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)))
                                            : Icon(MdiIcons.chevronRight, color: AppColors.primary),
                                        onTap: isFetchingThisItem ? null : () => _fetchAndSelectDetails(result),
                                        contentPadding: EdgeInsets.symmetric(horizontal: KSizes.margin2x, vertical: KSizes.margin1x),
                        ),
                                    );
                                  },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
} 