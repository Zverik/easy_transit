import 'package:easy_transit/constants.dart';
import 'package:easy_transit/l10n/l10n.dart';
import 'package:easy_transit/providers/geolocation.dart';
import 'package:easy_transit/providers/shared_prefs.dart';
import 'package:easy_transit/providers/transit.dart';
import 'package:easy_transit/screens/arrivals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtfs_binary_flutter/gtfs_binary_flutter.dart';
import 'package:latlong2/latlong.dart';

class LoadingPage extends ConsumerStatefulWidget {
  const LoadingPage({super.key});

  @override
  ConsumerState<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends ConsumerState<LoadingPage> {
  Future doInit() async {
    // So that we can use ref
    await Future.delayed(Duration.zero);

    if (!mounted) return;
    ref.read(geolocationProvider.notifier).enableTracking(context);
    await ref.read(sharedPrefsProvider.future);
    await ref.read(transitProvider.future);
    ref.read(geolocationProvider.notifier).enableTracking();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ArrivalsPage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    doInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kAppTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: null,
              color: Colors.blueGrey,
            ),
            SizedBox(height: 40.0),
            Text(
              AppLocalizations.of(context)?.loading ?? "Loading",
              style: TextStyle(fontSize: 20.0),
            ),
          ],
        ),
      ),
    );
  }
}
