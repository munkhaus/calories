import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/activity_notifier.dart';
import '../../domain/user_activity_log_model.dart';

/// Page for manually creating and logging a custom activity
class ManualActivityPage extends StatefulWidget {
  final ActivityNotifier notifier;

  const ManualActivityPage({
    super.key,
    required this.notifier,
  });

  @override
  State<ManualActivityPage> createState() => _ManualActivityPageState();
}

class _ManualActivityPageState extends State<ManualActivityPage> {
  final TextEditingController _activityNameController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  ActivityInputType _inputType = ActivityInputType.varighed;
  ActivityIntensity _intensity = ActivityIntensity.moderat;
  bool _isLogging = false;

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
        title: Text(
          'Manuel aktivitet',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: KSizes.fontWeightBold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(KSizes.margin4x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity name
            _buildActivityNameSection(),
            
            const SizedBox(height: KSizes.margin6x),
            
            // Input type selection
            _buildInputTypeSection(),
            
            const SizedBox(height: KSizes.margin6x),
            
            // Value input
            _buildValueInputSection(),
            
            const SizedBox(height: KSizes.margin6x),
            
            // Intensity selection
            _buildIntensitySection(),
            
            const SizedBox(height: KSizes.margin6x),
            
            // Calorie input
            _buildCalorieSection(),
            
            const SizedBox(height: KSizes.margin6x),
            
            // Notes
            _buildNotesSection(),
            
            const SizedBox(height: KSizes.margin8x),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildActivityNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aktivitetsnavn',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: KSizes.fontWeightBold,
          ),
        ),
        
        const SizedBox(height: KSizes.margin3x),
        
