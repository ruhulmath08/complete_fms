import 'package:mobile/data/datasources/dashboard/dashboard_datasource.dart';
import 'package:mobile/data/mappers/dashboard/dashboard_mappers.dart';
import 'package:mobile/data/models/dashboard/dashboard_aggregates_model.dart';
import 'package:mobile/domain/entities/dashboard/dashboard_aggregates.dart';
import 'package:mobile/domain/repositories/dashboard/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._datasource);

  final DashboardDatasource _datasource;

  @override
  Future<DashboardAggregates> getAggregates({
    required String from,
    required String to,
    required String grain,
  }) async {
    final model = DashboardAggregatesModel.fromJson(
      await _datasource.getAggregates(from: from, to: to, grain: grain),
    );
    return mapDashboardAggregatesModel(model);
  }
}
