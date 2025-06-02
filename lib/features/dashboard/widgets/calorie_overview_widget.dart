import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../onboarding/domain/user_profile_model.dart';
import '../../food_logging/application/food_logging_notifier.dart';
import '../application/selected_date_provider.dart';
import '../application/date_aware_providers.dart';
import '../presentation/calorie_calculation_page.dart';

/// Widget showing daily calorie intake vs goal with contextual guidance and actionable insights
class CalorieOverviewWidget extends ConsumerStatefulWidget {
  const CalorieOverviewWidget({super.key});

  @override
  ConsumerState<CalorieOverviewWidget> createState() => _CalorieOverviewWidgetState();
}

class _CalorieOverviewWidgetState extends ConsumerState<CalorieOverviewWidget> {
  @override
  void initState() {
    super.initState();
    // Force initial rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }
 
  @override
  Widget build(BuildContext context) {
    print('🔥 CalorieOverviewWidget: BUILD START');

    // CRITICAL FIX: Force rebuild by directly watching onboarding provider
    final onboardingState = ref.watch(onboardingProvider);
    final userProfile = onboardingState.userProfile;
    print('🔥 CalorieOverviewWidget: Watched onboardingProvider. UserProfile TDEE: ${userProfile.tdee}, Work: ${userProfile.isCurrentlyWorkDay}, Leisure: ${userProfile.isLeisureActivityEnabledToday}');
    
    // Add explicit listener to force rebuild when onboarding changes
    ref.listen(onboardingProvider, (previous, next) {
      print('🔥 CalorieOverviewWidget: ref.listen DETECTED change in onboardingProvider.');
      print('🔥 CalorieOverviewWidget: Previous TDEE: ${previous?.userProfile.tdee}, New TDEE: ${next.userProfile.tdee}');
      if (mounted && previous?.userProfile.tdee != next.userProfile.tdee) {
        print('🔥 CalorieOverviewWidget: TDEE changed AND widget is mounted. Calling setState() to FORCE rebuild.');
        setState(() {}); // FORCE rebuild when TDEE changes
      } else {
        print('🔥 CalorieOverviewWidget: TDEE did NOT change or widget NOT mounted. No forced rebuild via setState().');
      }
    });
    
    // FORCE widget invalidation when profile changes by adding a key based on TDEE
    // final widgetKey = Key('calorie_overview_${userProfile.tdee.hashCode}'); // Temporarily disabled to see if direct watch is enough
    
    // Also watch for selected date changes
    final selectedDate = ref.watch(selectedDateProvider);
    print('🔥 CalorieOverviewWidget: Watched selectedDateProvider. SelectedDate: $selectedDate');
    
    // Trigger date-aware activity loading
    ref.watch(dateAwareActivityProvider); // This is fine, just triggers loading
    print('🔥 CalorieOverviewWidget: Watched dateAwareActivityProvider.');
    
    // Force refresh of activity calories when profile changes
    final activityCalories = ref.watch(activityCaloriesForSelectedDateProvider);
    print('🔥 CalorieOverviewWidget: Watched activityCaloriesForSelectedDateProvider. Value: $activityCalories');
    
    // Get consumed calories for selected date
    final consumedCalories = ref.watch(totalCaloriesForSelectedDateProvider);
    print('🔥 CalorieOverviewWidget: Watched totalCaloriesForSelectedDateProvider. Value: $consumedCalories');
    
    // CRITICAL: Use DIRECT values from profile - no local calculations
    final currentTdee = userProfile.tdee;
    final dynamicTargetCalories = userProfile.targetCalories.toDouble();
    final totalAvailableCalories = dynamicTargetCalories + activityCalories;
    
    print('🔥 CalorieOverviewWidget: FINAL CALCULATED VALUES FOR UI:');
    print('🔥 CalorieOverviewWidget: - currentTdee (from userProfile.tdee): $currentTdee');
    print('🔥 CalorieOverviewWidget: - dynamicTargetCalories (from userProfile.targetCalories): $dynamicTargetCalories');
    print('🔥 CalorieOverviewWidget: - activityCalories (from provider): $activityCalories');
    print('🔥 CalorieOverviewWidget: - totalAvailableCalories (dynamicTarget + activity): $totalAvailableCalories');
    print('🔥 CalorieOverviewWidget: - consumedCalories (from provider): $consumedCalories');
    
    // Calculate remaining calories and progress
    final remainingCalories = totalAvailableCalories - consumedCalories;
    print('🔥 CalorieOverviewWidget: - remainingCalories: $remainingCalories');
    
    // Calculate time-based context
    final timeContext = _calculateTimeContext();
    final caloriesByTimeOfDay = _calculateExpectedCaloriesByTime(totalAvailableCalories);
    final isAheadOfPace = consumedCalories < caloriesByTimeOfDay;
    
    // Calculate next meal suggestion
    final nextMealSuggestion = _calculateNextMealSuggestion(remainingCalories, timeContext);
    
    // Prevent division by zero and invalid progress
    double progress = 0.0;
    if (totalAvailableCalories > 0 && !totalAvailableCalories.isNaN && !consumedCalories.isNaN) {
      progress = consumedCalories / totalAvailableCalories;
    }
    
    final displayProgress = progress.clamp(0.0, 1.2);
    final hasExceededGoal = consumedCalories > totalAvailableCalories;
    print('🔥 CalorieOverviewWidget: - displayProgress: $displayProgress, hasExceededGoal: $hasExceededGoal');
    print('🔥 CalorieOverviewWidget: BUILD END. Returning Container...');
    
    return Container(
      // key: widgetKey, // Temporarily disabled
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: _getContextualGradient(progress, isAheadOfPace),
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: _getProgressColor(displayProgress).withOpacity(0.15),
            blurRadius: KSizes.blurRadiusXL,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin6x),
        child: Column(
          children: [
            // Enhanced header with contextual status
            Row(
              children: [
                // Dynamic status icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getStatusIconColors(progress, isAheadOfPace),
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _getProgressColor(displayProgress).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getStatusIcon(progress, isAheadOfPace),
                    color: Colors.white,
                    size: KSizes.iconM,
                  ),
                ),
                
                const SizedBox(width: KSizes.margin3x),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dagens kalorier',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeL,
                          fontWeight: KSizes.fontWeightBold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      
                      // Removed contextual status message per user request
                      // SizedBox(height: KSizes.margin1x),
                      // Text(
                      //   _getContextualStatusMessage(progress, isAheadOfPace, timeContext, remainingCalories),
                      //   style: TextStyle(
                      //     fontSize: KSizes.fontSizeS,
                      //     color: _getStatusColor(progress, isAheadOfPace),
                      //     fontWeight: KSizes.fontWeightMedium,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                
                // Info button
                _buildControlButton(
                  icon: MdiIcons.informationOutline,
                  onTap: () => _showDetailedCalorieBreakdown(context, userProfile, ref),
                  isPrimary: true,
                ),
              ],
            ),
            
            SizedBox(height: KSizes.margin6x),
            
            // Enhanced progress visualization with better context
            Stack(
              alignment: Alignment.center,
              children: [
                // Background circle with pace indicator
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface.withOpacity(0.8),
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                ),
                
                // Pace indicator (expected consumption by time of day)
                if (caloriesByTimeOfDay > 0) ...[
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: (caloriesByTimeOfDay / totalAvailableCalories).clamp(0.0, 1.0),
                      strokeWidth: 4,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.textSecondary.withOpacity(0.3),
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ],
                
                // Main progress indicator
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: displayProgress,
                    strokeWidth: 16,
                    backgroundColor: AppColors.surface.withOpacity(0.6),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(displayProgress),
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                
                // Center content with actionable information
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.95),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Primary number - remaining calories instead of consumed
                      Text(
                        hasExceededGoal 
                            ? '+${(-remainingCalories).toInt()}'
                            : '${remainingCalories.toInt()}',
                        key: Key('remaining_calories_${remainingCalories.hashCode}'),
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: _getProgressColor(displayProgress),
                          letterSpacing: -1,
                        ),
                      ),
                      
                      Text(
                        hasExceededGoal ? 'over målet' : 'kcal tilbage',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeS,
                          color: AppColors.textSecondary,
                          fontWeight: KSizes.fontWeightMedium,
                        ),
                      ),
                      
