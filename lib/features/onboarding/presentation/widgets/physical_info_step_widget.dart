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
          title: 'Hvor høj er du?',
          subtitle: 'Indtast din højde i centimeter.',
        ),
        
        KSizes.spacingVerticalL,
        
        // Height input with simplified styling
        OnboardingInputContainer(
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
          minLabel: '120 cm',
          maxLabel: '220 cm',
        ),
        
        // Help text for height validation
        if (_heightController.text.isNotEmpty && state.userProfile.heightCm <= 0) ...[
          KSizes.spacingVerticalM,
          OnboardingHelpText(
            text: 'Indtast en højde mellem 120-220 cm',
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
          title: 'Hvad vejer du nu?',
          subtitle: 'Indtast din nuværende vægt i kilogram.',
        ),
        
        KSizes.spacingVerticalL,
        
        // Weight input with simplified styling
        OnboardingInputContainer(
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
              if (weight >= 30 && weight <= 300) {
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
        
        // Weight Slider
        OnboardingSlider(
          value: state.userProfile.currentWeightKg,
          min: 30,
          max: 300,
          divisions: 270,
          onChanged: notifier.updateCurrentWeight,
          minLabel: '30 kg',
          maxLabel: '300 kg',
        ),
        
        // Help text for weight validation
        if (_currentWeightController.text.isNotEmpty && state.userProfile.currentWeightKg <= 0) ...[
          KSizes.spacingVerticalM,
          OnboardingHelpText(
            text: 'Indtast en vægt mellem 30-300 kg',
          ),
        ],
      ],
    );
  }

  Widget _buildBMISection(BuildContext context, dynamic state) {
    final height = state.userProfile.heightCm;
    final weight = state.userProfile.currentWeightKg;
    
    if (height <= 0 || weight <= 0) return const SizedBox.shrink();
    
    // Calculate BMI
    final bmi = weight / ((height / 100) * (height / 100));
    
    // Determine BMI category and color
    String category;
    Color categoryColor;
    
    if (bmi < 18.5) {
      category = 'Undervægt';
      categoryColor = AppColors.warning;
    } else if (bmi < 25) {
      category = 'Normal vægt';
      categoryColor = AppColors.success;
    } else if (bmi < 30) {
      category = 'Overvægt';
      categoryColor = AppColors.warning;
    } else {
      category = 'Fedme';
      categoryColor = AppColors.error;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingSectionHeader(
          title: 'Dit BMI',
          subtitle: 'Body Mass Index baseret på højde og vægt.',
        ),
        
        KSizes.spacingVerticalL,
        
        // BMI Display
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(KSizes.margin4x),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(KSizes.radiusM),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    bmi.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: KSizes.fontWeightBold,
                    ),
                  ),
                  KSizes.spacingHorizontalS,
                  Text(
                    'BMI',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              KSizes.spacingVerticalS,
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: KSizes.margin3x,
                  vertical: KSizes.margin1x,
                ),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                ),
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: categoryColor,
                    fontWeight: KSizes.fontWeightMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}