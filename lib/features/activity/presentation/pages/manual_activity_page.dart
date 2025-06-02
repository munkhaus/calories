import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/activity_notifier.dart';
import '../../domain/user_activity_log_model.dart';
import '../../infrastructure/activity_calorie_data.dart';
import '../../infrastructure/activity_calorie_calculator.dart';
import '../../../onboarding/application/onboarding_notifier.dart';

/// Page for manually creating and logging a custom activity
class ManualActivityPage extends ConsumerStatefulWidget {
  final ActivityNotifier notifier;

  const ManualActivityPage({
    super.key,
    required this.notifier,
  });

  @override
  ConsumerState<ManualActivityPage> createState() => _ManualActivityPageState();
}

class _ManualActivityPageState extends ConsumerState<ManualActivityPage> {
  final TextEditingController _activityNameController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  
  ActivityInputType _inputType = ActivityInputType.varighed;
  ActivityIntensity _intensity = ActivityIntensity.moderat; // Legacy field
  ActivityCategory _activityCategory = ActivityCategory.anden;
  ActivityIntensityLevel _intensityLevel = ActivityIntensityLevel.moderat;
  bool _isLogging = false;
  bool _useAutomaticCalories = true; // New field for automatic vs manual calories
  ActivityCalorieEstimate? _currentEstimate;

  @override
  void initState() {
    super.initState();
    
    // Set defaults
    _valueController.text = '30';
    _caloriesController.text = '200';
    
    // Load user weight and calculate initial estimate
    _loadUserWeightAndCalculate();
    
    // Add listeners for automatic calculation
    _valueController.addListener(_onValueChanged);
    _weightController.addListener(_onValueChanged);
  }

  @override
  void dispose() {
    _activityNameController.dispose();
    _valueController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadUserWeightAndCalculate() async {
    // Try to get weight from user profile first
    final onboardingState = ref.read(onboardingProvider);
    final profileWeight = onboardingState.userProfile.currentWeightKg;
    
    double weight;
    if (profileWeight > 0) {
      // Use profile weight
      weight = profileWeight;
    } else {
      // Fallback to stored weight from calculator service
      weight = await ActivityCalorieCalculator.getUserWeight();
    }
    
    _weightController.text = weight.toStringAsFixed(1);
    _calculateCalories();
  }

  void _onValueChanged() {
    if (_useAutomaticCalories) {
      _calculateCalories();
    }
  }

  Future<void> _calculateCalories() async {
    if (!_useAutomaticCalories) return;

    final valueText = _valueController.text.trim();
    final weightText = _weightController.text.trim();

    double? value = double.tryParse(valueText);
    double? weight = double.tryParse(weightText);

    if (weight == null || weight <= 0 || value == null || value <= 0) return;

    try {
      final estimate = await ActivityCalorieCalculator.estimateCalories(
        category: _activityCategory,
        intensity: _intensityLevel,
        durationMinutes: _inputType == ActivityInputType.varighed ? value : null,
        distanceKm: _inputType == ActivityInputType.distance ? value : null,
        userWeightKg: weight,
      );

      if (mounted) {
        setState(() {
          _currentEstimate = estimate;
          _caloriesController.text = estimate.estimatedCalories.toString();
        });
      }
    } catch (e) {
      // Handle calculation error
      print('Error calculating calories: $e');
    }
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
            
            // Activity category dropdown
            _buildCategorySection(),
            
            const SizedBox(height: KSizes.margin6x),
            
            // Input type selection
            _buildInputTypeSection(),
            
            const SizedBox(height: KSizes.margin6x),
            
            // Value input
            _buildValueInputSection(),
            
            const SizedBox(height: KSizes.margin6x),
            
            // Intensity selection (4 levels)
            _buildIntensitySection(),
            
            const SizedBox(height: KSizes.margin6x),
            
            // User weight for calculation
            _buildWeightSection(),
            
            const SizedBox(height: KSizes.margin6x),
            
            // Calorie calculation toggle
            _buildCalorieCalculationToggle(),
            
            const SizedBox(height: KSizes.margin6x),
            
            // Calorie input
            _buildCalorieSection(),
            
            // Show calculation details if using automatic
            if (_useAutomaticCalories && _currentEstimate != null) ...[
              const SizedBox(height: KSizes.margin4x),
              _buildCalculationDetails(),
            ],
            
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

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: KSizes.fontWeightBold,
          ),
        ),
        
        const SizedBox(height: KSizes.margin3x),
        