        TextField(
          controller: _activityNameController,
          decoration: InputDecoration(
            hintText: 'Skriv navn på aktivitet',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KSizes.radiusM),
            ),
            prefixIcon: Icon(
              MdiIcons.runFast,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Input type',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: KSizes.fontWeightBold,
          ),
        ),
        
        const SizedBox(height: KSizes.margin3x),
        
        Row(
          children: [
            Expanded(
              child: _buildInputTypeOption(
                ActivityInputType.varighed,
                'Varighed',
                'Minutter',
                MdiIcons.clock,
              ),
            ),
            
            SizedBox(width: KSizes.margin3x),
            
            Expanded(
              child: _buildInputTypeOption(
                ActivityInputType.distance,
                'Distance',
                'Kilometer',
                MdiIcons.mapMarker,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputTypeOption(
    ActivityInputType type,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _inputType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _inputType = type;
          _valueController.clear();
        });
      },
      child: Container(
        padding: EdgeInsets.all(KSizes.margin4x),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: KSizes.iconL,
            ),
            
            SizedBox(height: KSizes.margin2x),
            
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: KSizes.fontWeightMedium,
              ),
            ),
            
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? AppColors.primary.withOpacity(0.8) : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueInputSection() {
    final isDistance = _inputType == ActivityInputType.distance;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isDistance ? 'Distance' : 'Varighed',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: KSizes.fontWeightBold,
          ),
        ),
        
        const SizedBox(height: KSizes.margin3x),
        
        TextField(
          controller: _valueController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            hintText: isDistance ? 'Distance i kilometer' : 'Varighed i minutter',
            suffixText: isDistance ? 'km' : 'min',
            suffixStyle: TextStyle(
              color: AppColors.textSecondary,
              fontSize: KSizes.fontSizeM,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KSizes.radiusM),
            ),
            prefixIcon: Icon(
              isDistance ? MdiIcons.mapMarker : MdiIcons.clock,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntensitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intensitet',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: KSizes.fontWeightBold,
          ),
        ),
        
        const SizedBox(height: KSizes.margin3x),
        
        Column(
          children: ActivityIntensity.values.map((intensity) => 
            _buildIntensityOption(intensity)
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildIntensityOption(ActivityIntensity intensity) {
    final isSelected = _intensity == intensity;
    final color = _getIntensityColor(intensity);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _intensity = intensity;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: KSizes.margin2x),
        padding: EdgeInsets.all(KSizes.margin4x),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          border: Border.all(
            color: isSelected ? color : AppColors.border.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: KSizes.iconM,
              height: KSizes.iconM,
              decoration: BoxDecoration(
                color: isSelected ? color : AppColors.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
            
            SizedBox(width: KSizes.margin3x),
            
            Expanded(
              child: Text(
                _getIntensityDisplayName(intensity),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isSelected ? color : AppColors.textPrimary,
                  fontWeight: KSizes.fontWeightMedium,
                ),
              ),
            ),
            
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: KSizes.iconM,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kalorieforbrug',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: KSizes.fontWeightBold,
          ),
        ),
        
        const SizedBox(height: KSizes.margin3x),
        
        TextField(
          controller: _caloriesController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            hintText: 'Kalorier forbrændt',
            suffixText: 'kcal',
            suffixStyle: TextStyle(
              color: AppColors.textSecondary,
              fontSize: KSizes.fontSizeM,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KSizes.radiusM),
            ),
            prefixIcon: Icon(
              MdiIcons.fire,
              color: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Noter (valgfrit)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: KSizes.fontWeightBold,
          ),
        ),
        
        const SizedBox(height: KSizes.margin3x),
        
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Tilføj noter om aktiviteten...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KSizes.radiusM),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: KSizes.margin6x),
              child: Icon(
                MdiIcons.noteText,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: KSizes.blurRadiusM,
            offset: KSizes.shadowOffsetReverse,
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: KSizes.buttonHeight,
          child: ElevatedButton(
            onPressed: _canLogActivity() ? _logActivity : null,
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
                    'Log aktivitet',
                    style: TextStyle(
                      fontWeight: KSizes.fontWeightBold,
                      fontSize: KSizes.fontSizeL,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  bool _canLogActivity() {
    return !_isLogging &&
           _activityNameController.text.trim().isNotEmpty &&
           _valueController.text.isNotEmpty &&
           _caloriesController.text.isNotEmpty &&
           double.tryParse(_valueController.text) != null &&
           double.parse(_valueController.text) > 0 &&
           int.tryParse(_caloriesController.text) != null &&
           int.parse(_caloriesController.text) > 0;
  }

  Future<void> _logActivity() async {
    if (!_canLogActivity()) return;

    setState(() => _isLogging = true);

    try {
      final activityName = _activityNameController.text.trim();
      final value = double.parse(_valueController.text);
      final calories = int.parse(_caloriesController.text);
      final notes = _notesController.text.trim();

      final activity = UserActivityLogModel(
        userId: 1, // TODO: Get real user ID
        activityName: activityName,
        inputType: _inputType,
        durationMinutes: _inputType == ActivityInputType.varighed ? value : 0,
        distanceKm: _inputType == ActivityInputType.distance ? value : 0,
        intensity: _intensity,
        caloriesBurned: calories,
        isManualEntry: true,
        isCaloriesAdjusted: false,
        notes: notes,
      );

      final success = await widget.notifier.logActivity(activity);

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$activityName er logget'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kunne ikke logge aktivitet'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved logning af aktivitet'),
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

  Color _getIntensityColor(ActivityIntensity intensity) {
    switch (intensity) {
      case ActivityIntensity.let:
        return AppColors.success;
      case ActivityIntensity.moderat:
        return AppColors.primary;
      case ActivityIntensity.haardt:
        return AppColors.error;
    }
  }

  String _getIntensityDisplayName(ActivityIntensity intensity) {
    switch (intensity) {
      case ActivityIntensity.let:
        return 'Let';
      case ActivityIntensity.moderat:
        return 'Moderat';
      case ActivityIntensity.haardt:
        return 'Hård';
    }
  }
} 