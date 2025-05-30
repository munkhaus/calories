import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/user_food_log_model.dart';
import '../../application/food_logging_notifier.dart';

/// Page for editing an existing meal log entry
class EditMealPage extends ConsumerStatefulWidget {
  final UserFoodLogModel meal;

  const EditMealPage({
    super.key,
    required this.meal,
  });

  @override
  ConsumerState<EditMealPage> createState() => _EditMealPageState();
}

class _EditMealPageState extends ConsumerState<EditMealPage> {
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _servingUnitController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  
  late MealType _selectedMealType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize form with current meal data
    _foodNameController.text = widget.meal.foodName;
    _caloriesController.text = widget.meal.calories.toString();
    _quantityController.text = widget.meal.quantity.toString();
    _servingUnitController.text = widget.meal.servingUnit;
    _proteinController.text = widget.meal.protein.toStringAsFixed(1);
    _fatController.text = widget.meal.fat.toStringAsFixed(1);
    _carbsController.text = widget.meal.carbs.toStringAsFixed(1);
    _selectedMealType = widget.meal.mealType;
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    _quantityController.dispose();
    _servingUnitController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Rediger Måltid'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: KSizes.fontSizeL,
          fontWeight: KSizes.fontWeightBold,
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveMeal,
            icon: Icon(MdiIcons.check),
            tooltip: 'Gem ændringer',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(KSizes.margin4x),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header info
                Container(
                  padding: EdgeInsets.all(KSizes.margin4x),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                    border: Border.all(color: AppColors.info.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        MdiIcons.informationOutline,
                        color: AppColors.info,
                      ),
                      SizedBox(width: KSizes.margin2x),
                      Expanded(
                        child: Text(
                          'Rediger oplysningerne for dette måltid',
                          style: TextStyle(
                            color: AppColors.info,
                            fontSize: KSizes.fontSizeS,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: KSizes.margin6x),

                // Food name
                _buildFormSection(
                  title: 'Navn på mad',
                  child: TextField(
                    controller: _foodNameController,
                    decoration: InputDecoration(
                      hintText: 'F.eks. Spaghetti Bolognese',
                      prefixIcon: Icon(MdiIcons.silverwareForkKnife),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: KSizes.margin4x),

                // Meal type
                _buildFormSection(
                  title: 'Måltidstype',
                  child: _buildMealTypeSelector(),
                ),

                SizedBox(height: KSizes.margin4x),

                // Quantity and serving unit
                _buildFormSection(
                  title: 'Mængde og enhed',
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: '1.0',
                            prefixIcon: Icon(MdiIcons.scaleBalance),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(KSizes.radiusM),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(KSizes.radiusM),
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: KSizes.margin2x),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _servingUnitController,
                          decoration: InputDecoration(
                            hintText: 'portion, g, stk',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(KSizes.radiusM),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(KSizes.radiusM),
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: KSizes.margin4x),

                // Calories
                _buildFormSection(
                  title: 'Kalorier',
                  child: TextField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '450',
                      suffixText: 'kcal',
                      prefixIcon: Icon(MdiIcons.fire),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: KSizes.margin4x),

                // Nutrition details (expandable)
                _buildNutritionSection(),

                SizedBox(height: KSizes.margin8x),

                // Action buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required Widget child,
  }) {
    return Column(
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
        SizedBox(height: KSizes.margin2x),
        child,
      ],
    );
  }

  Widget _buildMealTypeSelector() {
    return Wrap(
      spacing: KSizes.margin2x,
      runSpacing: KSizes.margin2x,
      children: MealType.values.where((type) => type != MealType.none).map((mealType) {
        final isSelected = _selectedMealType == mealType;
        return GestureDetector(
          onTap: () => setState(() => _selectedMealType = mealType),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: KSizes.margin3x,
              vertical: KSizes.margin2x,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(KSizes.radiusM),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 1,
              ),
            ),
            child: Text(
              mealType.mealTypeDisplayName,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? KSizes.fontWeightBold : KSizes.fontWeightMedium,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNutritionSection() {
    return ExpansionTile(
      title: Text(
        'Næringsværdier (valgfrit)',
        style: TextStyle(
          fontSize: KSizes.fontSizeL,
          fontWeight: KSizes.fontWeightBold,
          color: AppColors.textPrimary,
        ),
      ),
      leading: Icon(MdiIcons.nutrition, color: AppColors.secondary),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: KSizes.margin4x),
          child: Column(
            children: [
              // Protein
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _proteinController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Protein',
                        suffixText: 'g',
                        prefixIcon: Icon(MdiIcons.chefHat),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(KSizes.radiusM),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: KSizes.margin2x),
                  Expanded(
                    child: TextField(
                      controller: _fatController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Fedt',
                        suffixText: 'g',
                        prefixIcon: Icon(MdiIcons.water),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(KSizes.radiusM),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: KSizes.margin3x),
              
              // Carbohydrates
              TextField(
                controller: _carbsController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Kulhydrater',
                  suffixText: 'g',
                  prefixIcon: Icon(MdiIcons.grain),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: KSizes.margin4x),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Save button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveMeal,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: KSizes.margin4x),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KSizes.radiusM),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Gem Ændringer',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeL,
                      fontWeight: KSizes.fontWeightBold,
                    ),
                  ),
          ),
        ),
        
        SizedBox(height: KSizes.margin3x),
        
        // Cancel button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: BorderSide(color: AppColors.border),
              padding: EdgeInsets.symmetric(vertical: KSizes.margin4x),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KSizes.radiusM),
              ),
            ),
            child: Text(
              'Annuller',
              style: TextStyle(
                fontSize: KSizes.fontSizeL,
                fontWeight: KSizes.fontWeightMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveMeal() async {
    // Validate input
    if (_foodNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Angiv venligst navn på maden'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final calories = int.tryParse(_caloriesController.text.trim());
    if (calories == null || calories < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Angiv venligst gyldige kalorier'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final quantity = double.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Angiv venligst gyldig mængde'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_servingUnitController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Angiv venligst enhed'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parse nutrition values (default to 0 if empty)
      final protein = double.tryParse(_proteinController.text.trim()) ?? 0.0;
      final fat = double.tryParse(_fatController.text.trim()) ?? 0.0;
      final carbs = double.tryParse(_carbsController.text.trim()) ?? 0.0;

      // Create updated meal
      final updatedMeal = widget.meal.copyWith(
        foodName: _foodNameController.text.trim(),
        mealType: _selectedMealType,
        quantity: quantity,
        servingUnit: _servingUnitController.text.trim(),
        calories: calories,
        protein: protein,
        fat: fat,
        carbs: carbs,
        updatedAt: DateTime.now().toIso8601String(),
      );

      // Update meal using the notifier
      await ref.read(foodLoggingProvider.notifier).updateFood(updatedMeal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${updatedMeal.foodName} er opdateret!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved opdatering: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
} 