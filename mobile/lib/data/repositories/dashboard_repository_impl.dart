import 'package:mobile/domain/entities/dashboard.dart';
import 'package:mobile/domain/repositories/dashboard_repository.dart';
import 'package:mobile/data/datasources/dashboard_api.dart';
import 'package:mobile/data/mappers/dashboard_mappers.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._api);

  final DashboardApi _api;

  @override
  Future<DashboardAggregates> getAggregates({
    required String from,
    required String to,
    required String grain,
  }) async =>
      mapDashboardAggregates(
        await _api.getAggregates(from: from, to: to, grain: grain),
      );
}
