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
    final weightState = ref.watch(weightTrackingProvider);
    final latestWeight = ref.watch(latestWeightProvider);

    // Don't show if user doesn't have weight goal
    if (!userProfile.hasWeightGoal) {
      return const SizedBox.shrink();
    }

    if (weightState.isLoading) {
      return _buildLoadingCard();
    }

    return _buildWeightCard(context, ref, userProfile, latestWeight);
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 160,
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.08),
            blurRadius: KSizes.blurRadiusL,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.success,
        ),
      ),
    );
  }

  Widget _buildWeightCard(
    BuildContext context,
    WidgetRef ref,
    UserProfileModel userProfile,
    WeightEntryModel? latestWeight,
  ) {
    final currentWeight = latestWeight?.weightKg ?? userProfile.currentWeightKg;
    final targetWeight = userProfile.targetWeightKg;
    final startWeight = userProfile.currentWeightKg; // Original weight from profile
    
    final totalWeightToLose = (startWeight - targetWeight).abs();
    final weightLost = (startWeight - currentWeight).abs();
    final remainingWeight = (currentWeight - targetWeight).abs();
    
    final progress = totalWeightToLose > 0 ? (weightLost / totalWeightToLose) : 0.0;
    final displayProgress = progress.clamp(0.0, 1.0);
    
    final isWeightLoss = userProfile.isWeightLossGoal;
    final isOnTrack = isWeightLoss ? currentWeight <= targetWeight : currentWeight >= targetWeight;
    final hasReachedGoal = isOnTrack && (currentWeight - targetWeight).abs() < 0.5; // Within 0.5kg

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.08),
            blurRadius: KSizes.blurRadiusL,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success,
                      AppColors.success.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
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
                      'Vægt fremgang ⚖️',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      hasReachedGoal
                          ? 'Tillykke! Du har nået dit mål'
                          : isWeightLoss
                              ? '${remainingWeight.toStringAsFixed(1)} kg tilbage'
                              : '${remainingWeight.toStringAsFixed(1)} kg til målet',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        color: hasReachedGoal ? AppColors.success : AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showAddWeightDialog(context, ref),
                child: Container(
                  padding: const EdgeInsets.all(KSizes.margin2x),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(KSizes.radiusS),
                  ),
                  child: Icon(
                    MdiIcons.plus,
                    color: AppColors.success,
                    size: KSizes.iconS,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          // Progress section
          Row(
            children: [
              // Progress indicator
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Fremgang',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeM,
                            fontWeight: KSizes.fontWeightMedium,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${(displayProgress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeM,
                            fontWeight: KSizes.fontWeightBold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: KSizes.margin2x),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(KSizes.radiusS),
                      child: LinearProgressIndicator(
                        value: displayProgress,
                        minHeight: 8,
                        backgroundColor: AppColors.surface.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          hasReachedGoal
                              ? AppColors.success
                              : displayProgress >= 0.8
                                  ? AppColors.success
                                  : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: KSizes.margin6x),
              
              // Current weight display
              Column(
                children: [
                  Text(
                    '${currentWeight.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeXXL,
                      fontWeight: KSizes.fontWeightBold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'kg',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeM,
                      color: AppColors.textSecondary,
                      fontWeight: KSizes.fontWeightMedium,
                    ),
                  ),
                  if (latestWeight != null) ...[
                    const SizedBox(height: KSizes.margin1x),
                    Text(
                      latestWeight.formattedDate,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXS,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          
          const SizedBox(height: KSizes.margin4x),
          
          // Stats row
          Row(
            children: [
              Expanded(
                child: _WeightStatCard(
                  label: 'Start',
                  value: '${startWeight.toStringAsFixed(1)} kg',
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: KSizes.margin3x),
              Expanded(
                child: _WeightStatCard(
                  label: isWeightLoss ? 'Tabt' : 'Opnået',
                  value: '${weightLost.toStringAsFixed(1)} kg',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: KSizes.margin3x),
              Expanded(
                child: _WeightStatCard(
                  label: 'Mål',
                  value: '${targetWeight.toStringAsFixed(1)} kg',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
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
}

class _WeightStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _WeightStatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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