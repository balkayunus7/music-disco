import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/core/util/locale_extensions.dart';
import 'package:music_disco/core/util/locale_keys.dart';

class StartupFailureApp extends StatelessWidget {
  const StartupFailureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      path: 'assets/translations',
      supportedLocales: LocaleLanguage.values.map((e) => e.locale).toList(),
      fallbackLocale: LocaleLanguage.en.locale,
      child: Builder(
        builder: (context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: Scaffold(
              body: SafeArea(
                child: Center(
                  child: Text(
                    LocaleKeys.startup_error.tr(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
