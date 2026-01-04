import 'package:flutter/material.dart';
import '../../utils/translations.dart';

class SettingsStore extends ChangeNotifier {
  String _language = 'en';
  String get language => _language;

  late Translations translations;

  // إعدادات أخرى
  String currency = 'USD';
  bool isDarkMode = false;
  bool notificationsEnabled = true;
  double textScale = 1.0;

  SettingsStore() {
    _loadTranslations();
  }

  // ===================== Translations =====================
  Future<void> _loadTranslations() async {
    translations = await Translations.forLanguage(_language);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    await _loadTranslations();
  }

  // ===================== Currency =====================
  void setCurrency(String val) {
    currency = val;
    notifyListeners();
  }

  /// Getter للعملة الرمزية
  String get currencySymbol {
    switch (currency) {
      case 'USD':
        return 'USD';
      case 'JOD':
        return 'JOD';
     
      default:
        return currency;
    }
  }

  // ===================== Other Settings =====================
  void setNotifications(bool val) {
    notificationsEnabled = val;
    notifyListeners();
  }

  void setTextScale(double val) {
    textScale = val;
    notifyListeners();
  }

  void toggleDarkMode() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  void resetSettings() {
    _language = 'en';
    currency = 'USD';
    isDarkMode = false;
    notificationsEnabled = true;
    textScale = 1.0;
    _loadTranslations();
  }
}
