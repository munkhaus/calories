import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../food_database/domain/portion_framework.dart';
import '../../domain/favorite_food_model.dart';

/// Smart portion selection dialog that shows relevant portion sizes based on food type
class SmartPortionSelectionDialog extends StatefulWidget {
  final FavoriteFoodModel food;
  final Function(double grams, String unitName, String displayName) onPortionSelected;

  const SmartPortionSelectionDialog({
    super.key,
    required this.food,
    required this.onPortionSelected,
  });

  @override
  State<SmartPortionSelectionDialog> createState() => _SmartPortionSelectionDialogState();
}

class _SmartPortionSelectionDialogState extends State<SmartPortionSelectionDialog> {
  late List<SmartPortionSize> _smartPortions;
  SmartPortionSize? _selectedPortion;
  double _customGrams = 100.0;
  final TextEditingController _customController = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    
    // Detect food category and generate smart portions
    final category = PortionFramework.detectFoodCategory(widget.food.foodName);
    _smartPortions = PortionFramework.generateSmartPortions(
      widget.food.foodName,
      category,
      widget.food.caloriesPer100g.toDouble(),
    );
    
    // Set default selection
    _selectedPortion = _smartPortions.firstWhere(
      (p) => p.isDefault,
      orElse: () => _smartPortions.first,
    );
    
