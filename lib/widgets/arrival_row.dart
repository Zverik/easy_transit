import 'package:easy_transit/l10n/l10n.dart';
import 'package:easy_transit/widgets/transit_icon.dart';
import 'package:flutter/material.dart';
import 'package:gtfs_binary_flutter/gtfs_binary_flutter.dart';
import 'package:intl/intl.dart' show DateFormat;

class ArrivalRow extends StatefulWidget {
  final Departure first;
  final Departure? second;
  final bool forceExactTime;

  const ArrivalRow(this.first, {this.second, this.forceExactTime = false});

  @override
  State<ArrivalRow> createState() => _ArrivalRowState();
}

class _ArrivalRowState extends State<ArrivalRow> {
  final scrollController = ScrollController();

  final tf = DateFormat.Hm();

  String formatArrivalTime(BuildContext context, Departure arrival) {
    final arrivesInSec = arrival.stop.departure.difference(DateTime.now()).inSeconds;
    final arrivalSec = arrivesInSec < 0 ? 0 : arrivesInSec;
    return arrivalSec > 700 || widget.forceExactTime
        ? tf.format(arrival.stop.departure)
        : '${(arrivalSec / 60).round()} min';
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firstTime = formatArrivalTime(context, widget.first);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
      child: Row(
        children: [
          TransitIcon(widget.first.trip.route),
          SizedBox(width: 10.0),
          Expanded(
            flex: 100,
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: Text(widget.first.stop.headsign ?? 'Bus', style: TextStyle(fontSize: 20.0)),
            ),
          ),
          Expanded(child: Container()),
          SizedBox(width: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatArrivalTime(context, widget.first), style: TextStyle(fontSize: 20.0)),
              if (widget.second != null)
                Text(
                  AppLocalizations.of(context)!.next(formatArrivalTime(context, widget.second!)),
                  style: TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
