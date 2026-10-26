import 'package:flutter/material.dart';
import 'package:public_transport/public_transport.dart';

class LegIcon extends StatelessWidget {
  final ItineraryLeg leg;

  const LegIcon(this.leg, {super.key});

  IconData _findIcon(TransitMode mode) => switch (mode) {
    TransitMode.walk => Icons.directions_walk,
    TransitMode.bus => Icons.directions_bus,
    TransitMode.coach => Icons.directions_bus,
    TransitMode.tram => Icons.tram,
    TransitMode.subway => Icons.subway,
    TransitMode.regionalRail => Icons.directions_train,
    TransitMode.suburban => Icons.directions_train,
    TransitMode.ferry => Icons.directions_ferry,
    TransitMode() => Icons.directions_bus,
  };

  @override
  Widget build(BuildContext context) {
    if (leg.route != null) {
      return RoutePlace(
        color: leg.route?.color == null
            ? Colors.blueAccent
            : Color(int.parse(leg.route!.color!, radix: 16)).withValues(alpha: 1.0),
        number: leg.route?.shortName ?? '00',
        icon: _findIcon(leg.mode),
        isBold: true,
        semantics: '${leg.mode.name} ${leg.route?.shortName}',
      );
    }

    final minutes = (leg.durationSeconds / 60.0).round().toString();
    return RoutePlace(
      color: Colors.grey.shade200,
      number: minutes,
      icon: Icons.directions_walk,
      isBold: false,
      // semantics: loc.walkMin(loc.minutes(minutes)),
    );
  }
}

class RoutePlace extends StatelessWidget {
  final Color color;
  final String number;
  final IconData icon;
  final bool isBold;
  final String? semantics;

  const RoutePlace({
    super.key,
    required this.color,
    required this.number,
    required this.icon,
    required this.isBold,
    this.semantics,
  });

  @override
  Widget build(BuildContext context) {
    Color foreground = color.computeLuminance() >= 0.8 ? Colors.black : Colors.white;

    return Semantics(
      label: semantics,
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          margin: EdgeInsets.symmetric(horizontal: 2.0),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5.0)),
          child: Row(
            children: [
              Icon(icon, color: foreground, size: 20.0),
              Text(
                number,
                style: TextStyle(
                  color: foreground,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: 20.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
