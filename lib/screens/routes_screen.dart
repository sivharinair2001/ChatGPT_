import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';
import '../theme/stride_theme.dart';
import '../widgets/activity_map.dart';

class RoutesScreen extends StatelessWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final e = app.entitlements;
    final heatPoints =
        app.activities.expand((a) => a.points).take(400).toList();

    return Scaffold(
      backgroundColor: StravaColors.canvas,
      appBar: AppBar(
        title: const Text('Maps'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          if (e.personalHeatmap) ...[
            Container(
              color: StravaColors.white,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Heatmap',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Your recorded GPS traces',
                    style: TextStyle(color: StravaColors.muted),
                  ),
                ],
              ),
            ),
            ActivityMap(
              points: heatPoints,
              height: 260,
              interactive: true,
            ),
            const SizedBox(height: 8),
          ],
          if (e.routeBuilder)
            Container(
              color: StravaColors.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saved Routes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _route('Ridge loop', '12.4 km · 180 m gain'),
                  _route('River path out-and-back', '8.0 km · flat'),
                  _route('Hill repeats circuit', '6.2 km · 220 m gain'),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Interactive route builder comes next.',
                            ),
                          ),
                        );
                      },
                      child: const Text('Create Route'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          if (e.liveSegments || e.beacon) ...[
            const SizedBox(height: 8),
            Container(
              color: StravaColors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (e.liveSegments) ...[
                    const Text(
                      'Live Segments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Matching segments surface live pace vs your PR while recording.',
                      style: TextStyle(color: StravaColors.muted),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (e.beacon) ...[
                    const Text(
                      'Beacon',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Share a live safety link so someone can follow your location.',
                      style: TextStyle(color: StravaColors.muted),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: StravaColors.orange,
                        side: const BorderSide(color: StravaColors.orange),
                      ),
                      child: const Text('Enable Beacon'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _route(String title, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: StravaColors.orange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.route, color: StravaColors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  detail,
                  style: const TextStyle(
                    color: StravaColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: StravaColors.muted),
        ],
      ),
    );
  }
}
