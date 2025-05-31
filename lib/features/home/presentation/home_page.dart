import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../activity/presentation/widgets/todays_activities_widget.dart';
import '../../dashboard/widgets/recent_meals_widget.dart';
import '../../food_logging/application/food_logging_notifier.dart';
import '../../dashboard/widgets/pending_foods_widget.dart';
import '../../food_logging/application/pending_food_cubit.dart';
import '../../food_logging/application/meal_session_cubit.dart';
import '../../food_logging/infrastructure/pending_food_service.dart';
import '../../food_logging/infrastructure/favorite_food_service.dart';
import '../../activity/infrastructure/favorite_activity_service.dart';
import '../../food_logging/domain/user_food_log_model.dart';
import '../../food_logging/presentation/pages/quick_favorites_page.dart';
import '../../food_logging/presentation/pages/multi_photo_meal_page.dart';
import '../../dashboard/widgets/calorie_overview_widget.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../activity/application/activity_notifier.dart';
import '../../dashboard/application/date_aware_providers.dart';

/// Main home page of the app after onboarding
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  
  @override
  void initState() {
    super.initState();
    
    // Initialize activity data with BMR calculation using provider system
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(onboardingProvider);
      final userProfile = state.userProfile;
      
      // Initialize pending foods
      ref.read(pendingFoodProvider.notifier).initialize();
      
      // Use the provider-based ActivityNotifier for consistency
      final activityNotifier = ref.read(activityNotifierProvider);
      
      if (userProfile.isCompleteForCalculations) {
        // Use BMR calculation for total calories
        activityNotifier.initializeWithBmr(userProfile.bmr);
      } else {
        // Fallback to activity-only calories
        activityNotifier.loadTodaysActivities();
        activityNotifier.loadTodaysCaloriesBurned();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('🔍 HomePage - build method called');
    final state = ref.watch(onboardingProvider);
    final activityNotifier = ref.watch(activityNotifierProvider);
    
    print('🔍 HomePage - state: ${state.userProfile.activityTrackingPreference}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalorie App'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            onPressed: () => _showRestartOnboardingDialog(context, ref.read(onboardingProvider.notifier)),
            icon: Icon(
              MdiIcons.accountCog,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Gennemgå onboarding igen',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(KSizes.margin4x),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TEST WIDGET - Dette skal ALTID vises ØVERST EFTER DATO-VÆLGEREN
              Container(
                height: 60,
                width: double.infinity,
                color: Colors.orange,
                margin: EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    '🧪 TEST: DateNavigationWidget skal være lige over denne boks 🧪',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              
              KSizes.spacingVerticalL,
              
              // Daily summary card - REMOVED per user request
              // _buildDailySummaryCard(context, state),
              
              // TEST WIDGET - Dette skal ALTID vises ØVERST
              Container(
                height: 80,
                width: double.infinity,
                color: Colors.orange,
                margin: EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    '🧪 ØVERSTE TEST WIDGET 🧪',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // DEBUG: Make it very clear this is the HOME page
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(KSizes.margin4x),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Text(
                  '🏠 DU ER PÅ HJEM-SIDEN 🏠',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              KSizes.spacingVerticalL,
              
              // Today's meals section
              const RecentMealsWidget(),
              
              KSizes.spacingVerticalL,
              
              // Pending food items section
              const PendingFoodsWidget(),
              
              KSizes.spacingVerticalL,
              
              // TEST WIDGET - Dette skal ALTID vises
              Container(
                height: 100,
                width: double.infinity,
                color: Colors.purple,
                margin: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'TEST AKTIVITETS WIDGET',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              KSizes.spacingVerticalL,
              
              // Today's activities section - ALWAYS SHOW
              TodaysActivitiesWidget(
                notifier: activityNotifier,
                onDeleteActivity: _onDeleteActivity,
                activityTrackingPreference: state.userProfile.activityTrackingPreference,
              ),
              
              KSizes.spacingVerticalL,
              
              // Coming soon features
              _buildComingSoonFeatures(context),
              
              KSizes.spacingVerticalXL,
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "home_fab",
        onPressed: () => _captureQuickFood(context),
        backgroundColor: AppColors.warning,
        foregroundColor: Colors.white,
        child: Icon(
          MdiIcons.cameraPlus,
          size: KSizes.iconL,
        ),
        tooltip: 'Tag hurtigt billede af mad',
      ),
    );
  }

  void _onDeleteActivity(dynamic activity) async {
    final activityNotifier = ref.read(activityNotifierProvider);
    final success = await activityNotifier.deleteActivity(activity.logEntryId);
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
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.border.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Velkommen tilbage, ${state.userProfile.name}! 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.textPrimary,
            ),
          ),
          KSizes.spacingVerticalS,
          Text(
            'Du er på vej til dit mål om ${_getGoalDescription(state.userProfile.goalType)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummaryCard(BuildContext context, dynamic state) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.border.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Dagens oversigt',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: KSizes.fontWeightSemiBold,
              color: AppColors.textPrimary,
            ),
          ),
          KSizes.spacingVerticalS,
          Text(
            'Din daglige status og fremgang',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
          
          KSizes.spacingVerticalL,
          
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
                child: Consumer(
                  builder: (context, ref, child) {
                    final activityNotifier = ref.watch(activityNotifierProvider);
                    return AnimatedBuilder(
                      animation: activityNotifier,
                      builder: (context, child) {
                        final activityState = activityNotifier.state;
                        final caloriesBurned = activityState?.todaysCaloriesBurned ?? 0;
                        
                        return _buildStatCard(
                          context,
                          'Kalorier forbrændt',
                          '$caloriesBurned',
                          'kcal',
                          MdiIcons.fireCircle,
                          AppColors.secondary,
                        );
                      },
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.border.withOpacity(0.1),
        ),
      ),
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
    );
  }

  String _getGoalDescription(dynamic goalType) {
    return switch (goalType?.toString()) {
      'GoalType.weightLoss' => 'vægttab',
      'GoalType.weightGain' => 'vægtøgning', 
      'GoalType.muscleGain' => 'muskelopbygning',
      'GoalType.weightMaintenance' => 'vægtvedligeholdelse',
      _ => 'dit mål',
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

  void _captureQuickFood(BuildContext context) async {
    // Show main category selection dialog first
    _showMainCategoryDialog(context);
  }

  void _showMainCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusL),
        ),
        title: Row(
          children: [
            Icon(MdiIcons.plus, color: AppColors.primary),
            SizedBox(width: KSizes.margin2x),
            Text('Hvad vil du registrere?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Food category
            _buildMainCategoryOption(
              context: context,
              icon: MdiIcons.foodApple,
              title: 'Mad & Drikke',
              subtitle: 'Registrer måltider og snacks',
              color: AppColors.warning,
              onTap: () {
                Navigator.of(context).pop();
                _showFoodSubmenu(context);
              },
            ),
            
            SizedBox(height: KSizes.margin3x),
            
            // Activity category
            _buildMainCategoryOption(
              context: context,
              icon: MdiIcons.runFast,
              title: 'Aktivitet & Motion',
              subtitle: 'Log træning og aktiviteter',
              color: AppColors.secondary,
              onTap: () {
                Navigator.of(context).pop();
                _showActivitySubmenu(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuller'),
          ),
        ],
      ),
    );
  }

  void _showFoodSubmenu(BuildContext context) async {
    // Check if there are food favorites
    final favoriteFoodService = FavoriteFoodService();
    final foodFavoritesResult = await favoriteFoodService.getFavorites();
    final hasFoodFavorites = foodFavoritesResult.isSuccess && foodFavoritesResult.success.isNotEmpty;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusL),
        ),
        title: Row(
          children: [
            Icon(MdiIcons.foodApple, color: AppColors.warning),
            SizedBox(width: KSizes.margin2x),
            Text('Mad & Drikke'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Multi-photo meal option - NEW FIRST
            _buildSubmenuOption(
              context: context,
              icon: MdiIcons.cameraPlus,
              title: 'Flere Billeder Måltid',
              subtitle: 'Tag flere billeder af samme måltid',
              color: AppColors.secondary,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToMultiPhotoMeal(context);
              },
            ),
            
            SizedBox(height: KSizes.margin3x),
            
            // Quick photo option
            _buildSubmenuOption(
              context: context,
              icon: MdiIcons.camera,
              title: 'Tag Billede',
              subtitle: 'Hurtig fotografering af mad',
              color: AppColors.warning,
              onTap: () {
                Navigator.of(context).pop();
                _captureFromCamera(context);
              },
            ),
            
            SizedBox(height: KSizes.margin3x),
            
            // Gallery option
            _buildSubmenuOption(
              context: context,
              icon: MdiIcons.image,
              title: 'Fra Galleri',
              subtitle: 'Vælg billede fra telefonen',
              color: AppColors.success,
              onTap: () {
                Navigator.of(context).pop();
                _captureFromGallery(context);
              },
            ),
            
            SizedBox(height: KSizes.margin3x),
            
            // Favorites option - ALWAYS show but indicate if empty
            _buildSubmenuOption(
              context: context,
              icon: MdiIcons.star,
              title: 'Fra Favoritter',
              subtitle: hasFoodFavorites 
                  ? 'Vælg fra gemte mad-favoritter'
                  : 'Ingen favoritter endnu',
              color: hasFoodFavorites ? AppColors.primary : AppColors.textSecondary,
              onTap: () {
                Navigator.of(context).pop();
                if (hasFoodFavorites) {
                  _navigateToFoodFavorites(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Du har ikke gemt nogen mad-favoritter endnu'),
                      backgroundColor: AppColors.info,
                    ),
                  );
                }
              },
            ),
            
            SizedBox(height: KSizes.margin3x),
            
            // Detailed registration - ALWAYS show
            _buildSubmenuOption(
              context: context,
              icon: MdiIcons.formTextbox,
              title: 'Detaljeret Registrering',
              subtitle: 'Manuel indtastning af mad',
              color: AppColors.info,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToDetailedFood(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showMainCategoryDialog(context);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(MdiIcons.arrowLeft, size: KSizes.iconXS),
                Text(' Tilbage'),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuller'),
          ),
        ],
      ),
    );
  }

  void _showActivitySubmenu(BuildContext context) async {
    // Check if there are activity favorites
    final favoriteActivityService = FavoriteActivityService();
    final activityFavoritesResult = await favoriteActivityService.getFavorites();
    final hasActivityFavorites = activityFavoritesResult.isSuccess && activityFavoritesResult.success.isNotEmpty;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusL),
        ),
        title: Row(
          children: [
            Icon(MdiIcons.runFast, color: AppColors.secondary),
            SizedBox(width: KSizes.margin2x),
            Text('Aktivitet & Motion'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Favorites option - ALWAYS show but indicate if empty
            _buildSubmenuOption(
              context: context,
              icon: MdiIcons.star,
              title: 'Fra Favoritter',
              subtitle: hasActivityFavorites 
                  ? 'Vælg fra gemte aktiviteter'
                  : 'Ingen favoritter endnu',
              color: hasActivityFavorites ? AppColors.primary : AppColors.textSecondary,
              onTap: () {
                Navigator.of(context).pop();
                if (hasActivityFavorites) {
                  _navigateToActivityFavorites(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Du har ikke gemt nogen aktivitets-favoritter endnu'),
                      backgroundColor: AppColors.info,
                    ),
                  );
                }
              },
            ),
            
            SizedBox(height: KSizes.margin3x),
            
            // Detailed registration - ALWAYS show
            _buildSubmenuOption(
              context: context,
              icon: MdiIcons.formTextbox,
              title: 'Detaljeret Registrering',
              subtitle: 'Manuel indtastning af aktivitet',
              color: AppColors.info,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToDetailedActivity(context);
              },
            ),
            
            SizedBox(height: KSizes.margin3x),
            
            // Quick activity - ALWAYS show
            _buildSubmenuOption(
              context: context,
              icon: MdiIcons.timerOutline,
              title: 'Hurtig Aktivitet',
              subtitle: 'Simple aktiviteter (gåtur, løb)',
              color: AppColors.secondary,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToQuickActivity(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showMainCategoryDialog(context);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(MdiIcons.arrowLeft, size: KSizes.iconXS),
                Text(' Tilbage'),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuller'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCategoryOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KSizes.radiusL),
      child: Container(
        padding: EdgeInsets.all(KSizes.margin4x),
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
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(KSizes.margin3x),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(KSizes.radiusM),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: KSizes.iconL,
              ),
            ),
            
            SizedBox(width: KSizes.margin4x),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: KSizes.fontSizeL,
                      fontWeight: KSizes.fontWeightBold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: KSizes.margin1x),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: KSizes.fontSizeM,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              MdiIcons.chevronRight,
              color: color,
              size: KSizes.iconM,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmenuOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KSizes.radiusM),
      child: Container(
        padding: EdgeInsets.all(KSizes.margin3x),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(KSizes.radiusM),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(KSizes.margin2x),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(KSizes.radiusS),
              ),
              child: Icon(
                icon,
                color: color,
                size: KSizes.iconM,
              ),
            ),
            
            SizedBox(width: KSizes.margin3x),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: KSizes.fontSizeM,
                      fontWeight: KSizes.fontWeightBold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: KSizes.margin1x),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: KSizes.fontSizeS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToFoodFavorites(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuickFavoritesPage(initialTab: 0), // Food tab
      ),
    );
  }

  void _navigateToActivityFavorites(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuickFavoritesPage(initialTab: 1), // Activity tab
      ),
    );
  }

  void _navigateToDetailedFood(BuildContext context) {
    // TODO: Navigate to detailed food registration page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detaljeret mad-registrering kommer snart!'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _navigateToDetailedActivity(BuildContext context) {
    // TODO: Navigate to detailed activity registration page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detaljeret aktivitets-registrering kommer snart!'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _navigateToQuickActivity(BuildContext context) {
    // TODO: Navigate to quick activity registration page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Hurtig aktivitets-registrering kommer snart!'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _navigateToMultiPhotoMeal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiPhotoMealPage(),
      ),
    );
  }

  void _captureFromGallery(BuildContext context) async {
    final cubit = ref.read(pendingFoodProvider.notifier);
    
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: KSizes.margin3x),
              Flexible(child: Text('Åbner galleri...')),
            ],
          ),
          backgroundColor: AppColors.info,
          duration: Duration(seconds: 1),
        ),
      );
      
      await cubit.captureFromGallery();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(MdiIcons.check, color: Colors.white),
                SizedBox(width: KSizes.margin2x),
                Flexible(child: Text('Billede valgt! Kategoriser det når du er klar.')),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(MdiIcons.alertCircle, color: Colors.white),
                SizedBox(width: KSizes.margin2x),
                Flexible(child: Text('Kunne ikke vælge billede')),
              ],
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _captureFromCamera(BuildContext context) async {
    final cubit = ref.read(pendingFoodProvider.notifier);
    
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: KSizes.margin3x),
              Flexible(child: Text('Tager billede...')),
            ],
          ),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 1),
        ),
      );
      
      await cubit.captureFood();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(MdiIcons.check, color: Colors.white),
                SizedBox(width: KSizes.margin2x),
                Flexible(child: Text('Billede taget! Kategoriser det når du er klar.')),
              ],
            ),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'Se afventende',
              textColor: Colors.white,
              onPressed: () {
                // Scroll to pending foods widget if it exists
                // For now, just show a message
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(MdiIcons.alertCircle, color: Colors.white),
                SizedBox(width: KSizes.margin2x),
                Flexible(child: Text('Kunne ikke tage billede')),
              ],
            ),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Prøv igen',
              textColor: Colors.white,
              onPressed: () => _captureFromCamera(context),
            ),
          ),
        );
      }
    }
  }
} 