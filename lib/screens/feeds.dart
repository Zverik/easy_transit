import 'package:easy_transit/providers/geolocation.dart';
import 'package:easy_transit/providers/transit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtfs_binary_flutter/gtfs_binary_flutter.dart';
import 'package:latlong2/latlong.dart';

class FeedsPage extends ConsumerStatefulWidget {
  const FeedsPage({super.key});

  @override
  ConsumerState<FeedsPage> createState() => _FeedsPageState();
}

class _FeedsPageState extends ConsumerState<FeedsPage> {
  LatLng? location;
  final _downloading = <String, UpdateStatus>{};

  @override
  void initState() {
    super.initState();
    location = ref.read(geolocationProvider);
  }

  @override
  Widget build(BuildContext context) {
    final feeds = ref.watch(feedProvider);
    final feedsHere = <FeedInfo>[];
    final feedsAll = <FeedInfo>[];

    if (location == null) {
      ref.listen(geolocationProvider, (_, next) {
        location = next;
      });
    } else {
      feedsHere.addAll(feeds.value?.where((f) => f.contains(location!)) ?? []);
      feedsAll.addAll(feeds.value?.where((f) => !f.contains(location!)) ?? []);
    }

    return Scaffold(
      appBar: AppBar(title: Text("Manage Feeds")),
      body: location == null || !feeds.hasValue
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: feedsHere.length + feedsAll.length + 1 + (feedsHere.isEmpty ? 0 : 1),
              itemBuilder: (context, index) {
                if (feedsHere.isNotEmpty && index == 0) {
                  return Text('Here:');
                }
                if (index == (feedsHere.isEmpty ? 0 : feedsHere.length + 1)) {
                  return Text('Other feeds:');
                }
                final feed = feedsHere.isEmpty
                    ? feedsAll[index - 1]
                    : (index <= feedsHere.length ? feedsHere[index - 1] : feedsAll[index - feedsHere.length - 2]);

                Widget? trailing;
                if (_downloading.containsKey(feed.feedId)) {
                  CircularProgressIndicator();
                } else if (!feed.isInstalled) {
                  trailing = IconButton(
                    icon: Icon(Icons.download),
                    onPressed: () {
                      ref.read(transitProvider).requireValue.downloadFeeds([feed.feedId]).listen((status) {
                        setState(() {
                          _downloading[feed.feedId] = status;
                        });
                      }, onDone: () async {
                        ref.invalidate(feedProvider);
                        setState(() {
                          _downloading.remove(feed.feedId);
                        });
                      });
                    },
                  );
                } else {
                  trailing = Icon(Icons.check, color: Colors.black26);
                }
                return ListTile(
                  title: Text(feed.titleEn ?? feed.title ?? feed.feedId),
                  trailing: trailing,
                );
              },
              separatorBuilder: (_, _) => Container(),
            ),
    );
  }
}
