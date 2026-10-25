import 'dart:math' show Random;

import 'package:latlong2/latlong.dart';

class StoredDestination {
  int id;
  final LatLng destination;
  String name;
  DateTime accessedOn;
  DateTime createdOn;
  static const kMaxInteger = 2000000000;

  StoredDestination(this.destination, {String? name, DateTime? accessedOn, int? id})
    : name = name ?? "${destination.round(decimals: 5)}",
      accessedOn = accessedOn ?? DateTime.now(),
      createdOn = DateTime.now(),
      id = id ?? Random().nextInt(kMaxInteger);

  static const kTableName = 'destinations';
  static const kTableColumns = ['id integer primary key', 'lat real', 'lon real', 'name text', 'last_used integer'];

  factory StoredDestination.fromJson(Map<String, dynamic> json) {
    return StoredDestination(
      LatLng(json['lat'], json['lon']),
      name: json['name'],
      accessedOn: DateTime.fromMillisecondsSinceEpoch(json['last_used']),
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lat': destination.latitude,
      'lon': destination.longitude,
      'name': name,
      'last_used': accessedOn.millisecondsSinceEpoch,
    };
  }

  bool get isRecent => createdOn.add(Duration(minutes: 3)).isAfter(DateTime.now());
}
