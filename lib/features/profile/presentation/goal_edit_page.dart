import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../onboarding/domain/user_profile_model.dart';

/// Standalone page for editing user goals from profile settings
class GoalEditPage extends ConsumerStatefulWidget {
  const GoalEditPage({super.key});

  @override
  ConsumerState<GoalEditPage> createState() => _GoalEditPageState();
}

class _GoalEditPageState extends ConsumerState<GoalEditPage> {
  late TextEditingController _targetWeightController;
  late TextEditingController _weeklyGoalController;
  late FocusNode _targetWeightFocus;
  late FocusNode _weeklyGoalFocus;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _targetWeightController = TextEditingController();
    _weeklyGoalController = TextEditingController();
    _targetWeightFocus = FocusNode();
    _weeklyGoalFocus = FocusNode();
    
    // Initialize with current values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(onboardingProvider);
      _targetWeightController.text = state.userProfile.targetWeightKg.toStringAsFixed(1);
      _weeklyGoalController.text = state.userProfile.weeklyGoalKg.toStringAsFixed(1);
    });
  }

  @override
  void dispose() {
    _targetWeightController.dispose();
    _weeklyGoalController.dispose();
    _targetWeightFocus.dispose();
    _weeklyGoalFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final userProfile = state.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rediger mål',
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
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(KSizes.margin4x),
                  child: Column(
                    children: [
                      // Target Weight Section
                      _buildTargetWeightSection(userProfile),
                      
                      const SizedBox(height: KSizes.margin6x),
                      
                      // Weekly Goal Section
                      _buildWeeklyGoalSection(userProfile),
                      
                      const SizedBox(height: KSizes.margin8x),
                      
                      // Info card
                      _buildInfoCard(),
                      
                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                ),
              ),
              
              // Bottom save button
              _buildBottomActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetWeightSection(UserProfileModel userProfile) {
    const double minWeight = 40.0;
    const double maxWeight = 200.0;
    final targetWeight = userProfile.targetWeightKg.clamp(minWeight, maxWeight);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin6x),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.success.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.08),
            blurRadius: KSizes.blurRadiusL,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success,
                      AppColors.success.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  MdiIcons.target,
                  color: Colors.white,
                  size: KSizes.iconM,
                ),
              ),
              const SizedBox(width: KSizes.margin3x),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Målvægt',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Hvad er din ønskede vægt?',
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
          
          // Current vs target display
          Container(
            padding: const EdgeInsets.all(KSizes.margin4x),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.success.withOpacity(0.05),
                  AppColors.success.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(KSizes.radiusL),
              border: Border.all(
                color: AppColors.success.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nuværende vægt',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${userProfile.currentWeightKg.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Icon(
                  MdiIcons.arrowRight,
                  color: AppColors.success,
                  size: KSizes.iconM,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Målvægt',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${targetWeight.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          // Target weight input
          Container(
            padding: const EdgeInsets.all(KSizes.margin3x),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(KSizes.radiusM),
              border: Border.all(
                color: targetWeight > 0 ? AppColors.success.withOpacity(0.3) : AppColors.border,
                width: targetWeight > 0 ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: _targetWeightController,
              focusNode: _targetWeightFocus,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              onChanged: (value) {
                final weight = double.tryParse(value);
                if (weight != null && weight >= minWeight && weight <= maxWeight) {
                  Future.delayed(const Duration(milliseconds: 200), () {
                    if (mounted && !_targetWeightFocus.hasFocus) {
                      final notifier = ref.read(onboardingProvider.notifier);
                      notifier.updateTargetWeight(weight);
                    }
                  });
                }
              },
              decoration: InputDecoration(
                hintText: 'Indtast målvægt',
                suffixText: 'kg',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: KSizes.fontSizeL,
                ),
                suffixStyle: TextStyle(
                  color: AppColors.success,
                  fontWeight: KSizes.fontWeightMedium,
                  fontSize: KSizes.fontSizeL,
                ),
              ),
              style: TextStyle(
                fontSize: KSizes.fontSizeXL,
                fontWeight: KSizes.fontWeightMedium,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          const SizedBox(height: KSizes.margin4x),
          
          // Target weight slider
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.success,
                  inactiveTrackColor: AppColors.success.withOpacity(0.2),
                  thumbColor: AppColors.success,
                  overlayColor: AppColors.success.withOpacity(0.2),
                  trackHeight: 6.0,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                ),
                child: Slider(
                  value: targetWeight,
                  min: minWeight,
                  max: maxWeight,
                  divisions: ((maxWeight - minWeight) * 2).round(),
                  onChanged: (value) {
                    final notifier = ref.read(onboardingProvider.notifier);
                    notifier.updateTargetWeight(value);
                    _targetWeightController.text = value.toStringAsFixed(1);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${minWeight.round()} kg',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${maxWeight.round()} kg',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGoalSection(UserProfileModel userProfile) {
    final goalType = userProfile.goalType ?? GoalType.weightMaintenance;
    
    double min, max;
    switch (goalType) {
      case GoalType.weightLoss:
        min = -1.5;
        max = -0.1;
        break;
      case GoalType.weightGain:
      case GoalType.muscleGain:
        min = 0.1;
        max = 1.0;
        break;
      case GoalType.weightMaintenance:
        min = -0.2;
        max = 0.2;
        break;
    }

    final weeklyGoal = userProfile.weeklyGoalKg.clamp(min, max);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin6x),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.secondary.withOpacity(0.02),
          ],
        ),
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
        children: [
          // Section header
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
                  MdiIcons.trendingUp,
                  color: Colors.white,
                  size: KSizes.iconM,
                ),
              ),
              const SizedBox(width: KSizes.margin3x),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ugentlig vægtændring',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Hvor hurtigt vil du nå dit mål?',
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
          
          // Goal info
          Container(
            padding: const EdgeInsets.all(KSizes.margin4x),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.secondary.withOpacity(0.05),
                  AppColors.secondary.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(KSizes.radiusL),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getGoalIcon(goalType),
                  color: AppColors.secondary,
                  size: KSizes.iconM,
                ),
                const SizedBox(width: KSizes.margin3x),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dit mål',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeS,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _getGoalTypeText(goalType),
                        style: TextStyle(
                          fontSize: KSizes.fontSizeL,
                          fontWeight: KSizes.fontWeightBold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${weeklyGoal > 0 ? '+' : ''}${weeklyGoal.toStringAsFixed(1)} kg/uge',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeL,
                    fontWeight: KSizes.fontWeightBold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          // Weekly goal input
          Container(
            padding: const EdgeInsets.all(KSizes.margin3x),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(KSizes.radiusM),
              border: Border.all(
                color: weeklyGoal != 0 ? AppColors.secondary.withOpacity(0.3) : AppColors.border,
                width: weeklyGoal != 0 ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: _weeklyGoalController,
              focusNode: _weeklyGoalFocus,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              onChanged: (value) {
                final goal = double.tryParse(value);
                if (goal != null && goal >= min && goal <= max) {
                  Future.delayed(const Duration(milliseconds: 200), () {
                    if (mounted && !_weeklyGoalFocus.hasFocus) {
                      final notifier = ref.read(onboardingProvider.notifier);
                      notifier.updateWeeklyGoal(goal);
                    }
                  });
                }
              },
              decoration: InputDecoration(
                hintText: 'Indtast ugentlig mål',
                suffixText: 'kg/uge',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: KSizes.fontSizeL,
                ),
                suffixStyle: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: KSizes.fontWeightMedium,
                  fontSize: KSizes.fontSizeL,
                ),
              ),
              style: TextStyle(
                fontSize: KSizes.fontSizeXL,
                fontWeight: KSizes.fontWeightMedium,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          const SizedBox(height: KSizes.margin4x),
          
          // Weekly goal slider
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.secondary,
                  inactiveTrackColor: AppColors.secondary.withOpacity(0.2),
                  thumbColor: AppColors.secondary,
                  overlayColor: AppColors.secondary.withOpacity(0.2),
                  trackHeight: 6.0,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                ),
                child: Slider(
                  value: weeklyGoal.clamp(min, max),
                  min: min,
                  max: max,
                  divisions: ((max - min) * 10).round(),
                  onChanged: (value) {
                    final notifier = ref.read(onboardingProvider.notifier);
                    notifier.updateWeeklyGoal(value);
                    _weeklyGoalController.text = value.toStringAsFixed(1);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${min.toStringAsFixed(1)} kg',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${max.toStringAsFixed(1)} kg',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.info.withOpacity(0.05),
            AppColors.info.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(
          color: AppColors.info.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            MdiIcons.informationOutline,
            color: AppColors.info,
            size: KSizes.iconM,
          ),
          const SizedBox(width: KSizes.margin3x),
          Expanded(
            child: Text(
              'Dine nye mål vil automatisk opdatere dit daglige kaloriemål. Ændringerne træder i kraft med det samme.',
              style: TextStyle(
                fontSize: KSizes.fontSizeM,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButton() {
    return Container(
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, KSizes.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KSizes.radiusL),
            ),
            elevation: 0,
          ),
          child: _isSaving
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: KSizes.margin3x),
                    Text(
                      'Gemmer...',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightMedium,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      MdiIcons.checkCircle,
                      size: KSizes.iconM,
                    ),
                    const SizedBox(width: KSizes.margin2x),
                    Text(
                      'Gem ændringer',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightMedium,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;
    
    setState(() {
      _isSaving = true;
    });

    try {
      final notifier = ref.read(onboardingProvider.notifier);
      
      // First, read current values from text controllers and update state
      final targetWeightText = _targetWeightController.text.trim();
      final weeklyGoalText = _weeklyGoalController.text.trim();
      
      // Update target weight if valid
      final targetWeight = double.tryParse(targetWeightText);
      if (targetWeight != null && targetWeight >= 40.0 && targetWeight <= 200.0) {
        notifier.updateTargetWeight(targetWeight);
      }
      
      // Update weekly goal if valid
      final weeklyGoal = double.tryParse(weeklyGoalText);
      if (weeklyGoal != null && weeklyGoal >= -1.5 && weeklyGoal <= 2.0) {
        notifier.updateWeeklyGoal(weeklyGoal);
      }
      
      // Small delay to ensure state updates are processed
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Force recalculation of targets to ensure calories are updated
      await notifier.forceRecalculateTargets();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(MdiIcons.checkCircle, color: Colors.white),
                const SizedBox(width: KSizes.margin2x),
                Text('Mål opdateret!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KSizes.radiusM),
            ),
          ),
        );
        
        // Navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(MdiIcons.alertCircle, color: Colors.white),
                const SizedBox(width: KSizes.margin2x),
                Text('Fejl ved opdatering'),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KSizes.radiusM),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  IconData _getGoalIcon(GoalType goalType) {
    switch (goalType) {
      case GoalType.weightLoss:
        return MdiIcons.trendingDown;
      case GoalType.weightMaintenance:
        return MdiIcons.equal;
      case GoalType.weightGain:
        return MdiIcons.trendingUp;
      case GoalType.muscleGain:
        return MdiIcons.dumbbell;
    }
  }

  String _getGoalTypeText(GoalType goalType) {
    switch (goalType) {
      case GoalType.weightLoss:
        return 'Tab vægt';
      case GoalType.weightMaintenance:
        return 'Vedligehold vægt';
      case GoalType.weightGain:
        return 'Tag på i vægt';
      case GoalType.muscleGain:
        return 'Byg muskler';
    }
  }
} 