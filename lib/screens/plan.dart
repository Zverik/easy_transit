import 'package:easy_transit/models/bookmark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

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
  @override
  void initState() {
    super.initState();
    // TODO: call the backend
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Route")),
      body: Center(child: Text("Not implemented yet")),
    );
  }
}
