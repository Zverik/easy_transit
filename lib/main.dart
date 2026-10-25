import 'dart:async';

import 'package:easy_transit/constants.dart';
import 'package:easy_transit/screens/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import 'helpers/log_store.dart';

void main() {
  const isRelease = bool.fromEnvironment('dart.vm.product');
  Logger.root.level = isRelease ? Level.WARNING : Level.INFO;
  Logger.root.onRecord.listen((event) {
    logStore.addFromLogger(event);
  });
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) {
      logStore.addFromFlutter(details);
      FlutterError.presentError(details);
    };
    runApp(ProviderScope(child: EasyTransitApp()));
  }, (error, stack) {logStore.addFromZone(error, stack); });
}

class EasyTransitApp extends ConsumerWidget {
  const EasyTransitApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: kAppTitle,
      // debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.blue),
      ),
      home: const LoadingPage(),
    );
  }
}
