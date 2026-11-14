import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/activity.dart';
import '../state/app_controller.dart';
import '../theme/stride_theme.dart';
import '../utils/formatters.dart';
import '../widgets/activity_map.dart';
import 'activity_detail_screen.dart';

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();

    return Scaffold(
      backgroundColor: StravaColors.navy,
      body: Stack(
        children: [
          Positioned.fill(
            child: ActivityMap(
              points: app.livePoints.isEmpty
                  ? const []
                  : app.livePoints,
              height: double.infinity,
              interactive: true,
              followLive: app.isRecording,
            ),
          ),
          if (app.livePoints.isEmpty)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0xFF2A2A2E),
                child: Center(
                  child: Icon(Icons.map_outlined,
                      size: 72, color: Color(0xFF55555C)),
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.settings_outlined,
                            color: Colors.white),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'GPS OK',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.layers_outlined,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                if (!app.isRecording)
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: SportType.values.map((sport) {
                        final selected = app.selectedSport == sport;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(sport.label),
                            selected: selected,
                            onSelected: (_) => app.setSport(sport),
                            selectedColor: StravaColors.orange,
                            backgroundColor: Colors.black.withOpacity(0.45),
                            side: BorderSide.none,
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  selected ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  decoration: const BoxDecoration(
                    color: StravaColors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _liveStat(
                              'Distance',
                              '${formatDistanceKm(app.liveDistanceMeters)} km',
                            ),
                          ),
                          Expanded(
                            child: _liveStat(
                              'Time',
                              formatDuration(
                                Duration(seconds: app.liveElapsedSeconds),
                              ),
                            ),
                          ),
                          Expanded(
                            child: _liveStat(
                              app.selectedSport == SportType.ride
                                  ? 'Speed'
                                  : 'Pace',
                              _liveMetric(app),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      if (!app.isRecording)
                        GestureDetector(
                          onTap: () => app.startRecording(),
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: const BoxDecoration(
                              color: StravaColors.orange,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'START',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _roundAction(
                              label: 'Discard',
                              color: StravaColors.muted,
                              icon: Icons.close,
                              onTap: () => app.stopRecording(save: false),
                            ),
                            _roundAction(
                              label: app.isPaused ? 'Resume' : 'Pause',
                              color: StravaColors.navy,
                              icon: app.isPaused
                                  ? Icons.play_arrow
                                  : Icons.pause,
                              onTap: app.isPaused
                                  ? app.resumeRecording
                                  : app.pauseRecording,
                            ),
                            _roundAction(
                              label: 'Finish',
                              color: StravaColors.orange,
                              icon: Icons.stop,
                              onTap: () async {
                                final activity = await app.stopRecording();
                                if (activity != null && context.mounted) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ActivityDetailScreen(
                                        activity: activity,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _liveStat(String label, String value) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: StravaColors.muted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: StravaColors.text,
          ),
        ),
      ],
    );
  }

  Widget _roundAction({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: StravaColors.text,
          ),
        ),
      ],
    );
  }

  String _liveMetric(AppController app) {
    if (app.liveDistanceMeters < 5 || app.liveElapsedSeconds < 1) return '—';
    if (app.selectedSport == SportType.ride) {
      final kmh =
          (app.liveDistanceMeters / 1000) / (app.liveElapsedSeconds / 3600);
      return formatSpeed(kmh);
    }
    final pace = app.liveElapsedSeconds / (app.liveDistanceMeters / 1000);
    return formatPace(pace);
  }
}
