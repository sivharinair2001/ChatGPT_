import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';
import '../theme/stride_theme.dart';
import '../utils/formatters.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final e = app.entitlements;
    final totalKm = app.activities.fold<double>(
          0,
          (sum, a) => sum + a.distanceMeters,
        ) /
        1000;

    return Scaffold(
      backgroundColor: StravaColors.canvas,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: StravaColors.orange,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              bottom: 20,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings_outlined,
                          color: Colors.white),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white,
                  child: Text(
                    app.ownerName.characters.first.toUpperCase(),
                    style: const TextStyle(
                      color: StravaColors.orange,
                      fontWeight: FontWeight.w900,
                      fontSize: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  app.ownerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  app.ownerEmail,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _followStat('${app.activities.length}', 'Activities'),
                    Container(
                      width: 1,
                      height: 28,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      color: Colors.white.withOpacity(0.35),
                    ),
                    _followStat(formatDistanceKm(totalKm * 1000), 'Kilometers'),
                    Container(
                      width: 1,
                      height: 28,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      color: Colors.white.withOpacity(0.35),
                    ),
                    _followStat('∞', 'Following'),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: StravaColors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: StravaColors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'SUBSCRIBER',
                    style: TextStyle(
                      color: StravaColors.orange,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Owner plan · all premium features unlocked',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: StravaColors.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            color: StravaColors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Benefits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                ...e.unlockedLabels.map(
                  (label) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(Icons.check_circle,
                        color: StravaColors.orange, size: 22),
                    title: Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: StravaColors.text,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _followStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
