import 'package:mobile/domain/entities/dashboard/dashboard_series_key_entity.dart';
import 'package:mobile/domain/entities/dashboard/dashboard_series_point_entity.dart';

class DashboardAggregatesEntity {
  const DashboardAggregatesEntity({
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
  final Map<DashboardSeriesKeyEntity, List<DashboardSeriesPointEntity>> series;

  List<DashboardSeriesPointEntity> pointsFor(DashboardSeriesKeyEntity key) =>
      series[key] ?? const [];
}
