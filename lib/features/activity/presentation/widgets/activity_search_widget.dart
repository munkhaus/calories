import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/activity_notifier.dart';
import '../../domain/activity_item_model.dart';

/// Widget for searching activities
class ActivitySearchWidget extends StatefulWidget {
  final ActivityNotifier notifier;
  final void Function(ActivityItemModel) onActivitySelected;

  const ActivitySearchWidget({
    super.key,
    required this.notifier,
    required this.onActivitySelected,
  });

  @override
  State<ActivitySearchWidget> createState() => _ActivitySearchWidgetState();
}

class _ActivitySearchWidgetState extends State<ActivitySearchWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search field
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(KSizes.radiusM),
              border: Border.all(
                color: AppColors.border.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Søg efter aktiviteter...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: KSizes.fontSizeM,
                ),
                prefixIcon: Icon(
                  MdiIcons.magnify,
                  color: AppColors.textSecondary,
                  size: KSizes.iconM,
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _controller.clear();
                          widget.notifier.clearSearch();
                          _focusNode.unfocus();
                        },
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.textSecondary,
                          size: KSizes.iconM,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: KSizes.margin4x,
                  vertical: KSizes.margin3x,
                ),
              ),
              onChanged: (query) {
                setState(() {});
                widget.notifier.searchActivities(query);
              },
            ),
          ),

          // Search results
          AnimatedBuilder(
            animation: widget.notifier,
            builder: (context, child) {
              final state = widget.notifier.state;
              
              if (state.searchQuery.isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: KSizes.margin2x),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: KSizes.blurRadiusM,
                      offset: KSizes.shadowOffsetS,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.isSearching)
                      Padding(
                        padding: EdgeInsets.all(KSizes.margin4x),
                        child: Row(
                          children: [
                            SizedBox(
                              width: KSizes.iconS,
                              height: KSizes.iconS,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            ),
                            SizedBox(width: KSizes.margin2x),
                            Text(
                              'Søger...',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: KSizes.fontSizeS,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (state.searchResultsState.hasError)
                      Padding(
                        padding: EdgeInsets.all(KSizes.margin4x),
                        child: Row(
                          children: [
                            Icon(
                              MdiIcons.alertCircle,
                              color: AppColors.error,
                              size: KSizes.iconS,
                            ),
                            SizedBox(width: KSizes.margin2x),
                            Text(
                              'Fejl ved søgning',
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: KSizes.fontSizeS,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (state.searchResults.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(KSizes.margin4x),
                        child: Text(
                          'Ingen aktiviteter fundet',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: KSizes.fontSizeS,
                          ),
                        ),
                      )
                    else
                      ...state.searchResults.map((activity) => _buildActivityItem(activity)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(ActivityItemModel activity) {
    return InkWell(
      onTap: () {
        widget.onActivitySelected(activity);
        _controller.clear();
        widget.notifier.clearSearch();
        _focusNode.unfocus();
      },
      child: Container(
        padding: EdgeInsets.all(KSizes.margin4x),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.border.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: KSizes.iconL,
              height: KSizes.iconL,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(KSizes.radiusS),
              ),
              child: Icon(
                _getActivityIcon(activity.iconName),
                color: AppColors.primary,
                size: KSizes.iconM,
              ),
            ),

            SizedBox(width: KSizes.margin3x),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: KSizes.fontWeightMedium,
                    ),
                  ),
                  
                  if (activity.description.isNotEmpty)
                    Text(
                      activity.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
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