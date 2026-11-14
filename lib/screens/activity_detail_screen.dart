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
        DateFormat('EEEE, MMM d · HH:mm').format(activity.startedAt);

    return Scaffold(
      appBar: AppBar(
        title: Text(activity.displayName),
        actions: [
          if (app.entitlements.advancedAnalysis)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  'PREMIUM',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: StrideColors.moss,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          Text(date, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ActivityMap(
              points: activity.points,
              height: 240,
              interactive: true,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StatBlock(
                  label: 'Distance',
                  value: '${formatDistanceKm(activity.distanceMeters)} km',
                ),
              ),
              Expanded(
                child: StatBlock(
                  label: 'Moving time',
                  value: formatDuration(activity.movingTime),
                  align: TextAlign.center,
                ),
              ),
              Expanded(
                child: StatBlock(
                  label: activity.sport == SportType.ride ? 'Avg speed' : 'Pace',
                  value: activity.sport == SportType.ride
                      ? formatSpeed(activity.speedKmh)
                      : formatPace(activity.paceSecPerKm),
                  align: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: StatBlock(
                  label: 'Elev gain',
                  value: '${activity.elevationGainMeters.round()} m',
                ),
              ),
              if (app.entitlements.relativeEffort)
                Expanded(
                  child: StatBlock(
                    label: 'Relative effort',
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
          if (app.entitlements.advancedAnalysis && splits.isNotEmpty) ...[
            const SizedBox(height: 28),
            Text(
              'Kilometer splits',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...splits.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: Text(
                        'Km ${s.kmIndex}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        formatPace(s.paceSecPerKm),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      '${s.elevationDelta >= 0 ? '+' : ''}${s.elevationDelta.round()} m',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
