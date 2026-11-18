import 'package:mobile/data/models/dashboard/dashboard_aggregates_model.dart';
import 'package:mobile/data/models/dashboard/dashboard_series_point_model.dart';
import 'package:mobile/domain/entities/dashboard/dashboard_aggregates.dart';
import 'package:mobile/domain/entities/dashboard/dashboard_series_key.dart';
import 'package:mobile/domain/entities/dashboard/dashboard_series_point.dart';

DashboardAggregates mapDashboardAggregates(Map<String, dynamic> json) =>
    mapDashboardAggregatesModel(DashboardAggregatesModel.fromJson(json));

DashboardAggregates mapDashboardAggregatesModel(DashboardAggregatesModel model) {
  return DashboardAggregates(
    from: model.from,
    to: model.to,
    grain: model.grain,
    timezone: model.timezone,
    series: {
      DashboardSeriesKey.eggProduction: _mapPoints(model.series.eggProduction),
      DashboardSeriesKey.henHeadcount: _mapPoints(model.series.henHeadcount),
      DashboardSeriesKey.milk: _mapPoints(model.series.milk),
      DashboardSeriesKey.cowProduction: _mapPoints(model.series.cowProduction),
      DashboardSeriesKey.expensesCost: _mapPoints(model.series.expensesCost),
      DashboardSeriesKey.income: _mapPoints(model.series.income),
    },
  );
}

List<DashboardSeriesPoint> _mapPoints(List<DashboardSeriesPointModel> points) =>
    points
        .map(
          (p) => DashboardSeriesPoint(
            bucketStart: p.bucketStart,
            value: p.value,
          ),
        )
        .toList();
