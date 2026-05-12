import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'firebase_options.dart';

import 'theme/theme_controller.dart';
import 'services/settings_service.dart';
import 'services/locale_provider.dart';
import 'services/notification_service.dart';
import 'pages/welcome_page.dart';
import 'pages/home_page.dart';
import 'pages/add_book_page.dart';
import 'pages/library_page.dart';
import 'pages/analytics_page.dart';
import 'pages/recommendations_page.dart';
import 'pages/settings_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  settingsService = await SettingsService.init();
  themeController.loadSavedTheme();
  localeProvider = LocaleProvider();

  await NotificationService.initialize();
  if (settingsService.dailyReminder) {
    await NotificationService.scheduleDailyReminder(
      settingsService.reminderHour,
      settingsService.reminderMinute,
    );
  }

  runApp(const ReadifyApp());
}

class ReadifyApp extends StatelessWidget {
  const ReadifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([themeController, localeProvider]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Readify',
          debugShowCheckedModeBanner: false,
          theme: themeController.lightTheme,
          darkTheme: themeController.darkTheme,
          themeMode: themeController.themeMode,
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LocaleProvider.supportedLocales,
          initialRoute: '/',
          routes: {
            '/': (context) => const WelcomePage(),
            '/home': (context) => const HomePage(),
            '/add': (context) => const AddBookPage(),
            '/library': (context) => const LibraryPage(),
            '/analytics': (context) => const AnalyticsPage(),
            '/recommendations': (context) => const RecommendationsPage(),
            '/settings': (context) => const SettingsPage(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/onboarding': (context) => const OnboardingPage(),
            '/profile': (context) => const ProfilePage(),
          },
        );
      },
    );
  }
}