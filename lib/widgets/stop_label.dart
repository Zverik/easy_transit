import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gtfs_binary_flutter/gtfs_binary_flutter.dart';
import 'package:latlong2/latlong.dart';

class StopWithLabel extends StatelessWidget {
  final Stop stop;
  final bool showLabel;

  const StopWithLabel(this.stop, {this.showLabel = true, super.key});

  static const kFontSize = 14.0;

  @override
  Widget build(BuildContext context) {
    final name = stop.name ?? 'stop';
    final chosenStopLabelSize = _textSize(context, name, TextStyle(fontSize: kFontSize));
    final markerWidth = chosenStopLabelSize.width + 30.0;
    return Stack(
      children: [
        if (showLabel)
          MarkerLayer(
            markers: [
              Marker(
                point: stop.location,
                alignment: Alignment(1.0 - 20 / markerWidth, 0.0),
                height: 20.0,
                width: markerWidth,
                child: Container(
                  padding: const EdgeInsets.only(left: 18.0, right: 2.0, top: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1.0),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
                  ),
                  child: Text(name, style: TextStyle(fontSize: kFontSize)),
                ),
              ),
            ],
          ),
        CircleLayer(circles: [StopCircle(stop.location)]),
      ],
    );
  }

  // From https://stackoverflow.com/a/62536187
  static Size _textSize(BuildContext context, String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: style.copyWith(fontSize: MediaQuery.textScalerOf(context).scale(style.fontSize!)),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }
}

class StopCircle extends CircleMarker {
  const StopCircle(LatLng location)
      : super(point: location, color: Colors.yellow, borderColor: Colors.black, borderStrokeWidth: 1.0, radius: 5.0);
}
