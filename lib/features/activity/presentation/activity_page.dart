import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../application/activity_notifier.dart';
import '../application/activity_calories_notifier.dart';
import '../domain/activity_item_model.dart';
import '../domain/user_activity_log_model.dart';
import 'widgets/activity_search_widget.dart';
import 'widgets/common_activities_widget.dart';
import 'widgets/todays_activities_widget.dart';

/// Main activity logging page with full functionality
class ActivityPage extends ConsumerStatefulWidget {
  const ActivityPage({super.key});

  @override
  ConsumerState<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends ConsumerState<ActivityPage> {
  late ActivityNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ActivityNotifier(
      onActivityChanged: () {
        // Refresh activity calories when activities are logged
        if (mounted) {
          refreshActivityCalories(ref);
        }
      },
    );
    // Initialize data after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      await _notifier.initialize();
    } catch (e) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kunne ikke indlæse aktivitetsdata'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Log aktivitet',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: KSizes.fontWeightBold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(KSizes.margin4x),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Activity search widget with error handling
              ActivitySearchWidget(
                notifier: _notifier,
                onActivitySelected: _onActivitySelected,
              ),
              
              SizedBox(height: KSizes.margin4x),
              
              // Expanded scrollable content
              Expanded(
                child: ListView(
                  children: [
                    // Common activities section with error handling
                    CommonActivitiesWidget(
                      notifier: _notifier,
                      onActivitySelected: _onActivitySelected,
                    ),
                    
                    SizedBox(height: KSizes.margin6x),
                    
                    // Manual entry options
                    _buildManualEntrySection(),
                    
                    SizedBox(height: KSizes.margin6x),
                    
                    // Today's activities with error handling
                    TodaysActivitiesWidget(
                      notifier: _notifier,
                      onDeleteActivity: _onDeleteActivity,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualEntrySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manuel registrering',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: KSizes.fontWeightBold,
            color: AppColors.textPrimary,
          ),
        ),
        
        SizedBox(height: KSizes.margin4x),
        
        // Manual activity registration
        Card(
          elevation: KSizes.cardElevation,
          child: InkWell(
            onTap: _onManualActivityTap,
            borderRadius: BorderRadius.circular(KSizes.radiusM),
            child: Padding(
              padding: EdgeInsets.all(KSizes.margin4x),
              child: Row(
                children: [
                  Container(
                    width: KSizes.iconXL,
                    height: KSizes.iconXL,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(KSizes.radiusM),
                    ),
                    child: Icon(
                      MdiIcons.pencilPlus,
                      color: AppColors.primary,
                      size: KSizes.iconL,
                    ),
                  ),
                  
                  SizedBox(width: KSizes.margin4x),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manuel registrering af aktivitet',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: KSizes.fontWeightMedium,
                          ),
                        ),
                        
                        Text(
                          'Opret din egen aktivitet',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textSecondary,
                    size: KSizes.iconS,
                  ),
                ],
              ),
            ),
          ),
        ),
        
        SizedBox(height: KSizes.margin4x),
        
        // Quick manual calorie entry
        _buildQuickCalorieEntry(),
      ],
    );
  }

  Widget _buildQuickCalorieEntry() {
    final TextEditingController calorieController = TextEditingController();
    
    return Card(
      elevation: KSizes.cardElevation,
      child: Padding(
        padding: EdgeInsets.all(KSizes.margin4x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  MdiIcons.fire,
                  color: AppColors.secondary,
                  size: KSizes.iconM,
                ),
                SizedBox(width: KSizes.margin2x),
                Text(
                  'Hurtig kalore-log',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: KSizes.margin3x),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: calorieController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Kalorier',
                      suffixText: 'kcal',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusM),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: KSizes.margin3x,
                        vertical: KSizes.margin2x,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: KSizes.margin3x),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _logQuickCalories(calorieController),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(KSizes.radiusM),
                        ),
                      ),
                      child: const Text('Log'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logQuickCalories(TextEditingController calorieController) async {
    final calories = double.tryParse(calorieController.text);
    if (calories != null && calories > 0) {
      final activity = UserActivityLogModel(
        logEntryId: DateTime.now().millisecondsSinceEpoch,
        userId: 1, // TODO: Get real user ID from user session
        activityName: 'Manuel kalorier',
        caloriesBurned: calories.round(),
        durationMinutes: 0,
        loggedAt: DateTime.now().toIso8601String(),
        inputType: ActivityInputType.varighed,
        intensity: ActivityIntensity.moderat,
        isManualEntry: true,
      );

      final success = await _notifier.logActivity(activity);
      
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success 
                  ? '${calories.round()} kalorier logget!'
                  : 'Kunne ikke logge kalorier'
                ),
                backgroundColor: success ? AppColors.success : AppColors.error,
              ),
            );
          }
        });
      }
      
      // Clear the controller after successful logging
      if (success) {
        calorieController.clear();
      }
    }
  }

  void _onActivitySelected(ActivityItemModel activity) {
    _showActivityDialog(activity);
  }

  Future<void> _showActivityDialog(ActivityItemModel activity) async {
    final TextEditingController durationController = TextEditingController();
    final TextEditingController caloriesController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log ${activity.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Varighed',
                  suffixText: 'min',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                  ),
                ),
              ),
              SizedBox(height: KSizes.margin3x),
              TextField(
                controller: caloriesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Kalorier (valgfri)',
                  suffixText: 'kcal',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuller'),
          ),
          ElevatedButton(
            onPressed: () async {
              final duration = double.tryParse(durationController.text);
              if (duration != null && duration > 0) {
                await _logActivity(activity, duration, caloriesController.text);
                if (mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log'),
          ),
        ],
      ),
    );
  }

  Future<void> _logActivity(ActivityItemModel activity, double duration, String calories) async {
    final logEntry = UserActivityLogModel(
      logEntryId: DateTime.now().millisecondsSinceEpoch,
      userId: 1, // TODO: Get real user ID from user session
      activityName: activity.name,
      caloriesBurned: double.tryParse(calories)?.round() ?? 0,
      durationMinutes: duration,
      loggedAt: DateTime.now().toIso8601String(),
      inputType: ActivityInputType.varighed,
      intensity: ActivityIntensity.moderat,
      isManualEntry: false,
    );

    final success = await _notifier.logActivity(logEntry);
    
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success 
                ? '${activity.name} logget! ${double.tryParse(calories)?.round() ?? 0} kcal forbrændt'
                : 'Kunne ikke logge aktivitet'
              ),
              backgroundColor: success ? AppColors.success : AppColors.error,
            ),
          );
        }
      });
    }
  }

  void _onManualActivityTap() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Manuel aktivitetsoprettelse kommer snart'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      });
    }
  }

  void _onDeleteActivity(UserActivityLogModel activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Slet aktivitet'),
        content: Text('Er du sikker på, at du vil slette "${activity.activityName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuller'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await _notifier.deleteActivity(activity.logEntryId);
              
              if (mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success 
                          ? 'Aktivitet slettet' 
                          : 'Kunne ikke slette aktivitet'
                        ),
                        backgroundColor: success ? AppColors.success : AppColors.error,
                      ),
                    );
                  }
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Slet'),
          ),
        ],
      ),
    );
  }
} 