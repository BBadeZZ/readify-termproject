import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';
import '../services/settings_service.dart';
import '../services/notification_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';
import '../services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool dailyReminder;
  late bool showFavorites;
  late double dailyGoal;
  late int reminderHour;
  late int reminderMinute;

  @override
  void initState() {
    super.initState();
    dailyReminder = settingsService.dailyReminder;
    showFavorites = settingsService.showFavorites;
    dailyGoal = settingsService.dailyGoal;
    reminderHour = settingsService.reminderHour;
    reminderMinute = settingsService.reminderMinute;
  }

  String get _reminderTimeLabel {
    final h = reminderHour.toString().padLeft(2, '0');
    final m = reminderMinute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: reminderHour, minute: reminderMinute),
    );
    if (picked != null) {
      setState(() {
        reminderHour = picked.hour;
        reminderMinute = picked.minute;
      });
      await settingsService.saveReminderTime(picked.hour, picked.minute);
      await NotificationService.scheduleDailyReminder(picked.hour, picked.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      drawer: const AppDrawer(currentPage: 'Settings'),
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: cs.surface,
                  child: Icon(Icons.person, size: 45, color: cs.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  authService.currentUser?.displayName ?? 'Readify User',
                  style: tt.titleLarge?.copyWith(color: cs.onPrimaryContainer),
                ),
                Text(
                  authService.currentUser?.email ?? '',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onPrimaryContainer.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Theme
          Text(
            'Theme Selection',
            style: tt.titleLarge,
          ),
          RadioGroup<AppThemeType>(
            groupValue: themeController.themeType,
            onChanged: (value) {
              setState(() => themeController.setTheme(value!));
            },
            child: const Column(
              children: [
                RadioListTile<AppThemeType>(
                  title: Text('Soft Gold Theme'),
                  value: AppThemeType.softGold,
                ),
                RadioListTile<AppThemeType>(
                  title: Text('Soft Pink Theme'),
                  value: AppThemeType.softPink,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Daily reminder toggle
          SwitchListTile(
            title: const Text('Daily Reading Reminder'),
            subtitle: const Text('Receive a daily push notification'),
            value: dailyReminder,
            onChanged: (value) async {
              setState(() => dailyReminder = value);
              await settingsService.saveDailyReminder(value);
              if (value) {
                await NotificationService.scheduleDailyReminder(
                    reminderHour, reminderMinute);
              } else {
                await NotificationService.cancelAll();
              }
            },
          ),

          // Reminder time picker — only visible when reminder is ON
          if (dailyReminder)
            ListTile(
              leading: Icon(Icons.access_time, color: cs.primary),
              title: const Text('Reminder Time'),
              subtitle: Text(_reminderTimeLabel),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickReminderTime,
            ),

          CheckboxListTile(
            title: const Text('Highlight Favorite Books'),
            value: showFavorites,
            onChanged: (value) {
              setState(() => showFavorites = value!);
              settingsService.saveShowFavorites(value!);
            },
          ),
          const SizedBox(height: 10),

          // Daily goal
          Text(
            'Daily Reading Goal: ${dailyGoal.toInt()} pages',
            style: tt.titleMedium,
          ),
          Slider(
            value: dailyGoal,
            min: 5,
            max: 100,
            divisions: 19,
            label: dailyGoal.toInt().toString(),
            onChanged: (value) => setState(() => dailyGoal = value),
            onChangeEnd: (value) => settingsService.saveDailyGoal(value),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }
}
