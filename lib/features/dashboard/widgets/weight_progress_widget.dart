import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../onboarding/domain/user_profile_model.dart';
import '../../weight_tracking/application/weight_tracking_notifier.dart';
import '../../weight_tracking/domain/weight_entry_model.dart';

/// Widget der viser vægt fremgang mod mål
class WeightProgressWidget extends ConsumerWidget {
  const WeightProgressWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final userProfile = onboardingState.userProfile;
    
    // Check if user has weight goal
    if (userProfile.targetWeightKg <= 0) {
      return const SizedBox.shrink();
    }
    
    final weightEntries = ref.watch(weightEntriesProvider);
    final currentWeight = userProfile.currentWeightKg;
    final targetWeight = userProfile.targetWeightKg;
    
    // Get latest weight entry if available
    final latestEntry = weightEntries.isNotEmpty ? weightEntries.first : null;
    final displayWeight = latestEntry?.weightKg ?? currentWeight;
    
    // Calculate progress
    final isWeightLoss = currentWeight > targetWeight;
    final totalWeightToChange = (currentWeight - targetWeight).abs();
    final weightChanged = (currentWeight - displayWeight).abs();
    final progress = totalWeightToChange > 0 ? (weightChanged / totalWeightToChange).clamp(0.0, 1.0) : 0.0;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.08),
            blurRadius: KSizes.blurRadiusXL,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin6x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern header
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary,
                        AppColors.info,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.3),
                        blurRadius: KSizes.blurRadiusL,
                        offset: KSizes.shadowOffsetM,
                      ),
                    ],
                  ),
                  child: Icon(
                    MdiIcons.scale,
                    color: Colors.white,
                    size: KSizes.iconL,
                  ),
                ),
                
                const SizedBox(width: KSizes.margin4x),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vægt forløb',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeXXL,
                          fontWeight: KSizes.fontWeightBold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: KSizes.margin1x),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KSizes.margin3x,
                          vertical: KSizes.margin1x,
                        ),
                        decoration: BoxDecoration(
                          color: _getProgressColor(progress).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(KSizes.radiusL),
                          border: Border.all(
                            color: _getProgressColor(progress).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${(progress * 100).toInt()}% af målet',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeS,
                            color: _getProgressColor(progress),
                            fontWeight: KSizes.fontWeightSemiBold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: KSizes.margin8x),
            
            // Progress visualization
            Container(
              padding: const EdgeInsets.all(KSizes.margin4x),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getProgressColor(progress).withOpacity(0.05),
                    _getProgressColor(progress).withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(KSizes.radiusL),
                border: Border.all(
                  color: _getProgressColor(progress).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Current vs target display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildWeightDisplay(
                        label: 'Nuværende',
                        weight: displayWeight,
                        color: AppColors.textPrimary,
                        isMain: true,
                      ),
                      Icon(
                        isWeightLoss ? MdiIcons.trendingDown : MdiIcons.trendingUp,
                        color: _getProgressColor(progress),
                        size: KSizes.iconL,
                      ),
                      _buildWeightDisplay(
                        label: 'Mål',
                        weight: targetWeight,
                        color: AppColors.secondary,
                        isMain: false,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: KSizes.margin6x),
                  
                  // Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Fremgang',
                            style: TextStyle(
                              fontSize: KSizes.fontSizeS,
                              color: AppColors.textSecondary,
                              fontWeight: KSizes.fontWeightMedium,
                            ),
                          ),
                          Text(
                            '${weightChanged.toStringAsFixed(1)} kg af ${totalWeightToChange.toStringAsFixed(1)} kg',
                            style: TextStyle(
                              fontSize: KSizes.fontSizeS,
                              color: _getProgressColor(progress),
                              fontWeight: KSizes.fontWeightSemiBold,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: KSizes.margin2x),
                      
                      ClipRRect(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.surface.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(progress),
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: KSizes.margin6x),
            
            // Stats row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    label: 'Tilbage',
                    value: '${(totalWeightToChange - weightChanged).toStringAsFixed(1)} kg',
                    icon: MdiIcons.target,
                    color: AppColors.info,
                  ),
                ),
                SizedBox(width: KSizes.margin4x),
                Expanded(
                  child: _buildStatCard(
                    label: 'Ændring',
                    value: '${isWeightLoss ? '-' : '+'}${weightChanged.toStringAsFixed(1)} kg',
                    icon: isWeightLoss ? MdiIcons.trendingDown : MdiIcons.trendingUp,
                    color: _getProgressColor(progress),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWeightDialog(BuildContext context, WidgetRef ref) {
    final weightController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(MdiIcons.scale, color: AppColors.success),
              const SizedBox(width: KSizes.margin2x),
              Text('Registrer vægt'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Weight input
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Vægt (kg)',
                  hintText: 'f.eks. 75.5',
                  prefixIcon: Icon(MdiIcons.scale),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                  ),
                ),
              ),
              
              const SizedBox(height: KSizes.margin4x),
              
              // Date selector
              InkWell(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: AppColors.success,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Dato',
                    prefixIcon: Icon(MdiIcons.calendar),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KSizes.radiusM),
                    ),
                  ),
                  child: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                ),
              ),
              
              const SizedBox(height: KSizes.margin4x),
              
              // Notes input
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Noter (valgfrit)',
                  hintText: 'Eventuelle kommentarer...',
                  prefixIcon: Icon(MdiIcons.noteText),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuller'),
            ),
            ElevatedButton(
              onPressed: () async {
                final weightText = weightController.text.trim();
                if (weightText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Indtast venligst en vægt'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                
                final weight = double.tryParse(weightText);
                if (weight == null || weight <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Indtast venligst en gyldig vægt'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                
                final entry = WeightEntryModel(
                  userId: 1, // TODO: Get actual user ID
                  weightKg: weight,
                  recordedAt: selectedDate,
                  notes: notesController.text.trim(),
                );
                
                final success = await ref.read(weightTrackingProvider.notifier).addWeightEntry(entry);
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Vægt registreret!' : 'Fejl ved registrering'),
                      backgroundColor: success ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              child: Text('Gem'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.5) {
      return AppColors.success;
    } else {
      return AppColors.primary;
    }
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(KSizes.margin2x),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.success.withOpacity(0.1) : AppColors.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(KSizes.radiusS),
        ),
        child: Icon(
          icon,
          color: isPrimary ? AppColors.success : AppColors.secondary,
          size: KSizes.iconS,
        ),
      ),
    );
  }

  Widget _buildWeightDisplay({
    required String label,
    required double weight,
    required Color color,
    required bool isMain,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: KSizes.fontSizeM,
            color: color,
            fontWeight: KSizes.fontWeightMedium,
          ),
        ),
        Text(
          '${weight.toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: KSizes.fontSizeXXL,
            color: color,
            fontWeight: KSizes.fontWeightBold,
          ),
        ),
        Text(
          'kg',
          style: TextStyle(
            fontSize: KSizes.fontSizeM,
            color: color,
            fontWeight: KSizes.fontWeightMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(KSizes.margin3x),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: KSizes.iconS,
          ),
          const SizedBox(height: KSizes.margin1x),
          Text(
            value,
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              fontWeight: KSizes.fontWeightBold,
              color: color,
            ),
          ),
          const SizedBox(height: KSizes.margin1x),
          Text(
            label,
            style: TextStyle(
              fontSize: KSizes.fontSizeXS,
              color: AppColors.textSecondary,
              fontWeight: KSizes.fontWeightMedium,
            ),
          ),
        ],
      ),
    );
  }
} 