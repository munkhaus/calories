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
    return Card(
      elevation: KSizes.cardElevation,
      child: Padding(
        padding: EdgeInsets.all(KSizes.margin4x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: KSizes.iconL,
                  height: KSizes.iconL,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(KSizes.radiusS),
                  ),
                  child: Icon(
                    MdiIcons.fire,
                    color: AppColors.secondary,
                    size: KSizes.iconM,
                  ),
                ),
                
                SizedBox(width: KSizes.margin3x),
                
                Expanded(
                  child: Text(
                    'Angiv manuelt kalorieforbrug',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: KSizes.fontWeightMedium,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: KSizes.margin4x),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      hintText: 'Kalorier',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: KSizes.fontSizeM,
                      ),
                      suffixText: 'kcal',
                      suffixStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: KSizes.fontSizeM,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                        borderSide: BorderSide(
                          color: AppColors.border,
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
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: KSizes.margin4x,
                        vertical: KSizes.margin3x,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: KSizes.margin3x),
                
                SizedBox(
                  height: KSizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _isLogging ? null : _logCalories,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: KSizes.margin4x,
                      ),
                    ),
                    child: _isLogging
                        ? SizedBox(
                            width: KSizes.iconS,
                            height: KSizes.iconS,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                            ),
                          )
                        : Text(
                            'Log kalorier',
                            style: TextStyle(
                              fontWeight: KSizes.fontWeightMedium,
                              fontSize: KSizes.fontSizeM,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: KSizes.margin2x),
            
            Text(
              'Indtast det totale antal kalorier du har forbrændt',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
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

      final success = await widget.notifier.logActivity(activity);
      
      if (success) {
        _caloriesController.clear();
        widget.onCaloriesLogged();
      } else {
        _showErrorSnackBar('Kunne ikke logge kalorier');
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