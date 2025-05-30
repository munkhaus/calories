import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../constants/k_sizes.dart';
import '../theme/app_theme.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/progress/presentation/progress_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/food_logging/application/pending_food_cubit.dart';
import '../../features/food_logging/presentation/pages/food_search_page.dart';
import '../../features/food_logging/presentation/pages/categorize_food_page.dart';
import '../../features/food_logging/infrastructure/pending_food_service.dart';
import '../../features/activity/presentation/pages/quick_activity_registration_page.dart';
import '../../features/weight_tracking/application/weight_tracking_notifier.dart';
import '../../features/weight_tracking/domain/weight_entry_model.dart';
import '../../features/food_logging/application/food_logging_notifier.dart';
import '../../features/dashboard/application/date_aware_providers.dart';

/// Main app navigation with bottom navigation bar
class AppNavigation extends ConsumerStatefulWidget {
  const AppNavigation({super.key});

  @override
  ConsumerState<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends ConsumerState<AppNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const ProgressPage(),
    const ProfilePage(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: MdiIcons.home,
      label: 'Hjem',
    ),
    NavigationItem(
      icon: MdiIcons.chartLine,
      label: 'Forløb',
    ),
    NavigationItem(
      icon: Icons.person_outlined,
      label: 'Profil',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// Refresh all providers to update dashboard after registrations
  void _refreshProviders() {
    // Refresh food logging
    ProviderScope.containerOf(context).read(foodLoggingProvider.notifier).refresh();
    
    // Refresh activity data
    ProviderScope.containerOf(context).read(activityNotifierProvider).loadTodaysActivities();
    
    // Refresh weight tracking
    ProviderScope.containerOf(context).read(weightTrackingProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: KSizes.fontSizeXS,
        unselectedFontSize: KSizes.fontSizeXS,
        items: _navigationItems.map((item) => BottomNavigationBarItem(
          icon: Icon(item.icon),
          label: item.label,
        )).toList(),
      ),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () => _showRegistrationOptions(context),
        backgroundColor: AppColors.warning,
        foregroundColor: Colors.white,
        child: Icon(
          MdiIcons.plus,
          color: Colors.white,
          size: KSizes.iconL,
        ),
        tooltip: 'Registrer',
      ) : null,
    );
  }

  void _captureQuickFood(BuildContext context) async {
    final container = ProviderScope.containerOf(context);
    final cubit = container.read(pendingFoodProvider.notifier);
    
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
              Expanded(
                child: Text('Tager billede...'),
              ),
            ],
          ),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 1),
        ),
      );
      
      await cubit.captureFood();
      
      // Trigger refresh of providers to update home tab
      _refreshProviders();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(MdiIcons.check, color: Colors.white),
                SizedBox(width: KSizes.margin2x),
                Expanded(
                  child: Text('Billede taget! Kategoriser det når du er klar.'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'Se afventende',
              textColor: Colors.white,
              onPressed: () {
                // User is already on home tab, so just dismiss
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
                Expanded(
                  child: Text('Kunne ikke tage billede'),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Prøv igen',
              textColor: Colors.white,
              onPressed: () => _captureQuickFood(context),
            ),
          ),
        );
      }
    }
  }

  void _showRegistrationOptions(BuildContext context) {
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

  void _navigateToDetailedRegistration(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FoodSearchPage(
          // Ingen forudvalgt måltid - brugeren vælger selv
          initialMealType: null,
        ),
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
                // Weight input
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
                
                // Date selector
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
                
                // Notes
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
                    userId: 1, // TODO: Get actual user ID
                    weightKg: weight,
                    recordedAt: selectedDate,
                    notes: notesController.text.trim(),
                  );
                  
                  final success = await ref.read(weightTrackingProvider.notifier).addWeightEntry(entry);
                  
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    
                    if (success) {
                      // Trigger refresh of providers to update home tab
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

  void _openPendingFoodsRegistration(BuildContext context) {
    // Get first pending food and navigate to categorization
    final container = ProviderScope.containerOf(context);
    final pendingFoods = container.read(pendingFoodProvider).pendingFoodsState.data ?? [];
    
    if (pendingFoods.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CategorizeFoodPage(
            pendingFood: pendingFoods.first,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    
    // No longer adding test data - service starts clean
    // PendingFoodService.addTestData() - removed since method no longer exists
  }
}

class NavigationItem {
  final IconData icon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.label,
  });
} 