import 'package:mobile/domain/entities/dashboard/dashboard_series_key.dart';
import 'package:mobile/domain/entities/dashboard/dashboard_series_point.dart';

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
