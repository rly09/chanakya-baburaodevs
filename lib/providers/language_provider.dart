import 'package:flutter/material.dart';
import '../utils/translations.dart';

// Independent Language Provider to break circular dependencies
class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = "English";
  String get currentLanguage => _currentLanguage;

  void setLanguage(String lang) {
    _currentLanguage = lang;
    notifyListeners();
  }

  String translate(String text) {
    return AppTranslations.translate(text, _currentLanguage);
  }
}