        DropdownButtonFormField<ActivityCategory>(
          value: _activityCategory,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KSizes.radiusM),
            ),
            prefixIcon: Icon(
              MdiIcons.formatListBulleted,
              color: AppColors.primary,
            ),
          ),
          items: ActivityCategory.values.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text('${category.emoji} ${category.displayName}'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _activityCategory = value!;
            });
            _onValueChanged(); // Trigger recalculation
          },
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
        _onValueChanged(); // Trigger recalculation
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
          children: ActivityIntensityLevel.values.map((intensity) => 
            _buildIntensityOption(intensity)
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildIntensityOption(ActivityIntensityLevel intensity) {
    final isSelected = _intensityLevel == intensity;
    final color = _getIntensityLevelColor(intensity);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _intensityLevel = intensity;
          // Map to legacy intensity for backward compatibility
          _intensity = _mapToLegacyIntensity(intensity);
        });
        _onValueChanged(); // Trigger recalculation
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
                intensity.displayName,
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

  Widget _buildWeightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Din vægt (kg)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: KSizes.fontWeightBold,
          ),
        ),
        
        const SizedBox(height: KSizes.margin3x),
        
        TextField(
          controller: _weightController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            hintText: 'f.eks. 70',
            suffixText: 'kg',
            suffixStyle: TextStyle(
              color: AppColors.textSecondary,
              fontSize: KSizes.fontSizeM,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KSizes.radiusM),
            ),
            prefixIcon: Icon(
              MdiIcons.scaleBalance,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalorieCalculationToggle() {
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _useAutomaticCalories ? MdiIcons.calculator : MdiIcons.pencil,
            color: _useAutomaticCalories ? AppColors.success : AppColors.warning,
          ),
          SizedBox(width: KSizes.margin3x),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _useAutomaticCalories ? 'Automatisk beregning' : 'Manuel indtastning',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    fontWeight: KSizes.fontWeightBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _useAutomaticCalories 
                      ? 'Kalorier beregnes ud fra kategori og intensitet'
                      : 'Indtast kalorier manuelt',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeS,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _useAutomaticCalories,
            onChanged: (value) {
              setState(() {
                _useAutomaticCalories = value;
                if (value) {
                  _calculateCalories(); // Recalculate when switching to automatic
                }
              });
            },
            activeColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationDetails() {
    if (_currentEstimate == null) return SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(MdiIcons.calculator, color: AppColors.info, size: KSizes.iconS),
              SizedBox(width: KSizes.margin2x),
              Text(
                'Kalorie beregning',
                style: TextStyle(
                  fontSize: KSizes.fontSizeM,
                  fontWeight: KSizes.fontWeightBold,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          SizedBox(height: KSizes.margin2x),
          Text(
            _currentEstimate!.formattedEstimate,
            style: TextStyle(
              fontSize: KSizes.fontSizeS,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: KSizes.margin1x),
          Text(
            _currentEstimate!.description,
            style: TextStyle(
              fontSize: KSizes.fontSizeXS,
              color: AppColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
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
          enabled: !_useAutomaticCalories,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            hintText: _useAutomaticCalories ? 'Automatisk beregnet' : 'Kalorier forbrændt',
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
           _weightController.text.isNotEmpty &&
           double.tryParse(_valueController.text) != null &&
           double.parse(_valueController.text) > 0 &&
           int.tryParse(_caloriesController.text) != null &&
           int.parse(_caloriesController.text) > 0 &&
           double.tryParse(_weightController.text) != null &&
           double.parse(_weightController.text) > 0;
  }

  Future<void> _logActivity() async {
    if (!_canLogActivity()) return;

    setState(() => _isLogging = true);

    try {
      final activityName = _activityNameController.text.trim();
      final value = double.parse(_valueController.text);
      final calories = int.parse(_caloriesController.text);
      final notes = _notesController.text.trim();
      final weight = double.tryParse(_weightController.text.trim()) ?? 70.0;

      // Save user weight for future calculations
      await ActivityCalorieCalculator.setUserWeight(weight);

      final activity = UserActivityLogModel(
        userId: 1, // TODO: Get real user ID
        activityName: activityName,
        inputType: _inputType,
        durationMinutes: _inputType == ActivityInputType.varighed ? value : 0,
        distanceKm: _inputType == ActivityInputType.distance ? value : 0,
        intensity: _intensity, // Legacy field
        activityCategory: _activityCategory, // New field
        intensityLevel: _intensityLevel, // New field
        caloriesBurned: calories,
        isManualEntry: true,
        isCaloriesAdjusted: !_useAutomaticCalories, // True if manual calories
        notes: notes,
      );

      await widget.notifier.logActivity(activity);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$activityName er logget'),
            backgroundColor: AppColors.success,
          ),
        );
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

  Color _getIntensityLevelColor(ActivityIntensityLevel intensity) {
    switch (intensity) {
      case ActivityIntensityLevel.let:
        return AppColors.success;
      case ActivityIntensityLevel.moderat:
        return AppColors.primary;
      case ActivityIntensityLevel.haard:
        return AppColors.warning;
      case ActivityIntensityLevel.ekstremt:
        return AppColors.error;
    }
  }

  // Map new intensity levels to legacy for backward compatibility
  ActivityIntensity _mapToLegacyIntensity(ActivityIntensityLevel level) {
    switch (level) {
      case ActivityIntensityLevel.let:
        return ActivityIntensity.let;
      case ActivityIntensityLevel.moderat:
        return ActivityIntensity.moderat;
      case ActivityIntensityLevel.haard:
      case ActivityIntensityLevel.ekstremt:
        return ActivityIntensity.haardt;
    }
  }
} 