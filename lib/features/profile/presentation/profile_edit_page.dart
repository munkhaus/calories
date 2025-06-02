import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../onboarding/domain/user_profile_model.dart';

/// Standalone page for editing user profile information from profile settings
class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  late TextEditingController _nameController;
  late FocusNode _nameFocus;
  bool _isSaving = false;
  DateTime? _selectedDateOfBirth;
  Gender? _selectedGender;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameFocus = FocusNode();
    
    // Initialize with current values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(onboardingProvider);
      _nameController.text = state.userProfile.name;
      setState(() {
        _selectedDateOfBirth = state.userProfile.dateOfBirth;
        _selectedGender = state.userProfile.gender;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final userProfile = state.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rediger profil',
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
                      // Name Section
                      _buildNameSection(),
                      
                      const SizedBox(height: KSizes.margin6x),
                      
                      // Date of Birth Section
                      _buildDateOfBirthSection(),
                      
                      const SizedBox(height: KSizes.margin6x),
                      
                      // Gender Section
                      _buildGenderSection(),
                      
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

  Widget _buildNameSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin6x),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
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
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  MdiIcons.account,
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
                      'Navn',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Hvad hedder du?',
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
          
          // Name input
          Container(
            padding: const EdgeInsets.all(KSizes.margin3x),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(KSizes.radiusM),
              border: Border.all(
                color: _nameController.text.isNotEmpty ? AppColors.primary.withOpacity(0.3) : AppColors.border,
                width: _nameController.text.isNotEmpty ? 2 : 1,
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
              controller: _nameController,
              focusNode: _nameFocus,
              textAlign: TextAlign.center,
              onChanged: (value) {
                setState(() {}); // Update border color
              },
              decoration: InputDecoration(
                hintText: 'Indtast dit navn',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
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
        ],
      ),
    );
  }

  Widget _buildDateOfBirthSection() {
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
                  MdiIcons.cake,
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
                      'Fødselsdato',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Hvornår er du født?',
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
          
          // Date picker button
          InkWell(
            onTap: _selectDateOfBirth,
            borderRadius: BorderRadius.circular(KSizes.radiusM),
            child: Container(
              padding: const EdgeInsets.all(KSizes.margin4x),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(KSizes.radiusM),
                border: Border.all(
                  color: _selectedDateOfBirth != null ? AppColors.info.withOpacity(0.3) : AppColors.border,
                  width: _selectedDateOfBirth != null ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    MdiIcons.calendar,
                    color: AppColors.info,
                    size: KSizes.iconM,
                  ),
                  const SizedBox(width: KSizes.margin2x),
                  Text(
                    _selectedDateOfBirth != null 
                        ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                        : 'Vælg fødselsdato',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeL,
                      fontWeight: KSizes.fontWeightMedium,
                      color: _selectedDateOfBirth != null ? AppColors.textPrimary : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSection() {
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
                  MdiIcons.humanMaleFemale,
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
                      'Køn',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Hvad er dit køn?',
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
          
          // Gender selection
          Row(
            children: [
              Expanded(
                child: _buildGenderOption(Gender.male, 'Mand', MdiIcons.genderMale),
              ),
              const SizedBox(width: KSizes.margin3x),
              Expanded(
                child: _buildGenderOption(Gender.female, 'Kvinde', MdiIcons.genderFemale),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(Gender gender, String label, IconData icon) {
    final isSelected = _selectedGender == gender;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      borderRadius: BorderRadius.circular(KSizes.radiusM),
      child: Container(
        padding: const EdgeInsets.all(KSizes.margin4x),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.secondary : AppColors.textSecondary,
              size: KSizes.iconL,
            ),
            const SizedBox(height: KSizes.margin2x),
            Text(
              label,
              style: TextStyle(
                fontSize: KSizes.fontSizeM,
                fontWeight: isSelected ? KSizes.fontWeightMedium : FontWeight.normal,
                color: isSelected ? AppColors.secondary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
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
              'Dine personlige oplysninger bruges til at beregne dit daglige kaloriebehov mere præcist.',
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
    final canSave = _nameController.text.trim().isNotEmpty && 
                   _selectedDateOfBirth != null && 
                   _selectedGender != null;

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
            backgroundColor: canSave ? AppColors.primary : AppColors.border,
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

  Future<void> _selectDateOfBirth() async {
    final initialDate = _selectedDateOfBirth ?? DateTime(1990, 1, 1);
    final firstDate = DateTime(1900);
    final lastDate = DateTime.now().subtract(const Duration(days: 365 * 13)); // At least 13 years old

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.info,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDateOfBirth = selectedDate;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;
    
    setState(() {
      _isSaving = true;
    });

    try {
      final notifier = ref.read(onboardingProvider.notifier);
      
      // Update profile information
      final name = _nameController.text.trim();
      if (name.isNotEmpty) {
        notifier.updateName(name);
      }
      
      if (_selectedDateOfBirth != null) {
        notifier.updateDateOfBirth(_selectedDateOfBirth!);
      }
      
      if (_selectedGender != null) {
        notifier.updateGender(_selectedGender!);
      }
      
      // Small delay to ensure state updates are processed
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(MdiIcons.checkCircle, color: Colors.white),
                const SizedBox(width: KSizes.margin2x),
                Text('Profil opdateret!'),
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