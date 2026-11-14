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

    return ColoredBox(
      color: StravaColors.canvas,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: StravaColors.white,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.search, color: StravaColors.text),
              onPressed: () {},
            ),
            title: const Text(
              'Home',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: StravaColors.text,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none,
                    color: StravaColors.text),
                onPressed: () {},
              ),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1),
            ),
          ),
          if (app.loading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: StravaColors.orange),
              ),
            )
          else if (app.activities.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'No activities yet.\nTap Record to start.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: StravaColors.muted),
                ),
              ),
            )
          else
            SliverList.separated(
              itemCount: app.activities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _StravaActivityCard(activity: app.activities[index]);
              },
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 88)),
        ],
      ),
    );
  }
}

class _StravaActivityCard extends StatelessWidget {
  const _StravaActivityCard({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final when = _relativeWhen(activity.startedAt);
    final primaryLabel =
        activity.sport == SportType.ride ? 'Avg Speed' : 'Pace';
    final primaryValue = activity.sport == SportType.ride
        ? formatSpeed(activity.speedKmh)
        : formatPace(activity.paceSecPerKm);

    return Material(
      color: StravaColors.white,
      child: InkWell(
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: StravaColors.orange,
                    child: Text(
                      app.ownerName.characters.first.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.ownerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: StravaColors.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$when · ${activity.sport.label}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: StravaColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_horiz,
                        color: StravaColors.muted),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Text(
                activity.displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: StravaColors.text,
                ),
              ),
            ),
            ActivityMap(points: activity.points, height: 210),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: _stat(
                      'Distance',
                      '${formatDistanceKm(activity.distanceMeters)} km',
                    ),
                  ),
                  Expanded(child: _stat(primaryLabel, primaryValue)),
                  Expanded(
                    child: _stat(
                      'Time',
                      formatDuration(activity.movingTime),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 20),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 16, 10),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.thumb_up_alt_outlined,
                        size: 18, color: StravaColors.muted),
                    label: const Text(
                      'Kudos',
                      style: TextStyle(
                        color: StravaColors.muted,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline,
                        size: 18, color: StravaColors.muted),
                    label: const Text(
                      'Comment',
                      style: TextStyle(
                        color: StravaColors.muted,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '12 kudos',
                    style: TextStyle(
                      color: StravaColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: StravaColors.muted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: StravaColors.text,
          ),
        ),
      ],
    );
  }

  String _relativeWhen(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inHours < 24 && now.day == dt.day) {
      return 'Today at ${DateFormat('h:mm a').format(dt)}';
    }
    if (diff.inHours < 48) {
      return 'Yesterday at ${DateFormat('h:mm a').format(dt)}';
    }
    return DateFormat('MMMM d, yyyy at h:mm a').format(dt);
  }
}
