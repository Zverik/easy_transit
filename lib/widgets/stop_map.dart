import 'dart:async';

import 'package:easy_transit/helpers/equirectangular.dart';
import 'package:easy_transit/helpers/osm_layer.dart';
import 'package:easy_transit/providers/geolocation.dart';
import 'package:easy_transit/providers/location.dart';
import 'package:easy_transit/providers/stop.dart';
import 'package:easy_transit/providers/transit.dart';
import 'package:easy_transit/widgets/stop_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtfs_binary_flutter/gtfs_binary_flutter.dart';
import 'package:latlong2/latlong.dart';

class StopMapController {
  Function(LatLng, bool)? listener;

  void setLocation(LatLng location, {bool emitDrag = true}) {
    if (listener != null) listener!(location, emitDrag);
  }
}

class StopMap extends ConsumerStatefulWidget {
  final void Function(LatLng)? onDrag;
  final void Function(LatLng)? onDragEnd;
  final StopMapController? controller;

  const StopMap({super.key, this.onDrag, this.onDragEnd, this.controller});

  @override
  ConsumerState createState() => _StopMapState();
}

class _StopMapState extends ConsumerState<StopMap> {
  static const _kDistanceToChosenStopPixels = 200.0;

  late final MapController mapController;
  late final StreamSubscription<MapEvent> mapSub;
  List<Stop> nearestStops = [];
  LatLngBounds? lastNearestStopCheck;
  LatLng location = EffectiveLocationController.kDefaultLocation;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    if (widget.controller != null) {
      widget.controller!.listener = onControllerLocation;
    }
    mapSub = mapController.mapEventStream.listen(onMapEvent);
  }

  void onMapEvent(MapEvent event) {
    if (event is MapEventMove) {
      updateNearestStops(event.camera.visibleBounds);
      setState(() {
        location = event.camera.center;
      });
      if (event.source != MapEventSource.mapController) {
        ref.read(trackingProvider.notifier).disable();
        if (widget.onDrag != null) widget.onDrag!(event.camera.center);
      }
    } else if (event is MapEventMoveEnd) {
      if (event.source != MapEventSource.mapController) {
        updateNearestStop(event.camera);
        if (widget.onDragEnd != null) {
          widget.onDragEnd!(event.camera.center);
        }
      }
    }
  }

  void updateNearestStop(MapCamera camera) {
    Stop? nearest;
    double dist = _kDistanceToChosenStopPixels * _kDistanceToChosenStopPixels;
    for (final stop in nearestStops) {
      final offset = camera.latLngToScreenOffset(stop.location) - camera.latLngToScreenOffset(camera.center);
      final d = offset.distanceSquared;
      if (d < dist) {
        dist = d;
        nearest = stop;
      }
    }
    ref.read(currentStopProvider.notifier).set(nearest);
  }

  void onControllerLocation(LatLng location, bool emitDrag) {
    mapController.move(location, mapController.camera.zoom);
    if (emitDrag && widget.onDrag != null) widget.onDrag!(location);
  }

  @override
  void dispose() {
    mapSub.cancel();
    super.dispose();
  }

  Future<void> updateNearestStops(LatLngBounds bounds) async {
    if (lastNearestStopCheck != null && lastNearestStopCheck!.containsBounds(bounds)) {
      return;
    }
    bounds = bounds.expand(0.001);
    lastNearestStopCheck = bounds;

    final transit = await ref.read(transitProvider.future);
    final stops = await transit.findStopsForBounds(bounds.southWest, bounds.northEast);
    setState(() {
      nearestStops = stops;
    });
  }

  @override
  Widget build(BuildContext context) {
    final LatLng? trackLocation = ref.watch(geolocationProvider);

    final chosenStop = ref.watch(currentStopProvider);

    // When tracking location, move map and notify the poi list.
    ref.listen<LatLng?>(geolocationProvider, (_, LatLng? location) {
      if (location != null && ref.watch(trackingProvider)) {
        mapController.move(location, mapController.camera.zoom);
        if (widget.onDragEnd != null) widget.onDragEnd!(location);
      }
    });

    // When turning the tracking on, move the map immediately.
    ref.listen(trackingProvider, (_, bool newState) {
      if (trackLocation != null && newState) {
        mapController.move(trackLocation, mapController.camera.zoom);
        updateNearestStop(mapController.camera);
        if (widget.onDragEnd != null) widget.onDragEnd!(trackLocation);
      }
    });

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: location,
        initialZoom: 16.0,
        minZoom: 13.0,
        maxZoom: 18.0,
        interactionOptions: InteractionOptions(flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom),
        onMapReady: () {
          updateNearestStops(mapController.camera.visibleBounds);
        },
      ),
      children: [
        buildTileLayer(),
        CircleLayer<Object>(
          circles: [
            if (trackLocation != null)
              CircleMarker(point: trackLocation, color: Colors.blue.withValues(alpha: 0.6), radius: 15.0),
            for (var stop in nearestStops) StopCircle(stop.location),
          ],
        ),
        if (chosenStop != null) StopWithLabel(chosenStop),
        if (!ref.watch(trackingProvider))
          MarkerLayer(
            markers: [
              if (trackLocation == null)
                Marker(
                  point: location,
                  alignment: Alignment(0.0, -0.7),
                  child: Icon(Icons.location_pin, color: Colors.black, size: 24.0),
                ),
              if (trackLocation != null)
                Marker(
                  point: location,
                  alignment: Alignment.center,
                  child: Icon(Icons.adjust, color: Colors.black.withValues(alpha: 0.3), size: 24.0),
                ),
            ],
          ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(padding: EdgeInsets.all(4.0), child: Text('© OpenStreetMap contributors')),
        ),
      ],
    );
  }
}

extension LatLngBoundsExpansion on LatLngBounds {
  LatLngBounds expand(double delta) =>
      LatLngBounds(LatLng(south - delta, west - delta), LatLng(north + delta, east + delta));

  double area() => (north - south) * (east - west);
}
