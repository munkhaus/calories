import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../constants/k_sizes.dart';
import '../theme/app_theme.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/progress/presentation/progress_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/activity/presentation/activity_page.dart';
import '../../features/food_logging/application/pending_food_cubit.dart';
import '../../features/food_logging/presentation/pages/food_search_page.dart';
import '../../features/food_logging/presentation/pages/categorize_food_page.dart';
import '../../features/food_logging/infrastructure/pending_food_service.dart';
import '../../features/food_logging/domain/pending_food_model.dart';
import '../../features/activity/presentation/pages/quick_activity_registration_page.dart';
import '../../features/weight_tracking/application/weight_tracking_notifier.dart';
import '../../features/weight_tracking/domain/weight_entry_model.dart';
import '../../features/food_logging/application/food_logging_notifier.dart';
import '../../features/dashboard/application/date_aware_providers.dart';
import '../../features/planning/presentation/planning_page.dart';
import '../../features/info/presentation/info_page.dart';
import '../../features/food_logging/presentation/pages/multi_photo_meal_page.dart';
import '../../features/food_logging/application/meal_session_cubit.dart';
import '../../features/food_logging/presentation/pages/food_favorites_page.dart';
import '../../features/activity/presentation/pages/activity_favorites_page.dart';
import '../../features/activity/presentation/pages/detailed_activity_registration_page.dart';
import '../../features/food_logging/presentation/pages/quick_photo_session_page.dart';
import '../../features/food_logging/presentation/pages/quick_favorites_page.dart';
import '../../features/food_logging/presentation/pages/favorites_page.dart';
import '../../features/food_database/presentation/widgets/food_edit_dialog.dart';
import '../../features/food_database/application/food_database_cubit.dart';
import '../../features/food_logging/domain/user_food_log_model.dart';
import '../../features/food_logging/domain/favorite_food_model.dart';

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
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🚀 SECTION 1: QUICK LOG (Most common actions)
              _buildSectionHeader('🚀 Hurtig Log', 'De mest brugte funktioner'),
              SizedBox(height: KSizes.margin2x),
              
              // Quick Photos - most used feature
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
              
              SizedBox(height: KSizes.margin2x),
              
              // Weight registration
              _buildMainCategoryOption(
                context: context,
                icon: MdiIcons.scaleBalance,
                title: 'Vægt Registrering',
                subtitle: 'Registrer din nuværende vægt',
                color: AppColors.info,
                onTap: () {
                  Navigator.of(context).pop();
                  _navigateToWeightRegistration(context);
                },
              ),
              
              SizedBox(height: KSizes.margin4x),
              
              // 💫 SECTION 2: FROM FAVORITES (Selection from existing)
              _buildSectionHeader('💫 Fra Favoritter', 'Vælg fra dine gemte favoritter'),
              SizedBox(height: KSizes.margin2x),
              
              // Food favorites - meals
              _buildMainCategoryOption(
                context: context,
                icon: MdiIcons.silverwareForkKnife,
                title: 'Retter',
                subtitle: 'Vælg fra dine gemte retter',
                color: AppColors.success,
                onTap: () {
                  Navigator.of(context).pop();
                  _navigateToFoodFavoritesWithFilter(context, FoodType.meal);
                },
              ),
              
              SizedBox(height: KSizes.margin2x),
              
              // Food favorites - ingredients
              _buildMainCategoryOption(
                context: context,
                icon: MdiIcons.carrot,
                title: 'Fødevarer',
                subtitle: 'Vælg fra dine gemte fødevarer',
                color: AppColors.success,
                onTap: () {
                  Navigator.of(context).pop();
                  _navigateToFoodFavoritesWithFilter(context, FoodType.ingredient);
                },
              ),
              
              SizedBox(height: KSizes.margin2x),
              
              // Activity favorites
              _buildMainCategoryOption(
                context: context,
                icon: MdiIcons.runFast,
                title: 'Aktiviteter',
                subtitle: 'Vælg fra dine gemte aktiviteter',
                color: AppColors.secondary,
                onTap: () {
                  Navigator.of(context).pop();
                  _navigateToActivityFavorites(context);
                },
              ),
              
              SizedBox(height: KSizes.margin4x),
              
              // 🔧 SECTION 3: ADVANCED (Detailed/Manual registration)
              _buildSectionHeader('🔧 Avanceret', 'Detaljeret registrering og tilpasning'),
              SizedBox(height: KSizes.margin2x),
              
              // Manual food entry
              _buildMainCategoryOption(
                context: context,
                icon: MdiIcons.foodApple,
                title: 'Manuel Mad',
                subtitle: 'Detaljeret madregistrering',
                color: AppColors.primary,
                onTap: () {
                  Navigator.of(context).pop();
                  _navigateToDetailedRegistration(context);
                },
              ),
              
              SizedBox(height: KSizes.margin2x),
              
              // Manual activity entry
              _buildMainCategoryOption(
                context: context,
                icon: MdiIcons.run,
                title: 'Manuel Aktivitet',
                subtitle: 'Detaljeret aktivitetsregistrering',
                color: AppColors.primary,
                onTap: () {
                  Navigator.of(context).pop();
                  _navigateToDetailedActivity(context);
                },
              ),
            ],
          ),
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

  Widget _buildSectionHeader(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: KSizes.margin1x),
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
              fontSize: KSizes.fontSizeS,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: KSizes.margin2x),
          Container(
            height: 1,
            width: double.infinity,
            color: AppColors.textSecondary.withOpacity(0.2),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KSizes.radiusM),
      child: Container(
        padding: EdgeInsets.all(KSizes.margin4x),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.textSecondary.withOpacity(0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(KSizes.radiusM),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(KSizes.margin2x),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(KSizes.radiusS),
              ),
              child: Icon(
                icon,
                color: iconColor,
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
                      fontSize: KSizes.fontSizeL,
                      fontWeight: KSizes.fontWeightMedium,
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
    );
  }

  void _navigateToDetailedRegistration(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ManualFoodEntryDialog(),
    );
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

  void _navigateToActivityFavorites(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActivityFavoritesPage(),
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
        builder: (context) => QuickFavoritesPage(
          showAddButton: false, // Hide add button - we just want to use existing favorites
        ),
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

  void _navigateToFoodFavoritesWithFilter(BuildContext context, FoodType foodType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FavoritesPage(
          initialFilter: foodType,
        ),
      ),
    ).then((_) {
      // Refresh providers when returning from filtered favorites
      _refreshProviders();
    });
  }
}

