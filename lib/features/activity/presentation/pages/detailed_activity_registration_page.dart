import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/activity_notifier.dart';
import '../../domain/user_activity_log_model.dart';
import '../../domain/activity_item_model.dart';
import '../../../onboarding/application/onboarding_notifier.dart';
import '../../../dashboard/application/date_aware_providers.dart';

/// Page for detailed activity registration
class DetailedActivityRegistrationPage extends ConsumerStatefulWidget {
  const DetailedActivityRegistrationPage({super.key});

  @override
  ConsumerState<DetailedActivityRegistrationPage> createState() => _DetailedActivityRegistrationPageState();
}

class _DetailedActivityRegistrationPageState extends ConsumerState<DetailedActivityRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedCategory = 'Cardio';
  final List<String> _categories = ['Cardio', 'Styrketræning', 'Sport', 'Yoga', 'Andet'];
  bool _isLogging = false;

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
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
                
                // Activity name
                _buildTextField(
                  controller: _nameController,
                  label: 'Aktivitetsnavn',
                  hint: 'f.eks. Løb i parken',
                  icon: MdiIcons.runFast,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Indtast aktivitetsnavn';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: KSizes.margin4x),
                
                // Category dropdown
                _buildCategoryDropdown(),
                
                SizedBox(height: KSizes.margin4x),
                
                // Duration
                _buildTextField(
                  controller: _durationController,
                  label: 'Varighed (minutter)',
                  hint: 'f.eks. 30',
                  icon: MdiIcons.clockOutline,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Indtast varighed';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Indtast et gyldigt tal';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: KSizes.margin4x),
                
                // Calories (optional)
                _buildTextField(
                  controller: _caloriesController,
                  label: 'Kalorier forbrændt (valgfrit)',
                  hint: 'f.eks. 250',
                  icon: MdiIcons.fire,
                  keyboardType: TextInputType.number,
                ),
                
                SizedBox(height: KSizes.margin4x),
                
                // Notes
                _buildTextField(
                  controller: _notesController,
                  label: 'Noter (valgfrit)',
                  hint: 'Eventuelle kommentarer...',
                  icon: MdiIcons.noteText,
                  maxLines: 3,
                ),
                
                SizedBox(height: KSizes.margin8x),
                
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.secondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusM),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          borderSide: BorderSide(color: AppColors.secondary, width: 2),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Kategori',
        prefixIcon: Icon(MdiIcons.tag, color: AppColors.secondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusM),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          borderSide: BorderSide(color: AppColors.secondary, width: 2),
        ),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
    );
  }

  Future<void> _saveActivity() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLogging = true;
      });

      try {
        final name = _nameController.text.trim();
        final duration = int.parse(_durationController.text.trim());
        final caloriesText = _caloriesController.text.trim();
        final notes = _notesController.text.trim();
        
        // Get user profile for weight calculation
        final userProfile = ref.read(onboardingProvider).userProfile;
        final activityNotifier = ref.read(activityNotifierProvider);
        
        // Calculate calories if not provided manually
        int estimatedCalories = 0;
        if (caloriesText.isNotEmpty) {
          estimatedCalories = int.parse(caloriesText);
        } else {
          // Use a simple estimation: 8 calories per minute for moderate activity
          estimatedCalories = (duration * 8).round();
        }

        // Create activity log with correct parameters
        final activityLog = UserActivityLogModel(
          logEntryId: DateTime.now().millisecondsSinceEpoch,
          userId: 1, // TODO: Use real user ID
          activityName: name,
          loggedAt: DateTime.now().toIso8601String(),
          inputType: ActivityInputType.varighed,
          durationMinutes: duration.toDouble(),
          distanceKm: 0.0,
          caloriesBurned: estimatedCalories,
          notes: notes.isNotEmpty ? notes : '',
          intensity: ActivityIntensity.moderat,
          isManualEntry: true,
          isCaloriesAdjusted: caloriesText.isNotEmpty, // True if user provided manual calories
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );

        // Log the activity using ActivityNotifier
        final success = await activityNotifier.logActivity(activityLog);
        
        if (success && mounted) {
          // Show success message and go back
          Navigator.of(context).pop(true); // Return true to indicate success
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$name registreret! ($duration min, $estimatedCalories kcal)'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (mounted) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kunne ikke registrere aktivitet'),
              backgroundColor: AppColors.error,
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