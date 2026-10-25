import 'package:easy_transit/helpers/equirectangular.dart';
import 'package:easy_transit/helpers/osm_layer.dart';
import 'package:easy_transit/helpers/path_utils.dart';
import 'package:easy_transit/widgets/stop_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gtfs_binary_flutter/gtfs_binary_flutter.dart';
import 'package:latlong2/latlong.dart';

class TripMapPage extends StatefulWidget {
  final Departure departure;

  const TripMapPage(this.departure, {super.key});

  @override
  State<TripMapPage> createState() => _TripMapPageState();
}

class _TripMapPageState extends State<TripMapPage> {
  bool showLabels = true;
  List<LatLng>? _before;
  List<LatLng>? _after;
  int _stopIndex = -1;

  Trip get trip => widget.departure.trip;

  @override
  void initState() {
    super.initState();
    preparePath();
  }

  void preparePath() {
    List<LatLng> path;
    if (trip.path != null) {
      path = trip.path!;
    } else {
      path = trip.stops.map((s) => s.stop.location).toList();
    }
    var paths = PathUtils().splitAt(Path.from(path), widget.departure.stop.stop.location);
    _before = paths.$1?.coordinates;
    _after = paths.$2.coordinates;
    _stopIndex = findStop([for (var s in trip.stops) s.stop], widget.departure.stop.stop);
  }

  int findStop(List<Stop> stops, Stop stop) {
    var dist = DistanceEquirectangular();
    Stop closestStop = stops.reduce(
      (a, b) => dist(a.location, stop.location) < dist(b.location, stop.location) ? a : b,
    );
    return stops.indexOf(closestStop);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trip.route.longName ?? 'Route ${trip.route.name}'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                showLabels = !showLabels;
              });
            },
            icon: Icon(showLabels ? Icons.label_off_outlined : Icons.label_outline),
            tooltip: 'Show stop names',
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: widget.departure.stop.stop.location,
          initialZoom: 13.0,
          minZoom: 10.0,
          maxZoom: 18.0,
          interactionOptions: InteractionOptions(
            flags: InteractiveFlag.all - InteractiveFlag.rotate - InteractiveFlag.flingAnimation,
          ),
        ),
        children: [
          buildTileLayer(),
          PolylineLayer(
            polylines: [
              if (_before != null)
                Polyline(points: _before!, color: Colors.blue.shade400.withValues(alpha: 0.4), strokeWidth: 3.0),
              if (_after != null)
                Polyline(points: _after!, color: Colors.blue.shade800.withValues(alpha: 0.9), strokeWidth: 3.0),
            ],
          ),
          for (var stop in trip.stops.sublist(_stopIndex)) StopWithLabel(stop.stop, showLabel: showLabels),
        ],
      ),
    );
  }
}