/// Simple dialog for manual food entry focused on logging meals
class _ManualFoodEntryDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ManualFoodEntryDialog> createState() => _ManualFoodEntryDialogState();
}

class _ManualFoodEntryDialogState extends ConsumerState<_ManualFoodEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _gramsController = TextEditingController();
  
  bool _isLogging = false;
  bool _useCaloriesPer100g = false; // Toggle between total calories and calories per 100g

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _gramsController.dispose();
    super.dispose();
  }

  // Calculate total calories based on mode
  int _calculateTotalCalories() {
    final grams = double.tryParse(_gramsController.text.trim()) ?? 100; // Default to 100g if not specified
    final caloriesValue = int.tryParse(_caloriesController.text.trim()) ?? 0;
    
    if (_useCaloriesPer100g && _gramsController.text.trim().isNotEmpty) {
      // Calculate total calories from calories per 100g
      return ((caloriesValue * grams) / 100).round();
    } else {
      // Use total calories directly
      return caloriesValue;
    }
  }

  // Determine meal type based on current time
  MealType _getMealTypeFromTime() {
    final now = DateTime.now();
    final hour = now.hour;
    
    if (hour >= 5 && hour < 11) {
      return MealType.morgenmad;
    } else if (hour >= 11 && hour < 16) {
      return MealType.frokost;
    } else if (hour >= 16 && hour < 22) {
      return MealType.aftensmad;
    } else {
      return MealType.snack;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusL),
      ),
      title: Row(
        children: [
          Icon(MdiIcons.silverwareForkKnife, color: AppColors.primary),
          SizedBox(width: KSizes.margin2x),
          Text('Registrer Mad'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Food name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Navn på mad',
                  hintText: 'f.eks. Spaghetti Bolognese',
                  prefixIcon: Icon(MdiIcons.foodVariant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                  ),
                ),
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Indtast navn på maden';
                  }
                  return null;
                },
                autofocus: true,
              ),
              
              SizedBox(height: KSizes.margin4x),
              
              // Calorie input mode toggle
              Container(
                padding: EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hvordan vil du angive kalorier?',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        fontWeight: KSizes.fontWeightMedium,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: KSizes.margin2x),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _useCaloriesPer100g = false;
                                _caloriesController.clear();
                              });
                            },
                            borderRadius: BorderRadius.circular(KSizes.radiusS),
                            child: Container(
                              padding: EdgeInsets.all(KSizes.margin2x),
                              decoration: BoxDecoration(
                                color: !_useCaloriesPer100g ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(KSizes.radiusS),
                                border: Border.all(
                                  color: !_useCaloriesPer100g ? AppColors.primary : AppColors.border,
                                ),
                              ),
                              child: Text(
                                'Samlet kalorier',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: !_useCaloriesPer100g ? Colors.white : AppColors.textSecondary,
                                  fontWeight: !_useCaloriesPer100g ? KSizes.fontWeightMedium : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: KSizes.margin2x),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _useCaloriesPer100g = true;
                                _caloriesController.clear();
                              });
                            },
                            borderRadius: BorderRadius.circular(KSizes.radiusS),
                            child: Container(
                              padding: EdgeInsets.all(KSizes.margin2x),
                              decoration: BoxDecoration(
                                color: _useCaloriesPer100g ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(KSizes.radiusS),
                                border: Border.all(
                                  color: _useCaloriesPer100g ? AppColors.primary : AppColors.border,
                                ),
                              ),
                              child: Text(
                                'Kalorier pr. 100g',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _useCaloriesPer100g ? Colors.white : AppColors.textSecondary,
                                  fontWeight: _useCaloriesPer100g ? KSizes.fontWeightMedium : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: KSizes.margin4x),
              
              // Calories input (MAIN FOCUS)
              TextFormField(
                controller: _caloriesController,
                decoration: InputDecoration(
                  labelText: _useCaloriesPer100g ? 'Kalorier pr. 100g' : 'Samlet kalorier',
                  hintText: _useCaloriesPer100g ? '250' : '450',
                  suffixText: 'kcal',
                  prefixIcon: Icon(MdiIcons.fire, color: Colors.orange),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Indtast kalorier';
                  }
                  if (int.tryParse(value!) == null) {
                    return 'Ugyldig tal';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Trigger rebuild to update calculated calories display
                  setState(() {});
                },
              ),
              
              // Show grams input only if using per 100g mode
              if (_useCaloriesPer100g) ...[
                SizedBox(height: KSizes.margin4x),
                
                // Grams input (OPTIONAL)
                TextFormField(
                  controller: _gramsController,
                  decoration: InputDecoration(
                    labelText: 'Mængde (valgfrit)',
                    hintText: '150',
                    suffixText: 'gram',
                    prefixIcon: Icon(MdiIcons.scaleBalance),
                    helperText: 'Hvis ikke angivet bruges 100g',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KSizes.radiusM),
                    ),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value?.trim().isNotEmpty ?? false) {
                      final grams = double.tryParse(value!);
                      if (grams == null || grams <= 0) {
                        return 'Ugyldig mængde';
                      }
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Trigger rebuild to update calculated calories display
                    setState(() {});
                  },
                ),
              ],
              
              // Show calculated total calories if using per 100g mode
              if (_useCaloriesPer100g && _caloriesController.text.isNotEmpty) ...[
                SizedBox(height: KSizes.margin3x),
                Container(
                  padding: EdgeInsets.all(KSizes.margin3x),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(MdiIcons.calculator, color: AppColors.success),
                      SizedBox(width: KSizes.margin2x),
                      Expanded(
                        child: Text(
                          'Samlet kalorier: ${_calculateTotalCalories()} kcal',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeM,
                            fontWeight: KSizes.fontWeightMedium,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLogging ? null : () => Navigator.of(context).pop(),
          child: Text('Annuller'),
        ),
        ElevatedButton(
          onPressed: _isLogging ? null : _logFood,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isLogging
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('Log Mad'),
        ),
      ],
    );
  }

  Future<void> _logFood() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLogging = true;
    });

    try {
      final totalCalories = _calculateTotalCalories();
      final grams = double.tryParse(_gramsController.text.trim()) ?? 100.0; // Default to 100g if not specified
      final mealType = _getMealTypeFromTime(); // Auto-determine based on time

      // Create food log entry
      final foodLog = UserFoodLogModel(
        userId: 1, // TODO: Get actual user ID
        customFoodId: DateTime.now().millisecondsSinceEpoch, // Use customFoodId for manual entries
        foodName: _nameController.text.trim(),
        mealType: mealType, // Auto-determined from time
        quantity: grams,
        servingUnit: 'g', // Always grams
        calories: totalCalories,
        protein: 0.0, // Keep simple - no nutrition details
        fat: 0.0,
        carbs: 0.0,
        foodItemSourceType: FoodItemSourceType.custom,
      );

      // Log the food
      await ref.read(foodLoggingProvider.notifier).logFood(foodLog);

      if (mounted) {
        Navigator.of(context).pop();
        
        // Show success message with auto-determined meal type
        String mealTypeText = _getMealTypeDisplayName(mealType);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_nameController.text.trim()} logget som ${mealTypeText.toLowerCase()}! (${totalCalories} kcal)'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved logging af mad'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLogging = false;
        });
      }
    }
  }

  String _getMealTypeDisplayName(MealType type) {
    switch (type) {
      case MealType.morgenmad:
        return 'Morgenmad';
      case MealType.frokost:
        return 'Frokost';
      case MealType.aftensmad:
        return 'Aftensmad';
      case MealType.snack:
        return 'Snack';
      case MealType.none:
        return 'Ingen kategori';
    }
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