import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/activity_notifier.dart';
import '../../domain/user_activity_log_model.dart';

/// Widget for manual calorie entry
class ManualCalorieEntryWidget extends StatefulWidget {
  final ActivityNotifier notifier;
  final VoidCallback onCaloriesLogged;

  const ManualCalorieEntryWidget({
    super.key,
    required this.notifier,
    required this.onCaloriesLogged,
  });

  @override
  State<ManualCalorieEntryWidget> createState() => _ManualCalorieEntryWidgetState();
}

class _ManualCalorieEntryWidgetState extends State<ManualCalorieEntryWidget> {
  final TextEditingController _caloriesController = TextEditingController();
  bool _isLogging = false;

  @override
  void dispose() {
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(KSizes.margin6x),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.08),
            blurRadius: KSizes.blurRadiusL,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with icon and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary,
                      AppColors.secondary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  MdiIcons.fire,
                  color: Colors.white,
                  size: KSizes.iconL,
                ),
              ),
              
              const SizedBox(width: KSizes.margin4x),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manuel Kalorieindtastning',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Angiv dit totale kalorieforbrug',
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
          
          const SizedBox(height: KSizes.margin6x),
          
          // Input field
          TextField(
            controller: _caloriesController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              labelText: 'Kalorier forbrændt',
              hintText: 'Indtast antal kalorier',
              suffixText: 'kcal',
              suffixStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: KSizes.fontSizeM,
                fontWeight: FontWeight.w500,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KSizes.radiusM),
                borderSide: BorderSide(
                  color: AppColors.border.withOpacity(0.3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KSizes.radiusM),
                borderSide: BorderSide(
                  color: AppColors.border.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KSizes.radiusM),
                borderSide: BorderSide(
                  color: AppColors.secondary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.background.withOpacity(0.5),
              contentPadding: EdgeInsets.symmetric(
                horizontal: KSizes.margin4x,
                vertical: KSizes.margin4x,
              ),
            ),
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          // Log button
          SizedBox(
            width: double.infinity,
            height: KSizes.buttonHeight,
            child: ElevatedButton(
              onPressed: _isLogging ? null : _logCalories,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                elevation: 2,
                shadowColor: AppColors.secondary.withOpacity(0.3),
              ),
              child: _isLogging
                  ? SizedBox(
                      width: KSizes.iconM,
                      height: KSizes.iconM,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Log Kalorier',
                      style: TextStyle(
                        fontWeight: KSizes.fontWeightBold,
                        fontSize: KSizes.fontSizeL,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logCalories() async {
    final caloriesText = _caloriesController.text.trim();
    
    if (caloriesText.isEmpty) {
      _showErrorSnackBar('Angiv venligst antal kalorier');
      return;
    }
    
    final calories = int.tryParse(caloriesText);
    if (calories == null || calories <= 0) {
      _showErrorSnackBar('Angiv venligst et gyldigt antal kalorier');
      return;
    }

    setState(() => _isLogging = true);

    try {
      final activity = UserActivityLogModel(
        userId: 1, // TODO: Get real user ID
        activityName: 'Manuel kalorieangivelse',
        inputType: ActivityInputType.varighed,
        durationMinutes: 0,
        distanceKm: 0,
        intensity: ActivityIntensity.moderat,
        caloriesBurned: calories,
        isManualEntry: true,
        isCaloriesAdjusted: false,
        notes: 'Manuelt angivet kalorieforbrug',
      );

      await widget.notifier.logActivity(activity);

      if (mounted) {
        _caloriesController.clear();
        widget.onCaloriesLogged();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${activity.activityName} er logget'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Fejl ved logning af kalorier');
    } finally {
      if (mounted) {
        setState(() => _isLogging = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
} 