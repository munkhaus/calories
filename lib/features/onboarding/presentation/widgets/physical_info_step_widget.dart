import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/onboarding_notifier.dart';
import '../../domain/user_profile_model.dart';
import 'onboarding_base_layout.dart';

/// Physical info step widget for onboarding
class PhysicalInfoStepWidget extends ConsumerStatefulWidget {
  const PhysicalInfoStepWidget({super.key});

  @override
  ConsumerState<PhysicalInfoStepWidget> createState() => _PhysicalInfoStepWidgetState();
}

class _PhysicalInfoStepWidgetState extends ConsumerState<PhysicalInfoStepWidget> {
  late TextEditingController _heightController;
  late TextEditingController _currentWeightController;
  late TextEditingController _targetWeightController;
  
  late FocusNode _heightFocus;
  late FocusNode _currentWeightFocus;
  late FocusNode _targetWeightFocus;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController();
    _currentWeightController = TextEditingController();
    _targetWeightController = TextEditingController();
    
    _heightFocus = FocusNode();
    _currentWeightFocus = FocusNode();
    _targetWeightFocus = FocusNode();
    
    // Auto-focus height field after widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _heightFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _heightController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    
    _heightFocus.dispose();
    _currentWeightFocus.dispose();
    _targetWeightFocus.dispose();
    super.dispose();
  }

  void _updateControllers(UserProfileModel profile) {
    // Only update if the controller text is different from the current value
    // AND the respective field is not currently focused (user is not typing)
    final heightText = profile.heightCm > 0 ? profile.heightCm.round().toString() : '';
    final currentWeightText = profile.currentWeightKg > 0 ? profile.currentWeightKg.toStringAsFixed(1) : '';
    final targetWeightText = profile.targetWeightKg > 0 ? profile.targetWeightKg.toStringAsFixed(1) : '';

    if (_heightController.text != heightText && !_heightFocus.hasFocus) {
      _heightController.text = heightText;
    }
    if (_currentWeightController.text != currentWeightText && !_currentWeightFocus.hasFocus) {
      _currentWeightController.text = currentWeightText;
    }
    if (_targetWeightController.text != targetWeightText && !_targetWeightFocus.hasFocus) {
      _targetWeightController.text = targetWeightText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    
    // Pre-populate fields with existing data
    if (_heightController.text.isEmpty && state.userProfile.heightCm > 0) {
      _heightController.text = state.userProfile.heightCm.round().toString();
    }
    if (_currentWeightController.text.isEmpty && state.userProfile.currentWeightKg > 0) {
      _currentWeightController.text = state.userProfile.currentWeightKg.toStringAsFixed(1);
    }
    if (_targetWeightController.text.isEmpty && state.userProfile.targetWeightKg > 0) {
      _targetWeightController.text = state.userProfile.targetWeightKg.toStringAsFixed(1);
    }

    return OnboardingBaseLayout(
      children: [
        // Height section
        OnboardingSection(
          child: _buildHeightSection(context, state, notifier),
        ),
        
        KSizes.spacingVerticalL,
        
        // Current weight section  
        OnboardingSection(
          child: _buildCurrentWeightSection(context, state, notifier),
        ),
        
        KSizes.spacingVerticalL,
        
        // Target weight section
        OnboardingSection(
          child: _buildTargetWeightSection(context, state, notifier),
        ),
        
        // BMI display
        if (state.userProfile.heightCm > 0 && state.userProfile.currentWeightKg > 0) ...[
          KSizes.spacingVerticalL,
          OnboardingSection(
            child: _buildBMISection(context, state),
          ),
        ],
      ],
    );
  }

  Widget _buildHeightSection(BuildContext context, dynamic state, dynamic notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingSectionHeader(
          icon: MdiIcons.humanMaleHeight,
          title: 'Hvor høj er du?',
          subtitle: 'Din højde hjælper os med at beregne dine kaloriebehov',
        ),
        
        KSizes.spacingVerticalM,
        
        // Single Input Field using standardized container
        OnboardingInputContainer(
          child: TextField(
            controller: _heightController,
            focusNode: _heightFocus,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
            ],
            onChanged: (value) {
              final height = double.tryParse(value) ?? 0;
              if (height >= 120 && height <= 220) {
                notifier.updateHeight(height);
              }
            },
            onSubmitted: (_) => _currentWeightFocus.requestFocus(),
            decoration: InputDecoration(
              hintText: 'Højde',
              suffixText: 'cm',
              suffixIcon: state.userProfile.heightCm > 0 
                  ? Icon(
                      MdiIcons.check,
                      color: AppColors.success,
                      size: KSizes.iconS,
                    )
                  : null,
              border: InputBorder.none,
              hintStyle: TextStyle(color: AppColors.primary.withOpacity(0.6)),
              suffixStyle: TextStyle(
                color: AppColors.primary,
                fontWeight: KSizes.fontWeightMedium,
                fontSize: 20,
              ),
              errorText: _heightController.text.isNotEmpty && state.userProfile.heightCm <= 0 
                  ? 'Indtast højde mellem 120-220 cm' 
                  : null,
              errorStyle: TextStyle(
                color: AppColors.error,
                fontSize: KSizes.fontSizeXS,
              ),
            ),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: KSizes.fontWeightBold,
            ),
          ),
        ),
        
        KSizes.spacingVerticalM,
        
        // Height Slider using standardized component
        OnboardingSlider(
          value: state.userProfile.heightCm,
          min: 120,
          max: 220,
          divisions: 100,
          onChanged: notifier.updateHeight,
          minLabel: '120 cm',
          maxLabel: '220 cm',
        ),
      ],
    );
  }

  Widget _buildCurrentWeightSection(BuildContext context, dynamic state, dynamic notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingSectionHeader(
          icon: MdiIcons.scale,
          title: 'Hvad vejer du nu?',
          subtitle: 'Din nuværende vægt bruges som udgangspunkt for dine mål',
          iconColor: AppColors.secondary,
        ),
        
        KSizes.spacingVerticalM,
        
        // Single Input Field using standardized container
        OnboardingInputContainer(
          color: AppColors.secondary,
          child: TextField(
            controller: _currentWeightController,
            focusNode: _currentWeightFocus,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
            ],
            onChanged: (value) {
              final weight = double.tryParse(value) ?? 0;
              if (weight >= 30 && weight <= 200) {
                notifier.updateCurrentWeight(weight);
              }
            },
            onSubmitted: (_) => _targetWeightFocus.requestFocus(),
            decoration: InputDecoration(
              hintText: 'Nuværende vægt',
              suffixText: 'kg',
              suffixIcon: state.userProfile.currentWeightKg > 0 
                  ? Icon(
                      MdiIcons.check,
                      color: AppColors.success,
                      size: KSizes.iconS,
                    )
                  : null,
              border: InputBorder.none,
              hintStyle: TextStyle(color: AppColors.secondary.withOpacity(0.6)),
              suffixStyle: TextStyle(
                color: AppColors.secondary,
                fontWeight: KSizes.fontWeightMedium,
                fontSize: 20,
              ),
            ),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.secondary,
              fontWeight: KSizes.fontWeightBold,
            ),
          ),
        ),
        
        KSizes.spacingVerticalM,
        
        // Current Weight Slider using standardized component
        OnboardingSlider(
          value: state.userProfile.currentWeightKg,
          min: 30,
          max: 200,
          divisions: 340,
          onChanged: notifier.updateCurrentWeight,
          color: AppColors.secondary,
          minLabel: '30 kg',
          maxLabel: '200 kg',
        ),
      ],
    );
  }

  Widget _buildTargetWeightSection(BuildContext context, dynamic state, dynamic notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingSectionHeader(
          icon: MdiIcons.target,
          title: 'Hvad er din målvægt?',
          subtitle: 'Den vægt du gerne vil opnå',
          iconColor: AppColors.success,
        ),
        
        KSizes.spacingVerticalM,
        
        // Single Input Field using standardized container
        OnboardingInputContainer(
          color: AppColors.success,
          child: TextField(
            controller: _targetWeightController,
            focusNode: _targetWeightFocus,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
            ],
            onChanged: (value) {
              final weight = double.tryParse(value) ?? 0;
              if (weight >= 30 && weight <= 200) {
                notifier.updateTargetWeight(weight);
              }
            },
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              hintText: 'Målvægt',
              suffixText: 'kg',
              suffixIcon: state.userProfile.targetWeightKg > 0 
                  ? Icon(
                      MdiIcons.check,
                      color: AppColors.success,
                      size: KSizes.iconS,
                    )
                  : null,
              border: InputBorder.none,
              hintStyle: TextStyle(color: AppColors.success.withOpacity(0.6)),
              suffixStyle: TextStyle(
                color: AppColors.success,
                fontWeight: KSizes.fontWeightMedium,
                fontSize: 20,
              ),
            ),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.success,
              fontWeight: KSizes.fontWeightBold,
            ),
          ),
        ),
        
        KSizes.spacingVerticalM,
        
        // Target Weight Slider using standardized component
        OnboardingSlider(
          value: state.userProfile.targetWeightKg,
          min: 30,
          max: 200,
          divisions: 340,
          onChanged: notifier.updateTargetWeight,
          color: AppColors.success,
          minLabel: '30 kg',
          maxLabel: '200 kg',
        ),
        
        // Weight Difference Display
        if (state.userProfile.currentWeightKg > 0 && state.userProfile.targetWeightKg > 0)
          _buildWeightDifferenceCard(context, state),
      ],
    );
  }

  Widget _buildWeightDifferenceCard(BuildContext context, dynamic state) {
    final difference = state.userProfile.targetWeightKg - state.userProfile.currentWeightKg;
    final isWeightLoss = difference < 0;
    final isWeightGain = difference > 0;
    final isMaintenance = difference.abs() < 0.5;

    if (isMaintenance) {
      return Container(
        margin: const EdgeInsets.only(top: KSizes.margin4x),
        padding: const EdgeInsets.all(KSizes.margin3x),
        decoration: BoxDecoration(
          color: AppColors.info.withOpacity(0.1),
          borderRadius: BorderRadius.circular(KSizes.radiusS),
          border: Border.all(color: AppColors.info.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              MdiIcons.equal,
              color: AppColors.info,
              size: KSizes.iconS,
            ),
            KSizes.spacingHorizontalS,
            Text(
              'Vægtvedligeholdelse',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.info,
                fontWeight: KSizes.fontWeightMedium,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: KSizes.margin4x),
      padding: const EdgeInsets.all(KSizes.margin3x),
      decoration: BoxDecoration(
        color: isWeightLoss 
            ? AppColors.warning.withOpacity(0.1)
            : AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusS),
        border: Border.all(
          color: isWeightLoss 
              ? AppColors.warning.withOpacity(0.3)
              : AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isWeightLoss ? MdiIcons.trendingDown : MdiIcons.trendingUp,
            color: isWeightLoss ? AppColors.warning : AppColors.success,
            size: KSizes.iconS,
          ),
          KSizes.spacingHorizontalS,
          Text(
            isWeightLoss 
                ? '${difference.abs().toStringAsFixed(1)} kg vægttab'
                : '${difference.abs().toStringAsFixed(1)} kg vægtøgning',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isWeightLoss ? AppColors.warning : AppColors.success,
              fontWeight: KSizes.fontWeightMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMISection(BuildContext context, dynamic state) {
    final bmi = state.userProfile.bmi;
    final category = state.userProfile.bmiCategory;
    
    Color bmiColor;
    IconData bmiIcon;
    
    if (bmi < 18.5) {
      bmiColor = AppColors.info;
      bmiIcon = MdiIcons.trendingDown;
    } else if (bmi < 25) {
      bmiColor = AppColors.success;
      bmiIcon = MdiIcons.checkCircle;
    } else if (bmi < 30) {
      bmiColor = AppColors.warning;
      bmiIcon = MdiIcons.alertCircle;
    } else {
      bmiColor = AppColors.error;
      bmiIcon = MdiIcons.alert;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingSectionHeader(
          icon: MdiIcons.calculator,
          title: 'Dit BMI',
          subtitle: 'Beregnet ud fra din højde og vægt',
        ),
        
        KSizes.spacingVerticalM,
        
        Container(
          padding: const EdgeInsets.all(KSizes.margin4x),
          decoration: BoxDecoration(
            color: bmiColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(KSizes.radiusM),
            border: Border.all(color: bmiColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  color: bmiColor,
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                ),
                child: Icon(
                  bmiIcon,
                  color: Colors.white,
                  size: KSizes.iconM,
                ),
              ),
              KSizes.spacingHorizontalM,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BMI: ${bmi.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: bmiColor,
                        fontWeight: KSizes.fontWeightBold,
                      ),
                    ),
                    Text(
                      category,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}