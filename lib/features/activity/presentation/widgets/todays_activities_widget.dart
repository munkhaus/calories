import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/activity_notifier.dart';
import '../../domain/user_activity_log_model.dart';

/// Widget displaying today's logged activities
class TodaysActivitiesWidget extends StatelessWidget {
  final ActivityNotifier notifier;
  final void Function(UserActivityLogModel) onDeleteActivity;

  const TodaysActivitiesWidget({
    super.key,
    required this.notifier,
    required this.onDeleteActivity,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: notifier,
      builder: (context, child) {
        final state = notifier.state;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with total calories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dagens aktivitet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: KSizes.fontWeightBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                if (state.todaysCaloriesState.isSuccess)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: KSizes.margin3x,
                      vertical: KSizes.margin1x,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(KSizes.radiusRound),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          MdiIcons.fire,
                          color: AppColors.secondary,
                          size: KSizes.iconS,
                        ),
                        SizedBox(width: KSizes.margin1x),
                        Text(
                          '${state.todaysCaloriesBurned} kcal',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: KSizes.fontSizeS,
                            fontWeight: KSizes.fontWeightMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: KSizes.margin4x),
            
            // Activities list
            if (state.isLoadingTodaysData)
              _buildLoadingState()
            else if (state.todaysActivitiesState.hasError)
              _buildErrorState(context)
            else if (state.todaysActivities.isEmpty)
              _buildEmptyState(context)
            else
              _buildActivitiesList(context, state.todaysActivities),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Card(
      elevation: KSizes.cardElevation,
      child: Container(
        padding: EdgeInsets.all(KSizes.margin6x),
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: KSizes.margin3x),
            Text(
              'Indlæser dagens aktiviteter...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: KSizes.fontSizeM,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Card(
      elevation: KSizes.cardElevation,
      child: Container(
        padding: EdgeInsets.all(KSizes.margin6x),
        child: Column(
          children: [
            Icon(
              MdiIcons.alertCircle,
              color: AppColors.error,
              size: KSizes.iconXL,
            ),
            SizedBox(height: KSizes.margin2x),
            Text(
              'Kunne ikke indlæse dagens aktiviteter',
              style: TextStyle(
                color: AppColors.error,
                fontSize: KSizes.fontSizeM,
                fontWeight: KSizes.fontWeightMedium,
              ),
            ),
            SizedBox(height: KSizes.margin3x),
            ElevatedButton(
              onPressed: () => notifier.loadTodaysActivities(),
              child: Text('Prøv igen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      elevation: KSizes.cardElevation,
      child: Container(
        padding: EdgeInsets.all(KSizes.margin6x),
        child: Column(
          children: [
            Icon(
              MdiIcons.runFast,
              color: AppColors.textSecondary,
              size: KSizes.iconXXL,
            ),
            SizedBox(height: KSizes.margin3x),
            Text(
              'Ingen aktiviteter i dag',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: KSizes.fontWeightMedium,
              ),
            ),
            SizedBox(height: KSizes.margin2x),
            Text(
              'Start med at logge din første aktivitet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesList(BuildContext context, List<UserActivityLogModel> activities) {
    return Column(
      children: activities.map((activity) => _buildActivityItem(context, activity)).toList(),
    );
  }

  Widget _buildActivityItem(BuildContext context, UserActivityLogModel activity) {
    return Card(
      elevation: KSizes.cardElevation,
      margin: EdgeInsets.only(bottom: KSizes.margin3x),
      child: InkWell(
        onTap: () => _showActivityDetails(context, activity),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        child: Padding(
          padding: EdgeInsets.all(KSizes.margin4x),
          child: Row(
            children: [
              // Activity icon
              Container(
                width: KSizes.iconXL,
                height: KSizes.iconXL,
                decoration: BoxDecoration(
                  color: activity.isManualEntry 
                      ? AppColors.secondary.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  activity.isManualEntry 
                      ? MdiIcons.fire
                      : _getActivityIcon(activity.activityName),
                  color: activity.isManualEntry 
                      ? AppColors.secondary
                      : AppColors.primary,
                  size: KSizes.iconL,
                ),
              ),
              
              SizedBox(width: KSizes.margin4x),
              
              // Activity details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.activityName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: KSizes.fontWeightMedium,
                      ),
                    ),
                    
                    SizedBox(height: KSizes.margin1x),
                    
                    Row(
                      children: [
                        if (!activity.isManualEntry && activity.primaryValue > 0) ...[
                          Icon(
                            activity.inputType == ActivityInputType.varighed 
                                ? MdiIcons.clock 
                                : MdiIcons.mapMarker,
                            color: AppColors.textSecondary,
                            size: KSizes.iconXS,
                          ),
                          SizedBox(width: KSizes.margin1x),
                          Text(
                            activity.inputType == ActivityInputType.varighed
                                ? activity.formattedDuration
                                : activity.formattedDistance,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: KSizes.margin3x),
                        ],
                        
                        Icon(
                          MdiIcons.fire,
                          color: AppColors.secondary,
                          size: KSizes.iconXS,
                        ),
                        SizedBox(width: KSizes.margin1x),
                        Text(
                          '${activity.caloriesBurned} kcal',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: KSizes.fontWeightMedium,
                          ),
                        ),
                        
                        if (activity.intensity != ActivityIntensity.moderat) ...[
                          SizedBox(width: KSizes.margin3x),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: KSizes.margin2x,
                              vertical: KSizes.margin1x / 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getIntensityColor(activity.intensity).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(KSizes.radiusS),
                            ),
                            child: Text(
                              activity.intensityDisplayName,
                              style: TextStyle(
                                color: _getIntensityColor(activity.intensity),
                                fontSize: KSizes.fontSizeXS,
                                fontWeight: KSizes.fontWeightMedium,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Delete button
              IconButton(
                onPressed: () => onDeleteActivity(activity),
                icon: Icon(
                  MdiIcons.deleteOutline,
                  color: AppColors.textSecondary,
                  size: KSizes.iconM,
                ),
              ),
            ],
          ),
        ),
      ),
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

  Color _getIntensityColor(ActivityIntensity intensity) {
    switch (intensity) {
      case ActivityIntensity.let:
        return AppColors.success;
      case ActivityIntensity.moderat:
        return AppColors.primary;
      case ActivityIntensity.haardt:
        return AppColors.error;
    }
  }
} 