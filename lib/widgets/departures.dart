import 'package:easy_transit/providers/transit.dart';
import 'package:easy_transit/screens/trip_map.dart';
import 'package:easy_transit/widgets/arrival_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtfs_binary_flutter/gtfs_binary_flutter.dart';

class DepartureDisplayedItem {
  final Departure first;
  Departure? second;

  DepartureDisplayedItem(this.first);
  bool get hasSecond => second != null;
}

class DeparturesPanel extends ConsumerStatefulWidget {
  final Stop stop;

  const DeparturesPanel(this.stop, {super.key});

  @override
  ConsumerState<DeparturesPanel> createState() => _DeparturesPanelState();
}

class _DeparturesPanelState extends ConsumerState<DeparturesPanel> {
  List<Departure> _departures = [];
  bool _updating = true;

  @override
  void initState() {
    super.initState();
    updateDepartures();
  }

  Future<void> updateDepartures() async {
    _updating = true;
    final transit = await ref.read(transitProvider.future);
    final departures = await transit.findDepartures(stop: widget.stop);
    setState(() {
      _updating = false;
      _departures = departures;
    });
  }

  List<DepartureDisplayedItem> sortArrivals() {
    if (_departures.isEmpty) return [];
    var byRoute = <int, DepartureDisplayedItem>{};
    for (var arrival in _departures) {
      if (!byRoute.containsKey(arrival.trip.route.feedId)) {
        byRoute[arrival.trip.route.feedId] = DepartureDisplayedItem(arrival);
      } else {
        var item = byRoute[arrival.trip.route.feedId]!;
        if (!item.hasSecond) item.second = arrival;
      }
    }
    var fixedArrivals = byRoute.values.toList();
    fixedArrivals.sort((a, b) => a.first.stop.departure.compareTo(b.first.stop.departure));
    return fixedArrivals;
  }

  @override
  void didUpdateWidget(covariant DeparturesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateDepartures();
  }

  String _firstNotNull(List<String?> strings) {
    for (final s in strings) {
      if (s != null && s.isNotEmpty) return s;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          border: BoxBorder.all(color: Colors.black26, style: BorderStyle.solid),
          borderRadius: BorderRadiusGeometry.circular(5.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.black.withValues(alpha: 0.1),
              child: Text(
                _firstNotNull([widget.stop.desc, widget.stop.name]),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87, fontSize: 14.0),
              ),
            ),
            if (_updating) SizedBox(height: 50.0),
            if (!_updating && _departures.isEmpty)
              SizedBox(height: 50.0, child: Center(child: Text("No departures here today"))),
            if (!_updating && _departures.isNotEmpty)
              for (final departure in sortArrivals())
                GestureDetector(
                  child: ArrivalRow(departure.first, second: departure.second),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => TripMapPage(departure.first)));
                  },
                ),
          ],
        ),
      ),
    );
  }
}
