import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/favorite_food_model.dart';
import '../../domain/user_food_log_model.dart';
import '../../infrastructure/favorite_food_service.dart';
import '../../../food_database/infrastructure/llm_food_service.dart';
import '../../../food_database/domain/online_food_models.dart';

/// Detailed page for creating and editing food favorites
class FoodFavoriteDetailPage extends ConsumerStatefulWidget {
  final FavoriteFoodModel? existingFavorite;
  
  const FoodFavoriteDetailPage({
    super.key,
    this.existingFavorite,
  });

  @override
  ConsumerState<FoodFavoriteDetailPage> createState() => _FoodFavoriteDetailPageState();
}

class _FoodFavoriteDetailPageState extends ConsumerState<FoodFavoriteDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();
  
  MealType _selectedMealType = MealType.morgenmad;
  String _selectedServingUnit = 'stk';
  bool _isLoading = false;
  bool _isEditing = false;
  bool _useAiSearch = false;
  bool _isSearching = false;
  List<OnlineFoodResult> _searchResults = [];
  LLMFoodService? _llmFoodService;

  // Predefined serving units
  static const List<String> _servingUnits = [
    'stk',
    'portioner',
    'gram',
    'skiver',
    'kopper',
    'spsk',
    'tsk',
    'dl',
    'liter',
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.existingFavorite != null;
    _llmFoodService = LLMFoodService();
    _llmFoodService!.initialize(); // Initialize the AI service
    
    if (_isEditing) {
      final favorite = widget.existingFavorite!;
      _nameController.text = favorite.foodName;
      _caloriesController.text = favorite.caloriesPer100g.toString();
      _quantityController.text = favorite.defaultQuantity.toString();
      _selectedServingUnit = favorite.defaultServingUnit;
      _selectedMealType = favorite.preferredMealType;
    } else {
      // Set defaults for new favorite
      _quantityController.text = '1';
      _selectedServingUnit = 'stk';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
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
                
                // Food name
                _buildTextField(
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
                
                SizedBox(height: KSizes.margin2x),
                
                // AI Search Toggle
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      'Brug AI søgning',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        fontWeight: KSizes.fontWeightMedium,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Søg og vælg mad for at få præcise data',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    value: _useAiSearch,
                    onChanged: (value) {
                      setState(() {
                        _useAiSearch = value;
                        if (!value) {
                          _searchResults = [];
                          _searchController.clear();
                        }
                      });
                    },
                    activeColor: AppColors.primary,
                    secondary: Icon(
                      MdiIcons.robot,
                      color: _useAiSearch ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
                
                if (_useAiSearch) ...[
                  SizedBox(height: KSizes.margin4x),
                  
                  // AI Search Field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Søg efter mad',
                      hintText: 'f.eks. "havregrød" eller "kylling"',
                      prefixIcon: Icon(MdiIcons.magnify, color: AppColors.primary),
                      suffixIcon: _isSearching
                          ? Padding(
                              padding: EdgeInsets.all(KSizes.margin3x),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                              ),
                            )
                          : IconButton(
                              onPressed: _searchFood,
                              icon: Icon(MdiIcons.send, color: AppColors.primary),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    onSubmitted: (_) => _searchFood(),
                  ),
                  
                  // Search Results
                  if (_searchResults.isNotEmpty) ...[
                    SizedBox(height: KSizes.margin3x),
                    Text(
                      'Søgeresultater:',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: KSizes.margin2x),
                    ...(_searchResults.map((food) => Container(
                      margin: EdgeInsets.only(bottom: KSizes.margin2x),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                      ),
                      child: ListTile(
                        title: Text(
                          food.name,
                          style: TextStyle(fontWeight: KSizes.fontWeightMedium),
                        ),
                        subtitle: Text(
                          food.description,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        trailing: Icon(MdiIcons.chevronRight, color: AppColors.primary),
                        onTap: () => _selectSearchResult(food),
                      ),
                    )).toList()),
                  ],
                ],
                
                SizedBox(height: KSizes.margin4x),
                
                // Meal type dropdown
                _buildMealTypeDropdown(),
                
                SizedBox(height: KSizes.margin4x),
                
                // Quantity and serving unit
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildTextField(
                        controller: _quantityController,
                        label: 'Mængde',
                        hint: '1',
                        icon: MdiIcons.scaleBalance,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Indtast mængde';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Indtast et gyldigt tal';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: KSizes.margin3x),
                    Expanded(
                      flex: 1,
                      child: _buildServingUnitDropdown(),
                    ),
                  ],
                ),
                
                SizedBox(height: KSizes.margin4x),
                
                // Calories
                _buildTextField(
                  controller: _caloriesController,
                  label: 'Kalorier',
                  hint: 'f.eks. 350',
                  icon: MdiIcons.fire,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Indtast kalorier';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Indtast et gyldigt tal';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: KSizes.margin6x),
                
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
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
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

  Widget _buildServingUnitDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedServingUnit,
      decoration: InputDecoration(
        labelText: 'Enhed',
        prefixIcon: Icon(MdiIcons.formatListBulleted, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusM),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      items: _servingUnits.map((unit) {
        return DropdownMenuItem(
          value: unit,
          child: Text(unit),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedServingUnit = value!;
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
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final name = _nameController.text.trim();
        final calories = int.parse(_caloriesController.text.trim());
        final quantity = double.parse(_quantityController.text.trim());

        final favoriteService = FavoriteFoodService();
        
        if (_isEditing) {
          // Update existing favorite
          final updatedFavorite = widget.existingFavorite!.copyWith(
            foodName: name,
            preferredMealType: _selectedMealType,
            defaultQuantity: quantity,
            defaultServingUnit: _selectedServingUnit,
            caloriesPer100g: calories,
            proteinPer100g: 0.0, // Set default nutrition values
            fatPer100g: 0.0,
            carbsPer100g: 0.0,
            usageCount: 0,
            lastUsed: DateTime.now(),
            createdAt: DateTime.now(),
          );
          
          final result = await favoriteService.updateFavorite(updatedFavorite);
          
          if (result.isSuccess && mounted) {
            Navigator.of(context).pop(true); // Return true to indicate success
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$name er opdateret i favoritter!'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kunne ikke opdatere favorit'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        } else {
          // Create new favorite
          final newFavorite = FavoriteFoodModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            foodName: name,
            preferredMealType: _selectedMealType,
            defaultQuantity: quantity,
            defaultServingUnit: _selectedServingUnit,
            caloriesPer100g: calories,
            proteinPer100g: 0.0, // Set default nutrition values
            fatPer100g: 0.0,
            carbsPer100g: 0.0,
            usageCount: 0,
            lastUsed: DateTime.now(),
            createdAt: DateTime.now(),
          );
          
          final result = await favoriteService.addToFavorites(newFavorite);
          
          if (result.isSuccess && mounted) {
            Navigator.of(context).pop(true); // Return true to indicate success
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$name er tilføjet til favoritter!'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kunne ikke gemme favorit'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fejl ved gemning: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _searchFood() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchResults = [];
    });

    try {
      final result = await _llmFoodService!.searchFoods(query);
      if (result.isSuccess) {
        setState(() {
          _searchResults = result.success;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ingen resultater fundet'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved søgning: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _selectSearchResult(OnlineFoodResult food) async {
    try {
      // Get detailed food information
      final detailsResult = await _llmFoodService!.getFoodDetails(food.id);
      
      if (detailsResult.isSuccess) {
        final details = detailsResult.success;
        
        // Auto-populate fields from AI search result
        _nameController.text = food.name;
        _caloriesController.text = details.nutrition.calories.round().toString();
        
        // Find the best matching serving size
        final defaultServing = details.servingSizes.firstWhere(
          (s) => s.isDefault,
          orElse: () => details.servingSizes.first,
        );
        
        _quantityController.text = '1';
        
        // Try to match serving unit to our predefined units
        String unit = 'stk'; // default
        final servingName = defaultServing.name.toLowerCase();
        if (servingName.contains('gram') || servingName.contains('g')) {
          unit = 'gram';
        } else if (servingName.contains('portion')) {
          unit = 'portioner';
        } else if (servingName.contains('skive')) {
          unit = 'skiver';
        }
        
        setState(() {
          _selectedServingUnit = unit;
          _useAiSearch = false; // Hide search after selection
          _searchResults = [];
          _searchController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${food.name} valgt - du kan nu redigere detaljerne'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kunne ikke hente detaljer for ${food.name}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fejl ved valg af mad: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
} 