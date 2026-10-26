import 'dart:ui' show Locale;

import 'package:easy_transit/l10n/l10n.dart';
import 'package:easy_transit/providers/shared_prefs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Exposes the current app locale. Guaranteed to be the same as visible
/// on the Settings page. For currently visible country locale,
/// see [countryLocaleProvider].
final languageProvider = NotifierProvider<LanguageController, Locale?>(LanguageController.new);

final localizationsProvider = Provider<AppLocalizations>((ref) {
  const kDefaultLocale = Locale('en', 'US');
  return lookupAppLocalizations(ref.watch(languageProvider) ?? kDefaultLocale);
});

class LanguageController extends Notifier<Locale?> {
  static const kLocaleKey = 'stored_locale';
  static const kNull = '-';

  @override
  Locale? build() {
    ref.read(sharedPrefsProvider).whenData((prefs) {
      final l = prefs.getStringList(kLocaleKey);
      if (l != null) {
        state = Locale.fromSubtags(
          languageCode: l[0],
          countryCode: l[1] == kNull ? null : l[1],
          scriptCode: l[2] == kNull ? null : l[2],
        );
      }
    });
    return null;
  }

  Future<void> set(Locale? newValue) async {
    if (state != newValue) {
      state = newValue;
      final prefs = ref.read(sharedPrefsProvider).requireValue;
      if (newValue == null) {
        await prefs.remove(kLocaleKey);
      } else {
        await prefs.setStringList(kLocaleKey, [
          newValue.languageCode,
          newValue.countryCode ?? kNull,
          newValue.scriptCode ?? kNull,
        ]);
      }
    }
  }
}
