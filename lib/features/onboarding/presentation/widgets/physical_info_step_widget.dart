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
  
  late FocusNode _heightFocus;
  late FocusNode _currentWeightFocus;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController();
    _currentWeightController = TextEditingController();
    
    _heightFocus = FocusNode();
    _currentWeightFocus = FocusNode();
    
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
    
    _heightFocus.dispose();
    _currentWeightFocus.dispose();
    super.dispose();
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

    return OnboardingBaseLayout(
      title: 'Dine fysiske mål',
      subtitle: 'Højde og vægt hjælper os med at beregne dine kaloriebehov.',
      titleIcon: Icons.straighten,
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
          icon: Icons.height,
          title: 'Hvor høj er du?',
          subtitle: 'Indtast din højde i centimeter.',
          iconColor: AppColors.primary,
        ),
        
        KSizes.spacingVerticalL,
        
        // Height input with better styling
        OnboardingInputContainer(
          color: AppColors.primary,
          isActive: state.userProfile.heightCm > 0,
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
              hintText: 'Indtast højde',
              suffixText: 'cm',
              suffixIcon: state.userProfile.heightCm > 0 
                  ? Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: KSizes.iconM,
                    )
                  : null,
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: AppColors.primary.withOpacity(0.6),
                fontSize: KSizes.fontSizeL,
              ),
              suffixStyle: TextStyle(
                color: AppColors.primary,
                fontWeight: KSizes.fontWeightMedium,
                fontSize: KSizes.fontSizeL,
              ),
            ),
            style: TextStyle(
              fontSize: KSizes.fontSizeXXL,
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.primary,
            ),
          ),
        ),
        
        KSizes.spacingVerticalL,
        
        // Height Slider
        OnboardingSlider(
          value: state.userProfile.heightCm,
          min: 120,
          max: 220,
          divisions: 100,
          onChanged: notifier.updateHeight,
          color: AppColors.primary,
          minLabel: '120 cm',
          maxLabel: '220 cm',
        ),
        
        // Help text for height validation
        if (_heightController.text.isNotEmpty && state.userProfile.heightCm <= 0) ...[
          KSizes.spacingVerticalM,
          OnboardingHelpText(
            text: 'Indtast en højde mellem 120-220 cm',
            icon: Icons.warning_outlined,
            color: AppColors.warning,
          ),
        ],
      ],
    );
  }

  Widget _buildCurrentWeightSection(BuildContext context, dynamic state, dynamic notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingSectionHeader(
          icon: Icons.monitor_weight_outlined,
          title: 'Hvad vejer du nu?',
          subtitle: 'Indtast din nuværende vægt i kilogram.',
          iconColor: AppColors.secondary,
        ),
        
        KSizes.spacingVerticalL,
        
        // Weight input with better styling
        OnboardingInputContainer(
          color: AppColors.secondary,
          isActive: state.userProfile.currentWeightKg > 0,
          child: TextField(
            controller: _currentWeightController,
            focusNode: _currentWeightFocus,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
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
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              hintText: 'Indtast vægt',
              suffixText: 'kg',
              suffixIcon: state.userProfile.currentWeightKg > 0 
                  ? Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: KSizes.iconM,
                    )
                  : null,
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: AppColors.secondary.withOpacity(0.6),
                fontSize: KSizes.fontSizeL,
              ),
              suffixStyle: TextStyle(
                color: AppColors.secondary,
                fontWeight: KSizes.fontWeightMedium,
                fontSize: KSizes.fontSizeL,
              ),
            ),
            style: TextStyle(
              fontSize: KSizes.fontSizeXXL,
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.secondary,
            ),
          ),
        ),
        
        KSizes.spacingVerticalL,
        
        // Current Weight Slider
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
        
        // Help text for weight validation
        if (_currentWeightController.text.isNotEmpty && state.userProfile.currentWeightKg <= 0) ...[
          KSizes.spacingVerticalM,
          OnboardingHelpText(
            text: 'Indtast en vægt mellem 30-200 kg',
            icon: Icons.warning_outlined,
            color: AppColors.warning,
          ),
        ],
      ],
    );
  }

  Widget _buildBMISection(BuildContext context, dynamic state) {
    final bmi = state.userProfile.bmi;
    final category = state.userProfile.bmiCategory;
    
    Color bmiColor;
    IconData bmiIcon;
    String explanation;
    
    if (bmi < 18.5) {
      bmiColor = AppColors.info;
      bmiIcon = Icons.trending_down;
      explanation = 'Undervægt - Overvej at tage på for optimal sundhed';
    } else if (bmi < 25) {
      bmiColor = AppColors.success;
      bmiIcon = Icons.check_circle;
      explanation = 'Normalvægt - Du har en sund vægt!';
    } else if (bmi < 30) {
      bmiColor = AppColors.warning;
      bmiIcon = Icons.warning_outlined;
      explanation = 'Overvægt - Overvej vægttab for bedre sundhed';
    } else {
      bmiColor = AppColors.error;
      bmiIcon = Icons.error_outline;
      explanation = 'Svær overvægt - Vægttab vil forbedre din sundhed betydeligt';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingSectionHeader(
          icon: Icons.calculate_outlined,
          title: 'Dit BMI resultat',
          subtitle: 'BMI viser din vægt i forhold til din højde.',
          iconColor: bmiColor,
        ),
        
        KSizes.spacingVerticalL,
        
        // BMI Display Card
        Container(
          padding: EdgeInsets.all(KSizes.margin4x),
          decoration: BoxDecoration(
            color: bmiColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(KSizes.radiusM),
            border: Border.all(color: bmiColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              // BMI Value
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    bmiIcon,
                    color: bmiColor,
                    size: KSizes.iconL,
                  ),
                  KSizes.spacingHorizontalM,
                  Column(
                    children: [
                      Text(
                        bmi.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: KSizes.fontSizeXXL,
                          fontWeight: KSizes.fontWeightBold,
                          color: bmiColor,
                        ),
                      ),
                      Text(
                        'BMI',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeS,
                          color: bmiColor,
                          fontWeight: KSizes.fontWeightMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              KSizes.spacingVerticalM,
              
              // Category and Explanation
              Text(
                category,
                style: TextStyle(
                  fontSize: KSizes.fontSizeL,
                  fontWeight: KSizes.fontWeightSemiBold,
                  color: bmiColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              KSizes.spacingVerticalS,
              
              Text(
                explanation,
                style: TextStyle(
                  fontSize: KSizes.fontSizeM,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        KSizes.spacingVerticalM,
        
        // BMI Information Help Text
        OnboardingHelpText(
          text: 'BMI er vejledende og tager ikke højde for muskelmasse.',
          icon: Icons.info_outline,
          color: AppColors.info,
        ),
      ],
    );
  }
}