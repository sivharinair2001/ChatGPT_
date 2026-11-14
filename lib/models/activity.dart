import 'track_point.dart';

enum SportType { run, ride, walk, hike }

extension SportTypeX on SportType {
  String get label {
    switch (this) {
      case SportType.run:
        return 'Run';
      case SportType.ride:
        return 'Ride';
      case SportType.walk:
        return 'Walk';
      case SportType.hike:
        return 'Hike';
    }
  }

  String get verb {
    switch (this) {
      case SportType.run:
        return 'Running';
      case SportType.ride:
        return 'Riding';
      case SportType.walk:
        return 'Walking';
      case SportType.hike:
        return 'Hiking';
    }
  }
}

class Activity {
  const Activity({
    required this.id,
    required this.sport,
    required this.startedAt,
    required this.endedAt,
    required this.distanceMeters,
    required this.movingTimeSeconds,
    required this.elevationGainMeters,
    required this.points,
    this.name,
    this.avgHeartRate,
    this.maxHeartRate,
  });

  final String id;
  final SportType sport;
  final DateTime startedAt;
  final DateTime endedAt;
  final double distanceMeters;
  final int movingTimeSeconds;
  final double elevationGainMeters;
  final List<TrackPoint> points;
  final String? name;
  final int? avgHeartRate;
  final int? maxHeartRate;

  String get displayName =>
      name ?? '${sport.label} · ${_weekday(startedAt)}';

  double get distanceKm => distanceMeters / 1000.0;

  Duration get movingTime => Duration(seconds: movingTimeSeconds);

  /// Pace in seconds per kilometer (runs/walks/hikes).
  double? get paceSecPerKm {
    if (distanceMeters < 1) return null;
    return movingTimeSeconds / distanceKm;
  }

  /// Speed in km/h (rides).
  double get speedKmh {
    if (movingTimeSeconds <= 0) return 0;
    return distanceKm / (movingTimeSeconds / 3600.0);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sport': sport.name,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'distanceMeters': distanceMeters,
        'movingTimeSeconds': movingTimeSeconds,
        'elevationGainMeters': elevationGainMeters,
        'points': points.map((p) => p.toJson()).toList(),
        'name': name,
        'avgHeartRate': avgHeartRate,
        'maxHeartRate': maxHeartRate,
      };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json['id'] as String,
        sport: SportType.values.firstWhere(
          (s) => s.name == json['sport'],
          orElse: () => SportType.run,
        ),
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: DateTime.parse(json['endedAt'] as String),
        distanceMeters: (json['distanceMeters'] as num).toDouble(),
        movingTimeSeconds: json['movingTimeSeconds'] as int,
        elevationGainMeters: (json['elevationGainMeters'] as num).toDouble(),
        points: (json['points'] as List<dynamic>)
            .map((e) => TrackPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        name: json['name'] as String?,
        avgHeartRate: json['avgHeartRate'] as int?,
        maxHeartRate: json['maxHeartRate'] as int?,
      );

  static String _weekday(DateTime d) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[d.weekday - 1];
  }
}
