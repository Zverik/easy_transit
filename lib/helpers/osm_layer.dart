import 'package:flutter_map/flutter_map.dart';

TileLayer buildTileLayer() => TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  tileProvider: NetworkTileProvider(
    cachingProvider: BuiltInMapCachingProvider.getOrCreateInstance(maxCacheSize: 10_000_000),
  ),
  tileDimension: 256,
  minNativeZoom: 0,
  maxNativeZoom: 19,
  userAgentPackageName: 'info.zverev.ilya.easy_transit',
);
