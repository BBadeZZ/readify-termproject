import 'package:flutter/material.dart';
import '../services/settings_service.dart';

enum AppThemeType { softGold, softPink }

class ThemeController extends ChangeNotifier {
  AppThemeType _themeType = AppThemeType.softGold;

  AppThemeType get themeType => _themeType;

  void loadSavedTheme() {
    final saved = settingsService.themeType;
    _themeType =
        saved == 'softPink' ? AppThemeType.softPink : AppThemeType.softGold;
  }

  void setTheme(AppThemeType newTheme) {
    _themeType = newTheme;
    settingsService.saveTheme(newTheme.name);
    notifyListeners();
  }

  ThemeData get currentTheme {
    if (_themeType == AppThemeType.softPink) {
      return _softPinkTheme;
    }
    return _softGoldTheme;
  }

  final ThemeData _softGoldTheme = ThemeData(
    primarySwatch: Colors.amber,
    scaffoldBackgroundColor: const Color(0xFFFFF8E7),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF7D774),
      foregroundColor: Colors.brown,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.brown,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 17, color: Colors.brown),
      bodyLarge: TextStyle(fontSize: 18, color: Colors.brown),
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.brown,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFD76A),
        foregroundColor: Colors.brown,
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(fontSize: 16, color: Colors.brown),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFFD76A),
      foregroundColor: Colors.brown,
    ),
  );

  final ThemeData _softPinkTheme = ThemeData(
    primarySwatch: Colors.pink,
    scaffoldBackgroundColor: const Color(0xFFFFF1F6),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFD6E7),
      foregroundColor: Color(0xFF7A3E57),
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFF7A3E57),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 17, color: Color(0xFF7A3E57)),
      bodyLarge: TextStyle(fontSize: 18, color: Color(0xFF7A3E57)),
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF7A3E57),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFB7D5),
        foregroundColor: const Color(0xFF7A3E57),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(fontSize: 16, color: Color(0xFF7A3E57)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFFB7D5),
      foregroundColor: Color(0xFF7A3E57),
    ),
  );
}

final ThemeController themeController = ThemeController();