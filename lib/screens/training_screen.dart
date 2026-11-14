import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';
import '../theme/stride_theme.dart';
import '../utils/formatters.dart';
import '../widgets/stat_block.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final e = app.entitlements;
    final fitness = app.fitness;
    final bests = app.analysis.bestEfforts(app.activities);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        Text('Training', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 6),
        Text(
          e.isOwner
              ? 'Owner premium unlocked — full training suite.'
              : 'Upgrade to unlock training tools.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        if (e.fitnessFreshness) ...[
          Text('Fitness & freshness',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
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
          const SizedBox(height: 10),
          _meter(context, '7-day relative effort', fitness.relativeEffort7d / 200),
          const SizedBox(height: 28),
        ],
        if (e.racePredictions) ...[
          Text('Race predictions',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _kv(context, '5K', formatDuration(fitness.predicted5k)),
          _kv(context, '10K', formatDuration(fitness.predicted10k)),
          _kv(context, 'Half marathon', formatDuration(fitness.predictedHalf)),
          const SizedBox(height: 28),
        ],
        if (e.bestEfforts) ...[
          Text('Best efforts', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (bests.isEmpty)
            Text(
              'Record a longer run to unlock estimated bests.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            ...bests.map((b) => _kv(context, b.key, formatDuration(b.value))),
          const SizedBox(height: 28),
        ],
        if (e.trainingPlans) ...[
          Text('This week plan', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _planRow(context, 'Mon', 'Easy run · 40 min'),
          _planRow(context, 'Wed', 'Intervals · 6×400m'),
          _planRow(context, 'Fri', 'Tempo · 30 min'),
          _planRow(context, 'Sun', 'Long run · 14 km'),
          const SizedBox(height: 28),
        ],
        if (e.monthlyReports)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: StrideColors.spruce,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly report',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${app.activities.length} activities saved · premium insights on.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.85),
                      ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _meter(BuildContext context, String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value.clamp(0.05, 1.0),
            minHeight: 10,
            backgroundColor: StrideColors.fog,
            color: StrideColors.moss,
          ),
        ),
      ],
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(k, style: Theme.of(context).textTheme.bodyLarge)),
          Text(v, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _planRow(BuildContext context, String day, String workout) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              day,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: StrideColors.moss,
                  ),
            ),
          ),
          Expanded(
            child: Text(workout, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
