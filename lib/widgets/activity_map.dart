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
  });

  final List<TrackPoint> points;
  final double height;
  final bool interactive;
  final bool followLive;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: DecoratedBox(
          decoration: const BoxDecoration(color: StrideColors.fog),
          child: Center(
            child: Text(
              'Waiting for GPS…',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    final latLngs = points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList(growable: false);
    final center = latLngs[latLngs.length ~/ 2];

    return SizedBox(
      height: height,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: followLive ? latLngs.last : center,
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
                color: StrideColors.ember,
                strokeWidth: 4.5,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: latLngs.first,
                width: 16,
                height: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: StrideColors.spruce,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
              Marker(
                point: latLngs.last,
                width: 16,
                height: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: StrideColors.ember,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
