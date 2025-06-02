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
import '../../../dashboard/application/date_aware_providers.dart';

/// Page for detailed activity registration with smart calorie calculation
class DetailedActivityRegistrationPage extends ConsumerStatefulWidget {
  const DetailedActivityRegistrationPage({super.key});

  @override
  ConsumerState<DetailedActivityRegistrationPage> createState() => _DetailedActivityRegistrationPageState();
}

class _DetailedActivityRegistrationPageState extends ConsumerState<DetailedActivityRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _weightController = TextEditingController();
  
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
    _valueController.dispose();
    _caloriesController.dispose();
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
      // Use a small delay to ensure UI updates are processed
      Future.microtask(() => _calculateCalories());
    }
  }

  Future<void> _calculateCalories() async {
    if (!_useAutomaticCalories) return;

    final valueText = _valueController.text.trim();
    final weightText = _weightController.text.trim();

    double? value = double.tryParse(valueText);
    double? weight = double.tryParse(weightText);

    // If either value or weight is missing/invalid, use sensible defaults for preview
    if (value == null || value <= 0) {
      value = 30.0; // Default 30 minutes/km for preview
    }
    if (weight == null || weight <= 0) {
      weight = 70.0; // Default 70kg for preview
    }

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
      // Handle calculation error and provide fallback
      print('Error calculating calories: $e');
      if (mounted) {
        setState(() {
          _currentEstimate = null;
          _caloriesController.text = '0';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detaljeret Aktivitet'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          TextButton(
            onPressed: _isLogging ? null : _saveActivity,
            child: _isLogging
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : Text(
                    'Gem',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: KSizes.fontWeightBold,
                    ),
                  ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(KSizes.margin4x),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Registrer aktivitet',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeXL,
                    fontWeight: KSizes.fontWeightBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                SizedBox(height: KSizes.margin2x),
                
                Text(
                  'Indtast detaljer om din aktivitet',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    color: AppColors.textSecondary,
                  ),
                ),
                
                SizedBox(height: KSizes.margin6x),
                
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
                
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLogging ? null : _saveActivity,
                    icon: _isLogging 
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(MdiIcons.check),
                    label: Text(_isLogging ? 'Registrerer...' : 'Registrer Aktivitet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.all(KSizes.margin4x),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusL),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
            // Immediate recalculation
            _onValueChanged();
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
        // Immediate recalculation
        _onValueChanged();
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
        
        TextFormField(
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return isDistance ? 'Indtast distance' : 'Indtast varighed';
            }
            if (double.tryParse(value) == null) {
              return 'Indtast et gyldigt tal';
            }
            return null;
          },
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
        // Immediate recalculation
        _onValueChanged();
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
        
        TextFormField(
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
              });
              if (value) {
                // Immediate recalculation when switching to automatic
                _onValueChanged();
              }
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
        
        TextFormField(
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

  // Generate activity name from category, intensity, and value
  String _generateActivityName() {
    final value = _valueController.text.trim();
    final valueStr = value.isNotEmpty ? value : '0';
    final unit = _inputType == ActivityInputType.varighed ? 'min' : 'km';
    final intensityStr = _intensityLevel.displayName.toLowerCase();
    
    return '${_activityCategory.displayName} - $intensityStr - $valueStr $unit';
  }

  Future<void> _saveActivity() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLogging = true;
      });

      try {
        final value = double.parse(_valueController.text);
        final calories = int.parse(_caloriesController.text);
        final weight = double.tryParse(_weightController.text.trim()) ?? 70.0;

        // Save user weight for future calculations
        await ActivityCalorieCalculator.setUserWeight(weight);

        // Get activity notifier
        final activityNotifier = ref.read(activityNotifierProvider);

        // Create activity log with complete data
        final activityLog = UserActivityLogModel(
          logEntryId: DateTime.now().millisecondsSinceEpoch,
          userId: 1, // TODO: Use real user ID
          activityName: _generateActivityName(),
          loggedAt: DateTime.now().toIso8601String(),
          inputType: _inputType,
          durationMinutes: _inputType == ActivityInputType.varighed ? value : 0,
          distanceKm: _inputType == ActivityInputType.distance ? value : 0,
          intensity: _intensity, // Legacy field
          activityCategory: _activityCategory, // New field
          intensityLevel: _intensityLevel, // New field
          caloriesBurned: calories,
          isManualEntry: true,
          isCaloriesAdjusted: !_useAutomaticCalories, // True if manual calories
          notes: '',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );

        // Log the activity
        await activityNotifier.logActivity(activityLog);
        
        if (mounted) {
          // Show success message and go back
          Navigator.of(context).pop(true);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_generateActivityName()} registreret! (${calories} kcal)'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fejl ved registrering: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLogging = false;
          });
        }
      }
    }
  }
} 