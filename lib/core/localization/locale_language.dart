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

  Locale get locale => Locale(value);
}

extension LocaleExtensions on BuildContext {
  List<Locale> get supportedCoreLocales =>
      LocaleLanguage.values.map((e) => e.locale).toList();

  Locale get currentLocale => locale;

  bool get isLocaleEn => currentLocale.languageCode == LocaleLanguage.en.value;
  bool get isLocaleTr => currentLocale.languageCode == LocaleLanguage.tr.value;

  LocaleLanguage get currentLocaleLanguage =>
      LocaleLanguage.fromLocale(currentLocale);
}
