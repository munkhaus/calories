import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/onboarding_notifier.dart';
import '../../domain/user_profile_model.dart';
import 'onboarding_base_layout.dart';

/// Personal info step widget for onboarding
class PersonalInfoStepWidget extends ConsumerStatefulWidget {
  const PersonalInfoStepWidget({super.key});

  @override
  ConsumerState<PersonalInfoStepWidget> createState() => _PersonalInfoStepWidgetState();
}

class _PersonalInfoStepWidgetState extends ConsumerState<PersonalInfoStepWidget> {
  late TextEditingController _nameController;
  late TextEditingController _dayController;
  late TextEditingController _monthController;
  late TextEditingController _yearController;
  
  late FocusNode _nameFocus;
  late FocusNode _dayFocus;
  late FocusNode _monthFocus;
  late FocusNode _yearFocus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _dayController = TextEditingController();
    _monthController = TextEditingController();
    _yearController = TextEditingController();
    
    _nameFocus = FocusNode();
    _dayFocus = FocusNode();
    _monthFocus = FocusNode();
    _yearFocus = FocusNode();
    
    // Auto-focus name field after widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _nameFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    
    _nameFocus.dispose();
    _dayFocus.dispose();
    _monthFocus.dispose();
    _yearFocus.dispose();
    super.dispose();
  }

  void _updateControllers(UserProfileModel profile) {
    if (_nameController.text != profile.name) {
      _nameController.text = profile.name;
    }
    
    if (profile.dateOfBirth != null) {
      final date = profile.dateOfBirth!;
      final day = date.day.toString();
      final month = date.month.toString();
      final year = date.year.toString();
      
      if (_dayController.text != day) _dayController.text = day;
      if (_monthController.text != month) _monthController.text = month;
      if (_yearController.text != year) _yearController.text = year;
    }
  }

  void _updateDateOfBirth() {
    final day = int.tryParse(_dayController.text) ?? 0;
    final month = int.tryParse(_monthController.text) ?? 0;
    final year = int.tryParse(_yearController.text) ?? 0;
    
    // Only proceed if all fields have valid values
    if (day > 0 && day <= 31 && month > 0 && month <= 12 && year > 1900 && year <= DateTime.now().year) {
      try {
        final date = DateTime(year, month, day);
        // Check if the created date matches the input (handles invalid dates like Feb 30)
        if (date.year == year && date.month == month && date.day == day) {
          // Check if date is not in the future
          if (date.isBefore(DateTime.now()) || date.isAtSameMomentAs(DateTime.now())) {
            ref.read(onboardingProvider.notifier).updateDateOfBirth(date);
          }
        }
      } catch (e) {
        // Invalid date, ignore
        print('Invalid date: $day/$month/$year - $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    
    // Pre-populate fields with existing data
    if (_nameController.text.isEmpty && state.userProfile.name.isNotEmpty) {
      _nameController.text = state.userProfile.name;
    }
    
    // Pre-populate date fields with existing dateOfBirth
    if (state.userProfile.dateOfBirth != null) {
      final date = state.userProfile.dateOfBirth!;
      final day = date.day.toString();
      final month = date.month.toString();
      final year = date.year.toString();
      
      if (_dayController.text != day) _dayController.text = day;
      if (_monthController.text != month) _monthController.text = month;
      if (_yearController.text != year) _yearController.text = year;
    }

    return OnboardingBaseLayout(
      children: [
        // Name section
        OnboardingSection(
          child: _buildNameSection(context, state, notifier),
        ),
        
        KSizes.spacingVerticalL,
        
        // Date of birth section
        OnboardingSection(
          child: _buildDateOfBirthSection(context, state, notifier),
        ),
        
        KSizes.spacingVerticalL,
        
        // Gender section
        OnboardingSection(
          child: _buildGenderSection(context, state, notifier),
        ),
      ],
    );
  }

  Widget _buildNameSection(BuildContext context, dynamic state, dynamic notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              MdiIcons.account,
              size: KSizes.iconM,
              color: AppColors.primary,
            ),
            KSizes.spacingHorizontalS,
            Text(
              'Hvad hedder du?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        KSizes.spacingVerticalS,
        Text(
          'Dit navn hjælper os med at personalisere din oplevelse',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        KSizes.spacingVerticalM,
        TextField(
          controller: _nameController,
          focusNode: _nameFocus,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'Dit navn',
            prefixIcon: Icon(
              MdiIcons.account,
              color: state.userProfile.name.isNotEmpty ? AppColors.success : AppColors.primary,
            ),
            suffixIcon: state.userProfile.name.isNotEmpty 
                ? Icon(
                    MdiIcons.check,
                    color: AppColors.success,
                    size: KSizes.iconS,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KSizes.radiusM),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KSizes.radiusM),
              borderSide: BorderSide(
                color: state.userProfile.name.isNotEmpty 
                    ? AppColors.success.withOpacity(0.5)
                    : AppColors.primary.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KSizes.radiusM),
              borderSide: BorderSide(
                color: state.userProfile.name.isNotEmpty 
                    ? AppColors.success
                    : AppColors.primary,
                width: 2,
              ),
            ),
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: notifier.updateName,
          onSubmitted: (_) => _dayFocus.requestFocus(),
        ),
      ],
    );
  }

  Widget _buildDateOfBirthSection(BuildContext context, dynamic state, dynamic notifier) {
    // Calculate age directly to avoid Freezed issues
    final dateOfBirth = state.userProfile.dateOfBirth;
    final age = dateOfBirth != null 
        ? DateTime.now().year - dateOfBirth.year -
          (DateTime.now().month < dateOfBirth.month || 
           (DateTime.now().month == dateOfBirth.month && DateTime.now().day < dateOfBirth.day) ? 1 : 0)
        : 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              MdiIcons.cake,
              size: KSizes.iconM,
              color: AppColors.secondary,
            ),
            KSizes.spacingHorizontalS,
            Text(
              'Hvornår er din fødselsdag?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        KSizes.spacingVerticalS,
        Text(
          'Vi bruger din alder til at beregne dine kaloriebehov',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        KSizes.spacingVerticalM,
        
        // Simple 3-field date input
        Row(
          children: [
            // Day
            Expanded(
              child: _buildDateField(
                context: context,
                controller: _dayController,
                focusNode: _dayFocus,
                hint: 'DD',
                maxLength: 2,
                onChanged: (value) {
                  if (value.length == 2) {
                    _monthFocus.requestFocus();
                  }
                  _updateDateOfBirth();
                },
                onSubmitted: (_) => _monthFocus.requestFocus(),
              ),
            ),
            
            KSizes.spacingHorizontalS,
            
            // Month
            Expanded(
              child: _buildDateField(
                context: context,
                controller: _monthController,
                focusNode: _monthFocus,
                hint: 'MM',
                maxLength: 2,
                onChanged: (value) {
                  if (value.length == 2) {
                    _yearFocus.requestFocus();
                  }
                  _updateDateOfBirth();
                },
                onSubmitted: (_) => _yearFocus.requestFocus(),
              ),
            ),
            
            KSizes.spacingHorizontalS,
            
            // Year
            Expanded(
              flex: 2,
              child: _buildDateField(
                context: context,
                controller: _yearController,
                focusNode: _yearFocus,
                hint: 'YYYY',
                maxLength: 4,
                onChanged: (value) {
                  _updateDateOfBirth();
                  // Auto-focus next section when year is complete
                  if (value.length == 4) {
                    FocusScope.of(context).unfocus();
                  }
                },
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
              ),
            ),
          ],
        ),
        
        // Show age if date is valid
        if (age > 0) ...[
          KSizes.spacingVerticalM,
          Container(
            padding: const EdgeInsets.all(KSizes.margin3x),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(KSizes.radiusM),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  MdiIcons.information,
                  size: KSizes.iconS,
                  color: AppColors.secondary,
                ),
                KSizes.spacingHorizontalS,
                Text(
                  'Du er $age år gammel',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: KSizes.fontWeightMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required int maxLength,
    required Function(String) onChanged,
    required Function(String) onSubmitted,
  }) {
    // Determine the TextInputAction based on the hint
    TextInputAction inputAction;
    if (hint == 'DD') {
      inputAction = TextInputAction.next;
    } else if (hint == 'MM') {
      inputAction = TextInputAction.next;
    } else {
      inputAction = TextInputAction.done;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textInputAction: inputAction,
        textAlign: TextAlign.center,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(maxLength),
        ],
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.all(KSizes.margin3x),
          border: InputBorder.none,
          hintStyle: TextStyle(color: AppColors.secondary.withOpacity(0.6)),
          counterText: '',
        ),
        style: TextStyle(
          color: AppColors.secondary,
          fontWeight: KSizes.fontWeightMedium,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildGenderSection(BuildContext context, dynamic state, dynamic notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              MdiIcons.humanMaleFemale,
              size: KSizes.iconM,
              color: AppColors.success,
            ),
            KSizes.spacingHorizontalS,
            Text(
              'Hvad er dit køn?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        KSizes.spacingVerticalS,
        Text(
          'Dette hjælper os med at beregne dine kaloriebehov mere præcist',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        KSizes.spacingVerticalM,
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(
                context,
                gender: Gender.male,
                label: 'Mand',
                icon: MdiIcons.humanMale,
                isSelected: state.userProfile.gender == Gender.male,
                onTap: () => notifier.updateGender(Gender.male),
              ),
            ),
            KSizes.spacingHorizontalM,
            Expanded(
              child: _buildGenderOption(
                context,
                gender: Gender.female,
                label: 'Kvinde',
                icon: MdiIcons.humanFemale,
                isSelected: state.userProfile.gender == Gender.female,
                onTap: () => notifier.updateGender(Gender.female),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(
    BuildContext context, {
    required Gender gender,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KSizes.radiusM),
      child: Container(
        padding: const EdgeInsets.all(KSizes.margin4x),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.success.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          border: Border.all(
            color: isSelected 
                ? AppColors.success 
                : AppColors.success.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: KSizes.iconL,
              color: isSelected 
                  ? AppColors.success 
                  : AppColors.success.withOpacity(0.7),
            ),
            KSizes.spacingVerticalS,
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isSelected 
                    ? AppColors.success 
                    : AppColors.textSecondary,
                fontWeight: isSelected 
                    ? KSizes.fontWeightMedium 
                    : KSizes.fontWeightRegular,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 