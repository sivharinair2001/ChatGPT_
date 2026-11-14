import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../models/track_point.dart';

class LocationService {
  StreamSubscription<Position>? _sub;

  Future<bool> ensurePermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<TrackPoint?> currentPoint() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
      return _toPoint(pos);
    } catch (_) {
      return null;
    }
  }

  Stream<TrackPoint> watchPositions() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5,
    );
    return Geolocator.getPositionStream(locationSettings: settings)
        .map(_toPoint);
  }

  TrackPoint _toPoint(Position pos) => TrackPoint(
        latitude: pos.latitude,
        longitude: pos.longitude,
        altitudeMeters: pos.altitude,
        timestamp: pos.timestamp,
        speedMps: pos.speed >= 0 ? pos.speed : null,
      );

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }
}
