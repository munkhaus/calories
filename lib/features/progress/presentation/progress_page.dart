import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../weight_tracking/application/weight_tracking_notifier.dart';
import '../../food_logging/application/food_logging_notifier.dart';
import '../../activity/application/activity_notifier.dart';
import '../../../features/dashboard/application/date_aware_providers.dart';

/// Enum for time period selection
enum TimePeriod {
  week('Uge'),
  month('Måned'),
  threeMonths('3 måneder');

  const TimePeriod(this.label);
  final String label;
}

/// Simplified progress page focusing on key metrics
class ProgressPage extends ConsumerStatefulWidget {
  const ProgressPage({super.key});

  @override
  ConsumerState<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends ConsumerState<ProgressPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  TimePeriod selectedPeriod = TimePeriod.week;
  DateTime selectedStartDate = DateTime.now().subtract(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataForPeriod();
    });
  }

  void _loadDataForPeriod() {
    // Load data for selected period
    ref.read(foodLoggingProvider.notifier).refresh();
    ref.read(weightTrackingProvider.notifier).refresh();
    ref.read(activityNotifierProvider).loadTodaysActivities();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final onboardingState = ref.watch(onboardingProvider);
    final userProfile = onboardingState.userProfile;
    final weightEntries = ref.watch(weightTrackingProvider).entries;
    
    // Calculate simple metrics
    final currentWeight = weightEntries.isNotEmpty ? weightEntries.first.weightKg : userProfile.currentWeightKg;
    final targetWeight = userProfile.targetWeightKg ?? currentWeight;
    final weightDiff = currentWeight - targetWeight;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              _loadDataForPeriod();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(KSizes.margin4x),
                child: Column(
                  children: [
                    // Header
                    StandardPageHeader(
                      title: 'Forløb',
                      subtitle: 'Din fremgang i tal',
                      icon: MdiIcons.trendingUp,
                      iconColor: AppColors.info,
                    ),
                    
                    KSizes.spacingVerticalXL,
                    
                    // Time period selector
                    _buildTimePeriodSelector(),
                    
                    KSizes.spacingVerticalXL,
                    
                    // Key metrics overview
                    _buildKeyMetricsCard(),
                    
                    KSizes.spacingVerticalXL,
                    
                    // Weight progress
                    _buildWeightProgressCard(currentWeight, targetWeight, weightDiff),
                    
                    KSizes.spacingVerticalXL,
                    
                    // Calorie summary
                    _buildCalorieSummaryCard(),
                    
                    KSizes.spacingVerticalXL,
                    
                    // Goal achievement status
                    _buildGoalAchievementCard(userProfile, currentWeight, targetWeight),
                    
                    // Bottom padding
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePeriodSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Text(
            'Tidsperiode',
            style: TextStyle(
              fontSize: KSizes.fontSizeXL,
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: KSizes.margin4x),
          
          // Period selection chips
          Row(
            children: TimePeriod.values.map((period) {
              final isSelected = selectedPeriod == period;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: period != TimePeriod.values.last ? KSizes.margin2x : 0),
                  child: ChoiceChip(
                    label: Text(period.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          selectedPeriod = period;
                          _updateDateRangeForPeriod(period);
                        });
                        _loadDataForPeriod();
                      }
                    },
                    backgroundColor: Colors.transparent,
                    selectedColor: AppColors.info.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.info : AppColors.textSecondary,
                      fontWeight: isSelected ? KSizes.fontWeightSemiBold : KSizes.fontWeightMedium,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.info : AppColors.textTertiary,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(KSizes.radiusM),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  MdiIcons.chartBoxOutline,
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
                      'Nøgletal',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Vigtigste metrics fra ${selectedPeriod.label.toLowerCase()}',
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
          
          // Metrics grid - simplified to 2x2
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: KSizes.margin3x,
            crossAxisSpacing: KSizes.margin3x,
            childAspectRatio: 1.2,
            children: [
              _buildMetricCard(
                'Gennemsnit',
                '1,850 kcal',
                'Daglig kalorie indtag',
                AppColors.primary,
                MdiIcons.fire,
              ),
              _buildMetricCard(
                'Aktivitet',
                '320 kcal',
                'Gennemsnit pr. dag',
                AppColors.secondary,
                MdiIcons.runFast,
              ),
              _buildMetricCard(
                'Målopfyldelse',
                '85%',
                'Af kaloriemål nået',
                AppColors.success,
                MdiIcons.target,
              ),
              _buildMetricCard(
                'Konsistens',
                '6/7 dage',
                'Med logging',
                AppColors.info,
                MdiIcons.checkAll,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightProgressCard(double currentWeight, double targetWeight, double weightDiff) {
    final isWeightGoal = targetWeight != currentWeight;
    final progressText = isWeightGoal 
        ? weightDiff > 0 
            ? '${weightDiff.abs().toStringAsFixed(1)} kg over mål'
            : '${weightDiff.abs().toStringAsFixed(1)} kg til mål'
        : 'Vedligeholder vægt';
        
    final progressColor = isWeightGoal
        ? weightDiff <= 0 ? AppColors.success : AppColors.warning
        : AppColors.info;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: progressColor.withOpacity(0.08),
            blurRadius: KSizes.blurRadiusL,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      progressColor,
                      progressColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: progressColor.withOpacity(0.3),
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
                      'Vægt fremgang',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      progressText,
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
          
          // Weight stats
          Row(
            children: [
              Expanded(
                child: _buildWeightStat(
                  'Nuværende',
                  '${currentWeight.toStringAsFixed(1)} kg',
                  AppColors.primary,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.border.withOpacity(0.3),
              ),
              Expanded(
                child: _buildWeightStat(
                  'Mål',
                  '${targetWeight.toStringAsFixed(1)} kg',
                  AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withOpacity(0.08),
            blurRadius: KSizes.blurRadiusL,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.warning,
                      AppColors.warning.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.warning.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  MdiIcons.fire,
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
                      'Kalorie oversigt',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Indtag vs. aktivitet i ${selectedPeriod.label.toLowerCase()}',
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
          
          // Calorie breakdown
          Row(
            children: [
              Expanded(
                child: _buildCalorieStat(
                  'Spist i snit',
                  '1,850 kcal',
                  'pr. dag',
                  AppColors.primary,
                  MdiIcons.silverwareForkKnife,
                ),
              ),
              const SizedBox(width: KSizes.margin3x),
              Expanded(
                child: _buildCalorieStat(
                  'Forbrændt',
                  '320 kcal',
                  'aktivitet pr. dag',
                  AppColors.secondary,
                  MdiIcons.runFast,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: KSizes.margin4x),
          
          // Net calorie balance
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(KSizes.margin3x),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(KSizes.radiusM),
              border: Border.all(
                color: AppColors.success.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  MdiIcons.calculator,
                  color: AppColors.success,
                  size: KSizes.iconM,
                ),
                const SizedBox(width: KSizes.margin2x),
                Text(
                  'Net balance: -150 kcal/dag i snit',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    fontWeight: KSizes.fontWeightSemiBold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalAchievementCard(dynamic userProfile, double currentWeight, double targetWeight) {
    final weightProgress = targetWeight != currentWeight 
        ? ((targetWeight - (currentWeight - targetWeight)).abs() / targetWeight * 100).clamp(0, 100)
        : 100.0;
    
    final calorieConsistency = 85.0; // Mock data - would calculate from actual logs
    final overallProgress = (weightProgress + calorieConsistency) / 2;
    
    final statusColor = overallProgress >= 80 
        ? AppColors.success 
        : overallProgress >= 60 
            ? AppColors.warning 
            : AppColors.error;
    
    final statusText = overallProgress >= 80 
        ? 'Fantastisk fremgang!' 
        : overallProgress >= 60 
            ? 'God fremgang' 
            : 'Fokuser på konsistens';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.08),
            blurRadius: KSizes.blurRadiusL,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor,
                      statusColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  MdiIcons.trophy,
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
                      'Målopfyldelse',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        color: statusColor,
                        fontWeight: KSizes.fontWeightSemiBold,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          // Progress indicators
          Column(
            children: [
              _buildProgressIndicator(
                'Kalorie konsistens',
                calorieConsistency,
                AppColors.primary,
              ),
              const SizedBox(height: KSizes.margin3x),
              _buildProgressIndicator(
                'Vægtmål fremgang',
                weightProgress.toDouble(),
                AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(KSizes.margin3x),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: KSizes.iconM,
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: KSizes.fontSizeS,
                  color: AppColors.textSecondary,
                  fontWeight: KSizes.fontWeightMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: KSizes.margin2x),
          Text(
            value,
            style: TextStyle(
              fontSize: KSizes.fontSizeL,
              fontWeight: KSizes.fontWeightBold,
              color: color,
            ),
          ),
          const SizedBox(height: KSizes.margin1x),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: KSizes.fontSizeXS,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: KSizes.fontSizeS,
            color: AppColors.textSecondary,
            fontWeight: KSizes.fontWeightMedium,
          ),
        ),
        const SizedBox(height: KSizes.margin1x),
        Text(
          value,
          style: TextStyle(
            fontSize: KSizes.fontSizeXL,
            fontWeight: KSizes.fontWeightBold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCalorieStat(String label, String value, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(KSizes.margin3x),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: KSizes.iconM,
          ),
          const SizedBox(height: KSizes.margin2x),
          Text(
            label,
            style: TextStyle(
              fontSize: KSizes.fontSizeS,
              color: AppColors.textSecondary,
              fontWeight: KSizes.fontWeightMedium,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: KSizes.margin1x),
          Text(
            value,
            style: TextStyle(
              fontSize: KSizes.fontSizeL,
              fontWeight: KSizes.fontWeightBold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: KSizes.fontSizeXS,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String label, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: KSizes.fontSizeM,
                fontWeight: KSizes.fontWeightMedium,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${progress.toInt()}%',
              style: TextStyle(
                fontSize: KSizes.fontSizeM,
                fontWeight: KSizes.fontWeightBold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: KSizes.margin2x),
        LinearProgressIndicator(
          value: progress / 100,
          backgroundColor: AppColors.surface.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
        ),
      ],
    );
  }

  void _updateDateRangeForPeriod(TimePeriod period) {
    final now = DateTime.now();
    switch (period) {
      case TimePeriod.week:
        selectedStartDate = now.subtract(const Duration(days: 7));
        break;
      case TimePeriod.month:
        selectedStartDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case TimePeriod.threeMonths:
        selectedStartDate = DateTime(now.year, now.month - 3, now.day);
        break;
    }
  }
} 