import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtfs_binary_flutter/gtfs_binary_flutter.dart';

final transitProvider = FutureProvider((_) => GtfsWrapper.create());

final feedProvider = FutureProvider((ref) async {
  final transit = await ref.read(transitProvider.future);
  return await transit.queryFeeds(download: true);
});