import 'package:easy_transit/widgets/itinerary_leg.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:public_transport/public_transport.dart';

class ItineraryPage extends ConsumerStatefulWidget {
  final List<ItineraryLeg> itinerary;

  const ItineraryPage(this.itinerary, {super.key});

  @override
  ConsumerState createState() => _ItineraryPageState();
}

class _ItineraryPageState extends ConsumerState<ItineraryPage> {
  static final timeFormat = DateFormat.Hm();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWide = screenSize.width >= 600 || screenSize.width > screenSize.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${timeFormat.format(widget.itinerary.first.departure)} — ${timeFormat.format(widget.itinerary.last.arrival)}',
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        right: false,
        child: ListView.separated(
          itemCount: widget.itinerary.length,
          separatorBuilder: (context, index) => SizedBox(height: 5.0),
          itemBuilder: (context, index) => ItineraryLegCard(
            widget.itinerary[index],
            isPortrait: !isWide,
            lastLeg: index == 0 ? null : widget.itinerary[index - 1],
            nextLeg: index + 1 >= widget.itinerary.length ? null : widget.itinerary[index + 1],
          ),
        ),
      ),
    );
  }
}
