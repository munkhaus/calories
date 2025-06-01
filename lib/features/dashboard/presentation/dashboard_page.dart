import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../food_logging/application/food_logging_notifier.dart';
import '../../food_logging/application/pending_food_cubit.dart';
import '../../food_logging/domain/pending_food_model.dart';
import '../../food_logging/presentation/pages/categorize_food_page.dart';
import '../../food_logging/presentation/pages/pending_food_selection_page.dart';
import '../../activity/application/activity_notifier.dart';
import '../../activity/domain/user_activity_log_model.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/calorie_overview_widget.dart';
import '../widgets/daily_settings_widget.dart';
import '../widgets/daily_nutrition_widget.dart';
import '../widgets/weight_progress_widget.dart';
import '../widgets/date_navigation_widget.dart';
import '../widgets/recent_meals_widget.dart';
import '../widgets/pending_foods_widget.dart';
import '../../activity/presentation/widgets/todays_activities_widget.dart';
import '../application/selected_date_provider.dart';
import '../application/date_aware_providers.dart';
import '../../weight_tracking/application/weight_tracking_notifier.dart';
import '../../weight_tracking/domain/weight_entry_model.dart';
import '../../activity/presentation/pages/quick_activity_registration_page.dart';
import '../../food_logging/presentation/pages/food_search_page.dart';
import '../widgets/todays_meals_widget.dart';
import '../../onboarding/domain/user_profile_model.dart';

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
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Register this instance for static access
    DashboardPage._currentState = this;
    
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize data using providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  void _initializeProviders() {
    // Trigger all providers to load initial data
    ref.read(foodLoggingProvider.notifier).loadMealsForDate(DateTime.now());
    ref.read(activityNotifierProvider).loadTodaysActivities();
    ref.read(weightTrackingProvider.notifier).loadWeightEntries();
    
    // Initialize pending food cubit to load pending items
    ref.read(pendingFoodProvider.notifier).initialize();
  }

  @override
  void dispose() {
    // Clear static reference
    if (DashboardPage._currentState == this) {
      DashboardPage._currentState = null;
    }
    
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh all data when app comes back into focus
      _refreshDataForSelectedDate();
    }
  }

  void refreshActivityData() {
    // Public method to refresh all data when tab is selected
    print('🔄 Refreshing all data in DashboardPage');
    _refreshDataForSelectedDate();
  }

  void _refreshDataForSelectedDate() {
    final selectedDate = ref.read(selectedDateProvider);
    
    // Refresh all data for selected date
    ref.read(foodLoggingProvider.notifier).loadMealsForDate(selectedDate);
    ref.read(activityNotifierProvider).loadActivitiesForDate(selectedDate);
    ref.read(weightTrackingProvider.notifier).refresh();
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
                    // Header with new design - REMOVED per user request
                    // DashboardHeader(
                    //   greeting: _getGreeting(),
                    //   userName: userProfile.name.isNotEmpty 
                    //       ? userProfile.name.split(' ').first 
                    //       : 'der',
                    //   onInfoTap: () {
                    //     Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //         builder: (context) => const InfoPage(),
                    //       ),
                    //     );
                    //   },
                    //   onRegistrationTap: () => _showRegistrationOptions(context),
                    // ),
                    
                    // KSizes.spacingVerticalXL,
                    
                    // Date navigation widget - always at top of the actual home page
                    const DateNavigationWidget(),
                    
                    KSizes.spacingVerticalM,
                    
                    // Daily settings widget (only show for today)
                    if (selectedDateNotifier.isToday) ...[
                      const DailySettingsWidget(),
                      KSizes.spacingVerticalXL,
                    ],
                    
                    // Calorie overview widget (main card with date functionality)
                    const CalorieOverviewWidget(),
                    
                    KSizes.spacingVerticalXL,
                    
                    // Recent meals with enhanced design
                    const RecentMealsWidget(),
                    
                    KSizes.spacingVerticalXL,
                    
                    // Today's activities section
                    TodaysActivitiesWidget(
                      notifier: ref.watch(activityNotifierProvider),
                      onDeleteActivity: (activity) async {
                        // Handle activity deletion
                        await ref.read(activityNotifierProvider).deleteActivity(activity.logEntryId);
                        _refreshDataForSelectedDate();
                      },
                      activityTrackingPreference: userProfile.activityTrackingPreference ?? ActivityTrackingPreference.automatic,
                    ),
                    
                    KSizes.spacingVerticalXL,
                    
                    // Weight progress widget moved to bottom
                    const WeightProgressWidget(),
                    
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

  void _showRegistrationOptions(BuildContext context) {
    // Check if there are pending foods to process first
    final pendingCount = ref.read(pendingFoodsCountProvider);
    print('🍎 Dashboard: Pending count = $pendingCount');
    
    if (pendingCount > 0) {
      // Navigate directly to categorize pending foods
      print('🍎 Dashboard: Navigating to pending foods registration');
      _showPendingFoodsDialog(context, ref);
      return;
    }
    
    // Only show the modal if no pending foods exist
    print('🍎 Dashboard: Showing registration options modal');
    // Show registration options modal
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(KSizes.radiusXL),
            topRight: Radius.circular(KSizes.radiusXL),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(KSizes.margin4x),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle indicator
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                SizedBox(height: KSizes.margin3x),
                
                // Header
                Text(
                  'Hvad vil du registrere?',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeXXL,
                    fontWeight: KSizes.fontWeightBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                SizedBox(height: KSizes.margin1x),
                
                Text(
                  'Vælg hvad du vil logge i dag',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: KSizes.margin6x),
                
                // Quick food registration option
                _buildRegistrationOption(
                  context: context,
                  title: 'Hurtig mad',
                  subtitle: 'Tag et billede og kategoriser senere',
                  icon: MdiIcons.cameraPlus,
                  iconColor: AppColors.warning,
                  onTap: () {
                    Navigator.of(context).pop();
                    _captureQuickFood(context);
                  },
                ),
                
                SizedBox(height: KSizes.margin2x),
                
                // Detailed food registration option
                _buildRegistrationOption(
                  context: context,
                  title: 'Detaljeret mad',
                  subtitle: 'Søg og log mad med alle detaljer',
                  icon: MdiIcons.silverwareForkKnife,
                  iconColor: AppColors.primary,
                  onTap: () {
                    Navigator.of(context).pop();
                    _navigateToDetailedRegistration(context);
                  },
                ),
                
                SizedBox(height: KSizes.margin2x),
                
                // Activity registration option
                _buildRegistrationOption(
                  context: context,
                  title: 'Aktivitet',
                  subtitle: 'Log træning og aktiviteter',
                  icon: MdiIcons.runFast,
                  iconColor: AppColors.secondary,
                  onTap: () {
                    Navigator.of(context).pop();
                    _navigateToActivityRegistration(context);
                  },
                ),
                
                SizedBox(height: KSizes.margin2x),
                
                // Weight registration option
                _buildRegistrationOption(
                  context: context,
                  title: 'Vægt',
                  subtitle: 'Registrer din nuværende vægt',
                  icon: MdiIcons.scale,
                  iconColor: AppColors.info,
                  onTap: () {
                    Navigator.of(context).pop();
                    _navigateToWeightRegistration(context);
                  },
                ),
                
                SizedBox(height: KSizes.margin4x),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(KSizes.margin4x),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.border.withOpacity(0.2),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(KSizes.radiusL),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
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
                color: AppColors.textSecondary,
                size: KSizes.iconM,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _captureQuickFood(BuildContext context) async {
    // Show choice dialog for camera or gallery
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusL),
        ),
        title: Row(
          children: [
            Icon(MdiIcons.camera, color: AppColors.warning),
            SizedBox(width: KSizes.margin2x),
            Text('Hurtig mad'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hvordan vil du tilføje billedet?',
              style: TextStyle(fontSize: KSizes.fontSizeM),
            ),
            SizedBox(height: KSizes.margin4x),
            
            // Camera option
            _buildImageSourceOption(
              title: 'Tag nyt billede',
              subtitle: 'Brug kameraet til at tage et billede',
              icon: MdiIcons.camera,
              onTap: () => Navigator.of(context).pop('camera'),
            ),
            
            SizedBox(height: KSizes.margin3x),
            
            // Gallery option
            _buildImageSourceOption(
              title: 'Vælg fra galleri',
              subtitle: 'Vælg et eksisterende billede',
              icon: MdiIcons.image,
              onTap: () => Navigator.of(context).pop('gallery'),
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

    if (choice == null) return; // User cancelled

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
            Text(choice == 'camera' ? 'Åbner kamera...' : 'Åbner galleri...'),
          ],
        ),
        backgroundColor: AppColors.info,
        duration: Duration(seconds: 2),
      ),
    );
    
    try {
      final cubit = ref.read(pendingFoodProvider.notifier);
      
      if (choice == 'camera') {
        await cubit.captureFood();
      } else {
        // Use gallery picker
        await _pickFromGallery();
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        // Check if capture was successful by checking state
        final state = ref.read(pendingFoodProvider);
        
        if (state.captureState.isSuccess) {
          _refreshProviders();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(MdiIcons.check, color: Colors.white),
                  SizedBox(width: KSizes.margin2x),
                  Text('Billede tilføjet! Kategoriser det når du er klar.'),
                ],
              ),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state.captureState.hasError) {
          // Show specific error message
          _showCameraErrorMessage(context, state.captureState.error ?? 'Ukendt fejl');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showCameraErrorMessage(context, 'Uventet fejl: $e');
      }
    }
  }

  Widget _buildImageSourceOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(KSizes.margin3x),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.border.withOpacity(0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(KSizes.radiusM),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                ),
                child: Icon(
                  icon,
                  color: AppColors.warning,
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
                        fontWeight: KSizes.fontWeightSemiBold,
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
              
              Icon(
                MdiIcons.chevronRight,
                color: AppColors.textSecondary,
                size: KSizes.iconS,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    // Call the gallery picker method from cubit
    await ref.read(pendingFoodProvider.notifier).captureFromGallery();
  }

  void _showCameraErrorMessage(BuildContext context, String error) {
    String userMessage;
    Color backgroundColor;
    IconData icon;

    // Map technical errors to user-friendly messages
    if (error.contains('userCancelled') || error.toLowerCase().contains('cancel')) {
      userMessage = 'Billede annulleret';
      backgroundColor = AppColors.info;
      icon = MdiIcons.close;
    } else if (error.contains('permissionDenied') || error.toLowerCase().contains('permission')) {
      userMessage = 'Kamera tilladelse nægtet. Tjek app indstillinger.';
      backgroundColor = AppColors.error;
      icon = MdiIcons.security;
    } else if (error.contains('cameraUnavailable') || error.toLowerCase().contains('camera')) {
      userMessage = 'Kamera ikke tilgængeligt. Prøv igen senere.';
      backgroundColor = AppColors.error;
      icon = MdiIcons.cameraOff;
    } else if (error.contains('imageSave') || error.toLowerCase().contains('save')) {
      userMessage = 'Kunne ikke gemme billedet. Tjek lagerplads.';
      backgroundColor = AppColors.error;
      icon = MdiIcons.contentSave;
    } else {
      userMessage = 'Kunne ikke tage billede. Prøv igen.';
      backgroundColor = AppColors.error;
      icon = MdiIcons.alertCircle;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: KSizes.margin2x),
            Expanded(child: Text(userMessage)),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 3),
        action: error.contains('permissionDenied') 
            ? SnackBarAction(
                label: 'Indstillinger',
                textColor: Colors.white,
                onPressed: () {
                  // TODO: Open app settings
                },
              )
            : null,
      ),
    );
  }

  void _navigateToDetailedRegistration(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddFoodPage(initialMealType: null),
      ),
    );
  }

  void _navigateToActivityRegistration(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuickActivityRegistrationPage(),
      ),
    );
  }

  void _navigateToWeightRegistration(BuildContext context) {
    final weightController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KSizes.radiusL),
            ),
            title: Row(
              children: [
                Icon(MdiIcons.scale, color: AppColors.info),
                SizedBox(width: KSizes.margin2x),
                Text('Registrer vægt'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Vægt (kg)',
                    hintText: 'f.eks. 75.5',
                    prefixIcon: Icon(MdiIcons.scale),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KSizes.radiusM),
                    ),
                  ),
                  autofocus: true,
                ),
                SizedBox(height: KSizes.margin4x),
                GestureDetector(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(KSizes.margin4x),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(KSizes.radiusM),
                    ),
                    child: Row(
                      children: [
                        Icon(MdiIcons.calendar, color: AppColors.textSecondary),
                        SizedBox(width: KSizes.margin2x),
                        Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: TextStyle(fontSize: KSizes.fontSizeM),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: KSizes.margin4x),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: 'Noter (valgfrit)',
                    hintText: 'Eventuelle kommentarer...',
                    prefixIcon: Icon(MdiIcons.noteText),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KSizes.radiusM),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Annuller'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final weightText = weightController.text.trim();
                  if (weightText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Indtast venligst en vægt'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                  
                  final weight = double.tryParse(weightText);
                  if (weight == null || weight <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Indtast venligst en gyldig vægt'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                  
                  final entry = WeightEntryModel(
                    userId: 1,
                    weightKg: weight,
                    recordedAt: selectedDate,
                    notes: notesController.text.trim(),
                  );
                  
                  final success = await ref.read(weightTrackingProvider.notifier).addWeightEntry(entry);
                  
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    
                    if (success) {
                      _refreshProviders();
                    }
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Vægt registreret!' : 'Fejl ved registrering'),
                        backgroundColor: success ? AppColors.success : AppColors.error,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.info,
                  foregroundColor: Colors.white,
                ),
                child: Text('Gem'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPendingFoodsDialog(BuildContext context, WidgetRef ref) async {
    print('🍎 Dashboard: _showPendingFoodsDialog called');
    
    final pendingFoods = ref.read(pendingFoodProvider).pendingFoods;
    print('🍎 Dashboard: Found ${pendingFoods.length} pending foods');
    
    if (pendingFoods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ingen ventende registreringer fundet'),
          backgroundColor: AppColors.info,
        ),
      );
      return;
    }
    
    try {
      // If only one pending food, go directly to categorization
      if (pendingFoods.length == 1) {
        final selectedFood = pendingFoods.first;
        print('🍎 Dashboard: Only one pending food, navigating directly to CategorizeFoodPage');
        
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CategorizeFoodPage(
              pendingFood: selectedFood,
            ),
          ),
        );
        
        // Refresh data after categorization
        await ref.read(pendingFoodProvider.notifier).loadPendingFoods();
        return;
      }
      
      // Multiple pending foods - navigate to selection page
      print('🍎 Dashboard: Multiple pending foods, navigating to PendingFoodSelectionPage');
      
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PendingFoodSelectionPage(
            pendingFoods: pendingFoods,
          ),
        ),
      );
      
      print('🍎 Dashboard: Returned from PendingFoodSelectionPage');
      
      // Refresh data after categorization
      await ref.read(pendingFoodProvider.notifier).loadPendingFoods();
      
    } catch (e) {
      print('🍎 Dashboard: Error in _showPendingFoodsDialog: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved åbning af kategorisering: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Lige nu';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min siden';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} timer siden';  
    } else {
      return '${difference.inDays} dage siden';
    }
  }

  void _refreshProviders() {
    ref.read(foodLoggingProvider.notifier).refresh();
    ref.read(activityNotifierProvider).loadTodaysActivities();
    ref.read(weightTrackingProvider.notifier).refresh();
    ref.read(pendingFoodProvider.notifier).loadPendingFoods();
  }
}

