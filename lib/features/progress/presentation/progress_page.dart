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

/// Simplified progress page focusing on visual progress
class ProgressPage extends ConsumerStatefulWidget {
  const ProgressPage({super.key});

  @override
  ConsumerState<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends ConsumerState<ProgressPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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
                    
                    const SizedBox(height: KSizes.margin6x),
                    
                    // Weight Progress - Main visual element
                    _buildWeightProgressCard(currentWeight, targetWeight, startWeight),
                    
                    const SizedBox(height: KSizes.margin4x),
                    
                    // Quick stats row
                    _buildQuickStatsRow(foodState, userProfile),
                    
                    const SizedBox(height: KSizes.margin4x),
                    
                    // Recent achievements
                    _buildAchievementsCard(foodState, weightEntries, userProfile),
                    
                    const SizedBox(height: KSizes.margin4x),
                    
                    // Weekly summary
                    _buildWeeklySummaryCard(foodState, userProfile),
                    
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

  Widget _buildQuickStatsRow(FoodLoggingState foodState, UserProfileModel userProfile) {
    // Calculate total calories manually from meals for today
    final totalCaloriesToday = foodState.mealsForDate.fold<int>(0, (sum, meal) => sum + meal.calories);
    
    // Calculate progress percentage based on target
    final targetCalories = userProfile.targetCalories > 0 ? userProfile.targetCalories : 2000;
    final progressPercentage = targetCalories > 0 
        ? ((totalCaloriesToday / targetCalories) * 100).clamp(0, 120).toInt()
        : 0;
    
    return Row(
      children: [
        Expanded(
          child: _buildQuickStatCard(
            'Dagens kalorier',
            '$totalCaloriesToday',
            'af $targetCalories kcal',
            AppColors.primary,
            MdiIcons.fire,
          ),
        ),
        const SizedBox(width: KSizes.margin3x),
        Expanded(
          child: _buildQuickStatCard(
            'Måltider',
            '${foodState.mealsForDate.length}',
            'logget i dag',
            AppColors.secondary,
            MdiIcons.silverwareVariant,
          ),
        ),
        const SizedBox(width: KSizes.margin3x),
        Expanded(
          child: _buildQuickStatCard(
            'Målopfyldelse',
            '$progressPercentage%',
            'af dagens mål',
            progressPercentage >= 90 ? AppColors.success : progressPercentage >= 70 ? AppColors.warning : AppColors.error,
            MdiIcons.target,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(KSizes.margin3x),
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
        children: [
          Icon(
            icon,
            color: color,
            size: KSizes.iconM,
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
            title,
            style: TextStyle(
              fontSize: KSizes.fontSizeXS,
              color: AppColors.textPrimary,
              fontWeight: KSizes.fontWeightMedium,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
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

  Widget _buildAchievementsCard(FoodLoggingState foodState, List<WeightEntryModel> weightEntries, UserProfileModel userProfile) {
    // Calculate real achievements from data
    final totalCalories = foodState.mealsForDate.fold<int>(0, (sum, meal) => sum + meal.calories);
    final mealsLogged = foodState.mealsForDate.length;
    final weightLost = weightEntries.isNotEmpty ? 
        (userProfile.currentWeightKg - weightEntries.first.weightKg).abs() : 0.0;
    
    final achievements = <Map<String, dynamic>>[];
    
    // Add achievements based on real data
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
    
    if (weightLost > 0) {
      achievements.add({
        'icon': MdiIcons.trendingDown, 
        'text': '${weightLost.toStringAsFixed(1)} kg fremgang', 
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
                'Seneste resultater',
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

  Widget _buildWeeklySummaryCard(FoodLoggingState foodState, UserProfileModel userProfile) {
    final targetCalories = userProfile.targetCalories > 0 ? userProfile.targetCalories : 2000;
    final todayCalories = foodState.mealsForDate.fold<int>(0, (sum, meal) => sum + meal.calories);
    final todayProgress = targetCalories > 0 ? (todayCalories / targetCalories).clamp(0.0, 1.2) : 0.0;
    
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
                  MdiIcons.chartLine,
                  color: Colors.white,
                  size: KSizes.iconM,
                ),
              ),
              const SizedBox(width: KSizes.margin3x),
              Text(
                'Dagens fremgang',
                style: TextStyle(
                  fontSize: KSizes.fontSizeXL,
                  fontWeight: KSizes.fontWeightBold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: KSizes.margin4x),
          
          // Today's progress
          Padding(
            padding: const EdgeInsets.only(bottom: KSizes.margin2x),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    'I dag',
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
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: todayProgress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: todayProgress >= 0.9 
                              ? AppColors.success 
                              : todayProgress >= 0.7 
                                  ? AppColors.warning 
                                  : AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: KSizes.margin2x),
                SizedBox(
                  width: 50,
                  child: Text(
                    todayProgress > 0 ? '${(todayProgress * 100).toInt()}%' : '-',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeS,
                      color: todayProgress >= 0.9 
                          ? AppColors.success 
                          : todayProgress >= 0.7 
                              ? AppColors.warning 
                              : AppColors.primary,
                      fontWeight: KSizes.fontWeightMedium,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: KSizes.margin2x),
          
          // Summary text
          Container(
            padding: const EdgeInsets.all(KSizes.margin3x),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(KSizes.radiusM),
            ),
            child: Row(
              children: [
                Icon(
                  todayProgress >= 0.9 
                      ? MdiIcons.checkCircle 
                      : todayProgress >= 0.5 
                          ? MdiIcons.clockOutline 
                          : MdiIcons.informationOutline,
                  color: todayProgress >= 0.9 
                      ? AppColors.success 
                      : todayProgress >= 0.5 
                          ? AppColors.warning 
                          : AppColors.info,
                  size: KSizes.iconS,
                ),
                const SizedBox(width: KSizes.margin2x),
                Expanded(
                  child: Text(
                    todayProgress >= 0.9 
                        ? 'Flot arbejde! Du er godt på vej med dagens kaloriemål.'
                        : todayProgress >= 0.5 
                            ? 'Du er halvvejs til dagens mål. Fortsæt det gode arbejde!'
                            : 'Start dagen med at logge dine måltider for at følge din fremgang.',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeS,
                      color: AppColors.textSecondary,
                      fontWeight: KSizes.fontWeightMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
} 