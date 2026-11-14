import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/activity.dart';
import '../state/app_controller.dart';
import '../theme/stride_theme.dart';
import '../utils/formatters.dart';
import '../widgets/activity_map.dart';
import '../widgets/stat_block.dart';

class ActivityDetailScreen extends StatelessWidget {
  const ActivityDetailScreen({super.key, required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final splits = app.analysis.kilometerSplits(activity);
    final effort = app.analysis.relativeEffort(activity);
    final date =
        DateFormat('EEEE, MMM d · h:mm a').format(activity.startedAt);

    return Scaffold(
      backgroundColor: StravaColors.white,
      appBar: AppBar(
        title: Text(activity.sport.label),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.ios_share_outlined),
          ),
        ],
      ),
      body: ListView(
        children: [
          ActivityMap(
            points: activity.points,
            height: 260,
            interactive: true,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.displayName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: StravaColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    color: StravaColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: StatBlock(
                        label: 'Distance',
                        value:
                            '${formatDistanceKm(activity.distanceMeters)} km',
                      ),
                    ),
                    Expanded(
                      child: StatBlock(
                        label: 'Moving Time',
                        value: formatDuration(activity.movingTime),
                        align: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: StatBlock(
                        label: activity.sport == SportType.ride
                            ? 'Avg Speed'
                            : 'Pace',
                        value: activity.sport == SportType.ride
                            ? formatSpeed(activity.speedKmh)
                            : formatPace(activity.paceSecPerKm),
                        align: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatBlock(
                        label: 'Elev Gain',
                        value: '${activity.elevationGainMeters.round()} m',
                      ),
                    ),
                    if (app.entitlements.relativeEffort)
                      Expanded(
                        child: StatBlock(
                          label: 'Rel Effort',
                          value: effort.toStringAsFixed(0),
                          align: TextAlign.center,
                        ),
                      ),
                    if (activity.avgHeartRate != null)
                      Expanded(
                        child: StatBlock(
                          label: 'Avg HR',
                          value: '${activity.avgHeartRate} bpm',
                          align: TextAlign.right,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (app.entitlements.advancedAnalysis && splits.isNotEmpty) ...[
            const Divider(height: 28),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Splits',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ...splits.map(
              (s) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 52,
                      child: Text(
                        '${s.kmIndex}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: StravaColors.text,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: (s.paceSecPerKm / 600).clamp(0.15, 1),
                          minHeight: 8,
                          backgroundColor: StravaColors.hairline,
                          color: StravaColors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 72,
                      child: Text(
                        formatPace(s.paceSecPerKm),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}
