import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/user_activity_log_model.dart';
import '../../application/activity_notifier.dart';

/// Page for editing an existing activity log entry
class EditActivityPage extends StatefulWidget {
  final UserActivityLogModel activity;
  final ActivityNotifier notifier;

  const EditActivityPage({
    super.key,
    required this.activity,
    required this.notifier,
  });

  @override
  State<EditActivityPage> createState() => _EditActivityPageState();
}

class _EditActivityPageState extends State<EditActivityPage> {
  final TextEditingController _activityNameController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  late ActivityInputType _inputType;
  late ActivityIntensity _intensity;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize form with current activity data
    _activityNameController.text = widget.activity.activityName;
    _caloriesController.text = widget.activity.caloriesBurned.toString();
    _notesController.text = widget.activity.notes;
    _inputType = widget.activity.inputType;
    _intensity = widget.activity.intensity;
    
    // Set the value controller based on input type
    if (_inputType == ActivityInputType.varighed) {
      _valueController.text = widget.activity.durationMinutes.toString();
    } else {
      _valueController.text = widget.activity.distanceKm.toString();
    }
  }

  @override
  void dispose() {
    _activityNameController.dispose();
    _valueController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Rediger Aktivitet'),
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
            onPressed: _isLoading ? null : _saveActivity,
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
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        MdiIcons.informationOutline,
                        color: AppColors.secondary,
                      ),
                      SizedBox(width: KSizes.margin2x),
                      Expanded(
                        child: Text(
                          'Rediger oplysningerne for denne aktivitet',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: KSizes.fontSizeS,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: KSizes.margin6x),

                // Activity name
                _buildFormSection(
                  title: 'Aktivitetsnavn',
                  child: TextField(
                    controller: _activityNameController,
                    decoration: InputDecoration(
                      hintText: 'F.eks. Løbetur',
                      prefixIcon: Icon(MdiIcons.runFast),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                        borderSide: BorderSide(color: AppColors.secondary),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: KSizes.margin4x),

                // Input type selector
                _buildFormSection(
                  title: 'Registreringstype',
                  child: _buildInputTypeSelector(),
                ),

                SizedBox(height: KSizes.margin4x),

                // Value input (duration or distance)
                _buildFormSection(
                  title: _getValueTitle(),
                  child: TextField(
                    controller: _valueController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: InputDecoration(
                      hintText: _getValueHint(),
                      suffixText: _getValueUnit(),
                      prefixIcon: Icon(_getValueIcon()),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                        borderSide: BorderSide(color: AppColors.secondary),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: KSizes.margin4x),

                // Intensity selector
                _buildFormSection(
                  title: 'Intensitet',
                  child: _buildIntensitySelector(),
                ),

                SizedBox(height: KSizes.margin4x),

                // Calories
                _buildFormSection(
                  title: 'Kalorier forbrændt',
                  child: TextField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: '300',
                      suffixText: 'kcal',
                      prefixIcon: Icon(MdiIcons.fire),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                        borderSide: BorderSide(color: AppColors.secondary),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: KSizes.margin4x),

                // Notes (optional)
                _buildFormSection(
                  title: 'Noter (valgfrit)',
                  child: TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Eventuelle kommentarer...',
                      prefixIcon: Icon(MdiIcons.noteText),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                        borderSide: BorderSide(color: AppColors.secondary),
                      ),
                    ),
                  ),
                ),

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

  Widget _buildInputTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _inputType = ActivityInputType.varighed),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: KSizes.margin3x,
                horizontal: KSizes.margin2x,
              ),
              decoration: BoxDecoration(
                color: _inputType == ActivityInputType.varighed
                    ? AppColors.secondary
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(KSizes.radiusM),
                border: Border.all(
                  color: _inputType == ActivityInputType.varighed
                      ? AppColors.secondary
                      : AppColors.border,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    MdiIcons.clock,
                    color: _inputType == ActivityInputType.varighed
                        ? Colors.white
                        : AppColors.textPrimary,
                    size: KSizes.iconS,
                  ),
                  SizedBox(width: KSizes.margin1x),
                  Text(
                    'Varighed',
                    style: TextStyle(
                      color: _inputType == ActivityInputType.varighed
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontWeight: _inputType == ActivityInputType.varighed
                          ? KSizes.fontWeightBold
                          : KSizes.fontWeightMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        SizedBox(width: KSizes.margin2x),
        
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _inputType = ActivityInputType.distance),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: KSizes.margin3x,
                horizontal: KSizes.margin2x,
              ),
              decoration: BoxDecoration(
                color: _inputType == ActivityInputType.distance
                    ? AppColors.secondary
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(KSizes.radiusM),
                border: Border.all(
                  color: _inputType == ActivityInputType.distance
                      ? AppColors.secondary
                      : AppColors.border,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    MdiIcons.mapMarker,
                    color: _inputType == ActivityInputType.distance
                        ? Colors.white
                        : AppColors.textPrimary,
                    size: KSizes.iconS,
                  ),
                  SizedBox(width: KSizes.margin1x),
                  Text(
                    'Distance',
                    style: TextStyle(
                      color: _inputType == ActivityInputType.distance
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontWeight: _inputType == ActivityInputType.distance
                          ? KSizes.fontWeightBold
                          : KSizes.fontWeightMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntensitySelector() {
    return Wrap(
      spacing: KSizes.margin2x,
      runSpacing: KSizes.margin2x,
      children: ActivityIntensity.values.map((intensity) {
        final isSelected = _intensity == intensity;
        return GestureDetector(
          onTap: () => setState(() => _intensity = intensity),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: KSizes.margin3x,
              vertical: KSizes.margin2x,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondary : AppColors.surface,
              borderRadius: BorderRadius.circular(KSizes.radiusM),
              border: Border.all(
                color: isSelected ? AppColors.secondary : AppColors.border,
                width: 1,
              ),
            ),
            child: Text(
              intensity.intensityDisplayName,
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Save button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveActivity,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
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

  String _getValueTitle() {
    return _inputType == ActivityInputType.varighed ? 'Varighed' : 'Distance';
  }

  String _getValueHint() {
    return _inputType == ActivityInputType.varighed ? '30' : '5.0';
  }

  String _getValueUnit() {
    return _inputType == ActivityInputType.varighed ? 'min' : 'km';
  }

  IconData _getValueIcon() {
    return _inputType == ActivityInputType.varighed ? MdiIcons.clock : MdiIcons.mapMarker;
  }

  bool _canSaveActivity() {
    return _activityNameController.text.trim().isNotEmpty &&
           _valueController.text.trim().isNotEmpty &&
           _caloriesController.text.trim().isNotEmpty &&
           double.tryParse(_valueController.text.trim()) != null &&
           double.parse(_valueController.text.trim()) > 0 &&
           int.tryParse(_caloriesController.text.trim()) != null &&
           int.parse(_caloriesController.text.trim()) > 0;
  }

  Future<void> _saveActivity() async {
    if (!_canSaveActivity()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Udfyld venligst alle påkrævede felter korrekt'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final value = double.parse(_valueController.text.trim());
      final calories = int.parse(_caloriesController.text.trim());
      
      // Create updated activity
      final updatedActivity = widget.activity.copyWith(
        activityName: _activityNameController.text.trim(),
        inputType: _inputType,
        durationMinutes: _inputType == ActivityInputType.varighed ? value : 0,
        distanceKm: _inputType == ActivityInputType.distance ? value : 0,
        intensity: _intensity,
        caloriesBurned: calories,
        notes: _notesController.text.trim(),
        isCaloriesAdjusted: true, // Mark as adjusted since user edited
        updatedAt: DateTime.now().toIso8601String(),
      );

      // Update activity using the notifier
      final success = await widget.notifier.updateActivity(updatedActivity);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${updatedActivity.activityName} er opdateret!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kunne ikke opdatere aktivitet'),
              backgroundColor: AppColors.error,
            ),
          );
        }
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

// Extension for ActivityIntensity display names (if not already defined)
extension ActivityIntensityDisplayName on ActivityIntensity {
  String get intensityDisplayName {
    switch (this) {
      case ActivityIntensity.let:
        return 'Let';
      case ActivityIntensity.moderat:
        return 'Moderat';
      case ActivityIntensity.haardt:
        return 'Hård';
    }
  }
} 