import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:easy_transit/l10n/l10n.dart';
import 'package:easy_transit/models/bookmark.dart';
import 'package:easy_transit/providers/bookmarks.dart';
import 'package:easy_transit/providers/geolocation.dart';
import 'package:easy_transit/providers/motis.dart';
import 'package:easy_transit/screens/bookmark.dart';
import 'package:easy_transit/widgets/itinerary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:public_transport/public_transport.dart';

class PlanRoutePage extends ConsumerStatefulWidget {
  final LatLng? from;
  final LatLng to;
  final String? title;
  final Bookmark? bookmark;

  const PlanRoutePage({super.key, this.from, required this.to, this.title, this.bookmark});

  @override
  ConsumerState<PlanRoutePage> createState() => _PlanRoutePageState();
}

class _PlanRoutePageState extends ConsumerState<PlanRoutePage> {
  List<List<ItineraryLeg>>? options;
  String? errorMessage;
  Bookmark? bookmark;

  @override
  void initState() {
    super.initState();
    bookmark = widget.bookmark;
    findRoute();
  }

  Future<void> findRoute() async {
    try {
      final opts = await ref
          .read(motisProvider)
          .planJourney(from: widget.from ?? ref.read(geolocationProvider)!, to: widget.to);
      setState(() {
        options = opts;
        errorMessage = null;
      });
    } on BackendException catch (e) {
      setState(() {
        options = [];
        errorMessage = e.toString();
      });
    } on BackendParseException catch (e) {
      setState(() {
        options = [];
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (loc == null) return Container();
    Widget body;
    if (options == null) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: double.infinity),
          CircularProgressIndicator(value: null),
          SizedBox(height: 20.0),
          Text(
            loc.lookingForRoute,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ],
      );
    } else if (errorMessage != null) {
      body = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20.0),
          ),
        ),
      );
    } else if (options!.isEmpty) {
      body = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            loc.noRoutes,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20.0),
          ),
        ),
      );
    } else {
      body = ListView.separated(
        itemCount: options!.length,
        itemBuilder: (context, index) => ItineraryCard(options![index]),
        separatorBuilder: (context, index) => Divider(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(bookmark?.name ?? widget.title ?? 'Route Plans'),
        actions: [
          if (bookmark?.id != null)
            IconButton(
              icon: Icon(Icons.delete),
              tooltip: loc.deleteBookmark(bookmark?.name ?? ""),
              onPressed: () async {
                var bookmarkHelper = ref.read(bookmarkProvider.notifier);
                OkCancelResult result = await showOkCancelAlertDialog(
                  context: context,
                  title: '${loc.delete}?',
                  message: loc.deleteBookmark(bookmark!.name),
                  okLabel: loc.delete,
                );
                if (result == OkCancelResult.ok) {
                  bookmarkHelper.remove(bookmark!);
                  setState(() {
                    bookmark = null;
                  });
                }
              },
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        right: false,
        child: body,
      ),
      floatingActionButton: options != null && bookmark == null
          ? FloatingActionButton(
        tooltip: loc.addBookmark,
        onPressed: () async {
          var bookmarkHelper = ref.read(bookmarkProvider.notifier);
          Bookmark? result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddBookmarkPage(widget.to),
              ));
          if (result != null) {
            bookmarkHelper.add(result);
            setState(() {
              bookmark = result;
            });
          }
        },
        child: Icon(Icons.bookmark_outline),
      )
          : null,
    );
  }
}
