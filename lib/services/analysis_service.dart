import 'dart:math' as math;

import '../models/activity.dart';
import '../models/track_point.dart';

class Split {
  const Split({
    required this.kmIndex,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.elevationDelta,
  });

  final int kmIndex;
  final double distanceMeters;
  final int durationSeconds;
  final double elevationDelta;

  double get paceSecPerKm =>
      distanceMeters <= 0 ? 0 : durationSeconds / (distanceMeters / 1000.0);
}

class FitnessSnapshot {
  const FitnessSnapshot({
    required this.fitness,
    required this.fatigue,
    required this.form,
    required this.relativeEffort7d,
    required this.predicted5k,
    required this.predicted10k,
    required this.predictedHalf,
  });

  final double fitness;
  final double fatigue;
  final double form;
  final double relativeEffort7d;
  final Duration predicted5k;
  final Duration predicted10k;
  final Duration predictedHalf;
}

class AnalysisService {
  List<Split> kilometerSplits(Activity activity) {
    if (activity.points.length < 2) return const [];

    final splits = <Split>[];
    var kmIndex = 1;
    var segmentStart = activity.points.first;
    var accumulated = 0.0;
    var elevStart = segmentStart.altitudeMeters;

    for (var i = 1; i < activity.points.length; i++) {
      final prev = activity.points[i - 1];
      final curr = activity.points[i];
      final d = _haversineMeters(prev, curr);
      accumulated += d;

      while (accumulated >= 1000) {
        final overshoot = accumulated - 1000;
        final ratio = d <= 0 ? 0.0 : (d - overshoot) / d;
        final splitEndTime = prev.timestamp.add(
          Duration(
            milliseconds:
                ((curr.timestamp.difference(prev.timestamp).inMilliseconds) *
                        ratio)
                    .round(),
          ),
        );
        splits.add(
          Split(
            kmIndex: kmIndex,
            distanceMeters: 1000,
            durationSeconds:
                splitEndTime.difference(segmentStart.timestamp).inSeconds,
            elevationDelta: curr.altitudeMeters - elevStart,
          ),
        );
        kmIndex += 1;
        accumulated = overshoot;
        segmentStart = curr;
        elevStart = curr.altitudeMeters;
      }
    }

    if (accumulated > 50) {
      splits.add(
        Split(
          kmIndex: kmIndex,
          distanceMeters: accumulated,
          durationSeconds: activity.points.last.timestamp
              .difference(segmentStart.timestamp)
              .inSeconds,
          elevationDelta:
              activity.points.last.altitudeMeters - elevStart,
        ),
      );
    }

    return splits;
  }

  double relativeEffort(Activity activity) {
    // Simplified TRIMP-style score from duration + intensity proxy.
    final hours = activity.movingTimeSeconds / 3600.0;
    final intensity = switch (activity.sport) {
      SportType.ride => (activity.speedKmh / 25.0).clamp(0.6, 1.6),
      SportType.run =>
        (360.0 / (activity.paceSecPerKm ?? 360)).clamp(0.6, 1.8),
      SportType.walk || SportType.hike => 0.7,
    };
    final hrFactor = activity.avgHeartRate != null
        ? (activity.avgHeartRate! / 140.0).clamp(0.7, 1.5)
        : 1.0;
    return (hours * 100 * intensity * hrFactor).clamp(1, 500);
  }

  FitnessSnapshot fitnessFreshness(List<Activity> activities) {
    final now = DateTime.now();
    double fitness = 30;
    double fatigue = 20;
    double effort7d = 0;

    final sorted = [...activities]
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));

    for (final a in sorted) {
      final daysAgo = now.difference(a.startedAt).inHours / 24.0;
      final effort = relativeEffort(a);
      fitness += effort * math.exp(-daysAgo / 42);
      fatigue += effort * math.exp(-daysAgo / 7);
      if (daysAgo <= 7) effort7d += effort;
    }

    fitness = fitness.clamp(0, 120);
    fatigue = fatigue.clamp(0, 120);
    final form = fitness - fatigue;

    final recentRuns = activities
        .where((a) => a.sport == SportType.run && a.distanceMeters > 1000)
        .toList();
    final basePace = recentRuns.isEmpty
        ? 330.0
        : recentRuns
                .map((a) => a.paceSecPerKm ?? 330)
                .reduce((a, b) => a + b) /
            recentRuns.length;

    return FitnessSnapshot(
      fitness: fitness,
      fatigue: fatigue,
      form: form,
      relativeEffort7d: effort7d,
      predicted5k: Duration(seconds: (basePace * 5 * 0.98).round()),
      predicted10k: Duration(seconds: (basePace * 10 * 1.02).round()),
      predictedHalf: Duration(seconds: (basePace * 21.0975 * 1.06).round()),
    );
  }

  List<MapEntry<String, Duration>> bestEfforts(List<Activity> activities) {
    Duration? best(double targetMeters) {
      Duration? bestTime;
      for (final a in activities) {
        if (a.sport != SportType.run) continue;
        if (a.distanceMeters + 20 < targetMeters) continue;
        final estimated = Duration(
          seconds: ((a.movingTimeSeconds / a.distanceMeters) * targetMeters)
              .round(),
        );
        if (bestTime == null || estimated < bestTime) bestTime = estimated;
      }
      return bestTime;
    }

    return [
      if (best(1000) != null) MapEntry('1K', best(1000)!),
      if (best(5000) != null) MapEntry('5K', best(5000)!),
      if (best(10000) != null) MapEntry('10K', best(10000)!),
      if (best(21097.5) != null) MapEntry('Half', best(21097.5)!),
    ];
  }

  static double _haversineMeters(TrackPoint a, TrackPoint b) {
    const r = 6371000.0;
    final dLat = _rad(b.latitude - a.latitude);
    final dLon = _rad(b.longitude - a.longitude);
    final lat1 = _rad(a.latitude);
    final lat2 = _rad(b.latitude);
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    return 2 * r * math.asin(math.sqrt(h));
  }

  static double _rad(double deg) => deg * math.pi / 180.0;

  static double distanceAlong(List<TrackPoint> points) {
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += _haversineMeters(points[i - 1], points[i]);
    }
    return total;
  }

  static double elevationGain(List<TrackPoint> points) {
    var gain = 0.0;
    for (var i = 1; i < points.length; i++) {
      final d = points[i].altitudeMeters - points[i - 1].altitudeMeters;
      if (d > 0.8) gain += d;
    }
    return gain;
  }
}
