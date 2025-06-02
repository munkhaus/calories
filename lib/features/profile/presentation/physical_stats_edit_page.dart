import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../onboarding/domain/user_profile_model.dart';

/// Standalone page for editing user physical stats from profile settings
class PhysicalStatsEditPage extends ConsumerStatefulWidget {
  const PhysicalStatsEditPage({super.key});

  @override
  ConsumerState<PhysicalStatsEditPage> createState() => _PhysicalStatsEditPageState();
}

class _PhysicalStatsEditPageState extends ConsumerState<PhysicalStatsEditPage> {
  late TextEditingController _heightController;
  late TextEditingController _currentWeightController;
  late FocusNode _heightFocus;
  late FocusNode _currentWeightFocus;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController();
    _currentWeightController = TextEditingController();
    _heightFocus = FocusNode();
    _currentWeightFocus = FocusNode();
    
    // Initialize with current values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(onboardingProvider);
      _heightController.text = state.userProfile.heightCm.round().toString();
      _currentWeightController.text = state.userProfile.currentWeightKg.toStringAsFixed(1);
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
    final userProfile = state.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rediger fysiske data',
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
                      // Height Section
                      _buildHeightSection(userProfile),
                      
                      const SizedBox(height: KSizes.margin6x),
                      
                      // Current Weight Section
                      _buildCurrentWeightSection(userProfile),
                      
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

  Widget _buildHeightSection(UserProfileModel userProfile) {
    const double minHeight = 120.0;
    const double maxHeight = 220.0;
    final height = userProfile.heightCm.clamp(minHeight, maxHeight);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin6x),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.info.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.08),
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
                      AppColors.info,
                      AppColors.info.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.info.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  MdiIcons.human,
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
                      'Højde',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Hvor høj er du?',
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
          
          // Height input
          Container(
            padding: const EdgeInsets.all(KSizes.margin3x),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(KSizes.radiusM),
              border: Border.all(
                color: height > 0 ? AppColors.info.withOpacity(0.3) : AppColors.border,
                width: height > 0 ? 2 : 1,
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
              controller: _heightController,
              focusNode: _heightFocus,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              textAlign: TextAlign.center,
              onChanged: (value) {
                final heightValue = double.tryParse(value);
                if (heightValue != null && heightValue >= minHeight && heightValue <= maxHeight) {
                  Future.delayed(const Duration(milliseconds: 200), () {
                    if (mounted && !_heightFocus.hasFocus) {
                      final notifier = ref.read(onboardingProvider.notifier);
                      notifier.updateHeight(heightValue);
                    }
                  });
                }
              },
              decoration: InputDecoration(
                hintText: 'Indtast højde',
                suffixText: 'cm',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: KSizes.fontSizeL,
                ),
                suffixStyle: TextStyle(
                  color: AppColors.info,
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
          
          // Height slider
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.info,
                  inactiveTrackColor: AppColors.info.withOpacity(0.2),
                  thumbColor: AppColors.info,
                  overlayColor: AppColors.info.withOpacity(0.2),
                  trackHeight: 6.0,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                ),
                child: Slider(
                  value: height,
                  min: minHeight,
                  max: maxHeight,
                  divisions: (maxHeight - minHeight).round(),
                  onChanged: (value) {
                    final notifier = ref.read(onboardingProvider.notifier);
                    notifier.updateHeight(value);
                    if (!_heightFocus.hasFocus) {
                      _heightController.text = value.round().toString();
                    }
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${minHeight.round()} cm',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${maxHeight.round()} cm',
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

  Widget _buildCurrentWeightSection(UserProfileModel userProfile) {
    const double minWeight = 30.0;
    const double maxWeight = 200.0;
    final currentWeight = userProfile.currentWeightKg.clamp(minWeight, maxWeight);

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
                  MdiIcons.scale,
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
                      'Nuværende vægt',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Hvad vejer du nu?',
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
          
          // Weight input
          Container(
            padding: const EdgeInsets.all(KSizes.margin3x),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(KSizes.radiusM),
              border: Border.all(
                color: currentWeight > 0 ? AppColors.secondary.withOpacity(0.3) : AppColors.border,
                width: currentWeight > 0 ? 2 : 1,
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
              controller: _currentWeightController,
              focusNode: _currentWeightFocus,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              onChanged: (value) {
                final weight = double.tryParse(value);
                if (weight != null && weight >= minWeight && weight <= maxWeight) {
                  Future.delayed(const Duration(milliseconds: 200), () {
                    if (mounted && !_currentWeightFocus.hasFocus) {
                      final notifier = ref.read(onboardingProvider.notifier);
                      notifier.updateCurrentWeight(weight);
                    }
                  });
                }
              },
              decoration: InputDecoration(
                hintText: 'Indtast vægt',
                suffixText: 'kg',
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
          
          // Weight slider
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
                  value: currentWeight,
                  min: minWeight,
                  max: maxWeight,
                  divisions: ((maxWeight - minWeight) * 2).round(),
                  onChanged: (value) {
                    final notifier = ref.read(onboardingProvider.notifier);
                    notifier.updateCurrentWeight(value);
                    if (!_currentWeightFocus.hasFocus) {
                      _currentWeightController.text = value.toStringAsFixed(1);
                    }
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
              'Dine fysiske data bruges til at beregne dit BMR og daglige kaloriebehov.',
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
    final canSave = _heightController.text.trim().isNotEmpty && 
                   _currentWeightController.text.trim().isNotEmpty;

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
          onPressed: (_isSaving || !canSave) ? null : _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: canSave ? AppColors.info : AppColors.border,
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
      
      // Update physical stats
      final heightText = _heightController.text.trim();
      final weightText = _currentWeightController.text.trim();
      
      final height = double.tryParse(heightText);
      if (height != null && height >= 120.0 && height <= 220.0) {
        notifier.updateHeight(height);
      }
      
      final weight = double.tryParse(weightText);
      if (weight != null && weight >= 30.0 && weight <= 200.0) {
        notifier.updateCurrentWeight(weight);
      }
      
      // Small delay to ensure state updates are processed
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Force recalculation since physical stats affect BMR
      await notifier.forceRecalculateTargets();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(MdiIcons.checkCircle, color: Colors.white),
                const SizedBox(width: KSizes.margin2x),
                Text('Fysiske data opdateret!'),
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
} 