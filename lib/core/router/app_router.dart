import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:autism_avc_flutter/features/calendar/calendar_screen.dart';
import 'package:autism_avc_flutter/features/dashboard/dashboard_screen.dart';
import 'package:autism_avc_flutter/features/items/item_detail_screen.dart';
import 'package:autism_avc_flutter/features/items/item_form_screen.dart';
import 'package:autism_avc_flutter/features/child/child_screen.dart';
import 'package:autism_avc_flutter/features/settings/settings_screen.dart';
import 'package:autism_avc_flutter/l10n/app_localizations.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/child',
          builder: (context, state) => const ChildScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/items/new',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final dateStr = state.uri.queryParameters['date'];
        final initialDate =
            dateStr != null ? DateTime.tryParse(dateStr) : null;
        return ItemFormScreen(initialDate: initialDate);
      },
    ),
    GoRoute(
      path: '/items/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ItemDetailScreen(itemId: id);
      },
    ),
    GoRoute(
      path: '/items/:id/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ItemFormScreen(editItemId: id);
      },
    ),
  ],
);

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex(context),
        onDestinationSelected: (index) => _onTap(context, index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home),
            label: l10n.today,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month),
            label: l10n.calendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
          NavigationDestination(
            icon: const Icon(Icons.child_care),
            label: l10n.child,
          ),
        ],
      ),
    );
  }

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/calendar')) return 1;
    if (location.startsWith('/settings')) return 2;
    if (location.startsWith('/child')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
      case 1:
        context.go('/calendar');
      case 2:
        context.go('/settings');
      case 3:
        context.go('/child');
    }
  }
}
