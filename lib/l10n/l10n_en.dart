// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loading => 'Loading...';

  @override
  String get acquiringLocation => 'Finding you...';

  @override
  String get myLocation => 'My Location';

  @override
  String get enableGPS => 'Enable GPS';

  @override
  String get enableGPSMessage =>
      'Please turn on the location services in the settings panel that will be shown.';

  @override
  String get enableLocation => 'Enable Location';

  @override
  String get enableLocationMessage =>
      'Please allow location access for the app in the settings panel that will be shown.';

  @override
  String next(String time) {
    return 'next $time';
  }

  @override
  String get search => 'Search...';

  @override
  String get chooseOnMap => 'Choose on a map...';

  @override
  String get showMap => 'Map';

  @override
  String get whereTo => 'Where to?';
}
