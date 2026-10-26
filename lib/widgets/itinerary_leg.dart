import 'package:easy_transit/helpers/osm_layer.dart';
import 'package:easy_transit/helpers/rich_tags.dart';
import 'package:easy_transit/l10n/l10n.dart';
import 'package:easy_transit/providers/geolocation.dart';
import 'package:easy_transit/widgets/arrival_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtfs_binary_flutter/gtfs_binary_flutter.dart' show Departure;
import 'package:public_transport/public_transport.dart' hide Departure;

class ItineraryLegCard extends ConsumerStatefulWidget {
  final ItineraryLeg leg;
  final bool isPortrait;
  final ItineraryLeg? lastLeg;
  final ItineraryLeg? nextLeg;

  const ItineraryLegCard(this.leg, {super.key, this.isPortrait = true, this.lastLeg, this.nextLeg});

  @override
  ConsumerState createState() => _ItineraryLegState();
}

class _ItineraryLegState extends ConsumerState<ItineraryLegCard> {
  Departure? departure;
  late List<TextSpan> description;
  late Color pathColor;
  bool pathDotted = false;
  late LatLngBounds mapBounds;

  void prepareMessages(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    mapBounds = LatLngBounds.fromPoints(widget.leg.path);
    // final destination = widget.leg.endName == 'Destination' ? loc.walkDestination : widget.leg.endName;
    final destination = widget.leg.to.name!;
    if (widget.leg.mode != TransitMode.walk) {
      pathColor = widget.leg.mode == TransitMode.suburban ? Colors.red : Colors.blue;
      departure = null; // TODO: replace it with something?
      int? waitTimeMinutes;
      if (departure != null && widget.lastLeg?.mode != TransitMode.walk) {
        waitTimeMinutes = (widget.leg.departure.difference(widget.lastLeg!.arrival).inSeconds / 60).round();
      }
        if (waitTimeMinutes != null && waitTimeMinutes >= 1) {
          description = parseTaggedText(
            loc.waitAndRideTime(loc.fullMinutes(waitTimeMinutes), widget.leg.arrival, destination),
          );
        } else {
          description = parseTaggedText(loc.rideTime(widget.leg.arrival, destination));
        }
    } else {
      departure = null;
      pathColor = Colors.black;
      pathDotted = true;
      final walkMeters = widget.leg.distanceMeters;
      final walkDistance = walkMeters <= 30 ? walkMeters : (walkMeters / 50).round() * 50;
      String walkTime = '';
      if (widget.nextLeg != null && widget.nextLeg?.mode != TransitMode.walk) {
        final duration = widget.nextLeg!.departure.difference(widget.leg.departure).inSeconds;
        final speed = walkMeters / duration * 3.6;
        if (speed < 2.0) {
          walkTime = ' ' + loc.noHurry(loc.fullMinutes((duration / 60).floor()));
        } else {
          walkTime = ' ' + loc.youGotTime(loc.fullMinutes((duration / 60).floor()));
        }
      }
      description = parseTaggedText(loc.walkMeters(walkDistance, destination) + walkTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    prepareMessages(context);
    final descPart = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (departure != null)
          Padding(padding: const EdgeInsets.only(top: 10.0), child: ArrivalRow(departure!, forceExactTime: true)),
        Padding(
          padding: EdgeInsets.only(bottom: 10.0, left: 15.0, right: 10.0, top: departure != null ? 5.0 : 10.0),
          child: RichText(
            text: TextSpan(style: DefaultTextStyle.of(context).style.copyWith(fontSize: 20.0), children: description),
          ),
        ),
      ],
    );
    final location = ref.watch(geolocationProvider);
    final map = SizedBox(
      height: 200.0,
      child: FlutterMap(
        options: MapOptions(
          initialCameraFit: CameraFit.bounds(bounds: mapBounds, padding: const EdgeInsets.all(25.0)),
          minZoom: 10.0,
          maxZoom: 18.0,
          interactionOptions: InteractionOptions(flags: InteractiveFlag.pinchMove | InteractiveFlag.pinchZoom),
        ),
        children: [
          buildTileLayer(),
          if (location != null)
            CircleLayer(
              circles: [CircleMarker(point: location, color: Colors.blue.withValues(alpha: 0.6), radius: 20.0)],
            ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.leg.path,
                color: pathColor.withValues(alpha: 0.7),
                strokeWidth: 7.0,
                pattern: pathDotted ? StrokePattern.dotted() : StrokePattern.solid(),
              ),
            ],
          ),
          // TODO: draw intermediate stops
          CircleLayer(
            circles: [
              CircleMarker(
                point: widget.leg.path.last,
                color: Colors.yellow,
                borderColor: Colors.black,
                borderStrokeWidth: 1.0,
                radius: 5.0,
              ),
            ],
          ),
        ],
      ),
    );
    if (widget.isPortrait) {
      return Column(
        children: [
          descPart,
          ExcludeSemantics(child: map),
        ],
      );
    } else {
      // landscape
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: descPart),
          Expanded(child: ExcludeSemantics(child: map)),
        ],
      );
    }
  }
}
