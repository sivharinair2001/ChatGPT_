class TrackPoint {
  const TrackPoint({
    required this.latitude,
    required this.longitude,
    required this.altitudeMeters,
    required this.timestamp,
    this.speedMps,
  });

  final double latitude;
  final double longitude;
  final double altitudeMeters;
  final DateTime timestamp;
  final double? speedMps;

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'altitudeMeters': altitudeMeters,
        'timestamp': timestamp.toIso8601String(),
        'speedMps': speedMps,
      };

  factory TrackPoint.fromJson(Map<String, dynamic> json) => TrackPoint(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        altitudeMeters: (json['altitudeMeters'] as num?)?.toDouble() ?? 0,
        timestamp: DateTime.parse(json['timestamp'] as String),
        speedMps: (json['speedMps'] as num?)?.toDouble(),
      );
}
