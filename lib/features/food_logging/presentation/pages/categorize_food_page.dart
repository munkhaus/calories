import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:result_type/result_type.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/pending_food_model.dart';
import '../../domain/user_food_log_model.dart';
import '../../domain/favorite_food_model.dart';
import '../../application/pending_food_cubit.dart';
import '../../application/food_logging_notifier.dart';
import '../../infrastructure/gemini_service.dart';
import '../../infrastructure/favorite_food_service.dart';

/// Page for categorizing a pending food photo
class CategorizeFoodPage extends ConsumerStatefulWidget {
  final PendingFoodModel pendingFood;

  const CategorizeFoodPage({
    super.key,
    required this.pendingFood,
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
  bool _markAsFavorite = false;
  FoodAnalysisResult? _analysisResult;
  String? _analysisError;

  final GeminiService _geminiService = GeminiService();
  final FavoriteFoodService _favoriteFoodService = FavoriteFoodService();

  @override
  void initState() {
    super.initState();
    // Start analysis when page opens
    _analyzeImage();
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
        title: Text('Kategoriser Mad'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: KSizes.fontSizeL,
          fontWeight: KSizes.fontWeightBold,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(KSizes.margin4x),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image preview
              _buildImagePreview(),
              
              SizedBox(height: KSizes.margin4x),
              
              // AI Analysis display
              _buildAiAnalysisDisplay(),
              
              SizedBox(height: KSizes.margin4x),
              
              // Food name input
              _buildFoodNameSection(),
              
              SizedBox(height: KSizes.margin4x),
              
              // Meal type selector
              _buildMealTypeSection(),
              
              SizedBox(height: KSizes.margin4x),
              
              // Calories input
              _buildCaloriesSection(),
              
              SizedBox(height: KSizes.margin4x),
              
              // Favorite checkbox
              _buildFavoriteSection(),
              
              SizedBox(height: KSizes.margin8x),
              
              // Action buttons
              _buildActionButtons(),
            ],
          ),
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

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        child: Stack(
          children: [
            // Primary image
            Image.file(
              File(widget.pendingFood.primaryImagePath),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
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
            
            // Image count indicator if multiple images
            if (widget.pendingFood.imageCount > 1)
              Positioned(
                top: KSizes.margin2x,
                right: KSizes.margin2x,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: KSizes.margin2x,
                    vertical: KSizes.margin1x,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(KSizes.radiusS),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        MdiIcons.imageMultiple,
                        color: Colors.white,
                        size: KSizes.iconXS,
                      ),
                      SizedBox(width: KSizes.margin1x),
                      Text(
                        '${widget.pendingFood.imageCount}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: KSizes.fontSizeS,
                          fontWeight: KSizes.fontWeightBold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiAnalysisDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.info.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(
          color: AppColors.info.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  color: AppColors.info,
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                ),
                child: Icon(
                  MdiIcons.robot,
                  color: Colors.white,
                  size: KSizes.iconS,
                ),
              ),
              const SizedBox(width: KSizes.margin2x),
              Expanded(
                child: Text(
                  'AI Mad Analyse',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeL,
                    fontWeight: KSizes.fontWeightBold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (_isAnalyzing)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: KSizes.margin3x),
          
          // Content based on state
          if (_isAnalyzing) ...[
            _buildAnalyzingContent(),
          ] else if (_analysisResult != null) ...[
            _buildAnalysisResults(),
          ] else if (_analysisError != null) ...[
            _buildAnalysisError(),
          ] else ...[
            _buildNoAnalysisContent(),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalyzingContent() {
    return Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
          ),
        ),
        const SizedBox(width: KSizes.margin2x),
        Text(
          'Analyserer billede med AI...',
          style: TextStyle(
            fontSize: KSizes.fontSizeM,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisResults() {
    final result = _analysisResult!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Confidence indicator
        Row(
          children: [
            Icon(
              result.confidence > 0.7 
                  ? MdiIcons.checkCircle 
                  : result.confidence > 0.4 
                      ? MdiIcons.alertCircle 
                      : MdiIcons.closeCircle,
              color: result.confidence > 0.7 
                  ? AppColors.success 
                  : result.confidence > 0.4 
                      ? AppColors.warning 
                      : AppColors.error,
              size: KSizes.iconS,
            ),
            const SizedBox(width: KSizes.margin1x),
            Text(
              'Sikkerhed: ${(result.confidence * 100).toInt()}%',
              style: TextStyle(
                fontSize: KSizes.fontSizeS,
                fontWeight: KSizes.fontWeightMedium,
                color: result.confidence > 0.7 
                    ? AppColors.success 
                    : result.confidence > 0.4 
                        ? AppColors.warning 
                        : AppColors.error,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: KSizes.margin2x),
        
        // Analysis details
        _buildAnalysisDetail('Mad:', result.foodName, MdiIcons.silverwareForkKnife),
        _buildAnalysisDetail('Beskrivelse:', result.description, MdiIcons.textShort),
        _buildAnalysisDetail('Portion:', result.portionSize, MdiIcons.scaleBalance),
        _buildAnalysisDetail('Kalorier:', '${result.estimatedCalories} kcal', MdiIcons.fire),
        
        const SizedBox(height: KSizes.margin2x),
        
        // Helper text
        Text(
          'AI\'en har foreslået værdierne ovenfor. Du kan redigere dem efter behov.',
          style: TextStyle(
            fontSize: KSizes.fontSizeS,
            color: AppColors.textTertiary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisDetail(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KSizes.margin1x),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: KSizes.iconXS,
            color: AppColors.info,
          ),
          const SizedBox(width: KSizes.margin1x),
          Text(
            '$label ',
            style: TextStyle(
              fontSize: KSizes.fontSizeS,
              fontWeight: KSizes.fontWeightMedium,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: KSizes.fontSizeS,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisError() {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              MdiIcons.alertCircle,
              color: AppColors.error,
              size: KSizes.iconS,
            ),
            const SizedBox(width: KSizes.margin2x),
            Expanded(
              child: Text(
                _analysisError!,
                style: TextStyle(
                  fontSize: KSizes.fontSizeM,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: KSizes.margin2x),
        GestureDetector(
          onTap: _analyzeImage,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: KSizes.margin3x,
              vertical: KSizes.margin2x,
            ),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(KSizes.radiusM),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  MdiIcons.refresh,
                  size: KSizes.iconXS,
                  color: AppColors.info,
                ),
                const SizedBox(width: KSizes.margin1x),
                Text(
                  'Prøv igen',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeS,
                    color: AppColors.info,
                    fontWeight: KSizes.fontWeightMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoAnalysisContent() {
    return Text(
      'Ingen AI analyse tilgængelig for dette billede',
      style: TextStyle(
        fontSize: KSizes.fontSizeM,
        color: AppColors.textSecondary,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildFoodNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hvad er det for mad?',
          style: TextStyle(
            fontSize: KSizes.fontSizeL,
            fontWeight: KSizes.fontWeightBold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: KSizes.margin2x),
        TextField(
          controller: _foodNameController,
          decoration: InputDecoration(
            hintText: 'F.eks. Spaghetti Bolognese',
            prefixIcon: Icon(
              MdiIcons.silverwareForkKnife,
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
          ),
        ),
      ],
    );
  }

  Widget _buildMealTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hvilket måltid?',
          style: TextStyle(
            fontSize: KSizes.fontSizeL,
            fontWeight: KSizes.fontWeightBold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: KSizes.margin3x),
        Wrap(
          spacing: KSizes.margin2x,
          runSpacing: KSizes.margin2x,
          children: MealType.values.map((mealType) {
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
        ),
      ],
    );
  }

  Widget _buildCaloriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hvor mange kalorier?',
          style: TextStyle(
            fontSize: KSizes.fontSizeL,
            fontWeight: KSizes.fontWeightBold,
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
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteSection() {
    return Row(
      children: [
        Checkbox(
          value: _markAsFavorite,
          onChanged: (value) => setState(() => _markAsFavorite = value!),
        ),
        Text(
          'Gem som favorit',
          style: TextStyle(
            fontSize: KSizes.fontSizeS,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Categorize button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _categorizeFood,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: KSizes.margin4x),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KSizes.radiusM),
              ),
            ),
            child: _isProcessing
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Kategoriser og Gem',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeL,
                      fontWeight: KSizes.fontWeightBold,
                    ),
                  ),
          ),
        ),
        
        SizedBox(height: KSizes.margin3x),
        
        // Delete button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isProcessing ? null : _deleteImage,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error),
              padding: EdgeInsets.symmetric(vertical: KSizes.margin4x),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KSizes.radiusM),
              ),
            ),
            child: Text(
              'Slet Billede',
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

  void _categorizeFood() async {
    if (_foodNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Angiv venligst navn på maden'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_caloriesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Angiv venligst antal kalorier'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final calories = int.tryParse(_caloriesController.text.trim());
    if (calories == null || calories < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Angiv venligst et gyldigt antal kalorier (0 eller højere)'),
          backgroundColor: AppColors.error,
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
        loggedAt: DateTime.now().toIso8601String(),
      );

      // Log the food
      await ref.read(foodLoggingProvider.notifier).logFood(foodLog);

      // Save as favorite if requested
      if (_markAsFavorite) {
        final favorite = FavoriteFoodModel.fromUserFoodLog(foodLog);
        final result = await _favoriteFoodService.addToFavorites(favorite);
        
        if (result.isSuccess) {
          print('⭐ CategorizeFoodPage: Food saved as favorite');
        } else {
          print('⭐ CategorizeFoodPage: Failed to save as favorite: ${result.failure}');
          // Show warning but don't fail the whole operation
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Maden blev gemt, men kunne ikke tilføjes til favoritter'),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        }
      }

      // Mark pending food as processed
      await ref.read(pendingFoodProvider.notifier).markAsProcessed(widget.pendingFood.id);

      if (mounted) {
        final message = _markAsFavorite 
          ? 'Mad kategoriseret, gemt og tilføjet til favoritter!' 
          : 'Mad kategoriseret og gemt!';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved kategorisering: $e'),
            backgroundColor: AppColors.error,
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
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Slet billede?'),
        content: Text('Er du sikker på, at du vil slette dette billede?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Annuller'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Slet',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() => _isProcessing = true);

      try {
        await ref.read(pendingFoodProvider.notifier).deletePendingFood(widget.pendingFood.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Billede slettet'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop();
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
          content: Text('Kan ikke analysere billede - intet gyldigt billede fundet'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Use multiple image analysis if more than one image, otherwise single image
      Result<FoodAnalysisResult, GeminiError> result;
      if (widget.pendingFood.imageCount > 1) {
        result = await _geminiService.analyzeMultipleFoodImages(widget.pendingFood.imagePaths);
      } else {
        result = await _geminiService.analyzeFoodImage(widget.pendingFood.primaryImagePath);
      }

      if (result.isSuccess) {
        final analysis = result.success;
        
        setState(() {
          _analysisResult = analysis;
          _foodNameController.text = analysis.foodName;
          _caloriesController.text = analysis.estimatedCalories.toString();
          _isAnalyzing = false;
          _analysisError = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Analyse færdig! ${widget.pendingFood.imageCount > 1 ? "${widget.pendingFood.imageCount} billeder analyseret" : "Billede analyseret"}'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _analysisResult = null;
            _analysisError = result.failure.toString();
            _isAnalyzing = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Analyse fejlede: ${result.failure}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _analysisResult = null;
          _analysisError = e.toString();
          _isAnalyzing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uventet fejl under analyse: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
} 