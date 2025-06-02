import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../food_database/domain/portion_framework.dart';
import '../../domain/favorite_food_model.dart';
import 'progressive_portion_selection_dialog.dart';

/// Lightning-fast portion selection with only the most relevant options
/// Perfect for quick logging with minimal taps
class LightningPortionDialog extends StatefulWidget {
  final FavoriteFoodModel food;
  final Function(double grams, String unitName, String displayName) onPortionSelected;

  const LightningPortionDialog({
    super.key,
    required this.food,
    required this.onPortionSelected,
  });

  @override
  State<LightningPortionDialog> createState() => _LightningPortionDialogState();
}

class _LightningPortionDialogState extends State<LightningPortionDialog> {
  final TextEditingController _quickGramController = TextEditingController();

  @override
  void dispose() {
    _quickGramController.dispose();
    super.dispose();
  }

  List<SmartPortionSize> _getTopPortions() {
    final category = PortionFramework.detectFoodCategory(widget.food.foodName);
    final allPortions = PortionFramework.generateSmartPortions(
      widget.food.foodName,
      category,
      widget.food.caloriesPer100g.toDouble(),
    );

    // Get the top 4 most relevant portions
    final topPortions = <SmartPortionSize>[];
    
    // Always include the default portion
    final defaultPortion = allPortions.firstWhere(
      (p) => p.isDefault,
      orElse: () => allPortions.first,
    );
    topPortions.add(defaultPortion);
    
    // Add 2-3 other most common portions, avoiding duplicates
    final others = allPortions
        .where((p) => p != defaultPortion)
        .take(3)
        .toList();
    topPortions.addAll(others);
    
    return topPortions.take(4).toList();
  }

  void _selectPortion(SmartPortionSize portion) {
    HapticFeedback.mediumImpact();
    widget.onPortionSelected(
      portion.grams,
      portion.unit.shortName,
      portion.name,
    );
    Navigator.of(context).pop();
  }

