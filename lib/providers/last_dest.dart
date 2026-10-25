import 'package:easy_transit/models/destination.dart';
import 'package:easy_transit/providers/database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_nominatim/osm_nominatim.dart';

final lastDestinationsProvider = NotifierProvider(LastDestinations.new);

class LastDestinations extends Notifier<List<StoredDestination>> {
  static const kMaxLatestDestinations = 7;

  @override
  List<StoredDestination> build() {
    _loadDestinations();
    return [];
  }

  void add(LatLng destination, [String? name]) {
    final dest = StoredDestination(destination, name: name);
    if (state.any((element) => element.destination == destination)) return;
    var newList = [dest, ...state];
    if (newList.length > kMaxLatestDestinations) {
      newList = newList.sublist(0, kMaxLatestDestinations);
      _saveDestinations();
    } else {
      _addDestination(dest);
    }
    state = newList;
    if (name == null) findName(dest);
  }

  void used(StoredDestination dest) {
    dest.accessedOn = DateTime.now();
    _updateDestination(dest);
    var newList = state.toList();
    newList.sort((a, b) => b.accessedOn.compareTo(a.accessedOn));
    if (!listEquals(newList, state)) state = newList;
  }

  Future<void> findName(StoredDestination dest) async {
    var result = await Nominatim(
      userAgent: 'Easy Transit',
    ).reverseSearch(lat: dest.destination.latitude, lon: dest.destination.longitude, addressDetails: true, zoom: 18);
    dest.name = result.displayName;
    state = state;
    _updateDestination(dest);
  }

  Future<void> _loadDestinations() async {
    final db = await ref.read(databaseProvider.future);
    final results = await db.query(StoredDestination.kTableName);
    final dest = [for (var d in results) StoredDestination.fromJson(d)];
    dest.sort((a, b) => b.accessedOn.compareTo(a.accessedOn));
    state = dest;
  }

  Future<void> _addDestination(StoredDestination dest) async {
    final db = await ref.read(databaseProvider.future);
    await db.insert(StoredDestination.kTableName, dest.toJson());
  }

  Future<void> _updateDestination(StoredDestination dest) async {
    final db = await ref.read(databaseProvider.future);
    await db.update(StoredDestination.kTableName, dest.toJson(), where: 'id = ?', whereArgs: [dest.id]);
  }

  Future<void> _saveDestinations() async {
    final db = await ref.read(databaseProvider.future);
    await db.transaction((txn) async {
      await txn.delete(StoredDestination.kTableName);
      for (var q in state) {
        await txn.insert(StoredDestination.kTableName, q.toJson());
      }
    });
  }
}
