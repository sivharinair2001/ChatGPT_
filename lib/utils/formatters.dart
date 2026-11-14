String formatDistanceKm(double meters) {
  final km = meters / 1000.0;
  if (km < 10) return km.toStringAsFixed(2);
  return km.toStringAsFixed(1);
}

String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (h > 0) return '$h:$m:$s';
  return '${d.inMinutes}:$s';
}

String formatPace(double? secPerKm) {
  if (secPerKm == null || secPerKm <= 0 || secPerKm.isInfinite) return '—';
  final m = secPerKm ~/ 60;
  final s = (secPerKm % 60).round().toString().padLeft(2, '0');
  return "$m'$s\"/km";
}

String formatSpeed(double kmh) {
  if (kmh <= 0) return '—';
  return '${kmh.toStringAsFixed(1)} km/h';
}