    print('🥄 SmartPortionDialog: Generated ${_smartPortions.length} portions for ${widget.food.foodName} (category: $category)');
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(KSizes.margin4x),
                child: Column(
                  children: [
                    // Food info
                    _buildFoodInfo(),
                    
                    SizedBox(height: KSizes.margin6x),
                    
                    // Smart portion options
                    _buildSmartPortions(),
                    
                    SizedBox(height: KSizes.margin6x),
                    
                    // Custom amount section
                    _buildCustomAmountSection(),
                    
                    SizedBox(height: KSizes.margin6x),
                    
                    // Nutrition preview
                    _buildNutritionPreview(),
                  ],
                ),
              ),
            ),
            
            // Bottom actions
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(KSizes.radiusXL),
          topRight: Radius.circular(KSizes.radiusXL),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(KSizes.margin2x),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(KSizes.radiusM),
            ),
            child: Icon(
              MdiIcons.scaleBalance,
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
                  'Vælg portionsstørrelse',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: KSizes.fontSizeL,
                    fontWeight: KSizes.fontWeightBold,
                  ),
                ),
                Text(
                  'Relevante portioner for denne fødevare',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: KSizes.fontSizeM,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              MdiIcons.close,
              color: Colors.white,
              size: KSizes.iconM,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodInfo() {
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(KSizes.radiusM),
            ),
            child: Icon(
              MdiIcons.food,
              color: Colors.white,
              size: KSizes.iconL,
            ),
          ),
          SizedBox(width: KSizes.margin3x),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.food.foodName,
                  style: TextStyle(
                    fontSize: KSizes.fontSizeL,
                    fontWeight: KSizes.fontWeightBold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: KSizes.margin1x),
                Text(
                  '${widget.food.caloriesPer100g} kcal per 100g',
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
    );
  }

  Widget _buildSmartPortions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Anbefalede portionsstørrelser',
          style: TextStyle(
            fontSize: KSizes.fontSizeL,
            fontWeight: KSizes.fontWeightBold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: KSizes.margin3x),
        
        // Group portions by unit type
        ..._buildPortionsByUnit(),
      ],
    );
  }

  List<Widget> _buildPortionsByUnit() {
    final Map<PortionUnit, List<SmartPortionSize>> portionsByUnit = {};
    
    for (final portion in _smartPortions) {
      portionsByUnit.putIfAbsent(portion.unit, () => []).add(portion);
    }
    
    final widgets = <Widget>[];
    
    for (final entry in portionsByUnit.entries) {
      final unit = entry.key;
      final portions = entry.value;
      
      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unit header
            Padding(
              padding: EdgeInsets.only(bottom: KSizes.margin2x),
              child: Row(
                children: [
                  Icon(
                    _getIconForUnit(unit),
                    color: AppColors.primary,
                    size: KSizes.iconS,
                  ),
                  SizedBox(width: KSizes.margin1x),
                  Text(
                    unit.displayName.toUpperCase(),
                    style: TextStyle(
                      fontSize: KSizes.fontSizeS,
                      fontWeight: KSizes.fontWeightMedium,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            
            // Portion buttons for this unit
            Wrap(
              spacing: KSizes.margin2x,
              runSpacing: KSizes.margin2x,
              children: portions.map((portion) => _buildPortionButton(portion)).toList(),
            ),
            
            SizedBox(height: KSizes.margin4x),
          ],
        ),
      );
    }
    
    return widgets;
  }

  Widget _buildPortionButton(SmartPortionSize portion) {
    final isSelected = _selectedPortion == portion;
    final calories = ((widget.food.caloriesPer100g * portion.grams) / 100).round();
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPortion = portion;
        });
      },
      borderRadius: BorderRadius.circular(KSizes.radiusM),
      child: Container(
        padding: EdgeInsets.all(KSizes.margin3x),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              portion.name,
              style: TextStyle(
                fontSize: KSizes.fontSizeM,
                fontWeight: isSelected ? KSizes.fontWeightBold : KSizes.fontWeightMedium,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: KSizes.margin1x),
            Text(
              '${portion.grams.round()}g',
              style: TextStyle(
                fontSize: KSizes.fontSizeS,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '$calories kcal',
              style: TextStyle(
                fontSize: KSizes.fontSizeS,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAmountSection() {
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.05),
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(color: AppColors.info.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                MdiIcons.pencil,
                color: AppColors.info,
                size: KSizes.iconS,
              ),
              SizedBox(width: KSizes.margin2x),
              Text(
                'Eller indtast brugerdefineret mængde',
                style: TextStyle(
                  fontSize: KSizes.fontSizeM,
                  fontWeight: KSizes.fontWeightMedium,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          SizedBox(height: KSizes.margin3x),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _customController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    final grams = double.tryParse(value);
                    if (grams != null && grams > 0) {
                      setState(() {
                        _customGrams = grams;
                        _selectedPortion = null; // Deselect predefined portions
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Gram',
                    suffix: Text('g'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KSizes.radiusM),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KSizes.radiusM),
                      borderSide: BorderSide(color: AppColors.info, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: KSizes.margin3x,
                      vertical: KSizes.margin2x,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionPreview() {
    final grams = _selectedPortion?.grams ?? _customGrams;
    final calories = ((widget.food.caloriesPer100g * grams) / 100).round();
    final protein = ((widget.food.proteinPer100g * grams) / 100).toStringAsFixed(1);
    final carbs = ((widget.food.carbsPer100g * grams) / 100).toStringAsFixed(1);
    final fat = ((widget.food.fatPer100g * grams) / 100).toStringAsFixed(1);
    
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.success.withOpacity(0.1),
            AppColors.success.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                MdiIcons.nutrition,
                color: AppColors.success,
                size: KSizes.iconM,
              ),
              SizedBox(width: KSizes.margin2x),
              Text(
                'Ernæring for ${grams.round()}g',
                style: TextStyle(
                  fontSize: KSizes.fontSizeL,
                  fontWeight: KSizes.fontWeightBold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          SizedBox(height: KSizes.margin3x),
          
          Row(
            children: [
              Expanded(
                child: _buildNutritionItem('Kalorier', '$calories kcal', MdiIcons.fire),
              ),
              Expanded(
                child: _buildNutritionItem('Protein', '${protein}g', MdiIcons.dumbbell),
              ),
            ],
          ),
          SizedBox(height: KSizes.margin2x),
          Row(
            children: [
              Expanded(
                child: _buildNutritionItem('Kulhydrat', '${carbs}g', MdiIcons.grain),
              ),
              Expanded(
                child: _buildNutritionItem('Fedt', '${fat}g', MdiIcons.waterCircle),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.textSecondary,
          size: KSizes.iconS,
        ),
        SizedBox(height: KSizes.margin1x),
        Text(
          value,
          style: TextStyle(
            fontSize: KSizes.fontSizeM,
            fontWeight: KSizes.fontWeightBold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: KSizes.fontSizeS,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    final grams = _selectedPortion?.grams ?? _customGrams;
    final portionName = _selectedPortion?.name ?? '${_customGrams.round()}g';
    final unitName = _selectedPortion?.unit.shortName ?? 'g';
    
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(KSizes.radiusXL),
          bottomRight: Radius.circular(KSizes.radiusXL),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: KSizes.margin3x),
              ),
              child: Text(
                'Annuller',
                style: TextStyle(
                  fontSize: KSizes.fontSizeL,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          SizedBox(width: KSizes.margin2x),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                widget.onPortionSelected(grams, unitName, portionName);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: KSizes.margin3x),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KSizes.radiusL),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(MdiIcons.check, size: KSizes.iconM),
                  SizedBox(width: KSizes.margin2x),
                  Text(
                    'Vælg',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeL,
                      fontWeight: KSizes.fontWeightMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForUnit(PortionUnit unit) {
    switch (unit) {
      case PortionUnit.gram:
        return MdiIcons.scaleBalance;
      case PortionUnit.piece:
        return MdiIcons.numeric1Circle;
      case PortionUnit.slice:
        return MdiIcons.knife;
      case PortionUnit.cup:
        return MdiIcons.cupWater;
      case PortionUnit.spoon:
        return MdiIcons.silverwareSpoon;
      case PortionUnit.glass:
        return MdiIcons.glassWine;
      case PortionUnit.bottle:
        return MdiIcons.bottleWine;
      case PortionUnit.can:
        return MdiIcons.circle;
      case PortionUnit.portion:
        return MdiIcons.circle;
      case PortionUnit.handful:
        return MdiIcons.handBackRight;
      case PortionUnit.milliliter:
      case PortionUnit.deciliter:
      case PortionUnit.liter:
        return MdiIcons.beaker;
    }
  }
} 