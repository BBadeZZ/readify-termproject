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
    if (_themeType == AppThemeType.softPink) return _softPinkTheme;
    return _softGoldTheme;
  }

  static const _goldPrimary = Color(0xFFB8740A);
  static const _goldSurface = Color(0xFFFFF8E7);
  static const _goldOnSurface = Color(0xFF3E2000);
  static const _goldContainer = Color(0xFFFFE29A);

  static const _pinkPrimary = Color(0xFF9C3566);
  static const _pinkSurface = Color(0xFFFFF1F6);
  static const _pinkOnSurface = Color(0xFF5C1A38);
  static const _pinkContainer = Color(0xFFFFD6E7);

  final ThemeData _softGoldTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: _goldPrimary,
      onPrimary: Colors.white,
      primaryContainer: _goldContainer,
      onPrimaryContainer: _goldOnSurface,
      secondary: Color(0xFFD4860A),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFFECC0),
      onSecondaryContainer: _goldOnSurface,
      tertiary: Color(0xFF6B8E23),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFDEF7BA),
      onTertiaryContainer: Color(0xFF1A3300),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: _goldSurface,
      onSurface: _goldOnSurface,
      surfaceContainerHighest: Color(0xFFF5E6C0),
      outline: Color(0xFFD4A04A),
      outlineVariant: Color(0xFFEDD38A),
    ),
    scaffoldBackgroundColor: _goldSurface,
    appBarTheme: const AppBarTheme(
      backgroundColor: _goldSurface,
      foregroundColor: _goldOnSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: _goldOnSurface,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: _goldOnSurface),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFEDD38A), width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: _goldContainer,
      side: const BorderSide(color: Color(0xFFD4A04A)),
      labelStyle: const TextStyle(
        color: _goldOnSurface,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: _goldContainer,
      labelTextStyle: WidgetStatePropertyAll(TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _goldOnSurface,
      )),
      iconTheme: WidgetStatePropertyAll(IconThemeData(color: _goldOnSurface)),
      elevation: 4,
      height: 68,
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _goldOnSurface, letterSpacing: -0.5),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _goldOnSurface),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _goldOnSurface),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _goldOnSurface),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _goldOnSurface),
      bodyLarge: TextStyle(fontSize: 16, color: _goldOnSurface, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF6B4C1A), height: 1.5),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _goldOnSurface),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _goldPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _goldPrimary,
        side: const BorderSide(color: _goldPrimary, width: 1.5),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(fontSize: 15, color: _goldOnSurface),
      hintStyle: TextStyle(fontSize: 14, color: _goldOnSurface.withValues(alpha: 0.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD4A04A))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD4A04A))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _goldPrimary, width: 2)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _goldPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFEDD38A), thickness: 1, space: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: _goldPrimary, linearTrackColor: _goldContainer),
    sliderTheme: const SliderThemeData(activeTrackColor: _goldPrimary, thumbColor: _goldPrimary, inactiveTrackColor: _goldContainer),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(_goldPrimary),
      trackColor: WidgetStateProperty.fromMap({WidgetState.selected: _goldContainer, WidgetState.any: const Color(0xFFE0CEAD)}),
    ),
  );

  final ThemeData _softPinkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: _pinkPrimary,
      onPrimary: Colors.white,
      primaryContainer: _pinkContainer,
      onPrimaryContainer: _pinkOnSurface,
      secondary: Color(0xFFB5446E),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFFE0ED),
      onSecondaryContainer: _pinkOnSurface,
      tertiary: Color(0xFF7E5EA8),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFEDDCFF),
      onTertiaryContainer: Color(0xFF260054),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: _pinkSurface,
      onSurface: _pinkOnSurface,
      surfaceContainerHighest: Color(0xFFFADCEB),
      outline: Color(0xFFD48FAB),
      outlineVariant: Color(0xFFFFBDD4),
    ),
    scaffoldBackgroundColor: _pinkSurface,
    appBarTheme: const AppBarTheme(
      backgroundColor: _pinkSurface,
      foregroundColor: _pinkOnSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: _pinkOnSurface,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: _pinkOnSurface),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFFFBDD4), width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: _pinkContainer,
      side: const BorderSide(color: Color(0xFFD48FAB)),
      labelStyle: const TextStyle(color: _pinkOnSurface, fontSize: 13, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: _pinkContainer,
      labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _pinkOnSurface)),
      iconTheme: WidgetStatePropertyAll(IconThemeData(color: _pinkOnSurface)),
      elevation: 4,
      height: 68,
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _pinkOnSurface, letterSpacing: -0.5),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _pinkOnSurface),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _pinkOnSurface),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _pinkOnSurface),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _pinkOnSurface),
      bodyLarge: TextStyle(fontSize: 16, color: _pinkOnSurface, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF8B3558), height: 1.5),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _pinkOnSurface),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _pinkPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _pinkPrimary,
        side: const BorderSide(color: _pinkPrimary, width: 1.5),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(fontSize: 15, color: _pinkOnSurface),
      hintStyle: TextStyle(fontSize: 14, color: _pinkOnSurface.withValues(alpha: 0.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD48FAB))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD48FAB))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _pinkPrimary, width: 2)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _pinkPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFFFBDD4), thickness: 1, space: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: _pinkPrimary, linearTrackColor: _pinkContainer),
    sliderTheme: const SliderThemeData(activeTrackColor: _pinkPrimary, thumbColor: _pinkPrimary, inactiveTrackColor: _pinkContainer),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(_pinkPrimary),
      trackColor: WidgetStateProperty.fromMap({WidgetState.selected: _pinkContainer, WidgetState.any: const Color(0xFFE8C0CF)}),
    ),
  );
}

final ThemeController themeController = ThemeController();
