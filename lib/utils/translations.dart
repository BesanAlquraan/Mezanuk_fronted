import 'dart:convert';
import 'package:flutter/services.dart';

class Translations {
  final String language;
  late Map<String, dynamic> _localizedStrings;

  Translations(this.language);

  Future<void> load() async {
    final jsonString = await rootBundle.loadString('assets/lang/$language.json');
    _localizedStrings = json.decode(jsonString);
  }

  String of(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Static helper
  static Future<Translations> forLanguage(String lang) async {
    final t = Translations(lang);
    await t.load();
    return t;
  }
}
