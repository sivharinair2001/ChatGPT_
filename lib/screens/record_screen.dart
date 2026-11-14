import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/activity.dart';
import '../state/app_controller.dart';
import '../theme/stride_theme.dart';
import '../utils/formatters.dart';
import '../widgets/activity_map.dart';
import '../widgets/stat_block.dart';
import 'activity_detail_screen.dart';

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              app.isRecording ? app.selectedSport.verb : 'Record',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          if (!app.isRecording)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: SportType.values.map((sport) {
                  final selected = app.selectedSport == sport;
                  return ChoiceChip(
                    label: Text(sport.label),
                    selected: selected,
                    onSelected: (_) => app.setSport(sport),
                    selectedColor: StrideColors.fog,
                    labelStyle: TextStyle(
                      color: StrideColors.ink,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: ActivityMap(
              points: app.livePoints,
              height: double.infinity,
              interactive: true,
              followLive: app.isRecording,
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatBlock(
                        label: 'Distance',
                        value:
                            '${formatDistanceKm(app.liveDistanceMeters)} km',
                      ),
                    ),
                    Expanded(
                      child: StatBlock(
                        label: 'Time',
                        value: formatDuration(
                          Duration(seconds: app.liveElapsedSeconds),
                        ),
                        align: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: StatBlock(
                        label: app.selectedSport == SportType.ride
                            ? 'Speed'
                            : 'Pace',
                        value: _liveMetric(app),
                        align: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (!app.isRecording)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => app.startRecording(),
                      child: const Text('Start'),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await app.stopRecording(save: false);
                          },
                          child: const Text('Discard'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: app.isPaused
                              ? app.resumeRecording
                              : app.pauseRecording,
                          child: Text(app.isPaused ? 'Resume' : 'Pause'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            final activity = await app.stopRecording();
                            if (activity != null && context.mounted) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ActivityDetailScreen(activity: activity),
                                ),
                              );
                            }
                          },
                          child: const Text('Finish'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
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
