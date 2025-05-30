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
      title: 'Lad os lære dig at kende',
      subtitle: 'Fortæl os lidt om dig selv, så vi kan personalisere din oplevelse.',
      titleIcon: Icons.person_outline,
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
        OnboardingSectionHeader(
          icon: Icons.badge_outlined,
          title: 'Hvad hedder du?',
          subtitle: 'Dit navn gør appen mere personlig.',
          iconColor: AppColors.primary,
        ),
        
        KSizes.spacingVerticalL,
        
        OnboardingInputContainer(
          color: AppColors.primary,
          isActive: state.userProfile.name.isNotEmpty,
          child: TextField(
            controller: _nameController,
            focusNode: _nameFocus,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'Indtast dit navn',
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: AppColors.primary.withOpacity(0.6),
                fontSize: KSizes.fontSizeL,
              ),
              suffixIcon: state.userProfile.name.isNotEmpty 
                  ? Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: KSizes.iconM,
                    )
                  : null,
            ),
            style: TextStyle(
              fontSize: KSizes.fontSizeXL,
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.primary,
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: notifier.updateName,
            onSubmitted: (_) => _dayFocus.requestFocus(),
          ),
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
        OnboardingSectionHeader(
          icon: Icons.cake_outlined,
          title: 'Hvornår er din fødselsdag?',
          subtitle: 'Din alder bruges til at beregne dine kaloriebehov.',
          iconColor: AppColors.primary,
        ),
        
        KSizes.spacingVerticalL,
        
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
                label: 'Dag',
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
            
            KSizes.spacingHorizontalM,
            
            // Month
            Expanded(
              child: _buildDateField(
                context: context,
                controller: _monthController,
                focusNode: _monthFocus,
                hint: 'MM',
                label: 'Måned',
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
            
            KSizes.spacingHorizontalM,
            
            // Year
            Expanded(
              flex: 2,
              child: _buildDateField(
                context: context,
                controller: _yearController,
                focusNode: _yearFocus,
                hint: 'YYYY',
                label: 'År',
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
        
        // Age slider for consistent UX with other steps
        if (age >= 16 && age <= 80) ...[
          KSizes.spacingVerticalL,
          OnboardingSlider(
            value: age.toDouble(),
            min: 16,
            max: 80,
            divisions: 64,
            onChanged: (newAge) {
              // Calculate approximate birth year from age
              final currentYear = DateTime.now().year;
              final birthYear = currentYear - newAge.round();
              final currentMonth = DateTime.now().month;
              final currentDay = DateTime.now().day;
              
              // Set a reasonable birth date (middle of year)
              try {
                final newDate = DateTime(birthYear, currentMonth, currentDay);
                notifier.updateDateOfBirth(newDate);
                
                // Update text fields
                _dayController.text = currentDay.toString();
                _monthController.text = currentMonth.toString();  
                _yearController.text = birthYear.toString();
              } catch (e) {
                // Fallback to beginning of year if date is invalid
                final newDate = DateTime(birthYear, 1, 1);
                notifier.updateDateOfBirth(newDate);
                
                _dayController.text = '1';
                _monthController.text = '1';
                _yearController.text = birthYear.toString();
              }
            },
            color: AppColors.primary,
            minLabel: '16 år',
            maxLabel: '80 år',
          ),
        ],
        
        // Show age if date is valid
        if (age > 0) ...[
          KSizes.spacingVerticalM,
          OnboardingHelpText(
            text: 'Du er $age år gammel. Dette bruges til præcise beregninger.',
            icon: Icons.info_outline,
            color: AppColors.success,
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
    required String label,
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

    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.primary,
            fontWeight: KSizes.fontWeightMedium,
          ),
        ),
        KSizes.spacingVerticalS,
        OnboardingInputContainer(
          color: AppColors.primary,
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
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: AppColors.primary.withOpacity(0.6),
                fontSize: KSizes.fontSizeL,
              ),
            ),
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: KSizes.fontWeightBold,
              fontSize: KSizes.fontSizeXL,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSection(BuildContext context, dynamic state, dynamic notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingSectionHeader(
          icon: Icons.people_outline,
          title: 'Hvad er dit køn?',
          subtitle: 'Mænd og kvinder har forskellige kaloriebehov.',
          iconColor: AppColors.primary,
        ),
        
        KSizes.spacingVerticalL,
        
        Row(
          children: [
            Expanded(
              child: _buildGenderCard(
                context: context,
                title: 'Mand',
                icon: Icons.male,
                isSelected: state.userProfile.gender == Gender.male,
                onTap: () => notifier.updateGender(Gender.male),
              ),
            ),
            KSizes.spacingHorizontalM,
            Expanded(
              child: _buildGenderCard(
                context: context,
                title: 'Kvinde',
                icon: Icons.female,
                isSelected: state.userProfile.gender == Gender.female,
                onTap: () => notifier.updateGender(Gender.female),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shadowColor: AppColors.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        child: Container(
          height: 100, // Reduced height since we removed the checkmark
          padding: EdgeInsets.symmetric(
            horizontal: KSizes.margin2x,
            vertical: KSizes.margin3x,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(KSizes.margin1x),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(isSelected ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: KSizes.iconM,
                ),
              ),
              SizedBox(height: KSizes.margin2x),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: KSizes.fontWeightSemiBold,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 