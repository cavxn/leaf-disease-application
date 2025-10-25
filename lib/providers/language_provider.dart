import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'language_code';
  Locale _locale = const Locale('en', 'US');

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'en';
    final countryCode = prefs.getString('${_languageKey}_country') ?? 'US';
    _locale = Locale(languageCode, countryCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
    await prefs.setString('${_languageKey}_country', locale.countryCode ?? '');
    notifyListeners();
  }

  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'hi': 'हिंदी',
    'zh': '中文',
  };
} 