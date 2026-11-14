import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';
import '../theme/stride_theme.dart';
import '../utils/formatters.dart';
import '../widgets/stat_block.dart';

/// Groups tab in Strava chrome — surfaces the premium training suite.
class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final e = app.entitlements;
    final fitness = app.fitness;
    final bests = app.analysis.bestEfforts(app.activities);

    return Scaffold(
      backgroundColor: StravaColors.canvas,
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Create',
              style: TextStyle(
                color: StravaColors.orange,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
        children: [
          _section(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subscriber benefits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  e.isOwner
                      ? 'Your owner plan includes every Strava-style premium feature.'
                      : 'Upgrade to unlock training tools.',
                  style: const TextStyle(color: StravaColors.muted),
                ),
              ],
            ),
          ),
          if (e.fitnessFreshness)
            _section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fitness & Freshness',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: StatBlock(
                          label: 'Fitness',
                          value: fitness.fitness.toStringAsFixed(0),
                        ),
                      ),
                      Expanded(
                        child: StatBlock(
                          label: 'Fatigue',
                          value: fitness.fatigue.toStringAsFixed(0),
                          align: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: StatBlock(
                          label: 'Form',
                          value: fitness.form.toStringAsFixed(0),
                          align: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '7-DAY RELATIVE EFFORT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: StravaColors.muted,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (fitness.relativeEffort7d / 200).clamp(0.05, 1),
                      minHeight: 10,
                      backgroundColor: StravaColors.hairline,
                      color: StravaColors.orange,
                    ),
                  ),
                ],
              ),
            ),
          if (e.racePredictions)
            _section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Race Predictions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _kv('5K', formatDuration(fitness.predicted5k)),
                  _kv('10K', formatDuration(fitness.predicted10k)),
                  _kv('Half Marathon', formatDuration(fitness.predictedHalf)),
                ],
              ),
            ),
          if (e.bestEfforts)
            _section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Best Efforts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (bests.isEmpty)
                    const Text(
                      'Record a longer run to unlock estimated bests.',
                      style: TextStyle(color: StravaColors.muted),
                    )
                  else
                    ...bests.map((b) => _kv(b.key, formatDuration(b.value))),
                ],
              ),
            ),
          if (e.trainingPlans)
            _section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This Week',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _plan('Mon', 'Easy run · 40 min'),
                  _plan('Wed', 'Intervals · 6×400m'),
                  _plan('Fri', 'Tempo · 30 min'),
                  _plan('Sun', 'Long run · 14 km'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _section({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      color: StravaColors.white,
      child: child,
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              k,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: StravaColors.text,
              ),
            ),
          ),
          Text(
            v,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: StravaColors.orange,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _plan(String day, String workout) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              day,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: StravaColors.orange,
              ),
            ),
          ),
          Expanded(
            child: Text(
              workout,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: StravaColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
