enum DashboardSeriesKey {
  eggProduction('egg_production'),
  henHeadcount('hen_headcount'),
  milk('milk'),
  cowProduction('cow_production'),
  expensesCost('expenses_cost'),
  income('income');

  const DashboardSeriesKey(this.apiKey);

  final String apiKey;
}

class DashboardSeriesPoint {
  const DashboardSeriesPoint({required this.bucketStart, required this.value});

  final String bucketStart;
  final String value;
}

class DashboardAggregates {
  const DashboardAggregates({
    required this.to,
    required this.grain,
    required this.timezone,
    required this.series,
    this.from,
  });

  final String? from;
  final String to;
  final String grain;
  final String timezone;
  final Map<DashboardSeriesKey, List<DashboardSeriesPoint>> series;

  List<DashboardSeriesPoint> pointsFor(DashboardSeriesKey key) =>
      series[key] ?? const [];
}
