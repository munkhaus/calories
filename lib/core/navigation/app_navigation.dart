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
        onPressed: () {
          // Navigate to logging page
          setState(() {
            _currentIndex = 1;
          });
        },
        backgroundColor: AppColors.primary,
        child: Icon(
          MdiIcons.plus,
          color: Colors.white,
        ),
      ) : null,
    );
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