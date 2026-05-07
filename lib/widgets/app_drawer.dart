import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String currentPage;

  const AppDrawer({super.key, required this.currentPage});

  Widget drawerItem(
      BuildContext context,
      IconData icon,
      String title,
      String route,
      ) {
    bool selected = currentPage == title;

    return ListTile(
      leading: Icon(
        icon,
        color: selected ? Colors.brown : Colors.black54,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? Colors.brown : Colors.black87,
          fontSize: 17,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFF7D774),
            ),
            accountName: const Text(
              'Readify User',
              style: TextStyle(color: Colors.brown),
            ),
            accountEmail: const Text(
              'smart.reading@app.com',
              style: TextStyle(color: Colors.brown),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.auto_stories,
                color: Colors.brown,
                size: 40,
              ),
            ),
          ),
          drawerItem(context, Icons.home, 'Home', '/home'),
          drawerItem(context, Icons.add_circle, 'Add Book', '/add'),
          drawerItem(context, Icons.library_books, 'Library', '/library'),
          drawerItem(context, Icons.analytics, 'Analytics', '/analytics'),
          drawerItem(context, Icons.star, 'Recommendations', '/recommendations'),
          drawerItem(context, Icons.settings, 'Settings', '/settings'),
        ],
      ),
    );
  }
}