                      SizedBox(height: KSizes.margin2x),
                      
                      // Removed actionable insight per user request
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: KSizes.margin2x,
                      //     vertical: KSizes.margin1x,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: _getProgressColor(displayProgress).withOpacity(0.15),
                      //     borderRadius: BorderRadius.circular(KSizes.radiusL),
                      //     border: Border.all(
                      //       color: _getProgressColor(displayProgress).withOpacity(0.3),
                      //       width: 1,
                      //     ),
                      //   ),
                      //   child: Text(
                      //     nextMealSuggestion,
                      //     style: TextStyle(
                      //       fontSize: KSizes.fontSizeXS,
                      //       color: _getProgressColor(displayProgress),
                      //       fontWeight: KSizes.fontWeightBold,
                      //     ),
                      //     textAlign: TextAlign.center,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: KSizes.margin8x),
            
            // Enhanced stat cards with more actionable information
            Row(
              children: [
                Expanded(
                  child: _buildEnhancedStatCard(
                    key: Key('consumed_card_${consumedCalories.hashCode}'),
                    label: 'Spist i dag',
                    value: '${consumedCalories.toInt()}',
                    unit: 'kcal',
                    subtitle: '${(progress * 100).toInt()}% af målet',
                    color: _getProgressColor(displayProgress),
                    icon: MdiIcons.silverwareForkKnife,
                    trend: isAheadOfPace ? 'over pace' : 'under pace',
                  ),
                ),
                
                SizedBox(width: KSizes.margin4x),
                
                Expanded(
                  child: _buildEnhancedStatCard(
                    key: Key('activity_card_${activityCalories.hashCode}_${dynamicTargetCalories.hashCode}'),
                    label: 'Aktivitet',
                    value: '+${activityCalories.toInt()}',
                    unit: 'kcal',
                    subtitle: 'ekstra budget',
                    color: AppColors.secondary,
                    icon: MdiIcons.runFast,
                    trend: activityCalories > 0 ? 'active' : 'sedentary',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: isPrimary 
              ? LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                )
              : null,
          color: isPrimary ? null : AppColors.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          border: Border.all(
            color: isPrimary 
                ? Colors.transparent 
                : AppColors.border.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: isPrimary ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Icon(
          icon,
          size: KSizes.iconXS,
          color: isPrimary ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildEnhancedStatCard({
    required String label,
    required String value,
    required String unit,
    required String subtitle,
    required Color color,
    required IconData icon,
    required String trend,
    Key? key,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
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
          
          SizedBox(height: KSizes.margin3x),
          
          Text(
            value,
            style: TextStyle(
              fontSize: KSizes.fontSizeXL,
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.textPrimary,
            ),
          ),
          
          SizedBox(height: KSizes.margin1x),
          
          Text(
            label,
            style: TextStyle(
              fontSize: KSizes.fontSizeS,
              color: AppColors.textSecondary,
              fontWeight: KSizes.fontWeightMedium,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: KSizes.margin1x),
          
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

  Color _getProgressColor(double progress) {
    // Handle invalid progress values during initial load
    if (progress.isNaN || progress.isInfinite) {
      return const Color(0xFF81C784); // Light green for default
    }
    
    // Clamp progress to reasonable bounds
    progress = progress.clamp(0.0, 1.2);
    
    // Create smooth gradual color transition from very light green to dark red
    if (progress <= 0.3) {
      // Very many calories remaining: Very light green
      return const Color(0xFFA5D6A7); // Very light green
    } else if (progress <= 0.5) {
      // Many calories remaining: Light green
      return const Color(0xFF81C784); // Light green
    } else if (progress <= 0.7) {
      // Some calories remaining: Medium green
      return const Color(0xFF66BB6A); // Medium green
    } else if (progress <= 0.8) {
      // Getting close: Standard green
      return const Color(0xFF4CAF50); // Standard green
    } else if (progress <= 0.9) {
      // Close to goal: Light orange
      return const Color(0xFFFFB74D); // Light orange
    } else if (progress <= 0.95) {
      // Very close to goal: Orange
      return const Color(0xFFFF9800); // Orange
    } else if (progress <= 1.0) {
      // Almost at goal: Dark orange
      return const Color(0xFFFF5722); // Dark orange
    } else if (progress <= 1.05) {
      // Slightly over goal: Light red
      return const Color(0xFFEF5350); // Light red
    } else if (progress <= 1.1) {
      // Over goal: Red
      return const Color(0xFFF44336); // Red
    } else {
      // Way over goal: Dark red
      return const Color(0xFFD32F2F); // Dark red
    }
  }

  void _showDetailedCalorieBreakdown(BuildContext context, UserProfileModel userProfile, WidgetRef ref) {
    // Navigate to the new dedicated page instead of showing a dialog
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CalorieCalculationPage(),
      ),
    );
  }

  String _calculateTimeContext() {
    final now = DateTime.now();
    final hour = now.hour;
    
    if (hour >= 5 && hour < 10) return 'morning';
    if (hour >= 10 && hour < 14) return 'midday';
    if (hour >= 14 && hour < 18) return 'afternoon';
    if (hour >= 18 && hour < 22) return 'evening';
    return 'night';
  }

  double _calculateExpectedCaloriesByTime(double totalCalories) {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final totalMinutesInDay = 24 * 60;
    final currentMinutes = hour * 60 + minute;
    
    // Assume most calories are consumed between 6 AM and 10 PM (16 hours)
    final activeStartHour = 6;
    final activeEndHour = 22;
    
    if (hour < activeStartHour) return 0.0;
    if (hour >= activeEndHour) return totalCalories;
    
    final activeMinutes = (activeEndHour - activeStartHour) * 60;
    final minutesSinceActiveStart = (hour - activeStartHour) * 60 + minute;
    
    // Progressive consumption: lighter breakfast, heavier lunch/dinner
    double progressFactor;
    if (hour < 12) {
      // Morning: slower consumption
      progressFactor = (minutesSinceActiveStart / activeMinutes) * 0.6;
    } else if (hour < 18) {
      // Afternoon: faster consumption
      progressFactor = 0.6 + ((minutesSinceActiveStart - 6*60) / activeMinutes) * 0.3;
    } else {
      // Evening: final consumption
      progressFactor = 0.9 + ((minutesSinceActiveStart - 12*60) / activeMinutes) * 0.1;
    }
    
    return totalCalories * progressFactor.clamp(0.0, 1.0);
  }

  String _calculateNextMealSuggestion(double remainingCalories, String timeContext) {
    if (remainingCalories <= 0) return 'Målet nået!';
    
    switch (timeContext) {
      case 'morning':
        if (remainingCalories > 800) return 'Plads til morgenmad';
        if (remainingCalories > 400) return 'Let morgenmad';
        return 'Kaffe + snack';
        
      case 'midday':
        if (remainingCalories > 1200) return 'Plads til stor frokost';
        if (remainingCalories > 600) return 'Normal frokost';
        return 'Let frokost';
        
      case 'afternoon':
        if (remainingCalories > 800) return 'Healthy snack tid';
        if (remainingCalories > 400) return 'Let mellemmåltid';
        return 'Små snacks';
        
      case 'evening':
        if (remainingCalories > 600) return 'Plads til aftensmad';
        if (remainingCalories > 300) return 'Let aftensmad';
        return 'Meget let måltid';
        
      default:
        return 'Godt arbejde i dag!';
    }
  }
  
  LinearGradient _getContextualGradient(double progress, bool isAheadOfPace) {
    // Handle invalid progress values during initial load
    if (progress.isNaN || progress.isInfinite) {
      progress = 0.0;
    }
    
    // Clamp progress to reasonable bounds
    progress = progress.clamp(0.0, 1.2);
    
    // MEGET mere synlige farver baseret på kalorie-progress!
    Color primaryColor;
    Color secondaryColor;
    
    if (progress <= 0.3) {
      // Mange kalorier tilbage: Kraftig grøn gradient
      primaryColor = const Color(0xFF4CAF50); // Grøn
      secondaryColor = const Color(0xFF81C784); // Lys grøn
    } else if (progress <= 0.6) {
      // Nogle kalorier tilbage: Blå-grøn gradient
      primaryColor = const Color(0xFF26A69A); // Teal
      secondaryColor = const Color(0xFF66BB6A); // Mellem grøn
    } else if (progress <= 0.8) {
      // Kommer tættere på målet: Gul-orange gradient
      primaryColor = const Color(0xFFFFCA28); // Gul
      secondaryColor = const Color(0xFFFFB74D); // Lys orange
    } else if (progress <= 0.95) {
      // Tæt på målet: Orange gradient
      primaryColor = const Color(0xFFFF9800); // Orange
      secondaryColor = const Color(0xFFFFB74D); // Lys orange
    } else if (progress <= 1.05) {
      // Lige over målet: Rød-orange gradient
      primaryColor = const Color(0xFFFF5722); // Dyb orange
      secondaryColor = const Color(0xFFFF7043); // Orange-rød
    } else {
      // Langt over målet: Kraftig rød gradient
      primaryColor = const Color(0xFFF44336); // Rød
      secondaryColor = const Color(0xFFE57373); // Lys rød
    }
    
    // Skab MEGET mere synlig gradient med høj opacity
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor.withOpacity(0.9), // MEGET stærk farve!
        secondaryColor.withOpacity(0.7), // Stærk mellem farve
        primaryColor.withOpacity(0.4), // Stadig synlig i bunden
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }
  
  String _getContextualStatusMessage(double progress, bool isAheadOfPace, String timeContext, double remainingCalories) {
    if (progress > 1.0) {
      return 'Over målet - vælg lette alternativer resten af dagen';
    }
    
    final timeMessage = switch (timeContext) {
      'morning' => 'God morgen!',
      'midday' => 'Midt på dagen',
      'afternoon' => 'Eftermiddag',
      'evening' => 'Aftentime',
      _ => 'Sent på aftenen',
    };
    
    if (isAheadOfPace) {
      return '$timeMessage - Du spiser hurtigere end normalt';
    } else if (progress < 0.3) {
      return '$timeMessage - Husk at spise nok i dag';
    } else {
      return '$timeMessage - Du er godt på vej';
    }
  }
  
  Color _getStatusColor(double progress, bool isAheadOfPace) {
    if (progress > 1.0) return AppColors.error;
    if (isAheadOfPace) return AppColors.warning;
    if (progress < 0.3) return AppColors.info;
    return AppColors.success;
  }
  
  List<Color> _getStatusIconColors(double progress, bool isAheadOfPace) {
    final baseColor = _getStatusColor(progress, isAheadOfPace);
    return [baseColor, baseColor.withOpacity(0.8)];
  }
  
  IconData _getStatusIcon(double progress, bool isAheadOfPace) {
    if (progress > 1.0) return MdiIcons.alertCircle;
    if (isAheadOfPace) return MdiIcons.speedometer;
    if (progress < 0.3) return MdiIcons.silverwareForkKnife;
    return MdiIcons.checkCircle;
  }
}

/// Detail section widget for grouping related items
class _DetailSection extends StatelessWidget {
  final String title;
  final List<_DetailItem> items;

  const _DetailSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: KSizes.fontSizeL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: KSizes.margin2x),
        ...items.map((item) => Padding(
          padding: EdgeInsets.only(bottom: KSizes.margin1x),
          child: item,
        )),
      ],
    );
  }
}

/// Individual detail item widget
class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final String description;

  const _DetailItem(this.label, this.value, this.description);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: KSizes.fontSizeM,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (description.isNotEmpty) ...[
                SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: KSizes.fontSizeXS,
                    color: AppColors.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            value,
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
} 