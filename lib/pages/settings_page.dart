import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';
import '../services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool dailyReminder = true;
  bool showFavorites = true;
  double dailyGoal = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentPage: 'Settings'),
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE29A),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 45, color: Colors.brown),
                ),
                SizedBox(height: 12),
                Text(
                  authService.currentUser?.displayName ?? 'Readify User',
                  style: const TextStyle(color: Colors.brown, fontSize: 22),
                ),
                Text(
                  authService.currentUser?.email ?? '',
                  style: const TextStyle(color: Colors.brown),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Theme Selection',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          RadioListTile<AppThemeType>(
            title: const Text('Soft Gold Theme'),
            value: AppThemeType.softGold,
            groupValue: themeController.themeType,
            activeColor: Colors.brown,
            onChanged: (value) {
              setState(() {
                themeController.setTheme(value!);
              });
            },
          ),
          RadioListTile<AppThemeType>(
            title: const Text('Soft Pink Theme'),
            value: AppThemeType.softPink,
            groupValue: themeController.themeType,
            activeColor: Colors.brown,
            onChanged: (value) {
              setState(() {
                themeController.setTheme(value!);
              });
            },
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Daily Reading Reminder'),
            subtitle: const Text('Show daily reminder option'),
            value: dailyReminder,
            onChanged: (value) {
              setState(() {
                dailyReminder = value;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Highlight Favorite Books'),
            value: showFavorites,
            onChanged: (value) {
              setState(() {
                showFavorites = value!;
              });
            },
          ),
          const SizedBox(height: 10),
          Text(
            'Daily Reading Goal: ${dailyGoal.toInt()} pages',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.brown,
            ),
          ),
          Slider(
            value: dailyGoal,
            min: 5,
            max: 100,
            divisions: 19,
            label: dailyGoal.toInt().toString(),
            activeColor: Colors.amber,
            onChanged: (value) {
              setState(() {
                dailyGoal = value;
              });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings saved locally.')),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('Save Settings'),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }
}