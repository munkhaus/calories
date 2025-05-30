import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../activity/application/activity_notifier.dart';
import '../../activity/presentation/widgets/todays_activities_widget.dart';
import '../widgets/calorie_overview_widget.dart';
import '../widgets/recent_meals_widget.dart';
import '../widgets/daily_settings_widget.dart';
import '../widgets/weight_progress_widget.dart';
import '../application/selected_date_provider.dart';
import '../application/date_aware_providers.dart';
import '../../food_logging/application/food_logging_notifier.dart';
import '../../info/presentation/info_page.dart';

/// Main dashboard page showing daily overview
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  // Static reference to current dashboard state for external refresh
  static _DashboardPageState? _currentState;

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();

  // Static method to refresh dashboard data from outside
  static void refreshActivityData() {
    _currentState?.refreshActivityData();
  }
}

class _DashboardPageState extends ConsumerState<DashboardPage> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  late ActivityNotifier _activityNotifier;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Register this instance for static access
    DashboardPage._currentState = this;
    
    WidgetsBinding.instance.addObserver(this);
    _activityNotifier = ActivityNotifier();
    
    // Initialize activity data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(onboardingProvider);
      final userProfile = state.userProfile;
      
      if (userProfile.isCompleteForCalculations) {
        _activityNotifier.initializeWithBmr(userProfile.bmr);
      } else {
        _activityNotifier.loadTodaysActivities();
        _activityNotifier.loadTodaysCaloriesBurned();
      }
    });
  }

  @override
  void dispose() {
    // Clear static reference
    if (DashboardPage._currentState == this) {
      DashboardPage._currentState = null;
    }
    
    WidgetsBinding.instance.removeObserver(this);
    _activityNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh activity data when app comes back into focus
      _refreshDataForSelectedDate();
    }
  }

  void refreshActivityData() {
    // Public method to refresh activity data when tab is selected
    print('🔄 Refreshing activity data in DashboardPage');
    _refreshDataForSelectedDate();
  }

  void _refreshDataForSelectedDate() {
    final selectedDate = ref.read(selectedDateProvider);
    
    // Refresh food data for selected date
    ref.read(foodLoggingProvider.notifier).loadMealsForDate(selectedDate);
    
    // TODO: Refresh activity data for selected date when activity notifier supports it
    _activityNotifier.loadTodaysActivities();
    _activityNotifier.loadTodaysCaloriesBurned();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final onboardingState = ref.watch(onboardingProvider);
    final userProfile = onboardingState.userProfile;
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedDateNotifier = ref.read(selectedDateProvider.notifier);

    // Watch date-aware providers to trigger data loading for selected date
    ref.watch(dateAwareFoodProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              // Refresh data for the currently selected date
              _refreshDataForSelectedDate();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(KSizes.margin4x),
                child: Column(
                  children: [
                    // Header with new design
                    DashboardHeader(
                      greeting: _getGreeting(),
                      userName: userProfile.name.isNotEmpty 
                          ? userProfile.name.split(' ').first 
                          : 'der',
                      onInfoTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const InfoPage(),
                          ),
                        );
                      },
                      onNotificationTap: () {
                        // TODO: Navigate to notifications
                      },
                    ),
                    
                    KSizes.spacingVerticalXL,
                    
                    // Date navigation info card (only show if not today)
                    if (!selectedDateNotifier.isToday) ...[
                      _buildDateInfoCard(context),
                      KSizes.spacingVerticalXL,
                    ],
                    
                    // Daily settings widget (only show for today)
                    if (selectedDateNotifier.isToday) ...[
                      const DailySettingsWidget(),
                      KSizes.spacingVerticalXL,
                    ],
                    
                    // Calorie overview widget (main card with date functionality)
                    const CalorieOverviewWidget(),
                    
                    KSizes.spacingVerticalXL,
                    
                    // Weight progress widget (only show if user has weight goal)
                    const WeightProgressWidget(),
                    
                    KSizes.spacingVerticalXL,
                    
                    // Recent meals with enhanced design
                    const RecentMealsWidget(),
                    
                    KSizes.spacingVerticalXL,
                    
                    // Today's activities section
                    TodaysActivitiesWidget(
                      notifier: _activityNotifier,
                      onDeleteActivity: _onDeleteActivity,
                      activityTrackingPreference: onboardingState.userProfile.activityTrackingPreference,
                    ),
                    
                    KSizes.spacingVerticalXL,
                    
                    // Quick actions section with improved design
                    _buildQuickActionsSection(context, ref),
                    
                    // Bottom padding for FAB
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

  Widget _buildDateInfoCard(BuildContext context) {
    final selectedDateNotifier = ref.read(selectedDateProvider.notifier);
    
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
      child: Row(
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
              MdiIcons.calendar,
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
                  'Viser data for',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  selectedDateNotifier.formattedDate,
                  style: TextStyle(
                    fontSize: KSizes.fontSizeXL,
                    fontWeight: KSizes.fontWeightBold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: selectedDateNotifier.goToToday,
            icon: Icon(
              MdiIcons.calendarToday,
              size: KSizes.iconS,
              color: AppColors.primary,
            ),
            label: Text(
              'Gå til i dag',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: KSizes.fontWeightMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDeleteActivity(dynamic activity) async {
    final success = await _activityNotifier.deleteActivity(activity.logEntryId);
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success 
                ? 'Aktivitet slettet' 
                : 'Kunne ikke slette aktivitet'),
              backgroundColor: success ? AppColors.success : AppColors.error,
            ),
          );
        }
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'God morgen';
    } else if (hour < 17) {
      return 'God eftermiddag';
    } else {
      return 'God aften';
    }
  }

  Widget _buildQuickActionsSection(BuildContext context, WidgetRef ref) {
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
          // Header section
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
                  MdiIcons.flash,
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
                      'Hurtige handlinger',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Nem adgang til nøglefunktioner',
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
          
          // Quick action grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: KSizes.margin3x,
            crossAxisSpacing: KSizes.margin3x,
            childAspectRatio: 1.2,
            children: [
              _buildQuickActionCard(
                'Log måltid',
                'Tilføj mad',
                MdiIcons.silverwareForkKnife,
                [AppColors.primary, AppColors.primaryLight],
                () {
                  // Navigate to meal logging
                },
              ),
              _buildQuickActionCard(
                'Log aktivitet',
                'Tilføj træning',
                MdiIcons.runFast,
                [AppColors.secondary, AppColors.secondaryLight],
                () {
                  // Navigate to activity logging
                },
              ),
              _buildQuickActionCard(
                'Se fremgang',
                'Statistik',
                MdiIcons.chartLine,
                [AppColors.info, AppColors.info.withOpacity(0.7)],
                () {
                  // Navigate to progress
                },
              ),
              _buildQuickActionCard(
                'Indstillinger',
                'Profil & mere',
                MdiIcons.account,
                [AppColors.success, AppColors.success.withOpacity(0.7)],
                () {
                  // Navigate to profile
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    List<Color> gradient,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        child: Container(
          padding: const EdgeInsets.all(KSizes.margin3x),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient.map((c) => c.withOpacity(0.1)).toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(KSizes.radiusM),
            border: Border.all(
              color: gradient.first.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
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
                  fontSize: KSizes.fontSizeM,
                  fontWeight: KSizes.fontWeightSemiBold,
                  color: AppColors.textPrimary,
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
        ),
      ),
    );
  }
} 