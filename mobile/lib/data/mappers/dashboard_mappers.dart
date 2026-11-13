import '../../domain/entities/dashboard.dart';

DashboardAggregates mapDashboardAggregates(Map<String, dynamic> json) {
  final rawSeries = (json['series'] as Map<String, dynamic>?) ?? const {};
  final series = <DashboardSeriesKey, List<DashboardSeriesPoint>>{};
  for (final key in DashboardSeriesKey.values) {
    final raw = (rawSeries[key.apiKey] as List<dynamic>?) ?? const [];
    series[key] = raw
        .map((e) => e as Map<String, dynamic>)
        .map(
          (p) => DashboardSeriesPoint(
            bucketStart: p['bucket_start'] as String,
            value: p['value'].toString(),
          ),
        )
        .toList();
  }
  return DashboardAggregates(
    from: json['from'] as String?,
    to: json['to'] as String,
    grain: json['grain'] as String,
    timezone: json['timezone'] as String? ?? '',
    series: series,
  );
}
