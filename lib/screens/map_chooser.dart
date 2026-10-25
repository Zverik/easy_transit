import 'package:easy_transit/helpers/osm_layer.dart';
import 'package:easy_transit/l10n/l10n.dart';
import 'package:easy_transit/providers/last_dest.dart';
import 'package:easy_transit/screens/plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MapChooserPage extends ConsumerStatefulWidget {
  final LatLng start;
  final LatLng? destination;
  final bool zoomCloser;

  const MapChooserPage(
      {super.key, required this.start, this.destination, this.zoomCloser = false});

  @override
  ConsumerState createState() => _MapChooserPageState();
}

class _MapChooserPageState extends ConsumerState<MapChooserPage> {
  MapController mapController = MapController();
  late LatLng center;

  @override
  void initState() {
    super.initState();
    center = widget.destination ?? widget.start;
    mapController.mapEventStream.listen((event) {
      if (event is MapEventMove) {
        setState(() {
          center = mapController.camera.center;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.whereTo ?? 'Where to?'),
        actions: [
          IconButton(
            onPressed: () async {
              final pos = await Geolocator.getLastKnownPosition();
              if (pos != null) {
                final newPos = LatLng(pos.latitude, pos.longitude);
                mapController.move(newPos, mapController.camera.zoom);
              }
            },
            icon: const Icon(Icons.my_location),
            tooltip: AppLocalizations.of(context)?.myLocation,
          ),
        ],
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: center,
          initialZoom: widget.zoomCloser ? 15.0 : 13.0,
          minZoom: 11.0,
          maxZoom: 17.0,
          interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all ^ (InteractiveFlag.rotate)),
          onTap: (tapPos, latlng) {
            final zoom = mapController.camera.zoom;
            mapController.move(latlng, zoom >= 17 ? zoom : zoom + 2);
          },
        ),
        children: [
          buildTileLayer(),
          MarkerLayer(
            markers: [
              Marker(
                point: center,
                alignment: Alignment(0.0, -0.7),
                child: Icon(Icons.location_pin),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_forward),
        onPressed: () {
          final destination = mapController.camera.center;
          ref.read(lastDestinationsProvider.notifier).add(destination);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PlanRoutePage(
                  from: widget.start,
                  to: destination,
                ),
              ));
        },
      ),
    );
  }
}
