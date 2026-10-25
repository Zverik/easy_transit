import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// First message people see, when the app is opening feed files from memory.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// On the loading screen, a message when acquiring geolocation.
  ///
  /// In en, this message translates to:
  /// **'Finding you...'**
  String get acquiringLocation;

  /// Accessibility label for my location button on the main screen.
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get myLocation;

  /// Title of the alert for enabling location services.
  ///
  /// In en, this message translates to:
  /// **'Enable GPS'**
  String get enableGPS;

  /// Contents of the alert for enabling location services.
  ///
  /// In en, this message translates to:
  /// **'Please turn on the location services in the settings panel that will be shown.'**
  String get enableGPSMessage;

  /// Title of the alert for allowing app access to location.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get enableLocation;

  /// Contents of the alert for allowing app access to location.
  ///
  /// In en, this message translates to:
  /// **'Please allow location access for the app in the settings panel that will be shown.'**
  String get enableLocationMessage;

  /// For the timetable, prefix for next arrival ('next 12:30'). Keep it short.
  ///
  /// In en, this message translates to:
  /// **'next {time}'**
  String next(String time);

  /// Placeholder for the search text field.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// Item in the search panel to direct to the map for choosing a destination.
  ///
  /// In en, this message translates to:
  /// **'Choose on a map...'**
  String get chooseOnMap;

  /// Accessibility label for a map icon next to a search result.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get showMap;

  /// Title for the page where you choose a destination on a map.
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get whereTo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
