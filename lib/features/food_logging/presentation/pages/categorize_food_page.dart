import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:result_type/result_type.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/pending_food_model.dart';
import '../../domain/user_food_log_model.dart';
import '../../application/pending_food_cubit.dart';
import '../../application/food_logging_notifier.dart';
import '../../infrastructure/gemini_service.dart';
import '../../../dashboard/presentation/dashboard_page.dart';

/// Page for categorizing a pending food photo
class CategorizeFoodPage extends ConsumerStatefulWidget {
  final PendingFoodModel pendingFood;
  final bool fromQuickPhoto;

  const CategorizeFoodPage({
    super.key,
    required this.pendingFood,
    this.fromQuickPhoto = false,
  });

  @override
  ConsumerState<CategorizeFoodPage> createState() => _CategorizeFoodPageState();
}

class _CategorizeFoodPageState extends ConsumerState<CategorizeFoodPage> {
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  
  MealType _selectedMealType = MealType.morgenmad;
  bool _isProcessing = false;
  bool _isAnalyzing = false;
  FoodAnalysisResult? _analysisResult;
  String? _analysisError;
  int _currentImageIndex = 0;

  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    
    // Auto-set meal type based on image capture time instead of current time
    _selectedMealType = _getMealTypeForImageTime();
    
    // Check if AI results already exist
    if (widget.pendingFood.aiResult != null) {
      print('🤖 CategorizeFoodPage: Using existing AI results');
      _analysisResult = widget.pendingFood.aiResult;
      _foodNameController.text = _analysisResult!.foodName;
      _caloriesController.text = _analysisResult!.estimatedCalories.toString();
    } else {
      print('🤖 CategorizeFoodPage: No AI results available yet - user can manually analyze if needed');
      // Auto-analyze if no results exist and image is available
      if (widget.pendingFood.imagePaths.isNotEmpty && 
          !widget.pendingFood.primaryImagePath.startsWith('mock_')) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _analyzeImage());
      }
    }
  }

  MealType _getMealTypeForImageTime() {
    final imageTime = widget.pendingFood.capturedAt;
    final hour = imageTime.hour;
    
    if (hour >= 5 && hour < 10) {
      return MealType.morgenmad;
    } else if (hour >= 10 && hour < 14) {
      return MealType.frokost;
    } else if (hour >= 14 && hour < 18) {
      return MealType.aftensmad;
    } else {
      return MealType.snack;
    }
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Kategoriser din mad',
          style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: KSizes.fontSizeL,
          fontWeight: KSizes.fontWeightBold,
        ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(KSizes.margin4x),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image preview
              _buildImagePreview(),
              
              SizedBox(height: KSizes.margin4x),
              
                    // AI Analysis Section
                    _buildAiAnalysisSection(),
              
              SizedBox(height: KSizes.margin4x),
              
                    // Food details form - main focus
                    _buildFoodDetailsForm(),
              
              SizedBox(height: KSizes.margin8x),
                  ],
                ),
              ),
            ),
              
            // Fixed bottom action area
            _buildBottomActionArea(),
            ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (widget.pendingFood.imagePaths.isEmpty ||
        widget.pendingFood.primaryImagePath.startsWith('mock_')) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(KSizes.radiusL),
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                MdiIcons.imageOff,
                size: KSizes.iconXL,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              SizedBox(height: KSizes.margin2x),
              Text(
                'Billede ikke tilgængeligt',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: KSizes.fontSizeM,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _showImageGallery,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(KSizes.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(KSizes.radiusL),
          child: Stack(
            children: [
              // Current image
              Image.file(
                File(widget.pendingFood.imagePaths[_currentImageIndex]),
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 220,
                    color: AppColors.surface,
                    child: Center(
                      child: Icon(
                        MdiIcons.imageOff,
                        size: KSizes.iconXL,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
              
              // Image overlay with improved design
                  Positioned(
                    bottom: 0,
                left: 0,
                right: 0,
                        child: Container(
                  padding: EdgeInsets.all(KSizes.margin3x),
                          decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                  ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        MdiIcons.eye,
                        color: Colors.white,
                        size: KSizes.iconS,
                      ),
                      SizedBox(width: KSizes.margin1x),
                        Text(
                        'Tryk for fuld visning',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: KSizes.fontSizeS,
                          fontWeight: KSizes.fontWeightMedium,
                          ),
                        ),
                      Spacer(),
                      if (widget.pendingFood.imageCount > 1)
                        Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: KSizes.margin2x,
                    vertical: KSizes.margin1x,
                  ),
                  decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(KSizes.radiusS),
                  ),
                          child: Text(
                            '${_currentImageIndex + 1}/${widget.pendingFood.imageCount}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: KSizes.fontSizeXS,
                              fontWeight: KSizes.fontWeightBold,
                            ),
                        ),
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

  void _showImageGallery() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.all(KSizes.margin4x),
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(KSizes.margin4x),
                child: Row(
                  children: [
                    Text(
                      'Billeder af måltid',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightBold,
                      ),
                    ),
                    Spacer(),
                    if (widget.pendingFood.imageCount > 1)
                      Text(
                        '${_currentImageIndex + 1} af ${widget.pendingFood.imageCount}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: KSizes.fontSizeM,
                        ),
                      ),
                    SizedBox(width: KSizes.margin3x),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        MdiIcons.close,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Image gallery
              Expanded(
                child: PageView.builder(
                  itemCount: widget.pendingFood.imagePaths.length,
                  onPageChanged: (index) => setState(() => _currentImageIndex = index),
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.all(KSizes.margin2x),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                        child: Image.file(
                          File(widget.pendingFood.imagePaths[index]),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.surface,
                            child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                MdiIcons.imageOff,
                                      size: KSizes.iconXL,
                                color: AppColors.textSecondary,
                              ),
                                    SizedBox(height: KSizes.margin2x),
                                    Text(
                                      'Billede kunne ikke indlæses',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: KSizes.fontSizeM,
                                      ),
                                    ),
                                  ],
                            ),
                          ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiAnalysisSection() {
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
        ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(
                MdiIcons.robotConfused,
                color: AppColors.primary,
                size: KSizes.iconM,
              ),
              SizedBox(width: KSizes.margin2x),
              Text(
                'AI Analyse',
                style: TextStyle(
                  fontSize: KSizes.fontSizeL,
                  fontWeight: KSizes.fontWeightBold,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
              if (_analysisResult != null)
              Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: KSizes.margin2x,
                    vertical: KSizes.margin1x,
                  ),
                decoration: BoxDecoration(
                    color: _analysisResult!.confidence > 0.7 
                        ? AppColors.success.withOpacity(0.1)
                        : _analysisResult!.confidence > 0.4
                            ? AppColors.warning.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                    border: Border.all(
                      color: _analysisResult!.confidence > 0.7 
                          ? AppColors.success
                          : _analysisResult!.confidence > 0.4
                              ? AppColors.warning
                              : AppColors.error,
                ),
              ),
                child: Text(
                    '${(_analysisResult!.confidence * 100).toInt()}%',
                  style: TextStyle(
                      fontSize: KSizes.fontSizeS,
                    fontWeight: KSizes.fontWeightBold,
                      color: _analysisResult!.confidence > 0.7 
                          ? AppColors.success
                          : _analysisResult!.confidence > 0.4
                              ? AppColors.warning
                              : AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: KSizes.margin3x),
          
          // Analysis result or analyze button
          if (_analysisResult == null) ...[
            // No analysis yet - show analyze button
        SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isAnalyzing ? null : _analyzeImage,
                icon: _isAnalyzing
                    ? SizedBox(
                        width: KSizes.iconS,
                        height: KSizes.iconS,
          child: CircularProgressIndicator(
            strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
                      )
                    : Icon(MdiIcons.eye, size: KSizes.iconS),
                label: Text(_isAnalyzing ? 'Analyserer...' : 'Analyser Billede'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: EdgeInsets.symmetric(vertical: KSizes.margin3x),
          ),
        ),
            ),
          ] else ...[
            // Show analysis result
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(KSizes.margin3x),
              decoration: BoxDecoration(
                color: _analysisResult!.foodName.toLowerCase() != 'ingen mad'
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(KSizes.radiusM),
                border: Border.all(
                  color: _analysisResult!.foodName.toLowerCase() != 'ingen mad'
                      ? AppColors.success.withOpacity(0.3)
                      : AppColors.info.withOpacity(0.3),
                ),
              ),
              child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                  // Food name
        Row(
          children: [
            Icon(
                        _analysisResult!.foodName.toLowerCase() != 'ingen mad'
                            ? MdiIcons.foodVariant
                            : MdiIcons.alertCircle,
                        color: _analysisResult!.foodName.toLowerCase() != 'ingen mad'
                  ? AppColors.success 
                            : AppColors.info,
              size: KSizes.iconS,
            ),
                      SizedBox(width: KSizes.margin2x),
                      Expanded(
                        child: Text(
                          _analysisResult!.foodName,
              style: TextStyle(
                            fontSize: KSizes.fontSizeM,
                            fontWeight: KSizes.fontWeightBold,
                            color: _analysisResult!.foodName.toLowerCase() != 'ingen mad'
                    ? AppColors.success 
                                : AppColors.info,
                          ),
              ),
            ),
          ],
        ),
        
                  if (_analysisResult!.foodName.toLowerCase() != 'ingen mad') ...[
                    SizedBox(height: KSizes.margin2x),
        
                    // Calories estimate
                    Row(
                      children: [
                        Icon(MdiIcons.fire, color: AppColors.warning, size: KSizes.iconS),
                        SizedBox(width: KSizes.margin1x),
        Text(
                          '${_analysisResult!.estimatedCalories} kcal',
          style: TextStyle(
            fontSize: KSizes.fontSizeS,
                            fontWeight: KSizes.fontWeightMedium,
                            color: AppColors.textPrimary,
          ),
        ),
      ],
                    ),
                    
                    SizedBox(height: KSizes.margin2x),
                    
                    // Use suggestion button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _useAiSuggestion,
                        icon: Icon(MdiIcons.lightbulbOn, size: KSizes.iconS),
                        label: Text('Brug AI Forslag'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: KSizes.margin2x),
                        ),
                      ),
                    ),
                  ],
                  
                  SizedBox(height: KSizes.margin2x),
                  
                  // Re-analyze button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isAnalyzing ? null : _analyzeImage,
                      icon: _isAnalyzing
                          ? SizedBox(
                              width: KSizes.iconS,
                              height: KSizes.iconS,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
                            )
                          : Icon(MdiIcons.refresh, size: KSizes.iconS),
                      label: Text(_isAnalyzing ? 'Analyserer...' : 'Analyser Igen'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        padding: EdgeInsets.symmetric(vertical: KSizes.margin2x),
              ),
            ),
          ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _useAiSuggestion() {
    if (_analysisResult != null) {
      setState(() {
        _foodNameController.text = _analysisResult!.foodName;
        _caloriesController.text = _analysisResult!.estimatedCalories.toString();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
      children: [
              Icon(MdiIcons.lightbulbOn, color: Colors.white),
              SizedBox(width: KSizes.margin2x),
              Text('AI forslag anvendt!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildFoodDetailsForm() {
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
        Row(
          children: [
            Icon(
                MdiIcons.silverwareForkKnife,
                color: AppColors.primary,
                size: KSizes.iconM,
            ),
              SizedBox(width: KSizes.margin2x),
              Text(
                'Mad Detaljer',
                style: TextStyle(
                  fontSize: KSizes.fontSizeL,
                  fontWeight: KSizes.fontWeightBold,
                  color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
          
          SizedBox(height: KSizes.margin4x),
          
          // AI suggestion if available (simplified)
          if (_analysisResult != null && _analysisResult!.foodName.toLowerCase() != 'ingen mad') ...[
            Container(
              padding: EdgeInsets.all(KSizes.margin3x),
            decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(KSizes.radiusM),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                    MdiIcons.lightbulbOn,
                    color: AppColors.success,
                    size: KSizes.iconS,
                ),
                  SizedBox(width: KSizes.margin2x),
                  Expanded(
                    child: Text(
                      'AI forslag: ${_analysisResult!.foodName} (${_analysisResult!.estimatedCalories} kcal)',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeS,
                        color: AppColors.success,
                    fontWeight: KSizes.fontWeightMedium,
                      ),
                  ),
                ),
              ],
            ),
          ),
            SizedBox(height: KSizes.margin4x),
          ],
          
          // Food name input
        Text(
          'Hvad er det for mad?',
          style: TextStyle(
              fontSize: KSizes.fontSizeM,
              fontWeight: KSizes.fontWeightMedium,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: KSizes.margin2x),
        TextField(
          controller: _foodNameController,
          decoration: InputDecoration(
            hintText: 'F.eks. Spaghetti Bolognese',
            prefixIcon: Icon(
                MdiIcons.foodVariant,
              color: AppColors.primary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KSizes.radiusM),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KSizes.radiusM),
              borderSide: BorderSide(color: AppColors.primary),
            ),
              filled: true,
              fillColor: AppColors.background,
        ),
            onChanged: (_) => setState(() {}),
          ),
          
          SizedBox(height: KSizes.margin4x),
          
          // Meal type selector - show selected time
          Row(
      children: [
        Text(
                'Måltid: ',
          style: TextStyle(
                  fontSize: KSizes.fontSizeM,
                  fontWeight: KSizes.fontWeightMedium,
            color: AppColors.textPrimary,
          ),
        ),
              Text(
                '(${_formatImageTime()})',
                style: TextStyle(
                  fontSize: KSizes.fontSizeS,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: KSizes.margin2x),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
          children: MealType.values.map((mealType) {
            final isSelected = _selectedMealType == mealType;
                final index = MealType.values.indexOf(mealType);
                
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < MealType.values.length - 1 ? KSizes.margin2x : 0,
                  ),
                  child: GestureDetector(
              onTap: () => setState(() => _selectedMealType = mealType),
              child: Container(
                padding: EdgeInsets.symmetric(
                        horizontal: KSizes.margin4x,
                        vertical: KSizes.margin3x,
                ),
                decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(KSizes.radiusL),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2 : 1,
                  ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ] : null,
                ),
                child: Text(
                  mealType.mealTypeDisplayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? KSizes.fontWeightBold : KSizes.fontWeightMedium,
                          fontSize: KSizes.fontSizeM,
                        ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
          ),
          
          SizedBox(height: KSizes.margin4x),
          
          // Calories input
        Text(
          'Hvor mange kalorier?',
          style: TextStyle(
              fontSize: KSizes.fontSizeM,
              fontWeight: KSizes.fontWeightMedium,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: KSizes.margin2x),
        TextField(
          controller: _caloriesController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'F.eks. 450',
            suffixText: 'kcal',
            prefixIcon: Icon(
              MdiIcons.fire,
              color: AppColors.primary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KSizes.radiusM),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KSizes.radiusM),
              borderSide: BorderSide(color: AppColors.primary),
            ),
              filled: true,
              fillColor: AppColors.background,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  String _formatImageTime() {
    final time = widget.pendingFood.capturedAt;
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildBottomActionArea() {
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border.withOpacity(0.3)),
          ),
        ),
      child: Column(
      children: [
        // Primary action - Kategoriser Mad
          SizedBox(
          width: double.infinity,
            height: 56,
          child: ElevatedButton.icon(
              onPressed: (_isProcessing || !_isFormValid()) ? null : _categorizeFood,
            icon: _isProcessing 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(MdiIcons.check, size: KSizes.iconM),
            label: Text(
              _isProcessing ? 'Kategoriserer...' : 'Kategoriser Mad',
              style: TextStyle(
                fontSize: KSizes.fontSizeL,
                fontWeight: KSizes.fontWeightBold,
              ),
            ),
            style: ElevatedButton.styleFrom(
                backgroundColor: _isFormValid() ? AppColors.primary : AppColors.border,
              foregroundColor: Colors.white,
                elevation: _isFormValid() ? 8 : 0,
              shadowColor: AppColors.primary.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KSizes.radiusL),
              ),
            ),
          ),
        ),
        
          SizedBox(height: KSizes.margin2x),
        
          // Secondary actions row
          Row(
            children: [
              // Save for later button
              Expanded(
          child: OutlinedButton.icon(
            onPressed: _isProcessing ? null : _saveForLater,
            icon: Icon(MdiIcons.clockOutline, size: KSizes.iconS),
                  label: Text('Senere'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.warning,
                    side: BorderSide(color: AppColors.warning),
                    padding: EdgeInsets.symmetric(vertical: KSizes.margin3x),
            ),
          ),
        ),
        
              SizedBox(width: KSizes.margin2x),
        
            // Delete button
            Expanded(
                child: OutlinedButton.icon(
                onPressed: _isProcessing ? null : _deleteImage,
                icon: Icon(MdiIcons.delete, size: KSizes.iconS),
                label: Text('Slet'),
                  style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                    padding: EdgeInsets.symmetric(vertical: KSizes.margin3x),
                ),
              ),
            ),
          ],
        ),
      ],
      ),
    );
  }

  void _saveForLater() async {
    try {
      setState(() => _isProcessing = true);
      
      // If this comes from quick photo session, we need to save the pending food to the service
      if (widget.fromQuickPhoto) {
        print('🍎 CategorizeFoodPage: Saving pending food from quick photo session');
        await ref.read(pendingFoodProvider.notifier).addNewPendingFood(widget.pendingFood);
      }
      
      // Just pop back without processing - the pending food stays in the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(MdiIcons.clockOutline, color: Colors.white),
                SizedBox(width: KSizes.margin2x),
                Text('Mad gemt til senere kategorisering'),
              ],
            ),
            backgroundColor: AppColors.info,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Return special value to indicate save for later
        Navigator.of(context).pop('saved_for_later');
      }
    } catch (e) {
      print('🍎 CategorizeFoodPage: Error saving for later: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(MdiIcons.alertCircle, color: Colors.white),
                SizedBox(width: KSizes.margin2x),
                Expanded(child: Text('Fejl ved gemning til senere: $e')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _categorizeFood() async {
    if (_foodNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(MdiIcons.alertCircle, color: Colors.white),
              SizedBox(width: KSizes.margin2x),
              Text('Angiv venligst navn på maden'),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_caloriesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(MdiIcons.alertCircle, color: Colors.white),
              SizedBox(width: KSizes.margin2x),
              Text('Angiv venligst antal kalorier'),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final calories = int.tryParse(_caloriesController.text.trim());
    if (calories == null || calories < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(MdiIcons.alertCircle, color: Colors.white),
              SizedBox(width: KSizes.margin2x),
              Expanded(child: Text('Angiv venligst et gyldigt antal kalorier (0 eller højere)')),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Create food log entry
      final foodLog = UserFoodLogModel(
        userId: 1, // TODO: Get real user ID
        foodName: _foodNameController.text.trim(),
        mealType: _selectedMealType,
        calories: calories,
        protein: 0.0, // Default values for now
        fat: 0.0,
        carbs: 0.0,
        quantity: 1.0,
        servingUnit: 'portion',
        loggedAt: widget.pendingFood.capturedAt.toIso8601String(),
      );

      // Log the food
      await ref.read(foodLoggingProvider.notifier).logFood(foodLog);

      // Mark pending food as processed
      await ref.read(pendingFoodProvider.notifier).markAsProcessed(widget.pendingFood.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(MdiIcons.checkCircle, color: Colors.white),
                SizedBox(width: KSizes.margin2x),
                Text('Mad kategoriseret og gemt!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(MdiIcons.alertCircle, color: Colors.white),
                SizedBox(width: KSizes.margin2x),
                Expanded(child: Text('Fejl ved kategorisering: ${e.toString()}')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _deleteImage() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(MdiIcons.delete, color: AppColors.error),
            SizedBox(width: KSizes.margin2x),
            Text('Slet billede?'),
          ],
        ),
        content: Text('Er du sikker på at du vil slette dette billede? Denne handling kan ikke fortrydes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Annuller'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text('Slet'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
      setState(() => _isProcessing = true);

        // Delete pending food
        await ref.read(pendingFoodProvider.notifier).deletePendingFood(widget.pendingFood.id);

        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
              content: Row(
                children: [
                  Icon(MdiIcons.checkCircle, color: Colors.white),
                  SizedBox(width: KSizes.margin2x),
                  Text('Billede slettet'),
                ],
              ),
                backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              ),
            );
          
          // If this came from quick photo session, navigate back to home/dashboard
          // Otherwise just pop back to previous page
          if (widget.fromQuickPhoto) {
            // Navigate back to home by popping all routes until we get to the dashboard
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            Navigator.of(context).pop('deleted');
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(MdiIcons.alertCircle, color: Colors.white),
                  SizedBox(width: KSizes.margin2x),
                  Expanded(child: Text('Fejl ved sletning: ${e.toString()}')),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  void _analyzeImage() async {
    if (widget.pendingFood.imagePaths.isEmpty ||
        widget.pendingFood.primaryImagePath.startsWith('mock_')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(MdiIcons.alertCircle, color: Colors.white),
              SizedBox(width: KSizes.margin2x),
              Text('Ingen billede tilgængeligt til analyse'),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisError = null;
    });

    try {
      print('🤖 CategorizeFoodPage: Starting AI analysis');
      
      final result = await _geminiService.analyzeFoodImage(
        widget.pendingFood.primaryImagePath,
      );

      if (result.isSuccess) {
        final analysisResult = result.success;
        setState(() {
          _analysisResult = analysisResult;
          _foodNameController.text = analysisResult.foodName;
          _caloriesController.text = analysisResult.estimatedCalories.toString();
        });
        
        print('🤖 CategorizeFoodPage: AI analysis successful');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(MdiIcons.checkCircle, color: Colors.white),
                  SizedBox(width: KSizes.margin2x),
                  Text('AI analyse fuldført!'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        final error = result.failure;
        setState(() => _analysisError = error.toString());
        
        print('🤖 CategorizeFoodPage: AI analysis failed: $error');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(MdiIcons.alertCircle, color: Colors.white),
                  SizedBox(width: KSizes.margin2x),
                  Expanded(child: Text('AI analyse fejlede: ${error.toString()}')),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _analysisError = e.toString());
      
      print('🤖 CategorizeFoodPage: AI analysis exception: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(MdiIcons.alertCircle, color: Colors.white),
                SizedBox(width: KSizes.margin2x),
                Expanded(child: Text('Uventet fejl: ${e.toString()}')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  bool _isFormValid() {
    return _foodNameController.text.trim().isNotEmpty && 
           _caloriesController.text.trim().isNotEmpty &&
           (int.tryParse(_caloriesController.text.trim()) ?? 0) >= 0;
  }
} 