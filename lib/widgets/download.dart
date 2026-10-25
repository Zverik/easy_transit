import 'package:easy_transit/providers/geolocation.dart';
import 'package:easy_transit/providers/transit.dart';
import 'package:easy_transit/screens/feeds.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NeedDownloadPanel extends ConsumerWidget {
  const NeedDownloadPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feeds = ref.watch(feedProvider);
    final location = ref.watch(geolocationProvider);
    if (location != null && feeds.hasValue && !feeds.requireValue.any((f) => f.isInstalled && f.contains(location))) {
      return GestureDetector(
        child: Container(
          color: Colors.red,
          height: 200.0,
          child: Center(
            child: Text(
              "No data, tap here to download",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => FeedsPage()));
        },
      );
    }
    return Container();
  }
}
