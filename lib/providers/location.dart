import 'package:easy_transit/providers/geolocation.dart';
import 'package:easy_transit/providers/shared_prefs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

final effectiveLocationProvider = NotifierProvider<EffectiveLocationController, LatLng>(
  EffectiveLocationController.new,
);

class EffectiveLocationController extends Notifier<LatLng> {
  static const kSavedLocation = 'last_location';
  static const kDefaultLocation = LatLng(59.42, 24.71);

  @override
  LatLng build() {
    LatLng location = kDefaultLocation;
    final geoPos = ref.read(geolocationProvider);
    if (geoPos != null) {
      location = geoPos;
    } else {
      final prefs = ref.read(sharedPrefsProvider).requireValue;
      final loc = prefs.getStringList(kSavedLocation);
      if (loc != null) {
        location = LatLng(double.parse(loc[0]), double.parse(loc[1]));
      }
    }
    return location;
  }

  Future<void> set(LatLng location) async {
    state = location;
    final prefs = ref.read(sharedPrefsProvider).requireValue;
    await prefs.setStringList(kSavedLocation, [location.latitude.toString(), location.longitude.toString()]);
  }
}
