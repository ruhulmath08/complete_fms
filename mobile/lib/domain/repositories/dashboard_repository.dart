import '../entities/dashboard.dart';

abstract class DashboardRepository {
  Future<DashboardAggregates> getAggregates({
    required String from,
    required String to,
    required String grain,
  });
}
