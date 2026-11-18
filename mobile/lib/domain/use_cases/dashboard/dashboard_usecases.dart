import 'package:mobile/domain/repositories/dashboard/dashboard_repository.dart';
import 'package:mobile/domain/entities/dashboard/dashboard_aggregates.dart';

class GetDashboardAggregates {
  GetDashboardAggregates(this._repository);
  final DashboardRepository _repository;
  Future<DashboardAggregates> call({
    required String from,
    required String to,
    required String grain,
  }) =>
      _repository.getAggregates(from: from, to: to, grain: grain);
}
