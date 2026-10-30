import 'package:flutter/material.dart';
import '../state/app_store.dart';
import 'home_screen.dart';
import 'vendor_screens.dart';
import 'event_screens.dart';
import 'profile_screens.dart';

class AppShell extends StatefulWidget {
  final AppStore store;
  const AppShell({super.key, required this.store});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selected = 0;
  void tab(int index) => setState(() => selected = index);
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) => PopScope(
      canPop: selected == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && selected != 0) tab(0);
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: selected,
            children: [
              HomeScreen(store: widget.store, onTab: tab),
              ExploreScreen(store: widget.store),
              MyEventsScreen(store: widget.store),
              UpdatesScreen(store: widget.store),
              ProfileScreen(store: widget.store, onTab: tab),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selected,
          onDestinationSelected: tab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_rounded),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              label: 'My events',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_none_rounded),
              label: 'Updates',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    ),
  );
}
