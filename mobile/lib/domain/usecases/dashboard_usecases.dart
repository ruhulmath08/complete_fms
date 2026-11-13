import '../entities/dashboard.dart';
import '../repositories/dashboard_repository.dart';

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
