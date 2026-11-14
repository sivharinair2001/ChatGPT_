import 'dart:convert';
import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/activity.dart';
import '../models/track_point.dart';
import 'analysis_service.dart';

class ActivityStore {
  static const _key = 'stride_activities_v1';

  Future<List<Activity>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) {
        final seeded = _seedActivities();
        await save(seeded);
        return seeded;
      }
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Activity.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    } catch (_) {
      return _seedActivities();
    }
  }

  Future<void> save(List<Activity> activities) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        jsonEncode(activities.map((a) => a.toJson()).toList(growable: false));
    await prefs.setString(_key, encoded);
  }

  List<Activity> _seedActivities() {
    final now = DateTime.now();
    final morning = now.subtract(const Duration(days: 1, hours: 2));
    final runPoints = _syntheticLoop(
      start: morning,
      lat: 28.6139,
      lng: 77.2090,
      samples: 90,
      radiusMeters: 650,
      duration: const Duration(minutes: 32),
    );
    final rideStart = now.subtract(const Duration(days: 3));
    final ridePoints = _syntheticLoop(
      start: rideStart,
      lat: 28.61,
      lng: 77.22,
      samples: 120,
      radiusMeters: 1800,
      duration: const Duration(minutes: 55),
    );

    return [
      Activity(
        id: 'seed-run-1',
        sport: SportType.run,
        name: 'Morning tempo',
        startedAt: morning,
        endedAt: morning.add(const Duration(minutes: 32)),
        distanceMeters: AnalysisService.distanceAlong(runPoints),
        movingTimeSeconds: 32 * 60,
        elevationGainMeters: AnalysisService.elevationGain(runPoints),
        points: runPoints,
        avgHeartRate: 148,
        maxHeartRate: 171,
      ),
      Activity(
        id: 'seed-ride-1',
        sport: SportType.ride,
        name: 'Evening spin',
        startedAt: rideStart,
        endedAt: rideStart.add(const Duration(minutes: 55)),
        distanceMeters: AnalysisService.distanceAlong(ridePoints),
        movingTimeSeconds: 55 * 60,
        elevationGainMeters: AnalysisService.elevationGain(ridePoints),
        points: ridePoints,
        avgHeartRate: 132,
        maxHeartRate: 158,
      ),
    ];
  }

  List<TrackPoint> _syntheticLoop({
    required DateTime start,
    required double lat,
    required double lng,
    required int samples,
    required double radiusMeters,
    required Duration duration,
  }) {
    final points = <TrackPoint>[];
    for (var i = 0; i < samples; i++) {
      final t = i / (samples - 1);
      final angle = t * 2 * math.pi;
      final dLat = (radiusMeters / 111320.0) * math.cos(angle);
      final dLng =
          (radiusMeters / (111320.0 * math.cos(lat * math.pi / 180))) *
              math.sin(angle);
      points.add(
        TrackPoint(
          latitude: lat + dLat,
          longitude: lng + dLng,
          altitudeMeters: 216 + 12 * math.sin(angle * 2),
          timestamp: start.add(
            Duration(milliseconds: (duration.inMilliseconds * t).round()),
          ),
        ),
      );
    }
    return points;
  }
}
