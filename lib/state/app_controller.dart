import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/activity.dart';
import '../models/entitlements.dart';
import '../models/track_point.dart';
import '../services/activity_store.dart';
import '../services/analysis_service.dart';
import '../services/location_service.dart';

class AppController extends ChangeNotifier {
  AppController({
    ActivityStore? store,
    LocationService? locationService,
    AnalysisService? analysisService,
  })  : _store = store ?? ActivityStore(),
        _location = locationService ?? LocationService(),
        _analysis = analysisService ?? AnalysisService();

  final ActivityStore _store;
  final LocationService _location;
  final AnalysisService _analysis;
  final _uuid = const Uuid();

  /// Personal owner account — every premium feature unlocked.
  final Entitlements entitlements = Entitlements.owner;
  final String ownerName = 'You';
  final String ownerEmail = 'owner@stride.local';

  List<Activity> activities = [];
  bool loading = true;
  String? error;

  // Recording state
  bool isRecording = false;
  bool isPaused = false;
  SportType selectedSport = SportType.run;
  DateTime? recordStartedAt;
  final List<TrackPoint> livePoints = [];
  double liveDistanceMeters = 0;
  StreamSubscription<TrackPoint>? _gpsSub;
  Timer? _ticker;
  int liveElapsedSeconds = 0;

  AnalysisService get analysis => _analysis;

  Future<void> init() async {
    loading = true;
    notifyListeners();
    try {
      activities = await _store.load();
      error = null;
    } catch (e) {
      error = 'Could not load activities';
      activities = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> startRecording({bool simulateIfDenied = true}) async {
    if (isRecording) return;
    final ok = await _location.ensurePermission();
    livePoints.clear();
    liveDistanceMeters = 0;
    liveElapsedSeconds = 0;
    recordStartedAt = DateTime.now();
    isRecording = true;
    isPaused = false;
    notifyListeners();

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isPaused) {
        liveElapsedSeconds += 1;
        notifyListeners();
      }
    });

    if (ok) {
      final first = await _location.currentPoint();
      if (first != null) {
        livePoints.add(first);
        notifyListeners();
      }
      await _gpsSub?.cancel();
      _gpsSub = _location.watchPositions().listen(_onPoint);
    } else if (simulateIfDenied) {
      // Simulator / denied permission: generate a local loop so UI is usable.
      _startSimulation();
    } else {
      error = 'Location permission is required to record.';
      await stopRecording(save: false);
    }
  }

  void _startSimulation() {
    const baseLat = 28.6139;
    const baseLng = 77.2090;
    var i = 0;
    _gpsSub?.cancel();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isPaused && isRecording) {
        liveElapsedSeconds += 1;
        final t = i / 60.0;
        final sim = TrackPoint(
          latitude: baseLat + 0.0012 * t * (1 - (t % 1)),
          longitude: baseLng + 0.0018 * t,
          altitudeMeters: 220 + (i % 8).toDouble(),
          timestamp: DateTime.now(),
          speedMps: selectedSport == SportType.ride ? 7 : 2.8,
        );
        _onPoint(sim);
        i += 1;
        notifyListeners();
      }
    });
  }

  void _onPoint(TrackPoint point) {
    if (!isRecording || isPaused) return;
    if (livePoints.isNotEmpty) {
      final prev = livePoints.last;
      liveDistanceMeters += AnalysisService.distanceAlong([prev, point]);
    }
    livePoints.add(point);
    notifyListeners();
  }

  void pauseRecording() {
    isPaused = true;
    notifyListeners();
  }

  void resumeRecording() {
    isPaused = false;
    notifyListeners();
  }

  Future<Activity?> stopRecording({bool save = true}) async {
    await _gpsSub?.cancel();
    _gpsSub = null;
    _ticker?.cancel();
    _ticker = null;

    Activity? created;
    if (save && livePoints.length >= 2 && recordStartedAt != null) {
      final ended = DateTime.now();
      created = Activity(
        id: _uuid.v4(),
        sport: selectedSport,
        startedAt: recordStartedAt!,
        endedAt: ended,
        distanceMeters: liveDistanceMeters,
        movingTimeSeconds: liveElapsedSeconds,
        elevationGainMeters: AnalysisService.elevationGain(livePoints),
        points: List.unmodifiable(livePoints),
      );
      activities = [created, ...activities];
      await _store.save(activities);
    }

    isRecording = false;
    isPaused = false;
    livePoints.clear();
    liveDistanceMeters = 0;
    liveElapsedSeconds = 0;
    recordStartedAt = null;
    notifyListeners();
    return created;
  }

  void setSport(SportType sport) {
    selectedSport = sport;
    notifyListeners();
  }

  Future<void> deleteActivity(String id) async {
    activities = activities.where((a) => a.id != id).toList();
    await _store.save(activities);
    notifyListeners();
  }

  FitnessSnapshot get fitness => _analysis.fitnessFreshness(activities);

  @override
  void dispose() {
    _gpsSub?.cancel();
    _ticker?.cancel();
    _location.dispose();
    super.dispose();
  }
}
