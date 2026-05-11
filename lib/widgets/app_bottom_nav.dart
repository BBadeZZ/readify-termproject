import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
      case 1:
        Navigator.pushReplacementNamed(context, '/library');
      case 2:
        Navigator.pushReplacementNamed(context, '/recommendations');
      case 3:
        Navigator.pushReplacementNamed(context, '/analytics');
      case 4:
        Navigator.pushReplacementNamed(context, '/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _navigate(context, index),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded),
          label: l10n.navHome,
        ),
        NavigationDestination(
          icon: const Icon(Icons.library_books_outlined),
          selectedIcon: const Icon(Icons.library_books_rounded),
          label: l10n.navLibrary,
        ),
        NavigationDestination(
          icon: const Icon(Icons.auto_awesome_outlined),
          selectedIcon: const Icon(Icons.auto_awesome),
          label: l10n.navSuggest,
        ),
        NavigationDestination(
          icon: const Icon(Icons.bar_chart_outlined),
          selectedIcon: const Icon(Icons.bar_chart_rounded),
          label: l10n.navAnalytics,
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings_rounded),
          label: l10n.navSettings,
        ),
      ],
    );
  }
}
