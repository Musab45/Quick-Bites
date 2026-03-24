import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavScaffold extends StatelessWidget {
  const MainNavScaffold({required this.child, required this.location, super.key});

  final Widget child;
  final String location;

  static const tabs = [
    ('/home', Icons.home_outlined, 'Home'),
    ('/search', Icons.search, 'Search'),
    ('/orders', Icons.receipt_long_outlined, 'Orders'),
    ('/profile', Icons.person_outline, 'Profile'),
  ];

  int _indexForLocation() {
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
            destinations: [
              for (final tab in tabs)
                NavigationDestination(
                  icon: Icon(tab.$2),
                  selectedIcon: Icon(tab.$2),
                  label: tab.$3,
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
