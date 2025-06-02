import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/activity_notifier.dart';
import '../../application/activity_state.dart';
import '../../domain/user_activity_log_model.dart';
import '../pages/edit_activity_page.dart';
import '../../../onboarding/domain/user_profile_model.dart';

/// Widget displaying today's logged activities with enhanced design
class TodaysActivitiesWidget extends StatelessWidget {
  final ActivityNotifier notifier;
  final void Function(UserActivityLogModel) onDeleteActivity;
  final ActivityTrackingPreference activityTrackingPreference;

  const TodaysActivitiesWidget({
    super.key,
    required this.notifier,
    required this.onDeleteActivity,
    required this.activityTrackingPreference,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: notifier,
      builder: (context, child) {
        final state = notifier.state;
        
        // Debug information
        print('🔍 TodaysActivitiesWidget - State: $state');
        if (state != null) {
          print('🔍 Loading: ${state.isLoadingTodaysData}');
          print('🔍 Activities: ${state.todaysActivities?.length ?? 0}');
          print('🔍 Error: ${state.todaysActivitiesState?.hasError}');
          if (state.todaysActivities != null) {
            for (final activity in state.todaysActivities!) {
              print('🔍 Activity: ${activity.activityName} - ${activity.caloriesBurned} kcal');
            }
          }
        }
        
        if (state == null || state.isLoadingTodaysData) {
          return _buildLoadingCard();
        }

        if (state.todaysActivitiesState?.hasError ?? false) {
          return _buildErrorCard(context);
        }

        final activities = state.todaysActivities ?? [];
        return _buildActivitiesCard(context, activities);
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 200,
      decoration: AppDesign.sectionDecoration,
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Container(
      decoration: AppDesign.sectionDecoration,
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin4x),
        child: Column(
          children: [
            Icon(
              MdiIcons.alertCircle,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: KSizes.margin3x),
            Text(
              'Fejl ved indlæsning af aktiviteter',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: KSizes.margin2x),
            ElevatedButton(
              onPressed: () => notifier.loadTodaysActivities(),
              child: Text('Prøv igen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesCard(BuildContext context, List<UserActivityLogModel> activities) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: Colors.white,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header matching the new design pattern
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
                  MdiIcons.runFast,
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
                      'Dagens aktiviteter 🏃‍♂️',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      activities.isEmpty 
                          ? 'Ingen aktiviteter endnu'
                          : '${activities.length} ${activities.length == 1 ? 'aktivitet' : 'aktiviteter'} logget',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          // Activities list
          if (activities.isEmpty)
            _buildEmptyState(context)
          else
            Column(
              children: [
                Column(
                  children: activities
                      .take(3) // Show only first 3 activities like meals widget
                      .map((activity) => _buildActivityCard(context, activity))
                      .toList(),
                ),
                
                const SizedBox(height: KSizes.margin3x),
                
                // Summary footer
                _buildSummaryFooter(context, activities),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KSizes.margin6x),
      child: Column(
        children: [
          Icon(
            MdiIcons.runFast,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: KSizes.margin3x),
          Text(
            'Ingen aktiviteter logget endnu',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: KSizes.margin1x),
          Text(
            'Gå til Aktivitet-fanen for at logge din første aktivitet!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: KSizes.margin4x),
        ],
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, UserActivityLogModel activity) {
    return Dismissible(
      key: Key('activity_${activity.logEntryId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: KSizes.margin3x),
        padding: const EdgeInsets.all(KSizes.margin3x),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(KSizes.radiusM),
        ),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              MdiIcons.delete,
              color: Colors.white,
              size: KSizes.iconM,
            ),
            const SizedBox(width: KSizes.margin2x),
            Text(
              'Slet',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmDialog(context, activity) ?? false;
      },
      onDismissed: (direction) {
        // Let the parent handle all UI feedback and refreshing
        onDeleteActivity(activity);
      },
      child: GestureDetector(
        onLongPress: () => _showActivityOptionsMenu(context, activity),
        child: Container(
          margin: const EdgeInsets.only(bottom: KSizes.margin3x),
          padding: const EdgeInsets.all(KSizes.margin3x),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(KSizes.radiusM),
            border: Border.all(
              color: AppColors.border.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Activity icon
              Container(
                padding: const EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  color: activity.isManualEntry 
                      ? AppColors.secondary.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                ),
                child: Icon(
                  activity.isManualEntry 
                      ? MdiIcons.fire
                      : _getActivityIcon(activity.activityName),
                  color: activity.isManualEntry 
                      ? AppColors.secondary
                      : AppColors.primary,
                  size: KSizes.iconS,
                ),
              ),
              
              const SizedBox(width: KSizes.margin3x),
              
              // Activity info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.activityName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: KSizes.fontWeightMedium,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (activity.isManualEntry)
                          Text(
                            'Manuel registrering',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          )
                        else if (activity.durationMinutes > 0) ...[
                          Text(
                            '${activity.durationMinutes.round()} min',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(color: AppColors.textTertiary),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            activity.intensityDisplayName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ] else
                          Text(
                            activity.intensityDisplayName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Calories
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${activity.caloriesBurned}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: KSizes.fontWeightBold,
                      color: AppColors.secondary,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: KSizes.margin2x),
              
              // Options button
              IconButton(
                onPressed: () => _showActivityOptionsMenu(context, activity),
                icon: Icon(
                  MdiIcons.dotsVertical,
                  color: AppColors.textTertiary,
                  size: KSizes.iconS,
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: KSizes.iconM,
                  minHeight: KSizes.iconM,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getActivityIcon(String activityName) {
    final name = activityName.toLowerCase();
    if (name.contains('løb')) return MdiIcons.run;
    if (name.contains('gå') || name.contains('tur')) return MdiIcons.walk;
    if (name.contains('cykel')) return MdiIcons.bike;
    if (name.contains('svøm')) return MdiIcons.swim;
    if (name.contains('styrke') || name.contains('vægt')) return MdiIcons.dumbbell;
    if (name.contains('yoga')) return MdiIcons.yoga;
    if (name.contains('tennis')) return MdiIcons.tennis;
    if (name.contains('fodbold')) return MdiIcons.soccer;
    return MdiIcons.runFast;
  }

  void _showActivityOptionsMenu(BuildContext context, UserActivityLogModel activity) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KSizes.radiusL)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(KSizes.margin4x),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Text(
                activity.activityName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: KSizes.margin4x),
              
              // View details option
              ListTile(
                leading: Icon(MdiIcons.informationOutline, color: AppColors.primary),
                title: Text('Se detaljer'),
                subtitle: Text('Vis komplette aktivitetsoplysninger'),
                onTap: () {
                  Navigator.pop(context);
                  _showActivityDetails(context, activity);
                },
              ),
              
              // Edit option  
              ListTile(
                leading: Icon(MdiIcons.pencil, color: AppColors.secondary),
                title: Text('Rediger aktivitet'),
                subtitle: Text('Ret aktivitetsoplysninger'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditActivityPage(
                        activity: activity,
                        notifier: notifier,
                      ),
                    ),
                  );
                },
              ),
              
              // Delete option  
              ListTile(
                leading: Icon(MdiIcons.delete, color: AppColors.error),
                title: Text('Slet aktivitet'),
                subtitle: Text('Fjern aktivitet fra dagens log'),
                onTap: () async {
                  try {
                    // Close the action sheet first
                    Navigator.pop(context);
                    
                    // Small delay to ensure the action sheet is fully closed
                    await Future.delayed(const Duration(milliseconds: 100));
                    
                    // Show delete confirmation with a fresh context check
                    if (!context.mounted) return;
                    
                    final shouldDelete = await _showDeleteConfirmDialog(context, activity);
                    
                    // Only delete if user confirmed
                    if (shouldDelete == true) {
                      // Let the parent handle all UI feedback and refreshing
                      onDeleteActivity(activity);
                    }
                  } catch (e) {
                    print('❌ Error in delete activity flow: $e');
                    // Don't try to show SnackBar here to avoid context issues
                  }
                },
              ),
              
              // Cancel
              const SizedBox(height: KSizes.margin2x),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Annuller'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showActivityDetails(BuildContext context, UserActivityLogModel activity) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KSizes.radiusL)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(KSizes.margin4x),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                activity.activityName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: KSizes.fontWeightBold,
                ),
              ),
              
              SizedBox(height: KSizes.margin4x),
              
              // Details
              if (!activity.isManualEntry) ...[
                _buildDetailRow(
                  context,
                  'Input type',
                  activity.inputTypeDisplayName,
                  MdiIcons.formatListBulleted,
                ),
                
                if (activity.inputType == ActivityInputType.varighed)
                  _buildDetailRow(
                    context,
                    'Varighed',
                    activity.formattedDuration,
                    MdiIcons.clock,
                  )
                else
                  _buildDetailRow(
                    context,
                    'Distance',
                    activity.formattedDistance,
                    MdiIcons.mapMarker,
                  ),
                
                _buildDetailRow(
                  context,
                  'Intensitet',
                  activity.intensityDisplayName,
                  MdiIcons.speedometer,
                ),
              ],
              
              _buildDetailRow(
                context,
                'Kalorier forbrændt',
                '${activity.caloriesBurned} kcal',
                MdiIcons.fire,
              ),
              
              if (activity.isCaloriesAdjusted)
                _buildDetailRow(
                  context,
                  'Status',
                  'Kalorier justeret',
                  MdiIcons.pencil,
                ),
              
              if (activity.notes.isNotEmpty)
                _buildDetailRow(
                  context,
                  'Noter',
                  activity.notes,
                  MdiIcons.noteText,
                ),
              
              SizedBox(height: KSizes.margin4x),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: KSizes.margin3x),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.textSecondary,
            size: KSizes.iconM,
          ),
          SizedBox(width: KSizes.margin3x),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: KSizes.fontWeightMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmDialog(BuildContext context, UserActivityLogModel activity) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Slet ${activity.activityName}?'),
          content: Text('Er du sikker på, at du vil slette denne aktivitet?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('Nej'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text('Ja'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryFooter(BuildContext context, List<UserActivityLogModel> activities) {
    final totalCaloriesBurned = activities.fold(0, (sum, activity) => sum + activity.caloriesBurned);
    
    return Container(
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                MdiIcons.fire,
                color: AppColors.secondary,
                size: KSizes.iconM,
              ),
              const SizedBox(width: KSizes.margin2x),
              Text(
                'Total forbrændt i dag',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: KSizes.fontWeightBold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            '$totalCaloriesBurned kcal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
} 