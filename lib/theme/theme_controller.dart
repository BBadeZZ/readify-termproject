import 'package:flutter/material.dart';
import '../services/settings_service.dart';

enum ThemeBrightness { light, dark, system }

class ThemeController extends ChangeNotifier {
  ThemeBrightness _brightness = ThemeBrightness.system;

  ThemeBrightness get brightness => _brightness;

  void loadSavedTheme() {
    final saved = settingsService.themeBrightness;
    _brightness = switch (saved) {
      'dark' => ThemeBrightness.dark,
      'light' => ThemeBrightness.light,
      _ => ThemeBrightness.system,
    };
  }

  void setBrightness(ThemeBrightness newBrightness) {
    _brightness = newBrightness;
    settingsService.saveThemeBrightness(newBrightness.name);
    notifyListeners();
  }

  ThemeData get lightTheme => _pinterestLight;
  ThemeData get darkTheme => _pinterestDark;

  ThemeMode get themeMode => switch (_brightness) {
    ThemeBrightness.light => ThemeMode.light,
    ThemeBrightness.dark => ThemeMode.dark,
    ThemeBrightness.system => ThemeMode.system,
  };

  // ── Light palette — dusty rose + warm cream ──────────────────────────────
  static const _rose = Color(0xFFC2606A);          // soft dusty rose
  static const _roseContainer = Color(0xFFFFD9DC); // blush container
  static const _onRoseContainer = Color(0xFF5C1A20);
  static const _lightSurface = Color(0xFFFFF8F6);  // warm white
  static const _lightScaffold = Color(0xFFFFF0EE); // very soft blush bg
  static const _lightOnSurface = Color(0xFF3E1E20);

  // ── Dark palette — deep plum + warm rose ────────────────────────────────
  static const _darkRose = Color(0xFFE09098);       // soft rose on dark
  static const _darkRoseContainer = Color(0xFF6B1820);
  static const _darkSurface = Color(0xFF1E1518);    // deep warm dark
  static const _darkScaffold = Color(0xFF180F12);
  static const _darkOnSurface = Color(0xFFF5E0E3);  // warm pinkish cream

  // ── Pinterest Soft Light ─────────────────────────────────────────────────
  final ThemeData _pinterestLight = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: _rose,
      onPrimary: Colors.white,
      primaryContainer: _roseContainer,
      onPrimaryContainer: _onRoseContainer,
      secondary: Color(0xFFA0735A),          // warm terracotta
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFFDDD0),
      onSecondaryContainer: Color(0xFF3E2010),
      tertiary: Color(0xFF7A8C6A),           // sage green
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFD8EDCC),
      onTertiaryContainer: Color(0xFF1E3010),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      surfaceContainerHighest: Color(0xFFF5E0DC),
      outline: Color(0xFFD4A0A8),
      outlineVariant: Color(0xFFEDC8CC),
    ),
    scaffoldBackgroundColor: _lightScaffold,
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightSurface,
      foregroundColor: _lightOnSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: _lightOnSurface,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: _lightOnSurface),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFEDC8CC), width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: _roseContainer,
      side: const BorderSide(color: Color(0xFFD4A0A8)),
      labelStyle: const TextStyle(
        color: _lightOnSurface,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: _roseContainer,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _lightOnSurface),
      ),
      iconTheme: WidgetStatePropertyAll(IconThemeData(color: _lightOnSurface)),
      elevation: 4,
      height: 68,
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _lightOnSurface, letterSpacing: -0.5),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _lightOnSurface),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _lightOnSurface),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _lightOnSurface),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _lightOnSurface),
      bodyLarge: TextStyle(fontSize: 16, color: _lightOnSurface, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF8B5560), height: 1.5),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _lightOnSurface),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _rose,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _rose,
        side: const BorderSide(color: _rose, width: 1.5),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(fontSize: 15, color: _lightOnSurface),
      hintStyle: TextStyle(fontSize: 14, color: _lightOnSurface.withValues(alpha: 0.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD4A0A8))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD4A0A8))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _rose, width: 2)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _rose,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFEDC8CC), thickness: 1, space: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: _rose, linearTrackColor: _roseContainer),
    sliderTheme: const SliderThemeData(activeTrackColor: _rose, thumbColor: _rose, inactiveTrackColor: _roseContainer),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(_rose),
      trackColor: WidgetStateProperty.fromMap({
        WidgetState.selected: _roseContainer,
        WidgetState.any: const Color(0xFFE8C8CC),
      }),
    ),
  );

  // ── Pinterest Soft Dark ──────────────────────────────────────────────────
  final ThemeData _pinterestDark = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: _darkRose,
      onPrimary: Color(0xFF3A0810),
      primaryContainer: _darkRoseContainer,
      onPrimaryContainer: Color(0xFFFFD9DC),
      secondary: Color(0xFFD4A890),          // warm terracotta on dark
      onSecondary: Color(0xFF3A1A08),
      secondaryContainer: Color(0xFF6B3820),
      onSecondaryContainer: Color(0xFFFFDDD0),
      tertiary: Color(0xFFA8C498),           // sage green on dark
      onTertiary: Color(0xFF0A2000),
      tertiaryContainer: Color(0xFF284018),
      onTertiaryContainer: Color(0xFFD8EDCC),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      surfaceContainerHighest: Color(0xFF342028),
      outline: Color(0xFF9A6870),
      outlineVariant: Color(0xFF6A3840),
    ),
    scaffoldBackgroundColor: _darkScaffold,
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkSurface,
      foregroundColor: _darkOnSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: _darkOnSurface,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: _darkOnSurface),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF281820),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF4A2830), width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF281820),
      selectedColor: _darkRoseContainer,
      side: const BorderSide(color: Color(0xFF9A6870)),
      labelStyle: const TextStyle(
        color: _darkOnSurface,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: _darkSurface,
      indicatorColor: _darkRoseContainer,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _darkOnSurface),
      ),
      iconTheme: WidgetStatePropertyAll(IconThemeData(color: _darkOnSurface)),
      elevation: 8,
      height: 68,
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _darkOnSurface, letterSpacing: -0.5),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _darkOnSurface),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _darkOnSurface),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _darkOnSurface),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _darkOnSurface),
      bodyLarge: TextStyle(fontSize: 16, color: _darkOnSurface, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFCAA0A8), height: 1.5),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _darkOnSurface),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkRose,
        foregroundColor: const Color(0xFF3A0810),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkRose,
        side: const BorderSide(color: _darkRose, width: 1.5),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF281820),
      labelStyle: const TextStyle(fontSize: 15, color: _darkOnSurface),
      hintStyle: TextStyle(fontSize: 14, color: _darkOnSurface.withValues(alpha: 0.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF9A6870))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF9A6870))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _darkRose, width: 2)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _darkRose,
      foregroundColor: Color(0xFF3A0810),
      elevation: 4,
      shape: CircleBorder(),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF6A3840), thickness: 1, space: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: _darkRose, linearTrackColor: _darkRoseContainer),
    sliderTheme: const SliderThemeData(activeTrackColor: _darkRose, thumbColor: _darkRose, inactiveTrackColor: _darkRoseContainer),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(_darkRose),
      trackColor: WidgetStateProperty.fromMap({
        WidgetState.selected: _darkRoseContainer,
        WidgetState.any: const Color(0xFF3A1820),
      }),
    ),
  );
}

final ThemeController themeController = ThemeController();
