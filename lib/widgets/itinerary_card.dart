import 'package:easy_transit/l10n/l10n.dart';
import 'package:easy_transit/screens/itinerary.dart';
import 'package:easy_transit/widgets/transport_icon.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:public_transport/public_transport.dart';

class ItineraryCard extends StatelessWidget {
  final List<ItineraryLeg> itinerary;

  const ItineraryCard(this.itinerary, {super.key});

  @override
  Widget build(BuildContext context) {
    final tf = DateFormat.Hm();
    var interval = '${tf.format(itinerary.first.departure)} — ${tf.format(itinerary.last.arrival)}';
    var duration = itinerary.last.arrival.difference(itinerary.first.departure);
    var durationStr = AppLocalizations.of(context)!.minutes(duration.inMinutes);
    String? firstStop;
    try {
      ItineraryLeg firstTransit = itinerary.firstWhere((element) => element.mode != TransitMode.walk);
      firstStop = AppLocalizations.of(context)!.busLeavesFrom(
        '${firstTransit.mode.name} ${firstTransit.routeShortName}',
        firstTransit.departure,
        firstTransit.from.name ?? '?',
      );
    } on StateError {
      // nothing
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ItineraryPage(itinerary)));
      },
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 5.0, bottom: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // First row: duration and times
                  Text(
                    '$interval ($durationStr)',
                    style: TextStyle(
                      fontSize: 20.0,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  // Second row: diagram for modes
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [for (var leg in itinerary) LegIcon(leg)]),
                  ),
                  // Third row: "Leaves at 12:43 from stop StopName" (do we need it?)
                  if (firstStop != null) ...[
                    SizedBox(height: 10.0),
                    Text(firstStop, style: TextStyle(color: Colors.grey)),
                  ],
                ],
              ),
            ),
          ),
          Icon(Icons.navigate_next),
        ],
      ),
    );
  }
}
