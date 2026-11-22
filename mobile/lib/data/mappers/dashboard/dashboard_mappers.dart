import 'package:mobile/data/models/dashboard/dashboard_aggregates_model.dart';
import 'package:mobile/data/models/dashboard/dashboard_series_point_model.dart';
import 'package:mobile/domain/entities/dashboard/dashboard_aggregates_entity.dart';
import 'package:mobile/domain/entities/dashboard/dashboard_series_key_entity.dart';
import 'package:mobile/domain/entities/dashboard/dashboard_series_point_entity.dart';

DashboardAggregatesEntity mapDashboardAggregates(Map<String, dynamic> json) =>
    mapDashboardAggregatesModel(DashboardAggregatesModel.fromJson(json));

DashboardAggregatesEntity mapDashboardAggregatesModel(DashboardAggregatesModel model) {
  return DashboardAggregatesEntity(
    from: model.from,
    to: model.to,
    grain: model.grain,
    timezone: model.timezone,
    series: {
      DashboardSeriesKeyEntity.eggProduction: _mapPoints(model.series.eggProduction),
      DashboardSeriesKeyEntity.henHeadcount: _mapPoints(model.series.henHeadcount),
      DashboardSeriesKeyEntity.milk: _mapPoints(model.series.milk),
      DashboardSeriesKeyEntity.cowProduction: _mapPoints(model.series.cowProduction),
      DashboardSeriesKeyEntity.expensesCost: _mapPoints(model.series.expensesCost),
      DashboardSeriesKeyEntity.income: _mapPoints(model.series.income),
    },
  );
}

List<DashboardSeriesPointEntity> _mapPoints(List<DashboardSeriesPointModel> points) =>
    points
        .map(
          (p) => DashboardSeriesPointEntity(
            bucketStart: p.bucketStart,
            value: p.value,
          ),
        )
        .toList();
