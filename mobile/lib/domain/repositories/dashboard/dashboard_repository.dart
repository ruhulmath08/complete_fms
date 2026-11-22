import 'package:mobile/domain/entities/dashboard/dashboard_aggregates_entity.dart';

abstract class DashboardRepository {
  Future<DashboardAggregatesEntity> getAggregates({
    required String from,
    required String to,
    required String grain,
  });
}
