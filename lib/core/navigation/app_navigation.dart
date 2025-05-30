import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../constants/k_sizes.dart';
import '../theme/app_theme.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/logging/presentation/logging_page.dart';
import '../../features/progress/presentation/progress_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/activity/presentation/activity_page.dart'; // Re-enabled
import '../../features/food_logging/application/pending_food_cubit.dart';
import '../../features/food_logging/presentation/pages/food_search_page.dart';
import '../../features/food_logging/presentation/pages/categorize_food_page.dart';
import '../../features/food_logging/infrastructure/pending_food_service.dart';

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
    const LoggingPage(),
    const ActivityPage(), // Re-enabled for testing
    const ProgressPage(),
    const ProfilePage(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: MdiIcons.home,
      label: 'Hjem',
    ),
    NavigationItem(
      icon: MdiIcons.foodAppleOutline,
      label: 'Mad',
    ),
    NavigationItem(
      icon: MdiIcons.runFast,
      label: 'Aktivitet',
    ), // Re-enabled for testing
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
    final previousIndex = _currentIndex;
    
    setState(() {
      _currentIndex = index;
    });
    
    // If switching to home tab (0) from activity tab (2), refresh dashboard activity data
    if (index == 0 && previousIndex == 2) {
      print('🔄 Switching from Activity tab to Home tab - refreshing dashboard');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        DashboardPage.refreshActivityData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0 ? AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final pendingCount = ref.watch(pendingFoodsCountProvider);
              
              if (pendingCount == 0) return const SizedBox.shrink();
              
              return GestureDetector(
                onTap: () => _openPendingFoodsRegistration(context),
                child: Container(
                  margin: const EdgeInsets.only(right: KSizes.margin4x),
                  padding: const EdgeInsets.symmetric(
                    horizontal: KSizes.margin3x,
                    vertical: KSizes.margin2x,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.warning, AppColors.warning.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(KSizes.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.warning.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        MdiIcons.camera,
                        color: Colors.white,
                        size: KSizes.iconS,
                      ),
                      const SizedBox(width: KSizes.margin1x),
                      Text(
                        '$pendingCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: KSizes.fontSizeS,
                          fontWeight: KSizes.fontWeightBold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ) : null,
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
        tooltip: 'Registrer mad',
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
              Text('Tager billede...'),
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
                Text('Billede taget! Kategoriser det når du er klar.'),
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
                Text('Kunne ikke tage billede'),
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
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(KSizes.radiusXL),
            topRight: Radius.circular(KSizes.radiusXL),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(KSizes.margin6x),
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
              
              SizedBox(height: KSizes.margin4x),
              
              // Header
              Text(
                'Registrer mad',
                style: TextStyle(
                  fontSize: KSizes.fontSizeXXL,
                  fontWeight: KSizes.fontWeightBold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              SizedBox(height: KSizes.margin2x),
              
              Text(
                'Vælg hvordan du vil registrere din mad',
                style: TextStyle(
                  fontSize: KSizes.fontSizeM,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: KSizes.margin8x),
              
              // Quick registration option
              _buildRegistrationOption(
                context: context,
                title: 'Hurtig registrering',
                subtitle: 'Tag et billede og kategoriser senere',
                icon: MdiIcons.cameraPlus,
                iconColor: AppColors.warning,
                onTap: () {
                  Navigator.of(context).pop();
                  _captureQuickFood(context);
                },
              ),
              
              SizedBox(height: KSizes.margin4x),
              
              // Detailed registration option
              _buildRegistrationOption(
                context: context,
                title: 'Detaljeret registrering',
                subtitle: 'Søg og log mad med alle detaljer',
                icon: MdiIcons.silverwareForkKnife,
                iconColor: AppColors.primary,
                onTap: () {
                  Navigator.of(context).pop();
                  _navigateToDetailedRegistration(context);
                },
              ),
              
              SizedBox(height: KSizes.margin4x),
            ],
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
    
    // Add test data for pending foods
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PendingFoodService.addTestData();
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