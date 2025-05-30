import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../info/presentation/info_page.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../weight_tracking/application/weight_tracking_notifier.dart';
import '../../food_logging/application/food_logging_notifier.dart';

/// Enum for time period selection
enum TimePeriod {
  day('Dag'),
  week('Uge'),
  month('Måned'),
  threeMonths('3 måneder'),
  year('År');

  const TimePeriod(this.label);
  final String label;
}

/// Main progress page showing trends and analytics
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
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataForPeriod();
    });
  }

  void _loadDataForPeriod() {
    // TODO: Implement data loading for selected period
    // This will load calories, weight, and activity data for the selected time range
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final onboardingState = ref.watch(onboardingProvider);
    final userProfile = onboardingState.userProfile;

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
                      subtitle: 'Se din fremgang over tid',
                      icon: MdiIcons.trendingUp,
                      iconColor: AppColors.info,
                    ),
                    
                    KSizes.spacingVerticalXL,
                    
                    // Time period selector
                    _buildTimePeriodSelector(),
                    
                    KSizes.spacingVerticalXL,
                    
                    // Weight progress chart
                    if (userProfile.hasWeightGoal) ...[
                      _buildWeightProgressChart(),
                      KSizes.spacingVerticalXL,
                    ],
                    
                    // Calorie trends chart
                    _buildCalorieTrendsChart(),
                    
                    KSizes.spacingVerticalXL,
                    
                    // Statistics overview
                    _buildStatisticsOverview(),
                    
                    KSizes.spacingVerticalXL,
                    
                    // Achievement badges section
                    _buildAchievementsSection(),
                    
                    KSizes.spacingVerticalXL,
                    
                    // Summary insights
                    _buildInsightsSection(),
                    
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
            'Tidsperiode 📅',
            style: TextStyle(
              fontSize: KSizes.fontSizeXL,
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: KSizes.margin4x),
          
          // Period selection chips
          Wrap(
            spacing: KSizes.margin2x,
            runSpacing: KSizes.margin2x,
            children: TimePeriod.values.map((period) {
              final isSelected = selectedPeriod == period;
              return ChoiceChip(
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
              );
            }).toList(),
          ),
          
          const SizedBox(height: KSizes.margin4x),
          
          // Date range display
          Container(
            padding: const EdgeInsets.all(KSizes.margin3x),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.05),
              borderRadius: BorderRadius.circular(KSizes.radiusM),
              border: Border.all(
                color: AppColors.info.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  MdiIcons.calendarRange,
                  color: AppColors.info,
                  size: KSizes.iconS,
                ),
                const SizedBox(width: KSizes.margin2x),
                Text(
                  _getDateRangeText(),
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    color: AppColors.info,
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

  Widget _buildWeightProgressChart() {
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
                      'Vægt udvikling ⚖️',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Din vægtændring over tid',
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
          
          // Chart placeholder - would be replaced with actual chart library
          _buildChartPlaceholder(
            'Vægt (kg)',
            'Her vil være en graf der viser vægtændringer over tid',
            AppColors.success,
            150,
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieTrendsChart() {
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
          // Header
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
                      'Kalorie tendenser 🔥',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Indtag vs. mål over tid',
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
          
          // Chart placeholder
          _buildChartPlaceholder(
            'Kalorier',
            'Her vil være en graf der viser kalorie indtag vs. mål over tid',
            AppColors.primary,
            180,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsOverview() {
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
        children: [
          Text(
            'Statistik oversigt 📊',
            style: TextStyle(
              fontSize: KSizes.fontSizeXL,
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          // Stats grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: KSizes.margin3x,
            crossAxisSpacing: KSizes.margin3x,
            childAspectRatio: 1.3,
            children: [
              _buildStatCard(
                'Gennemsnit',
                '1,850 kcal',
                'Daglig kalorie indtag',
                AppColors.primary,
                MdiIcons.calculator,
              ),
              _buildStatCard(
                'Bedste dag',
                '95%',
                'Af kalorie målet',
                AppColors.success,
                MdiIcons.trophy,
              ),
              _buildStatCard(
                'Træning',
                '4 dage',
                'Med aktivitet',
                AppColors.secondary,
                MdiIcons.runFast,
              ),
              _buildStatCard(
                'Konsistens',
                '85%',
                'Dage med logging',
                AppColors.info,
                MdiIcons.checkAll,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
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
                  MdiIcons.medal,
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
                      'Præstationer 🏆',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Dine milepæle og badges',
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
          
          // Achievement badges
          Wrap(
            spacing: KSizes.margin3x,
            runSpacing: KSizes.margin3x,
            children: [
              _buildAchievementBadge(
                '7 dage',
                'Konsekutiv logging',
                MdiIcons.fire,
                AppColors.primary,
                true,
              ),
              _buildAchievementBadge(
                '1 kg tabt',
                'Første milepæl',
                MdiIcons.trendingDown,
                AppColors.success,
                true,
              ),
              _buildAchievementBadge(
                '5 træninger',
                'Aktiv uge',
                MdiIcons.runFast,
                AppColors.secondary,
                false,
              ),
              _buildAchievementBadge(
                '30 dage',
                'Månedens helt',
                MdiIcons.calendar,
                AppColors.warning,
                false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection() {
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
                padding: const EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.info,
                      AppColors.info.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.info.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  MdiIcons.lightbulb,
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
                      'Indsigter 💡',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Personaliserede anbefalinger',
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
          
          // Insights list
          Column(
            children: [
              _buildInsightCard(
                'Fantastisk fremgang!',
                'Du har været konsistent med din kalorie logging i ${selectedPeriod.label.toLowerCase()}. Fortsæt det gode arbejde!',
                MdiIcons.trendingUp,
                AppColors.success,
              ),
              const SizedBox(height: KSizes.margin3x),
              _buildInsightCard(
                'Overvej mere protein',
                'Dine data viser at du kunne have gavn af at øge protein indtaget for bedre mæthedsfølelse.',
                MdiIcons.food,
                AppColors.warning,
              ),
              const SizedBox(height: KSizes.margin3x),
              _buildInsightCard(
                'Weekend mønster',
                'Du spiser typisk 200-300 kalorier mere i weekenden. Det er normalt, men hold øje med det.',
                MdiIcons.informationOutline,
                AppColors.info,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder(String yAxisLabel, String description, Color color, double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            MdiIcons.chartLine,
            size: KSizes.iconXL,
            color: color.withOpacity(0.4),
          ),
          const SizedBox(height: KSizes.margin2x),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: KSizes.margin2x),
          Text(
            '(Graf kommer snart)',
            style: TextStyle(
              fontSize: KSizes.fontSizeS,
              color: AppColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, Color color, IconData icon) {
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
              fontSize: KSizes.fontSizeXL,
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

  Widget _buildAchievementBadge(String title, String subtitle, IconData icon, Color color, bool isUnlocked) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(KSizes.margin3x),
      decoration: BoxDecoration(
        color: isUnlocked ? color.withOpacity(0.1) : AppColors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: isUnlocked ? color.withOpacity(0.3) : AppColors.textTertiary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(KSizes.margin2x),
            decoration: BoxDecoration(
              color: isUnlocked ? color : AppColors.textTertiary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: KSizes.iconM,
            ),
          ),
          const SizedBox(height: KSizes.margin2x),
          Text(
            title,
            style: TextStyle(
              fontSize: KSizes.fontSizeS,
              fontWeight: KSizes.fontWeightBold,
              color: isUnlocked ? color : AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: KSizes.fontSizeXS,
              color: isUnlocked ? AppColors.textSecondary : AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(KSizes.margin2x),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(KSizes.radiusS),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: KSizes.iconS,
            ),
          ),
          const SizedBox(width: KSizes.margin3x),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    fontWeight: KSizes.fontWeightSemiBold,
                    color: color,
                  ),
                ),
                const SizedBox(height: KSizes.margin1x),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: KSizes.fontSizeS,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateDateRangeForPeriod(TimePeriod period) {
    final now = DateTime.now();
    switch (period) {
      case TimePeriod.day:
        selectedStartDate = DateTime(now.year, now.month, now.day);
        break;
      case TimePeriod.week:
        selectedStartDate = now.subtract(const Duration(days: 7));
        break;
      case TimePeriod.month:
        selectedStartDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case TimePeriod.threeMonths:
        selectedStartDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case TimePeriod.year:
        selectedStartDate = DateTime(now.year - 1, now.month, now.day);
        break;
    }
  }

  String _getDateRangeText() {
    final now = DateTime.now();
    final months = ['jan', 'feb', 'mar', 'apr', 'maj', 'jun', 'jul', 'aug', 'sep', 'okt', 'nov', 'dec'];
    
    switch (selectedPeriod) {
      case TimePeriod.day:
        return 'I dag (${now.day}. ${months[now.month - 1]})';
      case TimePeriod.week:
        return '${selectedStartDate.day}. ${months[selectedStartDate.month - 1]} - ${now.day}. ${months[now.month - 1]}';
      case TimePeriod.month:
        return months[now.month - 1].substring(0, 1).toUpperCase() + months[now.month - 1].substring(1) + ' ${now.year}';
      case TimePeriod.threeMonths:
        return '${months[selectedStartDate.month - 1]} - ${months[now.month - 1]} ${now.year}';
      case TimePeriod.year:
        return '${selectedStartDate.year} - ${now.year}';
    }
  }
} 