import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/activity_notifier.dart';
import '../../domain/activity_item_model.dart';
import '../../domain/user_activity_log_model.dart';

/// Page for entering activity details before logging
class ActivityDetailsPage extends StatefulWidget {
  final ActivityItemModel activity;
  final ActivityNotifier notifier;

  const ActivityDetailsPage({
    super.key,
    required this.activity,
    required this.notifier,
  });

  @override
  State<ActivityDetailsPage> createState() => _ActivityDetailsPageState();
}

class _ActivityDetailsPageState extends State<ActivityDetailsPage> {
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  
  ActivityInputType _inputType = ActivityInputType.varighed;
  ActivityIntensity _intensity = ActivityIntensity.moderat;
  bool _isCalculating = false;
  bool _isLogging = false;
  int? _calculatedCalories;
  bool _hasCalculated = false;

  @override
  void initState() {
    super.initState();
    // Set default input type based on what the activity supports
    if (widget.activity.supportsDistance && !widget.activity.supportsDuration) {
      _inputType = ActivityInputType.distance;
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.activity.name,
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
            // Activity info card
            _buildActivityInfoCard(),
            
            const SizedBox(height: KSizes.margin6x),
            
            // Input type selection (if activity supports both)
            if (widget.activity.supportsDuration && widget.activity.supportsDistance)
              _buildInputTypeSection(),
            
            if (widget.activity.supportsDuration && widget.activity.supportsDistance)
              const SizedBox(height: KSizes.margin6x),
            
            // Value input (duration or distance)
            _buildValueInputSection(),
            
            const SizedBox(height: KSizes.margin6x),
            
            // Intensity selection
            _buildIntensitySection(),
            
            const SizedBox(height: KSizes.margin6x),
            
            // Calorie calculation/adjustment
            _buildCalorieSection(),
            
            const SizedBox(height: KSizes.margin8x),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildActivityInfoCard() {
    return Card(
      elevation: KSizes.cardElevation,
      child: Padding(
        padding: EdgeInsets.all(KSizes.margin4x),
        child: Row(
          children: [
            Container(
              width: KSizes.iconXXL,
              height: KSizes.iconXXL,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(KSizes.radiusL),
              ),
              child: Icon(
                _getActivityIcon(widget.activity.iconName),
                color: AppColors.primary,
                size: KSizes.iconXL,
              ),
            ),
            
            SizedBox(width: KSizes.margin4x),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.activity.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: KSizes.fontWeightBold,
                    ),
                  ),
                  
                  if (widget.activity.description.isNotEmpty)
                    Text(
                      widget.activity.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  
                  SizedBox(height: KSizes.margin2x),
                  
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: KSizes.margin3x,
                      vertical: KSizes.margin1x,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(KSizes.radiusRound),
                    ),
                    child: Text(
                      widget.activity.category,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: KSizes.fontSizeS,
                        fontWeight: KSizes.fontWeightMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
          _calculatedCalories = null;
          _caloriesController.clear();
          _hasCalculated = false;
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
          onChanged: (value) {
            setState(() {
              _calculatedCalories = null;
              _caloriesController.clear();
              _hasCalculated = false;
            });
            
            if (value.isNotEmpty) {
              _calculateCalories();
            }
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
          _calculatedCalories = null;
          _caloriesController.clear();
          _hasCalculated = false;
        });
        
        if (_valueController.text.isNotEmpty) {
          _calculateCalories();
        }
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
            ),
            
            SizedBox(width: KSizes.margin3x),
            
            ElevatedButton(
              onPressed: _isCalculating || _valueController.text.isEmpty 
                  ? null 
                  : _calculateCalories,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
              ),
              child: _isCalculating
                  ? SizedBox(
                      width: KSizes.iconS,
                      height: KSizes.iconS,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                      ),
                    )
                  : Text('Beregn'),
            ),
          ],
        ),
        
        if (_hasCalculated && _calculatedCalories != null)
          Padding(
            padding: EdgeInsets.only(top: KSizes.margin2x),
            child: Text(
              'Automatisk beregnet: $_calculatedCalories kcal',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
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
           _valueController.text.isNotEmpty &&
           _caloriesController.text.isNotEmpty &&
           double.tryParse(_valueController.text) != null &&
           double.parse(_valueController.text) > 0 &&
           int.tryParse(_caloriesController.text) != null &&
           int.parse(_caloriesController.text) > 0;
  }

  Future<void> _calculateCalories() async {
    final valueText = _valueController.text.trim();
    if (valueText.isEmpty) return;

    final value = double.tryParse(valueText);
    if (value == null || value <= 0) return;

    setState(() => _isCalculating = true);

    try {
      final calories = await widget.notifier.calculateCalories(
        activityId: widget.activity.activityId,
        value: value,
        isDuration: _inputType == ActivityInputType.varighed,
        userWeightKg: 70.0, // TODO: Get real user weight
      );

      if (calories != null && mounted) {
        setState(() {
          _calculatedCalories = calories;
          _caloriesController.text = calories.toString();
          _hasCalculated = true;
        });
      }
    } catch (e) {
      // Handle error silently or show a small indicator
    } finally {
      if (mounted) {
        setState(() => _isCalculating = false);
      }
    }
  }

  Future<void> _logActivity() async {
    if (!_canLogActivity()) return;

    setState(() => _isLogging = true);

    try {
      final value = double.parse(_valueController.text);
      final calories = int.parse(_caloriesController.text);
      final isCaloriesAdjusted = _calculatedCalories != null && _calculatedCalories != calories;

      final activity = UserActivityLogModel(
        userId: 1, // TODO: Get real user ID
        activityName: widget.activity.name,
        inputType: _inputType,
        durationMinutes: _inputType == ActivityInputType.varighed ? value : 0,
        distanceKm: _inputType == ActivityInputType.distance ? value : 0,
        intensity: _intensity,
        caloriesBurned: calories,
        isManualEntry: false,
        isCaloriesAdjusted: isCaloriesAdjusted,
        notes: '',
      );

      final success = await widget.notifier.logActivity(activity);

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.activity.name} er logget'),
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

  IconData _getActivityIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'walk':
        return MdiIcons.walk;
      case 'run':
        return MdiIcons.run;
      case 'bike':
        return MdiIcons.bike;
      case 'swim':
        return MdiIcons.swim;
      case 'dumbbell':
        return MdiIcons.dumbbell;
      case 'yoga':
        return MdiIcons.yoga;
      case 'tennis':
        return MdiIcons.tennis;
      case 'soccer':
        return MdiIcons.soccer;
      default:
        return MdiIcons.runFast;
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