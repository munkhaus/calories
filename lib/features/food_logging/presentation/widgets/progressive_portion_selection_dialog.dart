import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add for vibration
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../food_database/domain/portion_framework.dart';
import '../../domain/favorite_food_model.dart';

/// Progressive portion selection dialog with better UX and auto-selection
/// Uses step-by-step approach for less cognitive load
class ProgressivePortionSelectionDialog extends StatefulWidget {
  final FavoriteFoodModel food;
  final Function(double grams, String unitName, String displayName) onPortionSelected;
  final bool enableFastMode; // New: Enable one-tap selection for recommended items

  const ProgressivePortionSelectionDialog({
    super.key,
    required this.food,
    required this.onPortionSelected,
    this.enableFastMode = true, // Default to fast mode
  });

  @override
  State<ProgressivePortionSelectionDialog> createState() => _ProgressivePortionSelectionDialogState();
}

class _ProgressivePortionSelectionDialogState extends State<ProgressivePortionSelectionDialog> {
  List<SmartPortionSize> _smartPortions = [];
  List<PortionCategory> _categories = [];
  PortionCategory? _selectedCategory;
  bool _showCustomInput = false;
  final TextEditingController _customController = TextEditingController();
  final TextEditingController _quickGramController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateSmartPortions();
  }

  void _generateSmartPortions() {
    final category = PortionFramework.detectFoodCategory(widget.food.foodName);
    _smartPortions = PortionFramework.generateSmartPortions(
      widget.food.foodName,
      category,
      widget.food.caloriesPer100g.toDouble(),
    );

    // Group portions by category for better UX
    _categories = _groupPortionsByCategory(_smartPortions);
  }

  List<PortionCategory> _groupPortionsByCategory(List<SmartPortionSize> portions) {
    final Map<String, List<SmartPortionSize>> grouped = {};
    
    for (final portion in portions) {
      final categoryName = _getCategoryName(portion.unit);
      if (categoryName != null) { // Only include non-null categories
        grouped.putIfAbsent(categoryName, () => []).add(portion);
      }
    }

    return grouped.entries.map((entry) => PortionCategory(
      name: entry.key,
      icon: _getCategoryIcon(entry.key),
      portions: entry.value,
      isRecommended: _isRecommendedCategory(entry.key),
    )).toList()
      ..sort((a, b) {
        // Recommended categories first
        if (a.isRecommended && !b.isRecommended) return -1;
        if (!a.isRecommended && b.isRecommended) return 1;
        return a.name.compareTo(b.name);
      });
  }

  String? _getCategoryName(PortionUnit unit) {
    switch (unit) {
      case PortionUnit.gram:
        return null; // Skip gram category since it's in the input at top
      case PortionUnit.piece:
        return 'Stykker';
      case PortionUnit.slice:
        return 'Skiver';
      case PortionUnit.cup:
      case PortionUnit.glass:
        return 'Glas & kopper';
      case PortionUnit.spoon:
        return 'Skeer';
      case PortionUnit.bottle:
      case PortionUnit.can:
        return 'Flasker & dåser';
      case PortionUnit.portion:
        return 'Portioner';
      case PortionUnit.handful:
        return 'Håndfulde';
      case PortionUnit.milliliter:
      case PortionUnit.deciliter:
      case PortionUnit.liter:
        return 'ml, dl & liter'; // More specific and understandable
      default:
        return 'Andet';
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName) {
      case 'Stykker':
        return MdiIcons.numeric;
      case 'Skiver':
        return MdiIcons.knife;
      case 'Glas & kopper':
        return MdiIcons.glassMug;
      case 'Skeer':
        return MdiIcons.silverwareSpoon;
      case 'Flasker & dåser':
        return MdiIcons.packageVariant;
      case 'Portioner':
        return MdiIcons.foodVariant;
      case 'Håndfulde':
        return MdiIcons.handBackRight;
      case 'ml, dl & liter':
        return MdiIcons.cupWater;
      default:
        return MdiIcons.circle;
    }
  }

  bool _isRecommendedCategory(String categoryName) {
    // Most intuitive categories for users
    return ['Stykker', 'Skiver', 'Glas & kopper', 'Portioner'].contains(categoryName);
  }

  // Auto-select category if only one recommended option exists
  void _handleCategorySelection(PortionCategory category) {
    setState(() {
      _selectedCategory = category;
    });
    
    // Add haptic feedback for better UX
    HapticFeedback.lightImpact();
    
    // If fast mode is enabled and this is a recommended category with only 1-2 options,
    // and there's a clear default, auto-proceed
    if (widget.enableFastMode && 
        category.isRecommended && 
        category.portions.length <= 2 &&
        category.portions.any((p) => p.isDefault)) {
      // Wait a moment for visual feedback, then auto-select
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _handleFastSelection(category.portions.first);
        }
      });
    }
  }

  // Fast selection for one-tap mode
  void _handleFastSelection(SmartPortionSize portion) {
    HapticFeedback.mediumImpact();
    widget.onPortionSelected(
      portion.grams,
      portion.unit.shortName,
      portion.name,
    );
    Navigator.of(context).pop();
  }

  // Handle double-tap for instant selection
  void _handlePortionDoubleTap(SmartPortionSize portion) {
    _handleFastSelection(portion);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KSizes.radiusXL),
          ),
          child: Column(
            children: [
              _buildHeader(),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(KSizes.margin3x),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick gram input FIRST
                      _buildQuickGramInput(),
                      SizedBox(height: KSizes.margin4x),
                      
                      // Divider with "eller" text
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.border)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: KSizes.margin3x),
                            child: Text(
                              'eller følg vejledning',
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
                      
                      // Step-by-step selection
                      _buildStepByStepSelection(),
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

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(KSizes.margin3x),
      decoration: BoxDecoration(
        gradient: AppDesign.primaryGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(KSizes.radiusXL),
          topRight: Radius.circular(KSizes.radiusXL),
        ),
      ),
      child: Row(
        children: [
          // Back button (only show when category is selected)
          if (_selectedCategory != null && !_showCustomInput)
            IconButton(
              onPressed: () => setState(() => _selectedCategory = null),
              icon: Icon(MdiIcons.arrowLeft, color: Colors.white),
              iconSize: KSizes.iconM,
            ),
          
          // Custom input back button
          if (_showCustomInput)
            IconButton(
              onPressed: () => setState(() => _showCustomInput = false),
              icon: Icon(MdiIcons.arrowLeft, color: Colors.white),
              iconSize: KSizes.iconM,
            ),

          // Title and food info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTitle(),
                  style: TextStyle(
                    fontSize: KSizes.fontSizeL,
                    fontWeight: KSizes.fontWeightBold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: KSizes.margin1x),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: KSizes.margin2x,
                          vertical: KSizes.margin1x,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(KSizes.radiusM),
                        ),
                        child: Text(
                          widget.food.foodName,
                          style: TextStyle(
                            fontSize: KSizes.fontSizeS,
                            color: Colors.white,
                            fontWeight: KSizes.fontWeightMedium,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(width: KSizes.margin2x),
                    Text(
                      '${widget.food.caloriesPer100g.round()} kcal/100g',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Close button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(MdiIcons.close, color: Colors.white),
            iconSize: KSizes.iconM,
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    if (_showCustomInput) return 'Indtast brugerdefineret';
    if (_selectedCategory != null) return 'Vælg ${_selectedCategory!.name.toLowerCase()}';
    return 'Vælg portionstype';
  }

  Widget _buildStepByStepSelection() {
    return _selectedCategory == null
        ? _buildCategorySelection()
        : _showCustomInput
            ? _buildCustomInput()
            : _buildPortionSelection();
  }

  Widget _buildCategorySelection() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(KSizes.margin3x),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Recommended categories
          if (_categories.any((c) => c.isRecommended)) ...[
            Text(
              'Anbefalede målinger',
              style: TextStyle(
                fontSize: KSizes.fontSizeM,
                fontWeight: KSizes.fontWeightMedium,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: KSizes.margin3x),
            ...(_categories.where((c) => c.isRecommended).map((category) => 
              _buildCategoryCard(category, isRecommended: true)
            )),
            SizedBox(height: KSizes.margin4x),
          ],

          // Other categories
          if (_categories.any((c) => !c.isRecommended)) ...[
            Text(
              'Andre målinger',
              style: TextStyle(
                fontSize: KSizes.fontSizeM,
                fontWeight: KSizes.fontWeightMedium,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: KSizes.margin3x),
            ...(_categories.where((c) => !c.isRecommended).map((category) => 
              _buildCategoryCard(category, isRecommended: false)
            )),
          ],

          SizedBox(height: KSizes.margin2x), // Extra bottom padding
        ],
      ),
    );
  }

  Widget _buildPortionSelection() {
    return Padding(
      padding: EdgeInsets.all(KSizes.margin3x),
      child: Column(
        children: [
          // Category info
          Row(
            children: [
              Icon(
                _selectedCategory!.icon,
                color: AppColors.primary,
                size: KSizes.iconM,
              ),
              SizedBox(width: KSizes.margin2x),
              Text(
                _selectedCategory!.name,
                style: TextStyle(
                  fontSize: KSizes.fontSizeL,
                  fontWeight: KSizes.fontWeightMedium,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: KSizes.margin4x),

          // Portion options
          SizedBox(
            height: 400, // Fixed height for the grid
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: KSizes.margin3x,
                mainAxisSpacing: KSizes.margin3x,
                childAspectRatio: 1.0, // Reduced from 1.2 to give more height
              ),
              itemCount: _selectedCategory!.portions.length,
              itemBuilder: (context, index) {
                final portion = _selectedCategory!.portions[index];
                
                return _buildPortionCard(portion);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomInput() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(KSizes.margin3x),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Indtast antal gram',
            style: TextStyle(
              fontSize: KSizes.fontSizeL,
              fontWeight: KSizes.fontWeightMedium,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: KSizes.margin4x),
          
          TextField(
            controller: _customController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Gram',
              suffixText: 'g',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KSizes.radiusL),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KSizes.radiusL),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            style: TextStyle(
              fontSize: KSizes.fontSizeXL,
              fontWeight: KSizes.fontWeightBold,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: KSizes.margin4x),
          
          // Quick select buttons
          Text(
            'Eller vælg hurtigt:',
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: KSizes.margin3x),
          
          Wrap(
            spacing: KSizes.margin2x,
            runSpacing: KSizes.margin2x,
            children: [25, 50, 75, 100, 150, 200].map((grams) => 
              InkWell(
                onTap: () => _customController.text = grams.toString(),
                borderRadius: BorderRadius.circular(KSizes.radiusM),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: KSizes.margin3x,
                    vertical: KSizes.margin2x,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                  ),
                  child: Text(
                    '${grams}g',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeM,
                      color: AppColors.primary,
                      fontWeight: KSizes.fontWeightMedium,
                    ),
                  ),
                ),
              ),
            ).toList(),
          ),
          SizedBox(height: KSizes.margin2x), // Extra bottom padding
        ],
      ),
    );
  }

  Widget _buildCategoryCard(PortionCategory category, {required bool isRecommended}) {
    return Container(
      margin: EdgeInsets.only(bottom: KSizes.margin3x),
      child: InkWell(
        onTap: () => _handleCategorySelection(category),
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        child: Container(
          padding: EdgeInsets.all(KSizes.margin4x),
          decoration: BoxDecoration(
            color: isRecommended 
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(KSizes.radiusL),
            border: Border.all(
              color: isRecommended
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.border.withOpacity(0.3),
              width: isRecommended ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  color: isRecommended
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  category.icon,
                  color: isRecommended ? AppColors.primary : AppColors.textSecondary,
                  size: KSizes.iconM,
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
                            category.name,
                            style: TextStyle(
                              fontSize: KSizes.fontSizeL,
                              fontWeight: KSizes.fontWeightMedium,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isRecommended) ...[
                          SizedBox(width: KSizes.margin2x),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: KSizes.margin2x,
                              vertical: KSizes.margin1x,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(KSizes.radiusS),
                            ),
                          ),
                        ],
                        // Show fast-select indicator for recommended categories
                        if (widget.enableFastMode && isRecommended && category.portions.length <= 2) ...[
                          SizedBox(width: KSizes.margin2x),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: KSizes.margin2x,
                              vertical: KSizes.margin1x,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(KSizes.radiusS),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  MdiIcons.flash,
                                  size: KSizes.fontSizeXS,
                                  color: AppColors.secondary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: KSizes.margin1x),
                    Text(
                      '${category.portions.length} muligheder',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                MdiIcons.chevronRight,
                color: AppColors.textSecondary,
                size: KSizes.iconM,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickGramInput() {
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
                  onSubmitted: (_) => _selectQuickGrams(),
                ),
              ),
              
              SizedBox(width: KSizes.margin2x),
              
              // OK button
              InkWell(
                onTap: _selectQuickGrams,
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

  void _selectQuickGrams() {
    final grams = double.tryParse(_quickGramController.text);
    if (grams != null && grams > 0) {
      Navigator.of(context).pop({
        'grams': grams,
        'unitName': 'gram',
        'displayName': '${grams.round()}g',
      });
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Indtast et gyldigt antal gram'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildPortionCard(SmartPortionSize portion) {
    final calories = (portion.grams * widget.food.caloriesPer100g / 100).round();
    
    return GestureDetector(
      onTap: () {
        // Direct selection - no need to mark as selected first
        HapticFeedback.mediumImpact();
        widget.onPortionSelected(
          portion.grams,
          portion.unit.shortName,
          portion.name,
        );
        Navigator.of(context).pop();
      },
      child: Container(
        padding: EdgeInsets.all(KSizes.margin2x), // Reduced from margin3x
        decoration: BoxDecoration(
          color: AppColors.surface, // Always use surface color since no selection state
          borderRadius: BorderRadius.circular(KSizes.radiusL),
          border: Border.all(
            color: AppColors.border.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Added to prevent expansion
          children: [
            // Add icon for the portion type
            Icon(
              _getPortionIcon(portion.unit),
              color: AppColors.primary,
              size: KSizes.iconM,
            ),
            SizedBox(height: KSizes.margin1x),
            Text(
              portion.name,
              style: TextStyle(
                fontSize: KSizes.fontSizeM, // Reduced from fontSizeL
                fontWeight: KSizes.fontWeightBold,
                color: AppColors.textPrimary, // Always primary text color
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2, // Allow 2 lines to prevent overflow
            ),
            SizedBox(height: KSizes.margin1x), // Reduced from margin2x
            Text(
              '${portion.grams.round()}g',
              style: TextStyle(
                fontSize: KSizes.fontSizeS, // Reduced from fontSizeM
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: KSizes.margin1x), // Kept small spacing
            Text(
              '$calories kcal',
              style: TextStyle(
                fontSize: KSizes.fontSizeS, // Reduced from fontSizeM
                color: AppColors.textSecondary,
                fontWeight: KSizes.fontWeightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPortionIcon(PortionUnit unit) {
    switch (unit) {
      case PortionUnit.piece:
        return MdiIcons.numeric;
      case PortionUnit.slice:
        return MdiIcons.knife;
      case PortionUnit.cup:
        return MdiIcons.coffee;
      case PortionUnit.glass:
        return MdiIcons.glassMug;
      case PortionUnit.spoon:
        return MdiIcons.silverwareSpoon;
      case PortionUnit.bottle:
        return MdiIcons.bottleWine;
      case PortionUnit.can:
        return MdiIcons.cup;
      case PortionUnit.portion:
        return MdiIcons.foodVariant;
      case PortionUnit.handful:
        return MdiIcons.handBackRight;
      case PortionUnit.milliliter:
      case PortionUnit.deciliter:
      case PortionUnit.liter:
        return MdiIcons.cupWater;
      case PortionUnit.gram:
        return MdiIcons.scaleBalance;
      default:
        return MdiIcons.circle;
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    _quickGramController.dispose();
    super.dispose();
  }
}

/// Helper class for organizing portion categories
class PortionCategory {
  final String name;
  final IconData icon;
  final List<SmartPortionSize> portions;
  final bool isRecommended;

  PortionCategory({
    required this.name,
    required this.icon,
    required this.portions,
    required this.isRecommended,
  });
} 