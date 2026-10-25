import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtfs_binary_flutter/gtfs_binary_flutter.dart';

final currentStopProvider = NotifierProvider(CurrentStopController.new);

class CurrentStopController extends Notifier<Stop?> {
  @override
  Stop? build() => null;

  void set(Stop? stop) {
    state = stop;
  }

  void clear() => set(null);
}