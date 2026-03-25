import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavScaffold extends StatelessWidget {
  const MainNavScaffold({required this.child, required this.location, super.key});

  final Widget child;
  final String location;

  static const tabs = [
    ('/home', Icons.home_outlined, Icons.home, 'Home'),
    ('/search', Icons.search_outlined, Icons.search, 'Search'),
    ('/orders', Icons.receipt_long_outlined, Icons.receipt_long, 'Orders'),
    ('/profile', Icons.person_outline, Icons.person, 'Profile'),
  ];

  int _indexForLocation() {
    if (location.startsWith('/order-tracking/')) {
      return 2;
    }
    for (var index = 0; index < tabs.length; index++) {
      if (location.startsWith(tabs[index].$1)) {
        return index;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _indexForLocation();

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: NavigationBar(
            selectedIndex: selectedIndex,
            indicatorColor: Theme.of(context).colorScheme.primaryContainer,
            destinations: [
              for (final tab in tabs)
                NavigationDestination(
                  icon: Icon(tab.$2),
                  selectedIcon: Icon(tab.$3),
                  label: tab.$4,
                ),
            ],
            onDestinationSelected: (index) {
              final target = tabs[index].$1;
              if (!location.startsWith(target)) {
                context.go(target);
              }
            },
          ),
        ),
      ),
    );
  }
}
