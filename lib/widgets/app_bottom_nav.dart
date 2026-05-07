import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/library');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/recommendations');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/analytics');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.brown,
      unselectedItemColor: Colors.brown.shade300,
      backgroundColor: const Color(0xFFFFF5DC),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      onTap: (index) => _navigate(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_books_rounded),
          label: 'Library',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_awesome),
          label: 'Suggest',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_rounded),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_rounded),
          label: 'Settings',
        ),
      ],
    );
  }
}