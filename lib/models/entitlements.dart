/// Owner account unlocks every premium capability — no paywall.
class Entitlements {
  const Entitlements({
    required this.isOwner,
    required this.trainingPlans,
    required this.relativeEffort,
    required this.fitnessFreshness,
    required this.racePredictions,
    required this.personalHeatmap,
    required this.routeBuilder,
    required this.liveSegments,
    required this.bestEfforts,
    required this.beacon,
    required this.advancedAnalysis,
    required this.monthlyReports,
  });

  final bool isOwner;
  final bool trainingPlans;
  final bool relativeEffort;
  final bool fitnessFreshness;
  final bool racePredictions;
  final bool personalHeatmap;
  final bool routeBuilder;
  final bool liveSegments;
  final bool bestEfforts;
  final bool beacon;
  final bool advancedAnalysis;
  final bool monthlyReports;

  bool get allPremium =>
      trainingPlans &&
      relativeEffort &&
      fitnessFreshness &&
      racePredictions &&
      personalHeatmap &&
      routeBuilder &&
      liveSegments &&
      bestEfforts &&
      beacon &&
      advancedAnalysis &&
      monthlyReports;

  static const owner = Entitlements(
    isOwner: true,
    trainingPlans: true,
    relativeEffort: true,
    fitnessFreshness: true,
    racePredictions: true,
    personalHeatmap: true,
    routeBuilder: true,
    liveSegments: true,
    bestEfforts: true,
    beacon: true,
    advancedAnalysis: true,
    monthlyReports: true,
  );

  List<String> get unlockedLabels => [
        if (trainingPlans) 'Training plans',
        if (relativeEffort) 'Relative effort',
        if (fitnessFreshness) 'Fitness & freshness',
        if (racePredictions) 'Race predictions',
        if (personalHeatmap) 'Personal heatmap',
        if (routeBuilder) 'Route builder',
        if (liveSegments) 'Live segments',
        if (bestEfforts) 'Best efforts',
        if (beacon) 'Beacon',
        if (advancedAnalysis) 'Pace & power analysis',
        if (monthlyReports) 'Progress reports',
      ];
}
