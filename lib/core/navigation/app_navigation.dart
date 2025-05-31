import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../constants/k_sizes.dart';
import '../theme/app_theme.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/progress/presentation/progress_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/food_logging/presentation/pages/favorites_page.dart';
import '../../features/food_logging/application/pending_food_cubit.dart';
import '../../features/food_logging/presentation/pages/food_search_page.dart';
import '../../features/food_logging/presentation/pages/categorize_food_page.dart';
import '../../features/food_logging/infrastructure/pending_food_service.dart';
import '../../features/activity/presentation/pages/quick_activity_registration_page.dart';
import '../../features/weight_tracking/application/weight_tracking_notifier.dart';
import '../../features/weight_tracking/domain/weight_entry_model.dart';
import '../../features/food_logging/application/food_logging_notifier.dart';
import '../../features/dashboard/application/date_aware_providers.dart';
import '../../features/planning/presentation/planning_page.dart';
import '../../features/activity/presentation/activity_page.dart';
import '../../features/info/presentation/info_page.dart';
import '../../features/food_logging/presentation/pages/multi_photo_meal_page.dart';
import '../../features/food_logging/application/meal_session_cubit.dart';
import '../../features/food_logging/presentation/pages/food_favorites_page.dart';
import '../../features/activity/presentation/pages/activity_favorites_page.dart';
import '../../features/activity/presentation/pages/detailed_activity_registration_page.dart';
import '../../features/food_logging/presentation/pages/quick_photo_session_page.dart';
import '../../features/food_logging/presentation/pages/quick_favorites_page.dart';

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
    const FavoritesPage(),
    const ProgressPage(),
    const ProfilePage(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: MdiIcons.home,
      label: 'Hjem',
    ),
    NavigationItem(
      icon: MdiIcons.star,
      label: 'Favoritter',
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
    if (!mounted) return;
    
    print('🔄 AppNavigation: All providers refreshed after registration');
    
    try {
      // Always refresh pending foods first - this is stable
      try {
        ref.read(pendingFoodProvider.notifier).loadPendingFoods();
        print('🔄 AppNavigation: Pending foods refreshed');
      } catch (e) {
        print('🔄 AppNavigation: Pending food refresh failed: $e');
      }
      
      // Only refresh other providers if we're on the home tab to avoid unnecessary work
      if (_currentIndex == 0) {
        // Use a small delay to allow navigation to complete
        Future.delayed(Duration(milliseconds: 100), () {
          if (!mounted) return;
          
          try {
            // Use the new centralized refresh function
            refreshActivityCalories(ref);
            
            print('🔄 AppNavigation: Activity calories refreshed');
          } catch (e) {
            print('🔄 AppNavigation: Activity calories refresh failed: $e');
          }
          
          try {
            // Refresh food logging for the selected date
            ref.read(foodLoggingProvider.notifier).refresh();
            
            print('🔄 AppNavigation: Food logging refreshed');
          } catch (e) {
            print('🔄 AppNavigation: Food logging refresh failed: $e');
          }
        });
      }
      
      print('🔄 AppNavigation: Provider refresh completed');
    } catch (e) {
      print('🔄 AppNavigation: Provider refresh failed: $e');
    }
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
        heroTag: "nav_fab",
        onPressed: () => _showMainCategoryDialog(context),
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
              Flexible(
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
                Flexible(
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
                Flexible(
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
            // Hurtig Billeder - DIRECT on first level
            _buildMainCategoryOption(
              context: context,
              icon: MdiIcons.cameraPlus,
              title: 'Hurtig Billeder',
              subtitle: 'Tag flere billeder af samme måltid',
              color: AppColors.warning,
              onTap: () {
                Navigator.of(context).pop();
                _startMultiPhotoWithCapture(context);
              },
            ),
            
            SizedBox(height: KSizes.margin3x),
            
            // Food category
            _buildMainCategoryOption(
              context: context,
              icon: MdiIcons.foodApple,
              title: 'Mad & Drikke',
              subtitle: 'Registrer måltider og snacks',
              color: AppColors.success,
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
            
            SizedBox(height: KSizes.margin3x),
            
            // Weight registration - ADDED BACK!
            _buildMainCategoryOption(
              context: context,
              icon: MdiIcons.scaleBalance,
              title: 'Vægt Registrering',
              subtitle: 'Registrer din nuværende vægt',
              color: AppColors.primary,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToWeightRegistration(context);
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
    ).then((_) {
      // Refresh providers when returning from detailed registration
      _refreshProviders();
    });
  }

  void _navigateToActivityRegistration(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuickActivityRegistrationPage(),
      ),
    ).then((_) {
      // Refresh providers when returning from activity registration
      _refreshProviders();
    });
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

  void _navigateToMultiPhotoMeal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiPhotoMealPage(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    
    // No longer adding test data - service starts clean
    // PendingFoodService.addTestData() - removed since method no longer exists
  }

  Widget _buildMainCategoryOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
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
      ),
    );
  }

  void _showFoodSubmenu(BuildContext context) {
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
            // Favorites option - FIRST
            _buildSubmenuOption(
              context: context,
              icon: MdiIcons.star,
              title: 'Fra Favoritter',
              subtitle: 'Vælg fra gemte mad-favoritter',
              color: AppColors.primary,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToFoodFavorites(context);
              },
            ),
            
            SizedBox(height: KSizes.margin3x),
            
            // Detailed registration - SECOND
            _buildSubmenuOption(
              context: context,
              icon: MdiIcons.formTextbox,
              title: 'Detaljeret Registrering',
              subtitle: 'Søg og log mad med alle detaljer',
              color: AppColors.info,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToDetailedRegistration(context);
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

  void _showActivitySubmenu(BuildContext context) {
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
            // Favorites option - FIRST
            _buildSubmenuOption(
              context: context,
              icon: MdiIcons.star,
              title: 'Fra Favoritter',
              subtitle: 'Vælg fra gemte aktiviteter',
              color: AppColors.primary,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToActivityFavorites(context);
              },
            ),
            
            SizedBox(height: KSizes.margin3x),
            
            // Detailed registration - SECOND
            _buildSubmenuOption(
              context: context,
              icon: MdiIcons.formTextbox,
              title: 'Detaljeret Registrering',
              subtitle: 'Søg og log aktiviteter med alle detaljer',
              color: AppColors.info,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToDetailedActivity(context);
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

  Widget _buildSubmenuOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
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
      ),
    );
  }

  void _navigateToActivityFavorites(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuickFavoritesPage(initialTab: 1), // Activity tab
      ),
    ).then((_) {
      // Refresh providers when returning from activity favorites
      _refreshProviders();
    });
  }

  void _navigateToDetailedActivity(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailedActivityRegistrationPage(),
      ),
    ).then((_) {
      // Refresh providers when returning from detailed activity registration
      _refreshProviders();
    });
  }

  void _navigateToFoodFavorites(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuickFavoritesPage(initialTab: 0), // Food tab
      ),
    ).then((_) {
      // Refresh providers when returning from food favorites
      _refreshProviders();
    });
  }

  void _startMultiPhotoWithCapture(BuildContext context) async {
    // Navigate directly to multi-photo session - it will handle the first capture
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuickPhotoSessionPage(),
      ),
    ).then((_) {
      // Refresh providers when returning from photo session
      _refreshProviders();
    });
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