  void _selectCustomGrams() {
    final gramsText = _quickGramController.text.trim();
    if (gramsText.isEmpty) return;
    
    final grams = double.tryParse(gramsText);
    if (grams == null || grams <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ugyldig antal gram'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    HapticFeedback.mediumImpact();
    widget.onPortionSelected(grams, 'gram', '${grams.round()}g');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
          borderRadius: BorderRadius.circular(KSizes.radiusXL),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(KSizes.margin4x),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Custom gram input FIRST - primary option
                    _buildQuickCustomInput(),
                    SizedBox(height: KSizes.margin4x),
                    
                    // Divider with "eller" text
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: KSizes.margin3x),
                          child: Text(
                            'eller vælg hurtigt',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: KSizes.fontSizeM,
                              fontWeight: KSizes.fontWeightMedium,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),
                    SizedBox(height: KSizes.margin3x),
                    
                    // Pre-defined portions
                    _buildPortionsGrid(),
                    SizedBox(height: KSizes.margin3x),
                    
                    // Action buttons
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        gradient: AppDesign.primaryGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(KSizes.radiusXL),
          topRight: Radius.circular(KSizes.radiusXL),
        ),
      ),
      child: Row(
        children: [
          Icon(
            MdiIcons.flash,
            color: Colors.white,
            size: KSizes.iconM,
          ),
          SizedBox(width: KSizes.margin2x),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hurtig portion',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeL,
                    fontWeight: KSizes.fontWeightBold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: KSizes.margin1x),
                Text(
                  widget.food.foodName,
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(MdiIcons.close, color: Colors.white),
            iconSize: KSizes.iconM,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCustomInput() {
    return Container(
      padding: EdgeInsets.all(KSizes.margin3x),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withOpacity(0.1),
            AppColors.success.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(
          color: AppColors.success.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  MdiIcons.scaleBalance,
                  color: AppColors.success,
                  size: KSizes.iconM,
                ),
              ),
              SizedBox(width: KSizes.margin3x),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Indtast gram direkte',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: KSizes.margin1x),
                    Text(
                      'Skriv antal gram og tryk OK',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: KSizes.margin2x,
                  vertical: KSizes.margin1x,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                ),
              ),
            ],
          ),
          
          SizedBox(height: KSizes.margin3x),
          
          // Input field with OK button (removed quick select buttons)
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _quickGramController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Skriv gram...',
                    suffixText: 'g',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KSizes.radiusL),
                      borderSide: BorderSide(color: AppColors.success.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KSizes.radiusL),
                      borderSide: BorderSide(color: AppColors.success, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: KSizes.margin3x,
                      vertical: KSizes.margin2x,
                    ),
                    isDense: true,
                  ),
                  style: TextStyle(
                    fontSize: KSizes.fontSizeL,
                    fontWeight: KSizes.fontWeightBold,
                  ),
                  textAlign: TextAlign.center,
                  onSubmitted: (_) => _selectCustomGrams(),
                ),
              ),
              
              SizedBox(width: KSizes.margin2x),
              
              // OK button
              InkWell(
                onTap: _selectCustomGrams,
                borderRadius: BorderRadius.circular(KSizes.radiusL),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: KSizes.margin3x,
                    vertical: KSizes.margin2x,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(KSizes.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.3),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeL,
                      color: Colors.white,
                      fontWeight: KSizes.fontWeightBold,
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

  Widget _buildPortionsGrid() {
    final topPortions = _getTopPortions();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: KSizes.margin3x,
        mainAxisSpacing: KSizes.margin3x,
        childAspectRatio: 1.1,
      ),
      itemCount: topPortions.length,
      itemBuilder: (context, index) {
        final portion = topPortions[index];
        final isDefault = portion.isDefault;
        final calories = (portion.grams * widget.food.caloriesPer100g / 100).round();
        
        return InkWell(
          onTap: () => _selectPortion(portion),
          borderRadius: BorderRadius.circular(KSizes.radiusL),
          child: Container(
            padding: EdgeInsets.all(KSizes.margin3x),
            decoration: BoxDecoration(
              color: isDefault 
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(KSizes.radiusL),
              border: Border.all(
                color: isDefault
                    ? AppColors.primary
                    : AppColors.border.withOpacity(0.3),
                width: isDefault ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isDefault) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: KSizes.margin2x,
                      vertical: KSizes.margin1x,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(KSizes.radiusS),
                    ),
                  ),
                  SizedBox(height: KSizes.margin2x),
                ],
                Text(
                  portion.name,
                  style: TextStyle(
                    fontSize: KSizes.fontSizeL,
                    fontWeight: KSizes.fontWeightBold,
                    color: isDefault ? AppColors.primary : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                SizedBox(height: KSizes.margin2x),
                Text(
                  '${portion.grams.round()}g',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    color: AppColors.textSecondary,
                    fontWeight: KSizes.fontWeightMedium,
                  ),
                ),
                SizedBox(height: KSizes.margin1x),
                Text(
                  '$calories kcal',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeS,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: KSizes.margin4x,
        vertical: KSizes.margin3x,
      ),
      child: TextButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          // Show the full progressive dialog
          showDialog(
            context: context,
            builder: (context) => ProgressivePortionSelectionDialog(
              food: widget.food,
              enableFastMode: false, // Disable fast mode for full experience
              onPortionSelected: widget.onPortionSelected,
            ),
          );
        },
        icon: Icon(
          MdiIcons.dotsHorizontal,
          size: KSizes.iconS,
          color: AppColors.textSecondary,
        ),
        label: Text(
          'Flere muligheder',
          style: TextStyle(
            fontSize: KSizes.fontSizeM,
            color: AppColors.textSecondary,
          ),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: KSizes.margin3x,
            vertical: KSizes.margin2x,
          ),
        ),
      ),
    );
  }
} 