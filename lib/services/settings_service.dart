import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyTheme = 'theme_type';
  static const _keyDailyReminder = 'daily_reminder';
  static const _keyShowFavorites = 'show_favorites';
  static const _keyDailyGoal = 'daily_goal';

  final SharedPreferences _prefs;

  SettingsService._(this._prefs);

  static Future<SettingsService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService._(prefs);
  }

  String get themeType => _prefs.getString(_keyTheme) ?? 'softGold';
  Future<void> saveTheme(String value) => _prefs.setString(_keyTheme, value);

  bool get dailyReminder => _prefs.getBool(_keyDailyReminder) ?? true;
  Future<void> saveDailyReminder(bool value) =>
      _prefs.setBool(_keyDailyReminder, value);

  bool get showFavorites => _prefs.getBool(_keyShowFavorites) ?? true;
  Future<void> saveShowFavorites(bool value) =>
      _prefs.setBool(_keyShowFavorites, value);

  double get dailyGoal => _prefs.getDouble(_keyDailyGoal) ?? 20.0;
  Future<void> saveDailyGoal(double value) =>
      _prefs.setDouble(_keyDailyGoal, value);
}

late SettingsService settingsService;