/// Widget for displaying pending food selection cards with image navigation
class _PendingFoodSelectCard extends StatefulWidget {
  final PendingFoodModel food;
  final VoidCallback onTap;
  
  const _PendingFoodSelectCard({
    required this.food,
    required this.onTap,
  });
  
  @override
  State<_PendingFoodSelectCard> createState() => _PendingFoodSelectCardState();
}

class _PendingFoodSelectCardState extends State<_PendingFoodSelectCard> {
  int _currentImageIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: KSizes.margin2x),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        child: Padding(
          padding: EdgeInsets.all(KSizes.margin3x),
          child: Row(
            children: [
              // Image preview with navigation
              _buildImagePreview(),
              
              SizedBox(width: KSizes.margin3x),
              
              // Food info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.food.aiResult?.foodName.isNotEmpty == true 
                          ? widget.food.aiResult!.foodName
                          : 'Måltid ${widget.food.id.substring(widget.food.id.length - 4)}',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: KSizes.margin1x),
                    
                    if (widget.food.aiResult?.description.isNotEmpty == true) ...[
                      Text(
                        widget.food.aiResult!.description,
                        style: TextStyle(
                          fontSize: KSizes.fontSizeS,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: KSizes.margin1x),
                    ],
                    
                    Row(
                      children: [
                        Icon(
                          MdiIcons.clock,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          _formatDateTime(widget.food.capturedAt),
                          style: TextStyle(
                            fontSize: KSizes.fontSizeXS,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        if (widget.food.aiResult?.estimatedCalories != null && widget.food.aiResult!.estimatedCalories > 0) ...[
                          SizedBox(width: KSizes.margin2x),
                          Icon(
                            MdiIcons.fire,
                            size: 12,
                            color: AppColors.warning,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${widget.food.aiResult!.estimatedCalories} kcal',
                            style: TextStyle(
                              fontSize: KSizes.fontSizeXS,
                              color: AppColors.warning,
                              fontWeight: KSizes.fontWeightMedium,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              Icon(
                MdiIcons.chevronRight,
                color: AppColors.textSecondary,
                size: KSizes.iconS,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildImagePreview() {
    if (widget.food.imagePaths.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.border.withOpacity(0.2),
          borderRadius: BorderRadius.circular(KSizes.radiusS),
        ),
        child: Icon(
          MdiIcons.foodApple,
          color: AppColors.primary,
        ),
      );
    }
    
    return GestureDetector(
      onTap: widget.food.imageCount > 1 ? _showImageNavigator : null,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(KSizes.radiusS),
            child: Image.file(
              File(widget.food.imagePaths[_currentImageIndex]),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                color: AppColors.border.withOpacity(0.2),
                child: Icon(
                  MdiIcons.foodApple,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          
          // Image counter if multiple images
          if (widget.food.imageCount > 1)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(KSizes.radiusXS),
                ),
                child: Text(
                  '${_currentImageIndex + 1}/${widget.food.imageCount}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
          // Navigation hint if multiple images
          if (widget.food.imageCount > 1)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  MdiIcons.imageMultiple,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  void _showImageNavigator() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Billeder af måltid'),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: PageView.builder(
            controller: PageController(initialPage: _currentImageIndex),
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: widget.food.imageCount,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(KSizes.radiusM),
                child: Image.file(
                  File(widget.food.imagePaths[index]),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.border.withOpacity(0.2),
                    child: Icon(
                      MdiIcons.imageOff,
                      size: KSizes.iconXL,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Luk'),
          ),
        ],
      ),
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Lige nu';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min siden';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} timer siden';  
    } else {
      return '${difference.inDays} dage siden';
    }
  }
} 