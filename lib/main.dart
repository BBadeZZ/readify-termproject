import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'theme/theme_controller.dart';
import 'services/settings_service.dart';
import 'pages/welcome_page.dart';
import 'pages/home_page.dart';
import 'pages/add_book_page.dart';
import 'pages/library_page.dart';
import 'pages/analytics_page.dart';
import 'pages/recommendations_page.dart';
import 'pages/settings_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  settingsService = await SettingsService.init();
  themeController.loadSavedTheme();

  runApp(const ReadifyApp());
}

class ReadifyApp extends StatelessWidget {
  const ReadifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Readify',
          debugShowCheckedModeBanner: false,
          theme: themeController.currentTheme,
          initialRoute: '/',
          routes: {
            '/': (context) => const WelcomePage(),
            '/home': (context) => HomePage(),
            '/add': (context) => AddBookPage(),
            '/library': (context) => LibraryPage(),
            '/analytics': (context) => AnalyticsPage(),
            '/recommendations': (context) => const RecommendationsPage(),
            '/settings': (context) => SettingsPage(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
          },
        );
      },
    );
  }
}