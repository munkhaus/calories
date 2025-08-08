import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RootShell extends StatefulWidget {
  const RootShell({required this.child, super.key});

  final Widget child;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  static const List<_TabSpec> _tabs = <_TabSpec>[
    _TabSpec(location: '/today', icon: Icons.home_outlined, label: 'Today'),
    _TabSpec(location: '/log', icon: Icons.add_chart_outlined, label: 'Log'),
    _TabSpec(location: '/trends', icon: Icons.show_chart, label: 'Trends'),
    _TabSpec(location: '/goals', icon: Icons.flag_outlined, label: 'Goals'),
    _TabSpec(
      location: '/settings',
      icon: Icons.settings_outlined,
      label: 'Settings',
    ),
  ];

  int _currentIndexFromLocation(String location) {
    final int index = _tabs.indexWhere((t) => location.startsWith(t.location));
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final String currentLocation = GoRouterState.of(context).uri.toString();
    final int currentIndex = _currentIndexFromLocation(currentLocation);

    return Scaffold(
      body: SafeArea(child: widget.child),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet<void>(
            context: context,
            showDragHandle: true,
            isScrollControlled: false,
            builder: (BuildContext bottomSheetContext) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: const Icon(Icons.restaurant),
                        title: const Text('Food'),
                        onTap: () {
                          Navigator.of(bottomSheetContext).pop();
                          context.go('/log/add');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.local_drink_outlined),
                        title: const Text('Water'),
                        onTap: () {
                          Navigator.of(bottomSheetContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Water: not implemented yet'),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.monitor_weight_outlined),
                        title: const Text('Weight'),
                        onTap: () {
                          Navigator.of(bottomSheetContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Weight: not implemented yet'),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.note_add_outlined),
                        title: const Text('Note'),
                        onTap: () {
                          Navigator.of(bottomSheetContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Note: not implemented yet'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (int index) => context.go(_tabs[index].location),
        destinations: _tabs
            .map(
              (t) => NavigationDestination(
                icon: Icon(t.icon),
                label: t.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec({
    required this.location,
    required this.icon,
    required this.label,
  });

  final String location;
  final IconData icon;
  final String label;
}
