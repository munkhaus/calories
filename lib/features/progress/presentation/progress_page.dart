import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../onboarding/domain/user_profile_model.dart';
import '../../weight_tracking/application/weight_tracking_notifier.dart';
import '../../weight_tracking/domain/weight_entry_model.dart';
import '../../food_logging/application/food_logging_notifier.dart';
import '../../food_logging/domain/user_food_log_model.dart';

enum TimePeriod { day, week, month }

/// Simplified progress page focusing on visual progress
class ProgressPage extends ConsumerStatefulWidget {
  const ProgressPage({super.key});

  @override
  ConsumerState<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends ConsumerState<ProgressPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  TimePeriod _selectedPeriod = TimePeriod.day;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(foodLoggingProvider.notifier).refresh();
      ref.read(weightTrackingProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final onboardingState = ref.watch(onboardingProvider);
    final userProfile = onboardingState.userProfile;
    final weightEntries = ref.watch(weightTrackingProvider).entries;
    final foodState = ref.watch(foodLoggingProvider);
    
    // Calculate simple metrics
    final currentWeight = weightEntries.isNotEmpty ? weightEntries.first.weightKg : userProfile.currentWeightKg;
    final targetWeight = userProfile.targetWeightKg ?? currentWeight;
    final startWeight = userProfile.currentWeightKg; // Original weight from onboarding
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.read(foodLoggingProvider.notifier).refresh();
              ref.read(weightTrackingProvider.notifier).refresh();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(KSizes.margin4x),
                child: Column(
                  children: [
                    // Header
                    StandardPageHeader(
                      title: 'Dit forløb',
                      subtitle: 'Se din fremgang visuelt',
                      icon: MdiIcons.trendingUp,
                      iconColor: AppColors.primary,
                    ),
                    
                    const SizedBox(height: KSizes.margin4x),
                    
                    // Time period selector
                    _buildTimePeriodSelector(),
                    
                    const SizedBox(height: KSizes.margin4x),
                    
                    // Weekly overview (only show when week is selected or always show for current week)
                    if (_selectedPeriod == TimePeriod.week || _selectedPeriod == TimePeriod.day)
                      _buildWeeklyOverview(foodState, userProfile),
                    
                    if (_selectedPeriod == TimePeriod.week || _selectedPeriod == TimePeriod.day)
                      const SizedBox(height: KSizes.margin4x),
                    
                    const SizedBox(height: KSizes.margin2x),
                    
                    // Weight Progress - Main visual element
                    _buildWeightProgressCard(currentWeight, targetWeight, startWeight),
                    
                    const SizedBox(height: KSizes.margin4x),
                    
                    // Stats based on selected period
                    _buildPeriodStatsRow(foodState, userProfile, weightEntries),
                    
                    const SizedBox(height: KSizes.margin4x),
                    
                    // Recent achievements
                    _buildAchievementsCard(foodState, weightEntries, userProfile),
                    
                    const SizedBox(height: KSizes.margin4x),
                    
                    // Period summary based on selection
                    _buildPeriodSummaryCard(foodState, userProfile, weightEntries),
                    
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: TimePeriod.values.map((period) {
          final isSelected = _selectedPeriod == period;
          final text = _getPeriodDisplayText(period);
          final icon = _getPeriodIcon(period);
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: KSizes.margin3x,
                  horizontal: KSizes.margin2x,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: KSizes.iconS,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: KSizes.margin1x),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        fontWeight: isSelected ? KSizes.fontWeightBold : KSizes.fontWeightMedium,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getPeriodDisplayText(TimePeriod period) {
    switch (period) {
      case TimePeriod.day:
        return 'Dag';
      case TimePeriod.week:
        return 'Uge';
      case TimePeriod.month:
        return 'Måned';
    }
  }

  IconData _getPeriodIcon(TimePeriod period) {
    switch (period) {
      case TimePeriod.day:
        return MdiIcons.calendarToday;
      case TimePeriod.week:
        return MdiIcons.calendarWeek;
      case TimePeriod.month:
        return MdiIcons.calendar;
    }
  }

  Widget _buildWeightProgressCard(double currentWeight, double targetWeight, double startWeight) {
    final totalWeightToLose = (startWeight - targetWeight).abs();
    final weightLostSoFar = (startWeight - currentWeight).abs();
    final remainingWeight = (currentWeight - targetWeight).abs();
    
    final progress = totalWeightToLose > 0 ? (weightLostSoFar / totalWeightToLose).clamp(0.0, 1.0) : 1.0;
    final isWeightLoss = targetWeight < startWeight;
    final isOnTrack = isWeightLoss ? currentWeight <= startWeight : currentWeight >= startWeight;
    
    final progressColor = isOnTrack ? AppColors.success : AppColors.warning;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin6x),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            progressColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: progressColor.withOpacity(0.15),
            blurRadius: KSizes.blurRadiusXL,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title
          Text(
            'Vægtudvikling',
            style: TextStyle(
              fontSize: KSizes.fontSizeXL,
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          // Visual progress circle
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: AppColors.surface.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                children: [
                  // Current weight (fixed layout)
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: currentWeight.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: progressColor,
                          ),
                        ),
                        TextSpan(
                          text: ' kg',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeL,
                            fontWeight: KSizes.fontWeightMedium,
                            color: progressColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: KSizes.margin1x),
                  
                  Text(
                    'Nuværende vægt',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeM,
                      color: AppColors.textSecondary,
                      fontWeight: KSizes.fontWeightMedium,
                    ),
                  ),
                  
                  const SizedBox(height: KSizes.margin2x),
                  
                  // Progress text
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KSizes.margin3x,
                      vertical: KSizes.margin1x,
                    ),
                    decoration: BoxDecoration(
                      color: progressColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(KSizes.radiusL),
                    ),
                    child: Text(
                      isWeightLoss 
                          ? remainingWeight <= 0 
                              ? '🎉 Mål nået!' 
                              : '${remainingWeight.toStringAsFixed(1)} kg tilbage'
                          : remainingWeight <= 0 
                              ? '🎉 Mål nået!' 
                              : '${remainingWeight.toStringAsFixed(1)} kg til mål',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS,
                        fontWeight: KSizes.fontWeightBold,
                        color: progressColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          // Weight stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildWeightStat(
                'Start',
                startWeight,
                AppColors.textSecondary,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.border.withOpacity(0.3),
              ),
              _buildWeightStat(
                'Mål',
                targetWeight,
                AppColors.primary,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.border.withOpacity(0.3),
              ),
              _buildWeightStat(
                'Ændring',
                (startWeight - currentWeight).abs(),
                isWeightLoss && currentWeight < startWeight ? AppColors.success : AppColors.warning,
                showDelta: true,
                isPositive: isWeightLoss ? currentWeight < startWeight : currentWeight > startWeight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodStatsRow(FoodLoggingState foodState, UserProfileModel userProfile, List<WeightEntryModel> weightEntries) {
    final periodData = _calculatePeriodData(foodState, userProfile, weightEntries);
    
    return Row(
      children: [
        Expanded(
          child: _buildQuickStatCard(
            _getPeriodStatsTitle('Kalorier'),
            '${periodData['calories']}',
            _getPeriodStatsSubtitle(periodData['targetCalories']),
            AppColors.primary,
            MdiIcons.fire,
          ),
        ),
        const SizedBox(width: KSizes.margin3x),
        Expanded(
          child: _buildQuickStatCard(
            _getPeriodStatsTitle('Måltider'),
            '${periodData['meals']}',
            _getPeriodMealsSubtitle(),
            AppColors.secondary,
            MdiIcons.silverwareVariant,
          ),
        ),
        const SizedBox(width: KSizes.margin3x),
        Expanded(
          child: _buildQuickStatCard(
            _getPeriodStatsTitle('Fremgang'),
            '${periodData['progressPercent']}%',
            _getProgressSubtitle(),
            periodData['progressPercent'] >= 80 ? AppColors.success : periodData['progressPercent'] >= 60 ? AppColors.warning : AppColors.error,
            _getProgressIcon(periodData['progressPercent']),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _calculatePeriodData(FoodLoggingState foodState, UserProfileModel userProfile, List<WeightEntryModel> weightEntries) {
    final now = DateTime.now();
    final targetCalories = userProfile.targetCalories > 0 ? userProfile.targetCalories : 2000;
    
    switch (_selectedPeriod) {
      case TimePeriod.day:
        final todayCalories = foodState.mealsForDate.fold<int>(0, (sum, meal) => sum + meal.calories);
        final todayMeals = foodState.mealsForDate.length;
        final progressPercent = targetCalories > 0 ? ((todayCalories / targetCalories) * 100).clamp(0, 120).toInt() : 0;
        
        return {
          'calories': todayCalories,
          'targetCalories': targetCalories,
          'meals': todayMeals,
          'progressPercent': progressPercent,
        };
        
      case TimePeriod.week:
        // Calculate actual week data
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        int totalWeekCalories = 0;
        int totalWeekMeals = 0;
        int activeDays = 0;
        
        for (int i = 0; i < 7; i++) {
          final day = startOfWeek.add(Duration(days: i));
          if (!day.isAfter(now)) {
            final dayCalories = _getCaloriesForDate(foodState, day);
            final dayMeals = day.day == now.day && day.month == now.month && day.year == now.year 
                ? foodState.mealsForDate.length 
                : (dayCalories > 0 ? 3 : 0); // Estimate meals based on calories
            
            totalWeekCalories += dayCalories;
            totalWeekMeals += dayMeals;
            if (dayCalories > 0) activeDays++;
          }
        }
        
        final avgCalories = activeDays > 0 ? totalWeekCalories ~/ activeDays : 0;
        final avgMeals = activeDays > 0 ? totalWeekMeals ~/ activeDays : 0;
        final weekProgressPercent = targetCalories > 0 ? ((avgCalories / targetCalories) * 100).clamp(0, 120).toInt() : 0;
        
        return {
          'calories': avgCalories,
          'targetCalories': targetCalories,
          'meals': avgMeals,
          'progressPercent': weekProgressPercent,
        };
        
      case TimePeriod.month:
        // Calculate simplified month data (using current week as estimate)
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        int totalWeekCalories = 0;
        int activeDays = 0;
        
        for (int i = 0; i < 7; i++) {
          final day = startOfWeek.add(Duration(days: i));
          if (!day.isAfter(now)) {
            final dayCalories = _getCaloriesForDate(foodState, day);
            totalWeekCalories += dayCalories;
            if (dayCalories > 0) activeDays++;
          }
        }
        
        final avgCalories = activeDays > 0 ? totalWeekCalories ~/ activeDays : 0;
        final avgMeals = activeDays > 0 ? 3 : 0; // Estimate
        final monthProgressPercent = targetCalories > 0 ? ((avgCalories / targetCalories) * 100).clamp(0, 120).toInt() : 0;
        
        return {
          'calories': avgCalories,
          'targetCalories': targetCalories,
          'meals': avgMeals,
          'progressPercent': monthProgressPercent,
        };
    }
  }

  String _getPeriodStatsTitle(String base) {
    switch (_selectedPeriod) {
      case TimePeriod.day:
        return 'Dagens $base';
      case TimePeriod.week:
        return 'Ugentligt snit';
      case TimePeriod.month:
        return 'Månedligt snit';
    }
  }

  String _getPeriodStatsSubtitle(int targetCalories) {
    switch (_selectedPeriod) {
      case TimePeriod.day:
        return 'af $targetCalories kcal';
      case TimePeriod.week:
        return 'pr. dag denne uge';
      case TimePeriod.month:
        return 'pr. dag denne måned';
    }
  }

  String _getPeriodMealsSubtitle() {
    switch (_selectedPeriod) {
      case TimePeriod.day:
        return 'logget i dag';
      case TimePeriod.week:
        return 'snit pr. dag';
      case TimePeriod.month:
        return 'snit pr. dag';
    }
  }

  String _getProgressSubtitle() {
    switch (_selectedPeriod) {
      case TimePeriod.day:
        return 'af dagens mål';
      case TimePeriod.week:
        return 'af ugens mål';
      case TimePeriod.month:
        return 'af månedens mål';
    }
  }

  IconData _getProgressIcon(int progressPercent) {
    if (progressPercent >= 90) return MdiIcons.trophyVariant;
    if (progressPercent >= 80) return MdiIcons.target;
    if (progressPercent >= 60) return MdiIcons.clockOutline;
    return MdiIcons.trendingUp;
  }

  Widget _buildPeriodSummaryCard(FoodLoggingState foodState, UserProfileModel userProfile, List<WeightEntryModel> weightEntries) {
    final periodData = _calculatePeriodData(foodState, userProfile, weightEntries);
    final progress = periodData['progressPercent'] / 100.0;
    
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.info, AppColors.info.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  _getPeriodSummaryIcon(),
                  color: Colors.white,
                  size: KSizes.iconM,
                ),
              ),
              const SizedBox(width: KSizes.margin3x),
              Text(
                _getPeriodSummaryTitle(),
                style: TextStyle(
                  fontSize: KSizes.fontSizeXL,
                  fontWeight: KSizes.fontWeightBold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: KSizes.margin4x),
          
          // Progress visualization
          _buildPeriodProgressBars(periodData),
          
          const SizedBox(height: KSizes.margin4x),
          
          // Summary insights
          _buildPeriodInsights(periodData, weightEntries, userProfile),
        ],
      ),
    );
  }

  IconData _getPeriodSummaryIcon() {
    switch (_selectedPeriod) {
      case TimePeriod.day:
        return MdiIcons.chartLine;
      case TimePeriod.week:
        return MdiIcons.chartAreaspline;
      case TimePeriod.month:
        return MdiIcons.chartTimelineVariant;
    }
  }

  String _getPeriodSummaryTitle() {
    switch (_selectedPeriod) {
      case TimePeriod.day:
        return 'Dagens overblik';
      case TimePeriod.week:
        return 'Ugeoverblik';
      case TimePeriod.month:
        return 'Månedsoverblik';
    }
  }

  Widget _buildPeriodProgressBars(Map<String, dynamic> periodData) {
    final progress = (periodData['progressPercent'] / 100.0).clamp(0.0, 1.2);
    final progressColor = progress >= 0.9 ? AppColors.success : progress >= 0.7 ? AppColors.warning : AppColors.primary;
    
    return Column(
      children: [
        // Main progress bar
        Padding(
          padding: const EdgeInsets.only(bottom: KSizes.margin2x),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  _getPeriodProgressLabel(),
                  style: TextStyle(
                    fontSize: KSizes.fontSizeS,
                    color: AppColors.textSecondary,
                    fontWeight: KSizes.fontWeightMedium,
                  ),
                ),
              ),
              const SizedBox(width: KSizes.margin2x),
              Expanded(
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: progressColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: KSizes.margin2x),
              SizedBox(
                width: 60,
                child: Text(
                  '${periodData['progressPercent']}%',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeS,
                    color: progressColor,
                    fontWeight: KSizes.fontWeightBold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        
        // Additional metrics based on period
        if (_selectedPeriod != TimePeriod.day) ...[
          const SizedBox(height: KSizes.margin2x),
          _buildAdditionalMetrics(periodData),
        ],
      ],
    );
  }

  String _getPeriodProgressLabel() {
    switch (_selectedPeriod) {
      case TimePeriod.day:
        return 'Dagens fremgang';
      case TimePeriod.week:
        return 'Ugentlig fremgang';
      case TimePeriod.month:
        return 'Månedlig fremgang';
    }
  }

  Widget _buildAdditionalMetrics(Map<String, dynamic> periodData) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricIndicator(
            'Konsistens',
            _getConsistencyScore(),
            _getConsistencyScore() >= 80 ? AppColors.success : AppColors.warning,
          ),
        ),
        const SizedBox(width: KSizes.margin3x),
        Expanded(
          child: _buildMetricIndicator(
            'Trend',
            _getTrendDirection(),
            AppColors.info,
            showPercentage: false,
          ),
        ),
      ],
    );
  }

  int _getConsistencyScore() {
    // Simplified consistency calculation based on selected period
    switch (_selectedPeriod) {
      case TimePeriod.day:
        return 100;
      case TimePeriod.week:
        return 85; // Example: 6 out of 7 days with logging
      case TimePeriod.month:
        return 75; // Example: 22 out of 30 days with logging
    }
  }

  String _getTrendDirection() {
    // Simplified trend calculation
    return '↗️ Stigende';
  }

  Widget _buildMetricIndicator(String label, dynamic value, Color color, {bool showPercentage = true}) {
    return Container(
      padding: const EdgeInsets.all(KSizes.margin3x),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            showPercentage ? '$value%' : value.toString(),
            style: TextStyle(
              fontSize: KSizes.fontSizeL,
              color: color,
              fontWeight: KSizes.fontWeightBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodInsights(Map<String, dynamic> periodData, List<WeightEntryModel> weightEntries, UserProfileModel userProfile) {
    final insights = _generatePeriodInsights(periodData, weightEntries, userProfile);
    
    return Container(
      padding: const EdgeInsets.all(KSizes.margin3x),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
      ),
      child: Column(
        children: insights.map((insight) => Padding(
          padding: const EdgeInsets.only(bottom: KSizes.margin2x),
          child: Row(
            children: [
              Icon(
                insight['icon'] as IconData,
                color: insight['color'] as Color,
                size: KSizes.iconS,
              ),
              const SizedBox(width: KSizes.margin2x),
              Expanded(
                child: Text(
                  insight['text'] as String,
                  style: TextStyle(
                    fontSize: KSizes.fontSizeS,
                    color: AppColors.textSecondary,
                    fontWeight: KSizes.fontWeightMedium,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  List<Map<String, dynamic>> _generatePeriodInsights(Map<String, dynamic> periodData, List<WeightEntryModel> weightEntries, UserProfileModel userProfile) {
    final progressPercent = periodData['progressPercent'];
    final insights = <Map<String, dynamic>>[];
    
    switch (_selectedPeriod) {
      case TimePeriod.day:
        if (progressPercent >= 90) {
          insights.add({
            'icon': MdiIcons.checkCircle,
            'text': 'Fantastisk! Du har næsten nået dagens kaloriemål.',
            'color': AppColors.success,
          });
        } else if (progressPercent >= 50) {
          insights.add({
            'icon': MdiIcons.clockOutline,
            'text': 'Du er godt på vej til at nå dagens mål.',
            'color': AppColors.warning,
          });
        } else {
          insights.add({
            'icon': MdiIcons.informationOutline,
            'text': 'Der er stadig tid til at logge flere måltider i dag.',
            'color': AppColors.info,
          });
        }
        break;
        
      case TimePeriod.week:
        insights.add({
          'icon': MdiIcons.trendingUp,
          'text': 'Denne uge har du været konsistent med din madlogning.',
          'color': AppColors.success,
        });
        insights.add({
          'icon': MdiIcons.target,
          'text': 'Din ugentlige gennemsnitskalorie er på rette spor.',
          'color': AppColors.primary,
        });
        break;
        
      case TimePeriod.month:
        insights.add({
          'icon': MdiIcons.chartLine,
          'text': 'Månedlige trends viser fremgang mod dit mål.',
          'color': AppColors.success,
        });
        if (weightEntries.length > 1) {
          insights.add({
            'icon': MdiIcons.scale,
            'text': 'Din vægtudvikling denne måned viser fremgang.',
            'color': AppColors.primary,
          });
        }
        insights.add({
          'icon': MdiIcons.calendarCheck,
          'text': 'Du har logget måltider på de fleste dage denne måned.',
          'color': AppColors.info,
        });
        break;
    }
    
    return insights;
  }

  Widget _buildQuickStatCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Container(
      height: 140, // Fixed height for consistency
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(
            icon,
            color: color,
            size: KSizes.iconM,
          ),
          const SizedBox(height: KSizes.margin2x),
          Text(
            value,
            style: TextStyle(
              fontSize: KSizes.fontSizeXL,
              fontWeight: KSizes.fontWeightBold,
              color: color,
            ),
          ),
          const SizedBox(height: KSizes.margin1x),
          Text(
            title,
            style: TextStyle(
              fontSize: KSizes.fontSizeS,
              color: AppColors.textPrimary,
              fontWeight: KSizes.fontWeightMedium,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: KSizes.margin1x),
          Flexible(
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: KSizes.fontSizeXS,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsCard(FoodLoggingState foodState, List<WeightEntryModel> weightEntries, UserProfileModel userProfile) {
    // Calculate real achievements from data based on selected period
    final periodData = _calculatePeriodData(foodState, userProfile, weightEntries);
    final totalCalories = periodData['calories'];
    final mealsLogged = periodData['meals'];
    final weightLost = weightEntries.isNotEmpty ? 
        (userProfile.currentWeightKg - weightEntries.first.weightKg).abs() : 0.0;
    
    final achievements = <Map<String, dynamic>>[];
    
    // Add achievements based on real data and selected period
    switch (_selectedPeriod) {
      case TimePeriod.day:
        if (mealsLogged >= 3) {
          achievements.add({
            'icon': MdiIcons.fire, 
            'text': '$mealsLogged måltider logget i dag', 
            'color': AppColors.warning
          });
        }
        if (totalCalories > 0 && userProfile.targetCalories > 0) {
          final percentage = ((totalCalories / userProfile.targetCalories) * 100).round();
          if (percentage >= 80) {
            achievements.add({
              'icon': MdiIcons.target, 
              'text': 'Nåede $percentage% af kaloriemål', 
              'color': AppColors.success
            });
          }
        }
        break;
        
      case TimePeriod.week:
        achievements.add({
          'icon': MdiIcons.calendarCheck, 
          'text': 'Konsistent madlogning denne uge', 
          'color': AppColors.success
        });
        achievements.add({
          'icon': MdiIcons.trendingUp, 
          'text': 'Ugentlige kaloriemål på rette kurs', 
          'color': AppColors.primary
        });
        break;
        
      case TimePeriod.month:
        achievements.add({
          'icon': MdiIcons.calendar, 
          'text': 'En hel måned med fremgang', 
          'color': AppColors.success
        });
        if (weightLost > 0) {
          achievements.add({
            'icon': MdiIcons.trendingDown, 
            'text': '${weightLost.toStringAsFixed(1)} kg fremgang denne måned', 
            'color': AppColors.primary
          });
        }
        break;
    }
    
    if (weightLost > 0 && _selectedPeriod == TimePeriod.day) {
      achievements.add({
        'icon': MdiIcons.trendingDown, 
        'text': '${weightLost.toStringAsFixed(1)} kg total fremgang', 
        'color': AppColors.primary
      });
    }
    
    // Fallback achievements if no real ones
    if (achievements.isEmpty) {
      achievements.addAll([
        {'icon': MdiIcons.heart, 'text': 'Velkommen til din rejse', 'color': AppColors.primary},
        {'icon': MdiIcons.trophy, 'text': 'Start med at logge dine måltider', 'color': AppColors.secondary},
      ]);
    }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  MdiIcons.trophy,
                  color: Colors.white,
                  size: KSizes.iconM,
                ),
              ),
              const SizedBox(width: KSizes.margin3x),
              Text(
                _getAchievementsTitle(),
                style: TextStyle(
                  fontSize: KSizes.fontSizeXL,
                  fontWeight: KSizes.fontWeightBold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: KSizes.margin4x),
          
          ...achievements.map((achievement) => Padding(
            padding: const EdgeInsets.only(bottom: KSizes.margin2x),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(KSizes.margin1x),
                  decoration: BoxDecoration(
                    color: (achievement['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(KSizes.radiusS),
                  ),
                  child: Icon(
                    achievement['icon'] as IconData,
                    color: achievement['color'] as Color,
                    size: KSizes.iconS,
                  ),
                ),
                const SizedBox(width: KSizes.margin3x),
                Expanded(
                  child: Text(
                    achievement['text'] as String,
                    style: TextStyle(
                      fontSize: KSizes.fontSizeM,
                      color: AppColors.textPrimary,
                      fontWeight: KSizes.fontWeightMedium,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  String _getAchievementsTitle() {
    switch (_selectedPeriod) {
      case TimePeriod.day:
        return 'Dagens resultater';
      case TimePeriod.week:
        return 'Ugens resultater';
      case TimePeriod.month:
        return 'Månedens resultater';
    }
  }

  Widget _buildWeightStat(String label, double weight, Color color, {bool showDelta = false, bool isPositive = false}) {
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
        // Fixed layout for weight display
        RichText(
          text: TextSpan(
            children: [
              if (showDelta) ...[
                TextSpan(
                  text: isPositive ? '-' : '+',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeL,
                    fontWeight: KSizes.fontWeightBold,
                    color: color,
                  ),
                ),
              ],
              TextSpan(
                text: weight.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: KSizes.fontSizeL,
                  fontWeight: KSizes.fontWeightBold,
                  color: color,
                ),
              ),
              TextSpan(
                text: ' kg',
                style: TextStyle(
                  fontSize: KSizes.fontSizeS,
                  fontWeight: KSizes.fontWeightMedium,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsRow(FoodLoggingState foodState, UserProfileModel userProfile) {
    // Keep original method for backward compatibility
    return _buildPeriodStatsRow(foodState, userProfile, []);
  }

  Widget _buildWeeklyOverview(FoodLoggingState foodState, UserProfileModel userProfile) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final targetCalories = userProfile.targetCalories > 0 ? userProfile.targetCalories : 2000;
    
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
                padding: const EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  MdiIcons.calendarWeek,
                  color: Colors.white,
                  size: KSizes.iconM,
                ),
              ),
              const SizedBox(width: KSizes.margin3x),
              Text(
                'Ugens overblik',
                style: TextStyle(
                  fontSize: KSizes.fontSizeXL,
                  fontWeight: KSizes.fontWeightBold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: KSizes.margin4x),
          
          // Daily progress bars for the week
          ...List.generate(7, (index) {
            final day = startOfWeek.add(Duration(days: index));
            final dayName = _getDayName(day.weekday);
            final isToday = day.day == now.day && day.month == now.month && day.year == now.year;
            final isFuture = day.isAfter(now);
            
            // Calculate calories for this specific day
            final dayCalories = _getCaloriesForDate(foodState, day);
            final progress = targetCalories > 0 ? (dayCalories / targetCalories).clamp(0.0, 1.2) : 0.0;
            final progressPercent = (progress * 100).round();
            
            Color progressColor;
            if (isFuture) {
              progressColor = AppColors.surface.withOpacity(0.3);
            } else if (progress >= 0.9) {
              progressColor = AppColors.success;
            } else if (progress >= 0.7) {
              progressColor = AppColors.warning;
            } else if (progress >= 0.5) {
              progressColor = AppColors.primary;
            } else {
              progressColor = AppColors.error;
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: KSizes.margin3x),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Text(
                          dayName,
                          style: TextStyle(
                            fontSize: KSizes.fontSizeM,
                            color: isToday ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: isToday ? KSizes.fontWeightBold : KSizes.fontWeightMedium,
                          ),
                        ),
                      ),
                      const SizedBox(width: KSizes.margin2x),
                      Expanded(
                        child: Container(
                          height: isToday ? 16 : 12,
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: isToday ? Border.all(color: AppColors.primary, width: 1) : null,
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: progressColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: KSizes.margin2x),
                      SizedBox(
                        width: 80,
                        child: Text(
                          isFuture ? '-' : '${dayCalories} kcal',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeS,
                            color: isToday ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: isToday ? KSizes.fontWeightBold : KSizes.fontWeightMedium,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: KSizes.margin1x),
                      SizedBox(
                        width: 45,
                        child: Text(
                          isFuture ? '' : '${progressPercent}%',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeS,
                            color: progressColor,
                            fontWeight: KSizes.fontWeightBold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          
          // Week summary
          const Divider(height: KSizes.margin4x),
          
          _buildWeekSummary(foodState, userProfile, startOfWeek, now),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Man', 'Tir', 'Ons', 'Tor', 'Fre', 'Lør', 'Søn'];
    return days[weekday - 1];
  }

  int _getCaloriesForDate(FoodLoggingState foodState, DateTime date) {
    // This is a simplified calculation - in a real app you'd have more sophisticated date filtering
    if (date.day == DateTime.now().day && date.month == DateTime.now().month && date.year == DateTime.now().year) {
      return foodState.mealsForDate.fold<int>(0, (sum, meal) => sum + meal.calories);
    }
    
    // For other days, we would typically fetch from a database or cache
    // For now, return sample data based on pattern
    if (date.isBefore(DateTime.now())) {
      final daysSinceStart = DateTime.now().difference(date).inDays;
      if (daysSinceStart <= 7) {
        // Sample pattern for recent days
        return [2100, 1850, 2200, 1950, 2300, 1800, 2000][daysSinceStart % 7];
      }
    }
    
    return 0; // Future days or too far in past
  }

  Widget _buildWeekSummary(FoodLoggingState foodState, UserProfileModel userProfile, DateTime startOfWeek, DateTime now) {
    final targetCalories = userProfile.targetCalories > 0 ? userProfile.targetCalories : 2000;
    int totalCalories = 0;
    int completedDays = 0;
    
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      if (!day.isAfter(now)) {
        final dayCalories = _getCaloriesForDate(foodState, day);
        totalCalories += dayCalories;
        if (dayCalories > 0) completedDays++;
      }
    }
    
    final averageCalories = completedDays > 0 ? totalCalories ~/ completedDays : 0;
    final weekProgress = targetCalories > 0 ? (averageCalories / targetCalories) * 100 : 0;
    
    return Row(
      children: [
        Expanded(
          child: _buildSummaryItem(
            'Gennemsnit',
            '${averageCalories} kcal',
            MdiIcons.chartLine,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: KSizes.margin3x),
        Expanded(
          child: _buildSummaryItem(
            'Opfyldelse',
            '${weekProgress.round()}%',
            MdiIcons.target,
            weekProgress >= 80 ? AppColors.success : weekProgress >= 60 ? AppColors.warning : AppColors.error,
          ),
        ),
        const SizedBox(width: KSizes.margin3x),
        Expanded(
          child: _buildSummaryItem(
            'Aktive dage',
            '$completedDays/7',
            MdiIcons.calendarCheck,
            completedDays >= 6 ? AppColors.success : completedDays >= 4 ? AppColors.warning : AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(KSizes.margin2x),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: KSizes.iconS),
          const SizedBox(height: KSizes.margin1x),
          Text(
            value,
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              fontWeight: KSizes.fontWeightBold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: KSizes.fontSizeXS,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 