import 'package:flutter/material.dart';
import 'settings_service.dart';

class LocaleProvider extends ChangeNotifier {
  static const supportedLocales = [
    Locale('en'),
    Locale('tr'),
    Locale('ar'),
  ];

  Locale _locale;

  LocaleProvider() : _locale = Locale(settingsService.languageCode);

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await settingsService.saveLanguageCode(locale.languageCode);
    notifyListeners();
  }
}

late LocaleProvider localeProvider;
