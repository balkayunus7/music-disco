import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum LocaleLanguage {
  en('en', 'English'),
  tr('tr', 'Türkçe');

  const LocaleLanguage(this.value, this.nativeName);

  factory LocaleLanguage.fromLocale(Locale locale) {
    return LocaleLanguage.values.firstWhere(
      (e) => e.value == locale.languageCode,
      orElse: () => LocaleLanguage.en,
    );
  }

  final String value;
  final String nativeName;

  static List<Locale> get supportedLocales =>
      values.map((language) => language.locale).toList();

  Locale get locale => Locale(value);
}

extension LocaleExtensions on BuildContext {
  List<Locale> get supportedCoreLocales => LocaleLanguage.supportedLocales;

  Locale get currentLocale => locale;

  bool get isLocaleEn => currentLocale.languageCode == LocaleLanguage.en.value;
  bool get isLocaleTr => currentLocale.languageCode == LocaleLanguage.tr.value;

  LocaleLanguage get currentLocaleLanguage =>
      LocaleLanguage.fromLocale(currentLocale);
}
