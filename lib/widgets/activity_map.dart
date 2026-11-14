import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/track_point.dart';
import '../theme/stride_theme.dart';

class ActivityMap extends StatelessWidget {
  const ActivityMap({
    super.key,
    required this.points,
    this.height = 220,
    this.interactive = false,
    this.followLive = false,
    this.borderRadius = 0,
  });

  final List<TrackPoint> points;
  final double height;
  final bool interactive;
  final bool followLive;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: const ColoredBox(
          color: StravaColors.canvas,
          child: Center(
            child: Text(
              'Waiting for GPS…',
              style: TextStyle(color: StravaColors.muted, fontSize: 14),
            ),
          ),
        ),
      );
    }

    final latLngs = points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList(growable: false);
    final center = followLive ? latLngs.last : latLngs[latLngs.length ~/ 2];

    final map = FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 14.2,
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.personal.athlete.stride',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: latLngs,
              color: StravaColors.mapLine,
              strokeWidth: 4,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: latLngs.first,
              width: 14,
              height: 14,
              child: Container(
                decoration: BoxDecoration(
                  color: StravaColors.navy,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
            Marker(
              point: latLngs.last,
              width: 14,
              height: 14,
              child: Container(
                decoration: BoxDecoration(
                  color: StravaColors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    return SizedBox(
      height: height,
      child: borderRadius > 0
          ? ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: map,
            )
          : map,
    );
  }
}
