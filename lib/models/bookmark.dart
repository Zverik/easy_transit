import 'package:latlong2/latlong.dart';

class Bookmark {
  int? id;
  int? position;
  final String name;
  final LatLng location;
  final String emoji;
  final DateTime createdOn;

  Bookmark({this.id, this.position, required this.name, required this.location, required this.emoji, DateTime? createdOn})
      : createdOn = createdOn ?? DateTime.now();

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'],
      position: json['position'],
      name: json['name'],
      emoji: json['emoji'],
      location: LatLng(json['lat'], json['lon']),
      createdOn: DateTime.fromMillisecondsSinceEpoch(json['created']),
    );
  }

  static const kTableName = 'bookmarks';
  static const kTableColumns = [
    'id integer primary key',
    'position integer',
    'name text',
    'emoji text',
    'lat real',
    'lon real',
    'created integer',
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': position,
      'name': name,
      'emoji': emoji,
      'lat': location.latitude,
      'lon': location.longitude,
      'created': createdOn.millisecondsSinceEpoch,
    };
  }

  @override
  int get hashCode => id ?? (emoji+name).hashCode;

  @override
  bool operator ==(Object other) {
    return other is Bookmark && id == other.id && name == other.name && emoji == other.emoji;
  }
}
