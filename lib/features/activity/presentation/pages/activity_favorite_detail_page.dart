import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/favorite_activity_model.dart';
import '../../domain/user_activity_log_model.dart';
import '../../infrastructure/favorite_activity_service.dart';

/// Detailed page for creating and editing activity favorites
class ActivityFavoriteDetailPage extends ConsumerStatefulWidget {
  final FavoriteActivityModel? existingFavorite;
  
  const ActivityFavoriteDetailPage({
    super.key,
    this.existingFavorite,
  });

  @override
  ConsumerState<ActivityFavoriteDetailPage> createState() => _ActivityFavoriteDetailPageState();
}

class _ActivityFavoriteDetailPageState extends ConsumerState<ActivityFavoriteDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _distanceController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _notesController = TextEditingController();
  
  ActivityInputType _inputType = ActivityInputType.varighed;
  ActivityIntensity _intensity = ActivityIntensity.moderat;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.existingFavorite != null;
    
    if (_isEditing) {
      final favorite = widget.existingFavorite!;
      _nameController.text = favorite.activityName;
      _durationController.text = favorite.durationMinutes.toString();
      _distanceController.text = favorite.distanceKm.toString();
      _caloriesController.text = favorite.caloriesBurned.toString();
      _notesController.text = favorite.notes;
      _inputType = favorite.inputType;
      _intensity = favorite.intensity;
    } else {
      // Set defaults for new favorite
      _durationController.text = '30';
      _distanceController.text = '0';
      _caloriesController.text = '200';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _distanceController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Rediger Aktivitet Favorit' : 'Ny Aktivitet Favorit'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveFavorite,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                    ),
                  )
                : Text(
                    'Gem',
                    style: TextStyle(
                      color: AppColors.secondary,
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
                  _isEditing ? 'Rediger din aktivitets favorit' : 'Opret en ny aktivitets favorit',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeXL,
                    fontWeight: KSizes.fontWeightBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                SizedBox(height: KSizes.margin2x),
                
                Text(
                  'Indtast detaljerede oplysninger om din favorit aktivitet',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    color: AppColors.textSecondary,
                  ),
                ),
                
                SizedBox(height: KSizes.margin6x),
                
                // Activity name
                _buildTextField(
                  controller: _nameController,
                  label: 'Navn på aktivitet',
                  hint: 'f.eks. Morgenløb i parken',
                  icon: MdiIcons.runFast,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Indtast navn på aktivitet';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: KSizes.margin4x),
                
                // Input type dropdown
                _buildInputTypeDropdown(),
                
                SizedBox(height: KSizes.margin4x),
                
                // Duration and distance based on input type
                if (_inputType == ActivityInputType.varighed) ...[
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
                      if (double.tryParse(value) == null) {
                        return 'Indtast et gyldigt tal';
                      }
                      return null;
                    },
                  ),
                ] else ...[
                  _buildTextField(
                    controller: _distanceController,
                    label: 'Distance (km)',
                    hint: 'f.eks. 5.2',
                    icon: MdiIcons.mapMarkerDistance,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Indtast distance';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Indtast et gyldigt tal';
                      }
                      return null;
                    },
                  ),
                ],
                
                SizedBox(height: KSizes.margin4x),
                
                // Intensity dropdown
                _buildIntensityDropdown(),
                
                SizedBox(height: KSizes.margin4x),
                
                // Calories
                _buildTextField(
                  controller: _caloriesController,
                  label: 'Kalorier forbrændt',
                  hint: 'f.eks. 250',
                  icon: MdiIcons.fire,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Indtast kalorier';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Indtast et gyldigt tal';
                    }
                    return null;
                  },
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
                    onPressed: _isLoading ? null : _saveFavorite,
                    icon: _isLoading 
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(_isEditing ? MdiIcons.check : MdiIcons.plus),
                    label: Text(_isLoading 
                        ? 'Gemmer...' 
                        : _isEditing ? 'Opdater Favorit' : 'Opret Favorit'),
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

  Widget _buildInputTypeDropdown() {
    return DropdownButtonFormField<ActivityInputType>(
      value: _inputType,
      decoration: InputDecoration(
        labelText: 'Type aktivitet',
        prefixIcon: Icon(MdiIcons.formatListBulleted, color: AppColors.secondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusM),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          borderSide: BorderSide(color: AppColors.secondary, width: 2),
        ),
      ),
      items: ActivityInputType.values.map((inputType) {
        return DropdownMenuItem(
          value: inputType,
          child: Text(_getInputTypeDisplayName(inputType)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _inputType = value!;
        });
      },
    );
  }

  Widget _buildIntensityDropdown() {
    return DropdownButtonFormField<ActivityIntensity>(
      value: _intensity,
      decoration: InputDecoration(
        labelText: 'Intensitet',
        prefixIcon: Icon(MdiIcons.speedometer, color: AppColors.secondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusM),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          borderSide: BorderSide(color: AppColors.secondary, width: 2),
        ),
      ),
      items: ActivityIntensity.values.map((intensity) {
        return DropdownMenuItem(
          value: intensity,
          child: Text(_getIntensityDisplayName(intensity)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _intensity = value!;
        });
      },
    );
  }

  String _getInputTypeDisplayName(ActivityInputType inputType) {
    switch (inputType) {
      case ActivityInputType.varighed:
        return 'Varighed (tid)';
      case ActivityInputType.distance:
        return 'Distance (km)';
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

  Future<void> _saveFavorite() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final name = _nameController.text.trim();
        final duration = double.tryParse(_durationController.text.trim()) ?? 0.0;
        final distance = double.tryParse(_distanceController.text.trim()) ?? 0.0;
        final calories = int.parse(_caloriesController.text.trim());
        final notes = _notesController.text.trim();

        final favoriteService = FavoriteActivityService();
        
        if (_isEditing) {
          // Update existing favorite
          final updatedFavorite = widget.existingFavorite!.copyWith(
            activityName: name,
            inputType: _inputType,
            durationMinutes: duration,
            distanceKm: distance,
            intensity: _intensity,
            caloriesBurned: calories,
            notes: notes,
          );
          
          final result = await favoriteService.updateFavorite(updatedFavorite);
          
          if (result.isSuccess && mounted) {
            Navigator.of(context).pop(true); // Return true to indicate success
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$name er opdateret i favoritter!'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kunne ikke opdatere favorit'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        } else {
          // Create new favorite
          final newFavorite = FavoriteActivityModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            activityName: name,
            inputType: _inputType,
            durationMinutes: duration,
            distanceKm: distance,
            intensity: _intensity,
            caloriesBurned: calories,
            notes: notes,
            usageCount: 0,
            lastUsed: DateTime.now(),
            createdAt: DateTime.now(),
          );
          
          final result = await favoriteService.addToFavorites(newFavorite);
          
          if (result.isSuccess && mounted) {
            Navigator.of(context).pop(true); // Return true to indicate success
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$name er tilføjet til favoritter!'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kunne ikke gemme favorit'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fejl ved gemning: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
} 