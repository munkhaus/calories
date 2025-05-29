import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/activity_notifier.dart';
import '../../domain/activity_item_model.dart';

/// Widget displaying common/popular activities
class CommonActivitiesWidget extends StatelessWidget {
  final ActivityNotifier notifier;
  final void Function(ActivityItemModel) onActivitySelected;

  const CommonActivitiesWidget({
    super.key,
    required this.notifier,
    required this.onActivitySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Almindelige aktiviteter',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: KSizes.fontWeightBold,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: KSizes.margin4x),
        
        AnimatedBuilder(
          animation: notifier,
          builder: (context, child) {
            final state = notifier.state;
            
            // Safety check to prevent layout issues during initialization
            if (state == null) {
              return _buildLoadingGrid();
            }
            
            if (state.isLoadingActivities) {
              return _buildLoadingGrid();
            }
            
            if (state.commonActivitiesState.hasError) {
              return _buildErrorState();
            }
            
            if (state.commonActivities.isEmpty) {
              return _buildEmptyState();
            }
            
            return _buildActivitiesGrid(state.commonActivities);
          },
        ),
      ],
    );
  }

  Widget _buildLoadingGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final crossAxisCount = availableWidth > 600 ? 3 : 2;
        final itemWidth = (availableWidth - (crossAxisCount - 1) * KSizes.margin3x) / crossAxisCount;
        final itemHeight = itemWidth * 0.8; // Same aspect ratio as main grid
        
        return SizedBox(
          height: 300, // Fixed reasonable height for loading state
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: KSizes.margin3x,
              mainAxisSpacing: KSizes.margin3x,
              childAspectRatio: itemWidth / itemHeight,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => _buildLoadingCard(),
          ),
        );
      },
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: KSizes.cardElevation,
      child: Container(
        padding: EdgeInsets.all(KSizes.margin4x),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(KSizes.radiusM),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: KSizes.iconXL,
              height: KSizes.iconXL,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(KSizes.radiusM),
              ),
              child: SizedBox(
                width: KSizes.iconS,
                height: KSizes.iconS,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
            SizedBox(height: KSizes.margin2x),
            Container(
              width: 60,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(KSizes.radiusS),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
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
              'Kunne ikke indlæse aktiviteter',
              style: TextStyle(
                color: AppColors.error,
                fontSize: KSizes.fontSizeM,
                fontWeight: KSizes.fontWeightMedium,
              ),
            ),
            SizedBox(height: KSizes.margin3x),
            ElevatedButton(
              onPressed: () => notifier.loadCommonActivities(),
              child: Text('Prøv igen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: KSizes.cardElevation,
      child: Container(
        padding: EdgeInsets.all(KSizes.margin6x),
        child: Column(
          children: [
            Icon(
              MdiIcons.runFast,
              color: AppColors.textSecondary,
              size: KSizes.iconXL,
            ),
            SizedBox(height: KSizes.margin2x),
            Text(
              'Ingen aktiviteter tilgængelige',
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

  Widget _buildActivitiesGrid(List<ActivityItemModel> activities) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final crossAxisCount = availableWidth > 600 ? 3 : 2;
        final itemWidth = (availableWidth - (crossAxisCount - 1) * KSizes.margin3x) / crossAxisCount;
        final itemHeight = itemWidth * 0.8; // Adjust aspect ratio
        
        return SizedBox(
          height: ((activities.length / crossAxisCount).ceil() * (itemHeight + KSizes.margin3x)).clamp(200.0, 400.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: KSizes.margin3x,
              mainAxisSpacing: KSizes.margin3x,
              childAspectRatio: itemWidth / itemHeight,
            ),
            itemCount: activities.length,
            itemBuilder: (context, index) => _buildActivityCard(context, activities[index]),
          ),
        );
      },
    );
  }

  Widget _buildActivityCard(BuildContext context, ActivityItemModel activity) {
    return Card(
      elevation: KSizes.cardElevation,
      child: InkWell(
        onTap: () => onActivitySelected(activity),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        child: Container(
          padding: EdgeInsets.all(KSizes.margin4x),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(KSizes.radiusM),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: KSizes.iconXL,
                height: KSizes.iconXL,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  _getActivityIcon(activity.iconName),
                  color: AppColors.primary,
                  size: KSizes.iconL,
                ),
              ),
              
              SizedBox(height: KSizes.margin2x),
              
              Text(
                activity.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: KSizes.fontWeightMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getActivityIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'walk':
        return MdiIcons.walk;
      case 'run':
        return MdiIcons.run;
      case 'bike':
        return MdiIcons.bike;
      case 'swim':
        return MdiIcons.swim;
      case 'dumbbell':
        return MdiIcons.dumbbell;
      case 'yoga':
        return MdiIcons.yoga;
      case 'tennis':
        return MdiIcons.tennis;
      case 'soccer':
        return MdiIcons.soccer;
      default:
        return MdiIcons.runFast;
    }
  }
} 