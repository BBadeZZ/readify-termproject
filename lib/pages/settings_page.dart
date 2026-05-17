import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';
import '../services/settings_service.dart';
import '../services/notification_service.dart';
import '../services/locale_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';

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

  Future<void> _toggleReminder(bool value) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    setState(() => dailyReminder = value);

    await settingsService.saveDailyReminder(value);

    if (value) {
      await NotificationService.scheduleDailyReminder(
        reminderHour,
        reminderMinute,
        title: l10n.settingsDailyReminder,
        body: l10n.settingsDailyReminderSub,
      );
    } else {
      await NotificationService.cancelAll();
    }

    final msg = kIsWeb
        ? 'Notifications are only supported on mobile & desktop apps'
        : value
        ? l10n.settingsReminderSet(_reminderTimeLabel)
        : l10n.settingsReminderCancelled;

    messenger.showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _pickReminderTime() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: reminderHour,
        minute: reminderMinute,
      ),
    );

    if (picked != null) {
      setState(() {
        reminderHour = picked.hour;
        reminderMinute = picked.minute;
      });

      await settingsService.saveReminderTime(
        picked.hour,
        picked.minute,
      );

      await NotificationService.scheduleDailyReminder(
        picked.hour,
        picked.minute,
        title: l10n.settingsDailyReminder,
        body: l10n.settingsDailyReminderSub,
      );

      final h = picked.hour.toString().padLeft(2, '0');
      final m = picked.minute.toString().padLeft(2, '0');

      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.settingsReminderSet('$h:$m')),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: const AppDrawer(currentPage: 'Settings'),
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.primaryContainer,
                  cs.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: cs.surface,
                  child: Icon(
                    Icons.person,
                    size: 45,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  authService.currentUser?.displayName ?? 'Readify User',
                  style: tt.titleLarge?.copyWith(
                    color: cs.onPrimaryContainer,
                  ),
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

          Text(
            l10n.settingsAppearance,
            style: tt.titleLarge,
          ),

          const SizedBox(height: 10),

          SegmentedButton<ThemeBrightness>(
            selected: {themeController.brightness},
            onSelectionChanged: (selection) {
              setState(() {
                themeController.setBrightness(selection.first);
              });
            },
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: cs.primaryContainer,
              selectedForegroundColor: cs.onPrimaryContainer,
            ),
            segments: [
              ButtonSegment(
                value: ThemeBrightness.light,
                icon: const Icon(
                  Icons.light_mode_rounded,
                  size: 18,
                ),
                label: Text(l10n.settingsBrightnessLight),
              ),
              ButtonSegment(
                value: ThemeBrightness.system,
                icon: const Icon(
                  Icons.brightness_auto_rounded,
                  size: 18,
                ),
                label: Text(l10n.settingsBrightnessSystem),
              ),
              ButtonSegment(
                value: ThemeBrightness.dark,
                icon: const Icon(
                  Icons.dark_mode_rounded,
                  size: 18,
                ),
                label: Text(l10n.settingsBrightnessDark),
              ),
            ],
          ),

          const SizedBox(height: 8),

          SwitchListTile(
            title: Text(l10n.settingsDailyReminder),
            subtitle: Text(l10n.settingsDailyReminderSub),
            value: dailyReminder,
            onChanged: _toggleReminder,
          ),

          if (dailyReminder) ...[
            ListTile(
              leading: Icon(
                Icons.access_time,
                color: cs.primary,
              ),
              title: Text(l10n.settingsReminderTime),
              subtitle: Text(_reminderTimeLabel),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickReminderTime,
            ),
            if (kIsWeb)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Notifications work on Android, iOS & desktop. Not supported in browser.',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],

          CheckboxListTile(
            title: Text(l10n.settingsHighlightFavorites),
            value: showFavorites,
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                showFavorites = value;
              });

              settingsService.saveShowFavorites(value);
            },
          ),

          const SizedBox(height: 10),

          Text(
            l10n.settingsDailyGoal(dailyGoal.toInt()),
            style: tt.titleMedium,
          ),

          Slider(
            value: dailyGoal,
            min: 5,
            max: 100,
            divisions: 19,
            label: dailyGoal.toInt().toString(),
            onChanged: (value) {
              setState(() {
                dailyGoal = value;
              });
            },
            onChangeEnd: (value) {
              settingsService.saveDailyGoal(value);
            },
          ),

          const SizedBox(height: 10),

          Text(
            l10n.settingsLanguage,
            style: tt.titleLarge,
          ),

          RadioGroup<String>(
            groupValue: localeProvider.locale.languageCode,
            onChanged: (value) {
              if (value != null) {
                localeProvider.setLocale(Locale(value));
              }
            },
            child: const Column(
              children: [
                RadioListTile<String>(
                  title: Text('English'),
                  value: 'en',
                ),
                RadioListTile<String>(
                  title: Text('Türkçe'),
                  value: 'tr',
                ),
                RadioListTile<String>(
                  title: Text('العربية'),
                  value: 'ar',
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }
}