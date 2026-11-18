import 'package:mobile/data/models/common/json_parsers.dart';
import 'package:mobile/data/models/dashboard/dashboard_series_bundle_model.dart';

class DashboardAggregatesModel {
  const DashboardAggregatesModel({
    required this.to,
    required this.grain,
    required this.timezone,
    required this.series,
    this.from,
  });

  factory DashboardAggregatesModel.fromJson(Map<String, dynamic> json) =>
      DashboardAggregatesModel(
        from: optionalString(json['from']),
        to: requireString(json['to'], 'to'),
        grain: requireString(json['grain'], 'grain'),
        timezone: optionalString(json['timezone']) ?? '',
        series: DashboardSeriesBundleModel.fromJson(
          (json['series'] as Map<String, dynamic>?) ?? const {},
        ),
      );

  final String? from;
  final String to;
  final String grain;
  final String timezone;
  final DashboardSeriesBundleModel series;

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'grain': grain,
        'timezone': timezone,
        'series': series.toJson(),
      };
}
