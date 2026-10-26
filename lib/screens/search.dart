import 'dart:async';

import 'package:easy_transit/helpers/equirectangular.dart';
import 'package:easy_transit/l10n/l10n.dart';
import 'package:easy_transit/providers/bookmarks.dart';
import 'package:easy_transit/providers/geolocation.dart';
import 'package:easy_transit/providers/last_dest.dart';
import 'package:easy_transit/providers/transit.dart';
import 'package:easy_transit/screens/log.dart';
import 'package:easy_transit/screens/map_chooser.dart';
import 'package:easy_transit/screens/plan.dart';
import 'package:flutter/foundation.dart' show mergeSort;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtfs_binary_flutter/gtfs_binary_flutter.dart';
import 'package:latlong2/latlong.dart';

class SearchResult {
  final IconData icon;
  final String title;
  final String? address;
  final LatLng? location;
  final bool isMapItem;

  SearchResult({required this.icon, required this.title, this.location, this.address, this.isMapItem = false});
}

class SearchPage extends ConsumerStatefulWidget {
  final LatLng? from;

  const SearchPage({super.key, this.from});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  List<SearchResult> results = [];
  List<SearchResult> geocoderResults = [];
  String query = '';
  String lastQuerySearchedForStops = '';
  final controller = TextEditingController();
  Timer? geocodeTimer;
  LatLng? start;

  @override
  void initState() {
    super.initState();
    start = widget.from ?? ref.read(geolocationProvider);
    updateResults('');
  }

  void updateResults(String query) {
    if (query.isEmpty) {
      lastQuerySearchedForStops = query;
      final chooseOnMapTitle = 'Choose on map...'; // AppLocalizations.of(context)!.chooseOnMap
      results = [SearchResult(icon: Icons.map, title: chooseOnMapTitle, isMapItem: true)];
      final lastDest = ref.watch(lastDestinationsProvider);
      for (var dest in lastDest) {
        results.add(SearchResult(icon: Icons.location_history_rounded, title: dest.name, location: dest.destination));
      }
      setState(() {});
    } else {
      if (query.length < 2) {
        lastQuerySearchedForStops = query;
        results = [];
      } else if (query != lastQuerySearchedForStops) {
        lastQuerySearchedForStops = query;
        _autocompeteStops(query, deduplicate: true).then((stops) {
          if (mounted) {
            setState(() {
              results = [];
              for (var stop in stops) {
                results.add(SearchResult(icon: Icons.directions_bus, title: stop.name, location: stop.location));
              }
            });
          }
        });
      }
    }
  }

  Future<List<Stop>> _autocompeteStops(String query, {int max = 3, bool deduplicate = true}) async {
    final transit = await ref.read(transitProvider.future);
    final stops = await transit.findStopsByName(query);
    final distance = DistanceEquirectangular();
    stops.sort((a, b) => distance(start!, a.location).compareTo(distance(start!, b.location)));

    if (deduplicate) {
      // Code from https://stackoverflow.com/a/63277386
      final names = <String>{};
      stops.retainWhere((element) => names.add(element.name));
    }

    // Put stops with names that start with part first.
    mergeSort(
      stops,
      compare: (Stop a, Stop b) {
        // TODO: normalization
        final hasPrefixA = a.name.toLowerCase().split(' ').any((element) => element.startsWith(query));
        final hasPrefixB = b.name.toLowerCase().split(' ').any((element) => element.startsWith(query));
        if (hasPrefixA == hasPrefixB) return 0;
        return hasPrefixA ? -1 : 1;
      },
    );
    return stops.length <= max ? stops : stops.sublist(0, max);
  }

  Future<void> doSearch(String q) async {
    cancelAutocomplete();
    if (q.length < 2) {
      geocoderResults = [];
      return;
    }
    var results = []; // TODO: await AutocompleteGeocoder().query(q, start);
    if (!mounted) return;
    setState(() {
      geocoderResults = [
        for (var r in results)
          SearchResult(icon: Icons.place, title: r.title, address: r.address, location: r.location),
      ];
    });
  }

  void autocompleteSearch(String q) {
    cancelAutocomplete();
    // Start geocoding 1 second after last key was typed.
    if (q.length >= 2) {
      geocodeTimer = Timer(Duration(milliseconds: 1000), () {
        geocodeTimer = null;
        doSearch(q);
      });
    }
  }

  void cancelAutocomplete() {
    if (geocodeTimer != null) {
      geocodeTimer!.cancel();
      geocodeTimer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(lastDestinationsProvider, (_, _) => updateResults(''));
    ref.listen(bookmarkProvider, (_, _) => updateResults(''));
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: double.infinity,
          height: 40.0,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5.0)),
          child: TextField(
            // autofocus: true,
            controller: controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: AppLocalizations.of(context)?.search ?? 'Search...',
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                tooltip: AppLocalizations.of(context)?.search,
                onPressed: () {
                  controller.clear();
                  setState(() {
                    updateResults('');
                    geocoderResults = [];
                  });
                },
              ),
            ),
            onSubmitted: (value) {
              doSearch(value);
            },
            onChanged: (value) {
              if (value == 'syslog') {
                controller.clear();
                value = '';
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LogDisplayPage()));
                return;
              }
              setState(() {
                updateResults(value);
              });
              if (value.length > 1) autocompleteSearch(value);
            },
          ),
        ),
      ),
      body: start == null
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView.builder(
                itemCount: results.length + geocoderResults.length,
                itemBuilder: (context, index) {
                  final item = index < results.length ? results[index] : geocoderResults[index - results.length];
                  return ListTile(
                    leading: Icon(item.icon),
                    title: Text(item.title),
                    subtitle: item.address == null ? null : Text(item.address!),
                    onTap: () {
                      if (item.isMapItem) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              final lastDestinations = ref.read(lastDestinationsProvider);
                              final destLoc = lastDestinations.isNotEmpty && lastDestinations.first.isRecent
                                  ? lastDestinations.first.destination
                                  : start;
                              return MapChooserPage(start: start!, destination: destLoc);
                            },
                          ),
                        );
                      } else if (item.location != null) {
                        ref.read(lastDestinationsProvider.notifier).add(item.location!, item.title);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlanRoutePage(from: start, to: item.location!, title: item.title),
                          ),
                        );
                      } else {
                        // This is a historic query
                        setState(() {
                          query = item.title;
                          controller.text = item.title;
                          doSearch(item.title);
                          FocusScope.of(context).unfocus();
                        });
                      }
                    },
                    trailing: item.location == null
                        ? null
                        : IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return MapChooserPage(start: start!, destination: item.location, zoomCloser: true);
                                  },
                                ),
                              );
                            },
                            icon: Icon(Icons.map_outlined),
                            tooltip: AppLocalizations.of(context)?.showMap,
                          ),
                  );
                },
              ),
            ),
    );
  }
}
