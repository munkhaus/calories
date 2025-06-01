import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/favorite_food_model.dart';
import '../../domain/user_food_log_model.dart';
import '../../infrastructure/favorite_food_service.dart';

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
  final _servingUnitController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbsController = TextEditingController();
  final _notesController = TextEditingController();
  
  MealType _selectedMealType = MealType.morgenmad;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.existingFavorite != null;
    
    if (_isEditing) {
      final favorite = widget.existingFavorite!;
      _nameController.text = favorite.foodName;
      _caloriesController.text = favorite.caloriesPer100g.toString();
      _quantityController.text = favorite.defaultQuantity.toString();
      _servingUnitController.text = favorite.defaultServingUnit;
      _proteinController.text = favorite.proteinPer100g.toString();
      _fatController.text = favorite.fatPer100g.toString();
      _carbsController.text = favorite.carbsPer100g.toString();
      _selectedMealType = favorite.preferredMealType;
    } else {
      // Set defaults for new favorite
      _quantityController.text = '1';
      _servingUnitController.text = 'stk';
      _proteinController.text = '0';
      _fatController.text = '0';
      _carbsController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _quantityController.dispose();
    _servingUnitController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    _notesController.dispose();
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
                  'Indtast detaljerede oplysninger om din favorit mad',
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
                      child: _buildTextField(
                        controller: _servingUnitController,
                        label: 'Enhed',
                        hint: 'stk',
                        icon: MdiIcons.formatListBulleted,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Indtast enhed';
                          }
                          return null;
                        },
                      ),
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
                
                // Nutrition section header
                Text(
                  'Næringsindhold (valgfrit)',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeL,
                    fontWeight: KSizes.fontWeightBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                SizedBox(height: KSizes.margin4x),
                
                // Nutrition row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _proteinController,
                        label: 'Protein (g)',
                        hint: '0',
                        icon: MdiIcons.cow,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: KSizes.margin2x),
                    Expanded(
                      child: _buildTextField(
                        controller: _fatController,
                        label: 'Fedt (g)',
                        hint: '0',
                        icon: MdiIcons.waterPercent,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: KSizes.margin2x),
                    Expanded(
                      child: _buildTextField(
                        controller: _carbsController,
                        label: 'Kulhydrater (g)',
                        hint: '0',
                        icon: MdiIcons.grain,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                
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
        final servingUnit = _servingUnitController.text.trim();
        final protein = double.tryParse(_proteinController.text.trim()) ?? 0.0;
        final fat = double.tryParse(_fatController.text.trim()) ?? 0.0;
        final carbs = double.tryParse(_carbsController.text.trim()) ?? 0.0;
        final notes = _notesController.text.trim();

        final favoriteService = FavoriteFoodService();
        
        if (_isEditing) {
          // Update existing favorite
          final updatedFavorite = widget.existingFavorite!.copyWith(
            foodName: name,
            preferredMealType: _selectedMealType,
            defaultQuantity: quantity,
            defaultServingUnit: servingUnit,
            caloriesPer100g: calories,
            proteinPer100g: protein,
            fatPer100g: fat,
            carbsPer100g: carbs,
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
            defaultServingUnit: servingUnit,
            caloriesPer100g: calories,
            proteinPer100g: protein,
            fatPer100g: fat,
            carbsPer100g: carbs,
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
} 