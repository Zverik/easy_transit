import 'package:easy_transit/constants.dart';
import 'package:easy_transit/l10n/l10n.dart';
import 'package:easy_transit/providers/geolocation.dart';
import 'package:easy_transit/providers/stop.dart';
import 'package:easy_transit/widgets/bookmark_row.dart';
import 'package:easy_transit/widgets/departures.dart';
import 'package:easy_transit/widgets/download.dart';
import 'package:easy_transit/widgets/stop_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArrivalsPage extends ConsumerStatefulWidget {
  const ArrivalsPage({super.key});

  @override
  ConsumerState<ArrivalsPage> createState() => _ArrivalsPageState();
}

class _ArrivalsPageState extends ConsumerState<ArrivalsPage> {
  @override
  Widget build(BuildContext context) {
    final chosenStop = ref.watch(currentStopProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(kAppTitle),
        actions: [
          IconButton(
            onPressed: ref.watch(trackingProvider)
                ? null
                : () {
                    ref.read(geolocationProvider.notifier).enableTracking(context);
                  },
            icon: const Icon(Icons.my_location),
            tooltip: AppLocalizations.of(context)?.myLocation,
          ),
        ],
      ),
      body: ListView(
        children: [
          // Order of elements:
          // if map off, the nearest/favourite near stop open to show all arrivals.
          // if map off, 1-2 more nearest used stops.
          // if map on, instead the map for 2/5 of screen with a stop highlighted.
          // if map on and stop selected, then a list of arrivals for the selected stop.
          // if map on and no stop selected, a list of 1-2 nearest used stops.
          // NB: on a square/portrait screen, the map is always visible.
          // then a panel to search (both stops and destinations)
          // then a panel with destination bookmarks
          // somewhere here a panel to download offline feeds.
          // then a verbatim text about buying tickets.
          // finally a button for about/settings.
          SizedBox(height: 300,child: StopMap(),),
          NeedDownloadPanel(),
          if (chosenStop != null) DeparturesPanel(chosenStop),
          BookmarkRow(),
        ],
      ),
    );
  }
}
