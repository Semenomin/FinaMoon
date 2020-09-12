import 'package:flutter/material.dart';
import '../config.dart';
import '../generated/locale_base.dart';

class LocDelegate extends LocalizationsDelegate<LocaleBase> {
  const LocDelegate();
  final idMap = const {'en': 'locales/EN_US.json', 'ru': 'locales/RU.json'};

  @override
  bool isSupported(Locale locale) => ['en', 'ru'].contains(locale.languageCode);

  @override
  Future<LocaleBase> load(Locale locale) async {
    var lang = Config.appLanguage;
    if (isSupported(locale)) lang = locale.languageCode;
    final loc = LocaleBase();
    await loc.load(idMap[lang]);
    return loc;
  }

  @override
  bool shouldReload(LocDelegate old) => false;
}
