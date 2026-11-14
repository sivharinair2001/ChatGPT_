import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';
import '../theme/stride_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final e = app.entitlements;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        Text('Profile', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 20),
        Text(app.ownerName, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(app.ownerEmail, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [StrideColors.spruce, Color(0xFF244C3C)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Owner plan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                e.allPremium
                    ? 'Every premium feature is enabled for you. No subscription wall.'
                    : 'Some features are locked.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text('Unlocked features',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        ...e.unlockedLabels.map(
          (label) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: StrideColors.moss, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          '${app.activities.length} activities on this device',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
