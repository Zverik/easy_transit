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

  /// Bookmark screen title.
  ///
  /// In en, this message translates to:
  /// **'Add Bookmark'**
  String get addBookmark;

  /// Hint on the bookmark adding screen.
  ///
  /// In en, this message translates to:
  /// **'Bookmark name'**
  String get bookmarkName;

  /// Hint for the emoji picked on the bookmark adding screen.
  ///
  /// In en, this message translates to:
  /// **'Choose an emoji'**
  String get chooseEmoji;

  /// Text on a panel for deleting a bookmark.
  ///
  /// In en, this message translates to:
  /// **'Delete bookmark \"{name}\"?'**
  String deleteBookmark(String name);

  /// Button text for bookmark deletion.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Text displayed when the app is looking for routes to a destination.
  ///
  /// In en, this message translates to:
  /// **'Looking for a route...'**
  String get lookingForRoute;

  /// When no routes to a destination found.
  ///
  /// In en, this message translates to:
  /// **'No routes found, sorry.'**
  String get noRoutes;

  /// Shorthand for minutes, used like '3 min'.
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String minutes(Object value);

  /// Subtitle for a planned route. Used like 'Tram 2 leaves at 11:34 from Balti jaam'.
  ///
  /// In en, this message translates to:
  /// **'{bus} leaves at {time} from {stop}'**
  String busLeavesFrom(String bus, DateTime time, String stop);

  /// Duration in minutes.
  ///
  /// In en, this message translates to:
  /// **'{value,plural, =1{{value} minute} few{{value} minutes} other{{value} minutes}}'**
  String fullMinutes(num value);

  /// Accessibility text for walking N minutes.
  ///
  /// In en, this message translates to:
  /// **'Walk {min}'**
  String walkMin(Object min);

  /// Accessibility text for an arrival row.
  ///
  /// In en, this message translates to:
  /// **'{bus} to {headsign} arrives {when}'**
  String arrivesText(Object bus, Object headsign, Object when);

  /// Accessibility text for the route plan bookmark button.
  ///
  /// In en, this message translates to:
  /// **'Save route plan'**
  String get storePlan;

  /// Accessibility text for the route plan button on the main screen.
  ///
  /// In en, this message translates to:
  /// **'Stored route plan'**
  String get restorePlan;

  /// Itinerary text for walking.
  ///
  /// In en, this message translates to:
  /// **'Walk {distance} m to <b>{destination}</b> (the yellow circle).'**
  String walkMeters(Object distance, String destination);

  /// Comment about walking time.
  ///
  /// In en, this message translates to:
  /// **'You\'ve got {minutes}.'**
  String youGotTime(String minutes);

  /// Comment about walking time when the speed is very low.
  ///
  /// In en, this message translates to:
  /// **'Don\'t hurry, you\'ve got {minutes}.'**
  String noHurry(String minutes);

  /// Generic name of a destination waypoint.
  ///
  /// In en, this message translates to:
  /// **'destination'**
  String get walkDestination;

  /// Number of stops for an itinerary text.
  ///
  /// In en, this message translates to:
  /// **'{stops,plural, =1{{stops} stop} few{{stops} stops} other{{stops} stops}}'**
  String stops(num stops);

  /// Itinerary text for riding a few stops after waiting.
  ///
  /// In en, this message translates to:
  /// **'Wait for {min} and ride {stops} to <b>{destination}</b>.'**
  String waitAndRideStops(String min, String stops, String destination);

  /// Itinerary text for riding a few stops.
  ///
  /// In en, this message translates to:
  /// **'Ride {stops} to <b>{destination}</b>.'**
  String rideStops(String stops, String destination);

  /// Itinerary text for riding until a specified time after waiting.
  ///
  /// In en, this message translates to:
  /// **'Wait {min} and ride until {arrival} to <b>{destination}</b>.'**
  String waitAndRideTime(String min, DateTime arrival, String destination);

  /// Itinerary text for riding until a specified time.
  ///
  /// In en, this message translates to:
  /// **'Ride until {arrival} to <b>{destination}</b>.'**
  String rideTime(DateTime arrival, String destination);
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
