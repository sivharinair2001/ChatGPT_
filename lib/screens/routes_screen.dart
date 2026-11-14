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

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        Text('Routes', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 6),
        Text(
          'Build routes, revisit preferred paths, see your personal heatmap.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        if (e.personalHeatmap) ...[
          Text('Personal heatmap',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ActivityMap(
              points: heatPoints,
              height: 220,
              interactive: true,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Compiled from your recorded GPS traces.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
        ],
        if (e.routeBuilder) ...[
          Text('Route builder', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          _routeIdea(
            context,
            title: 'Ridge loop',
            detail: '12.4 km · 180 m gain · run',
          ),
          _routeIdea(
            context,
            title: 'River path out-and-back',
            detail: '8.0 km · flat · easy',
          ),
          _routeIdea(
            context,
            title: 'Hill repeats circuit',
            detail: '6.2 km · 220 m gain · intervals',
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Route drawing on map lands in the next milestone.',
                  ),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: StrideColors.fog,
              foregroundColor: StrideColors.ink,
            ),
            child: const Text('Create route'),
          ),
          const SizedBox(height: 28),
        ],
        if (e.liveSegments) ...[
          Text('Live segments', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Text(
            'During a recording, matching segments will surface with live pace vs your PR.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        if (e.beacon) ...[
          const SizedBox(height: 28),
          Text('Beacon', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Text(
            'Share a live safety link while recording so someone can follow your location.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Beacon sharing will use a private live link.'),
                ),
              );
            },
            child: const Text('Enable beacon on next activity'),
          ),
        ],
      ],
    );
  }

  Widget _routeIdea(
    BuildContext context, {
    required String title,
    required String detail,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(detail, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
