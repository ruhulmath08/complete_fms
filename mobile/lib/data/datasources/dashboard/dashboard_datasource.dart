abstract class DashboardDatasource {
  Future<Map<String, dynamic>> getAggregates({
    required String from,
    required String to,
    required String grain,
  });
}
