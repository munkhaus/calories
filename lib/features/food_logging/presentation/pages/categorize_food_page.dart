import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/pending_food_model.dart';
import '../../domain/user_food_log_model.dart';
import '../../application/pending_food_cubit.dart';
import '../../application/food_logging_notifier.dart';

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
              
              SizedBox(height: KSizes.margin6x),
              
              // Food name input
              _buildFoodNameSection(),
              
              SizedBox(height: KSizes.margin4x),
              
              // Meal type selector
              _buildMealTypeSection(),
              
              SizedBox(height: KSizes.margin4x),
              
              // Calories input
              _buildCaloriesSection(),
              
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
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            MdiIcons.imageOutline,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: KSizes.margin2x),
          Text(
            'Billede fra ${widget.pendingFood.displayTime}',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: KSizes.fontSizeM,
            ),
          ),
        ],
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
    if (calories == null || calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Angiv venligst et gyldigt antal kalorier'),
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

      // Mark pending food as processed
      await ref.read(pendingFoodProvider.notifier).markAsProcessed(widget.pendingFood.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mad kategoriseret og gemt!'),
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
} 