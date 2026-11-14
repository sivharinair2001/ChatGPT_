import 'package:flutter/material.dart';

import '../widgets/strava_bottom_nav.dart';
import 'feed_screen.dart';
import 'profile_screen.dart';
import 'record_screen.dart';
import 'routes_screen.dart';
import 'training_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  static const _pages = [
    FeedScreen(),
    RoutesScreen(), // Maps tab — Strava layout
    RecordScreen(),
    TrainingScreen(), // Groups/Training stand-in with premium suite
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: _pages),
      bottomNavigationBar: StravaBottomNav(
        index: index,
        onChanged: (i) => setState(() => index = i),
      ),
    );
  }
}
