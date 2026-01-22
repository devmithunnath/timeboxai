import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage locale preferences and language metadata
class LocalizationService {
  static const String _localeKey = 'selected_locale';

  /// Get saved locale from SharedPreferences
  Future<Locale?> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);
    if (localeCode != null) {
      final parts = localeCode.split('_');
      if (parts.length == 2) {
        return Locale(parts[0], parts[1]);
      }
      return Locale(parts[0]);
    }
    return null;
  }

  /// Save locale to SharedPreferences
  Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode =
        locale.countryCode != null
            ? '${locale.languageCode}_${locale.countryCode}'
            : locale.languageCode;
    await prefs.setString(_localeKey, localeCode);
  }

  /// Get list of all supported languages with metadata
  List<LocaleInfo> getSupportedLanguages() {
    return [
      LocaleInfo(const Locale('en'), '🇬🇧', 'English'),
      LocaleInfo(const Locale('zh', 'Hans'), '🇨🇳', '简体中文'),
      LocaleInfo(const Locale('zh', 'Hant'), '🇹🇼', '繁體中文'),
      LocaleInfo(const Locale('ja'), '🇯🇵', '日本語'),
      LocaleInfo(const Locale('de'), '🇩🇪', 'Deutsch'),
      LocaleInfo(const Locale('fr'), '🇫🇷', 'Français'),
      LocaleInfo(const Locale('es'), '🇪🇸', 'Español'),
      LocaleInfo(const Locale('es', 'MX'), '🇲🇽', 'Español (México)'),
      LocaleInfo(const Locale('pt', 'BR'), '🇧🇷', 'Português (Brasil)'),
      LocaleInfo(const Locale('pt', 'PT'), '🇵🇹', 'Português (Portugal)'),
      LocaleInfo(const Locale('hi'), '🇮🇳', 'हिन्दी'),
      LocaleInfo(const Locale('ar'), '🇸🇦', 'العربية'),
      LocaleInfo(const Locale('ko'), '🇰🇷', '한국어'),
      LocaleInfo(const Locale('it'), '🇮🇹', 'Italiano'),
      LocaleInfo(const Locale('nl'), '🇳🇱', 'Nederlands'),
      LocaleInfo(const Locale('ru'), '🇷🇺', 'Русский'),
      LocaleInfo(const Locale('tr'), '🇹🇷', 'Türkçe'),
      LocaleInfo(const Locale('sv'), '🇸🇪', 'Svenska'),
      LocaleInfo(const Locale('pl'), '🇵🇱', 'Polski'),
      LocaleInfo(const Locale('id'), '🇮🇩', 'Bahasa Indonesia'),
      LocaleInfo(const Locale('th'), '🇹🇭', 'ไทย'),
      LocaleInfo(const Locale('vi'), '🇻🇳', 'Tiếng Việt'),
    ];
  }
}

/// Metadata for a locale including flag emoji and native name
class LocaleInfo {
  final Locale locale;
  final String flag;
  final String nativeName;

  LocaleInfo(this.locale, this.flag, this.nativeName);
}
