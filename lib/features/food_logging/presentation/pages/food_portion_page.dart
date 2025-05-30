import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../domain/food_item_model.dart';
import '../../domain/user_food_log_model.dart';
import '../../infrastructure/food_logging_service.dart';
import '../../application/food_logging_notifier.dart';

class FoodPortionPage extends ConsumerStatefulWidget {
  final FoodItemModel foodItem;
  final MealType mealType;

  const FoodPortionPage({
    super.key,
    required this.foodItem,
    required this.mealType,
  });

  @override
  ConsumerState<FoodPortionPage> createState() => _FoodPortionPageState();
}

class _FoodPortionPageState extends ConsumerState<FoodPortionPage> {
  final TextEditingController _quantityController = TextEditingController();
  String _selectedUnit = 'g';
  double _quantity = 100.0;
  bool _isLogging = false;

  @override
  void initState() {
    super.initState();
    
    // Set default values based on food item
    if (widget.foodItem.servingSize > 0 && widget.foodItem.servingUnit.isNotEmpty) {
      _selectedUnit = widget.foodItem.servingUnit;
      // For "stk" (pieces), default quantity should be 1, not the serving size in grams
      if (widget.foodItem.servingUnit == 'stk') {
        _quantity = 1.0;
      } else {
        _quantity = widget.foodItem.servingSize;
      }
    } else {
      _selectedUnit = 'g';
      _quantity = 100.0;
    }
    
    _quantityController.text = _quantity.toString();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _updateQuantity(String value) {
    final newQuantity = double.tryParse(value);
    if (newQuantity != null && newQuantity > 0) {
      setState(() => _quantity = newQuantity);
    }
  }

  void _selectPresetPortion(double portion, String unit) {
    setState(() {
      _quantity = portion;
      _selectedUnit = unit;
      _quantityController.text = portion.toString();
    });
  }

  Future<void> _logFood() async {
    if (_quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Angiv venligst en gyldig mængde'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLogging = true);

    try {
      // Calculate nutrition values
      final calories = widget.foodItem.caloriesForQuantity(_quantity, _selectedUnit);
      final protein = widget.foodItem.proteinForQuantity(_quantity, _selectedUnit);
      final fat = widget.foodItem.fatForQuantity(_quantity, _selectedUnit);
      final carbs = widget.foodItem.carbsForQuantity(_quantity, _selectedUnit);

      // Debug output
      print('🍎 Logging: ${widget.foodItem.name}');
      print('📏 Quantity: $_quantity $_selectedUnit');
      print('⚖️ Serving size: ${widget.foodItem.servingSize} ${widget.foodItem.servingUnit}');
      print('🔥 Calculated calories: $calories');
      print('🥩 Calculated protein: $protein');

      // Create food log entry
      final foodLog = UserFoodLogModel(
        userId: 1, // TODO: Get actual user ID
        foodItemId: widget.foodItem.foodId,
        foodName: widget.foodItem.name,
        mealType: widget.mealType,
        quantity: _quantity,
        servingUnit: _selectedUnit,
        calories: calories.round(),
        protein: protein,
        fat: fat,
        carbs: carbs,
        foodItemSourceType: FoodItemSourceType.foodItem,
      );

      // Log to database using the notifier (this will trigger dashboard update)
      await ref.read(foodLoggingProvider.notifier).logFood(foodLog);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.foodItem.name} er logget til ${widget.mealType.mealTypeDisplayName}'),
            backgroundColor: AppColors.success,
          ),
        );

        // Go back to previous screens
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved logning af mad: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLogging = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final calories = widget.foodItem.caloriesForQuantity(_quantity, _selectedUnit);
    final protein = widget.foodItem.proteinForQuantity(_quantity, _selectedUnit);
    final fat = widget.foodItem.fatForQuantity(_quantity, _selectedUnit);
    final carbs = widget.foodItem.carbsForQuantity(_quantity, _selectedUnit);

    return Scaffold(
      backgroundColor: AppColors.background,
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
                        title: 'Portionsstørrelse 🥄',
                        subtitle: 'Juster mængden efter dit indtag',
                        icon: MdiIcons.scaleBalance,
                        iconColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(KSizes.margin4x),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food Info - using OnboardingSection style
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(KSizes.margin4x),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(KSizes.radiusM),
                          border: Border.all(
                            color: AppColors.border.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.foodItem.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: KSizes.fontWeightBold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            KSizes.spacingVerticalS,
                            Text(
                              'Juster portionsstørrelsen efter dit indtag',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: KSizes.margin6x),

                      // Quantity Input
                      Text(
                        'Mængde',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: KSizes.fontWeightBold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      
                      SizedBox(height: KSizes.margin4x),
                      
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: TextField(
                              controller: _quantityController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Mængde',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                                ),
                                filled: true,
                                fillColor: AppColors.surface,
                              ),
                              onChanged: _updateQuantity,
                            ),
                          ),
                          
                          SizedBox(width: KSizes.margin2x),
                          
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              value: _selectedUnit,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Enhed',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                                ),
                                filled: true,
                                fillColor: AppColors.surface,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: KSizes.margin1x,
                                  vertical: KSizes.margin2x,
                                ),
                              ),
                              items: [
                                DropdownMenuItem(value: 'g', child: Text('gram', style: TextStyle(fontSize: KSizes.fontSizeS))),
                                if (widget.foodItem.servingUnit.isNotEmpty &&
                                    widget.foodItem.servingUnit != 'g')
                                  DropdownMenuItem(
                                    value: widget.foodItem.servingUnit,
                                    child: Text(_getUnitDisplayName(widget.foodItem.servingUnit), style: TextStyle(fontSize: KSizes.fontSizeS)),
                                  ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedUnit = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: KSizes.margin4x),

                      // Preset Portions
                      if (widget.foodItem.servingSize > 0) ...[
                        Text(
                          'Hurtige valg',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: KSizes.fontWeightBold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        
                        SizedBox(height: KSizes.margin4x),
                        
                        Wrap(
                          spacing: KSizes.margin2x,
                          runSpacing: KSizes.margin2x,
                          children: [
                            _buildPresetButton(
                              '1 ${_getUnitDisplayName(widget.foodItem.servingUnit)}',
                              widget.foodItem.servingSize,
                              widget.foodItem.servingUnit,
                            ),
                            _buildPresetButton('100g', 100.0, 'g'),
                            _buildPresetButton('200g', 200.0, 'g'),
                            if (widget.foodItem.servingSize > 0)
                              _buildPresetButton(
                                '2 ${_getUnitDisplayName(widget.foodItem.servingUnit)}',
                                widget.foodItem.servingSize * 2,
                                widget.foodItem.servingUnit,
                              ),
                          ],
                        ),
                        
                        SizedBox(height: KSizes.margin6x),
                      ],

                      // Nutrition Summary
                      Container(
                        padding: EdgeInsets.all(KSizes.margin4x),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(KSizes.radiusM),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ernæring for $_quantity $_selectedUnit',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: KSizes.fontWeightBold,
                                color: AppColors.primary,
                              ),
                            ),
                            
                            // Add conversion info for clarity
                            if (_selectedUnit == widget.foodItem.servingUnit && widget.foodItem.servingSize > 0)
                              Text(
                                '(= ${(_quantity * widget.foodItem.servingSize).toStringAsFixed(0)}g)',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            
                            SizedBox(height: KSizes.margin4x),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: _buildNutritionCard(
                                    'Kalorier',
                                    '${calories.round()}',
                                    'kcal',
                                    AppColors.primary,
                                  ),
                                ),
                                SizedBox(width: KSizes.margin2x),
                                Expanded(
                                  child: _buildNutritionCard(
                                    'Protein',
                                    protein.toStringAsFixed(1),
                                    'g',
                                    AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: KSizes.margin2x),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: _buildNutritionCard(
                                    'Fedt',
                                    fat.toStringAsFixed(1),
                                    'g',
                                    AppColors.warning,
                                  ),
                                ),
                                SizedBox(width: KSizes.margin2x),
                                Expanded(
                                  child: _buildNutritionCard(
                                    'Kulhydrater',
                                    carbs.toStringAsFixed(1),
                                    'g',
                                    AppColors.info,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Log Button
              Container(
                padding: EdgeInsets.all(KSizes.margin4x),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 56.0, // Standard button height
                    child: ElevatedButton(
                      onPressed: _isLogging ? null : _logFood,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(KSizes.radiusM),
                        ),
                      ),
                      child: _isLogging
                          ? SizedBox(
                              width: KSizes.iconM,
                              height: KSizes.iconM,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                              ),
                            )
                          : Text(
                              'Log til ${widget.mealType.mealTypeDisplayName}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: KSizes.fontWeightBold,
                                color: AppColors.surface,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetButton(String label, double quantity, String unit) {
    final isSelected = _quantity == quantity && _selectedUnit == unit;
    
    return GestureDetector(
      onTap: () => _selectPresetPortion(quantity, unit),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: KSizes.margin4x,
          vertical: KSizes.margin3x,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : AppColors.border.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected ? AppColors.surface : AppColors.textPrimary,
            fontWeight: KSizes.fontWeightMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionCard(String label, String value, String unit, Color color) {
    return Container(
      padding: EdgeInsets.all(KSizes.margin3x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusS),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: KSizes.margin1x),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: KSizes.fontWeightBold,
                    color: color,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getUnitDisplayName(String unit) {
    switch (unit) {
      case 'g':
        return 'gram';
      case 'kg':
        return 'kilogram';
      case 'ml':
        return 'milliliter';
      case 'cl':
        return 'centiliter';
      case 'l':
        return 'liter';
      case 'stk':
        return 'stykker';
      default:
        return unit;
    }
  }
} 