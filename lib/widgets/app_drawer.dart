import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  final String currentPage;

  const AppDrawer({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: cs.surface,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primaryContainer, cs.secondaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: cs.primary.withValues(alpha: 0.15),
                  child: Icon(Icons.auto_stories_rounded, color: cs.primary, size: 30),
                ),
                const SizedBox(height: 12),
                Text(
                  authService.currentUser?.displayName ?? 'Readify User',
                  style: TextStyle(
                    color: cs.onPrimaryContainer,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  authService.currentUser?.email ?? '',
                  style: TextStyle(
                    color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(context, icon: Icons.person_outline_rounded, label: 'Profile', route: '/profile', selected: currentPage == 'Profile'),
                _DrawerItem(context, icon: Icons.home_outlined, label: 'Home', route: '/home', selected: currentPage == 'Home'),
                _DrawerItem(context, icon: Icons.add_circle_outline_rounded, label: 'Add Book', route: '/add', selected: currentPage == 'Add Book'),
                _DrawerItem(context, icon: Icons.library_books_outlined, label: 'Library', route: '/library', selected: currentPage == 'Library'),
                _DrawerItem(context, icon: Icons.bar_chart_outlined, label: 'Analytics', route: '/analytics', selected: currentPage == 'Analytics'),
                _DrawerItem(context, icon: Icons.auto_awesome_outlined, label: 'Recommendations', route: '/recommendations', selected: currentPage == 'Recommendations'),
                _DrawerItem(context, icon: Icons.settings_outlined, label: 'Settings', route: '/settings', selected: currentPage == 'Settings'),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
                ),
                ListTile(
                  leading: Icon(Icons.logout_rounded, color: cs.error),
                  title: Text('Logout', style: TextStyle(color: cs.error, fontWeight: FontWeight.w600)),
                  onTap: () async {
                    Navigator.pop(context);
                    await authService.logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _DrawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required bool selected,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: selected ? cs.primaryContainer.withValues(alpha: 0.6) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: selected ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? cs.primary : cs.onSurface,
            fontSize: 15,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, route);
        },
      ),
    );
  }
}
