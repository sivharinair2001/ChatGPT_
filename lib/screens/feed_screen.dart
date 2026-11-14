import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/activity.dart';
import '../state/app_controller.dart';
import '../theme/stride_theme.dart';
import '../utils/formatters.dart';
import '../widgets/activity_map.dart';
import 'activity_detail_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: const Text('Stride'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: StrideColors.spruce,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'OWNER · ALL ACCESS',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (app.loading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (app.activities.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Text(
                'No activities yet.\nTap Record to start.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            sliver: SliverList.separated(
              itemCount: app.activities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 28),
              itemBuilder: (context, index) {
                final activity = app.activities[index];
                return _ActivityTile(activity: activity);
              },
            ),
          ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEE · MMM d · HH:mm').format(activity.startedAt);
    final primaryMetric = activity.sport == SportType.ride
        ? formatSpeed(activity.speedKmh)
        : formatPace(activity.paceSecPerKm);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ActivityDetailScreen(activity: activity),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activity.displayName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(date, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ActivityMap(points: activity.points, height: 180),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _mini(
                  context,
                  'Distance',
                  '${formatDistanceKm(activity.distanceMeters)} km',
                ),
              ),
              Expanded(
                child: _mini(
                  context,
                  'Time',
                  formatDuration(activity.movingTime),
                ),
              ),
              Expanded(
                child: _mini(
                  context,
                  activity.sport == SportType.ride ? 'Speed' : 'Pace',
                  primaryMetric,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mini(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: StrideColors.stone,
                letterSpacing: 0.9,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
