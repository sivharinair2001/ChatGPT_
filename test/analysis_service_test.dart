import 'package:athlete/models/activity.dart';
import 'package:athlete/models/track_point.dart';
import 'package:athlete/services/analysis_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('distanceAlong computes positive loop length', () {
    final points = <TrackPoint>[
      TrackPoint(
        latitude: 28.61,
        longitude: 77.20,
        altitudeMeters: 200,
        timestamp: DateTime(2026, 1, 1, 6),
      ),
      TrackPoint(
        latitude: 28.62,
        longitude: 77.20,
        altitudeMeters: 205,
        timestamp: DateTime(2026, 1, 1, 6, 5),
      ),
      TrackPoint(
        latitude: 28.62,
        longitude: 77.21,
        altitudeMeters: 210,
        timestamp: DateTime(2026, 1, 1, 6, 10),
      ),
    ];
    final d = AnalysisService.distanceAlong(points);
    expect(d, greaterThan(1000));
  });

  test('relativeEffort returns bounded score', () {
    final activity = Activity(
      id: '1',
      sport: SportType.run,
      startedAt: DateTime(2026, 1, 1),
      endedAt: DateTime(2026, 1, 1, 0, 30),
      distanceMeters: 5000,
      movingTimeSeconds: 1800,
      elevationGainMeters: 40,
      points: const [],
      avgHeartRate: 150,
    );
    final score = AnalysisService().relativeEffort(activity);
    expect(score, greaterThan(1));
    expect(score, lessThan(500));
  });
}
