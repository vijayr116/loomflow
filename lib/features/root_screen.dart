import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  int _getIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();

    if (loc.startsWith('/jobs')) return 1;
    if (loc.startsWith('/weavers')) return 2;
    if (loc.startsWith('/settings')) return 3;

    return 0;
  }

  String _getTitle(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();

    if (loc.startsWith('/jobs')) return 'Jobs';

    if (loc.startsWith('/weavers')) {
      return 'Weavers';
    }

    if (loc.startsWith('/settings')) {
      return 'Settings';
    }

    return 'Dashboard';
  }

  @override
  Widget build(BuildContext context) {
    final index = _getIndex(context);

    return Scaffold(
      appBar: AppBar(title: Text(_getTitle(context))),

      body: child,

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (value) {
                switch (value) {
                  case 0:
                    context.go('/dashboard');
                    break;
                  case 1:
                    context.go('/jobs');
                    break;
                  case 2:
                    context.go('/weavers');
                    break;
                  case 3:
                    context.go('/settings');
                    break;
                }
              },
              height: 72,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
              indicatorColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.16),
              surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
              animationDuration: const Duration(milliseconds: 250),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.work_outline),
                  selectedIcon: Icon(Icons.work),
                  label: 'Jobs',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: 'Weavers',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
