import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../activity/application/activity_notifier.dart';
import '../../activity/presentation/widgets/todays_activities_widget.dart';

/// Main home page of the app after onboarding
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late ActivityNotifier _activityNotifier;

  @override
  void initState() {
    super.initState();
    _activityNotifier = ActivityNotifier();
    // Initialize activity data with BMR calculation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(onboardingProvider);
      final userProfile = state.userProfile;
      
      if (userProfile.isCompleteForCalculations) {
        // Use BMR calculation for total calories
        _activityNotifier.initializeWithBmr(userProfile.bmr);
      } else {
        // Fallback to activity-only calories
        _activityNotifier.loadTodaysActivities();
        _activityNotifier.loadTodaysCaloriesBurned();
      }
    });
  }

  @override
  void dispose() {
    _activityNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dit Sunde Jeg'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showRestartOnboardingDialog(context, notifier),
            icon: Icon(
              MdiIcons.accountCog,
              color: Colors.white,
            ),
            tooltip: 'Gennemgå onboarding igen',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KSizes.margin4x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome back header
            _buildWelcomeHeader(context, state),
            
            KSizes.spacingVerticalL,
            
            // Daily summary card
            _buildDailySummaryCard(context, state),
            
            KSizes.spacingVerticalL,
            
            // Today's activities section
            TodaysActivitiesWidget(
              notifier: _activityNotifier,
              onDeleteActivity: _onDeleteActivity,
            ),
            
            KSizes.spacingVerticalL,
            
            // Coming soon features
            _buildComingSoonFeatures(context),
            
            KSizes.spacingVerticalXL,
          ],
        ),
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

  Widget _buildWelcomeHeader(BuildContext context, dynamic state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin6x),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(KSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Velkommen tilbage, ${state.userProfile.name}! 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.primary,
            ),
          ),
          KSizes.spacingVerticalS,
          Text(
            'Du er godt på vej til dit mål om ${_getGoalDescription(state.userProfile.goalType)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummaryCard(BuildContext context, dynamic state) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin6x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  MdiIcons.chartLine,
                  color: AppColors.primary,
                  size: KSizes.iconL,
                ),
                KSizes.spacingHorizontalS,
                Text(
                  'Dagens oversigt',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: KSizes.fontWeightBold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            KSizes.spacingVerticalM,
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Kalorie mål',
                    '${state.userProfile.targetCalories}',
                    'kcal',
                    MdiIcons.fire,
                    AppColors.warning,
                  ),
                ),
                KSizes.spacingHorizontalM,
                Expanded(
                  child: AnimatedBuilder(
                    animation: _activityNotifier,
                    builder: (context, child) {
                      final activityState = _activityNotifier.state;
                      final caloriesBurned = activityState.todaysCaloriesBurned;
                      
                      return _buildStatCard(
                        context,
                        'Kalorier forbrændt',
                        '$caloriesBurned',
                        'kcal',
                        MdiIcons.fireCircle,
                        AppColors.secondary,
                      );
                    },
                  ),
                ),
              ],
            ),
            KSizes.spacingVerticalM,
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Nuværende vægt',
                    '${state.userProfile.currentWeightKg.toStringAsFixed(1)}',
                    'kg',
                    MdiIcons.scaleBalance,
                    AppColors.primary,
                  ),
                ),
                KSizes.spacingHorizontalM,
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Målvægt',
                    '${state.userProfile.targetWeightKg.toStringAsFixed(1)}',
                    'kg',
                    MdiIcons.target,
                    AppColors.success,
                  ),
                ),
              ],
            ),
            KSizes.spacingVerticalM,
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'BMI',
                    state.userProfile.bmi.toStringAsFixed(1),
                    state.userProfile.bmiCategory,
                    MdiIcons.humanMale,
                    AppColors.secondary,
                  ),
                ),
                KSizes.spacingHorizontalM,
                Expanded(
                  child: _buildStatCard(
                    context,
                    'BMR (døgnforbrug)',
                    '${state.userProfile.bmr.toStringAsFixed(0)}',
                    'kcal/dag',
                    MdiIcons.heart,
                    AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(color: color.withOpacity(0.3)),
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
              KSizes.spacingHorizontalXS,
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: KSizes.fontWeightMedium,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          KSizes.spacingVerticalXS,
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: KSizes.fontWeightBold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kommende funktioner',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: KSizes.fontWeightBold,
            color: AppColors.primary,
          ),
        ),
        KSizes.spacingVerticalM,
        _buildComingSoonCard(
          context,
          'Måltid logging',
          'Log dine måltider og følg dit kalorie indtag',
          MdiIcons.foodApple,
          AppColors.warning,
        ),
        KSizes.spacingVerticalM,
        _buildComingSoonCard(
          context,
          'Progress tracking',
          'Se din udvikling over tid med grafer og statistik',
          MdiIcons.chartLine,
          AppColors.success,
        ),
        KSizes.spacingVerticalM,
        _buildComingSoonCard(
          context,
          'Fødevare database',
          'Søg i tusindvis af fødevarer og deres næringsværdier',
          MdiIcons.databaseSearch,
          AppColors.secondary,
        ),
      ],
    );
  }

  Widget _buildComingSoonCard(BuildContext context, String title, String description, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin4x),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(KSizes.margin3x),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(KSizes.radiusM),
              ),
              child: Icon(
                icon,
                color: color,
                size: KSizes.iconL,
              ),
            ),
            KSizes.spacingHorizontalM,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: KSizes.fontWeightBold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  KSizes.spacingVerticalXS,
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: KSizes.margin3x,
                vertical: KSizes.margin1x,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(KSizes.radiusS),
              ),
              child: Text(
                'Kommer snart',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.warning,
                  fontWeight: KSizes.fontWeightMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGoalDescription(dynamic goalType) {
    return switch (goalType?.toString()) {
      'GoalType.weightLoss' => 'vægttab',
      'GoalType.weightGain' => 'vægtøgning', 
      'GoalType.muscleGain' => 'muskelopbygning',
      'GoalType.weightMaintenance' => 'vægtvedligeholdelse',
      _ => 'dit sundhedsmål',
    };
  }

  void _showRestartOnboardingDialog(BuildContext context, dynamic notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              MdiIcons.restart,
              color: AppColors.warning,
            ),
            KSizes.spacingHorizontalS,
            const Text('Gennemgå onboarding igen?'),
          ],
        ),
        content: const Text(
          'Dette vil tage dig gennem opsætningsprocessen igen så du kan ændre dine grundlæggende oplysninger.\n\nVil du fortsætte?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuller'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              notifier.reset();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            child: const Text('Ja, gennemgå igen'),
          ),
        ],
      ),
    );
  }
} 