import 'package:mobile/data/datasources/dashboard/dashboard_datasource.dart';
import 'package:mobile/data/network/api_client.dart';
import 'package:mobile/data/network/api_endpoints.dart';

class DashboardDatasourceImpl implements DashboardDatasource {
  DashboardDatasourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> getAggregates({
    required String from,
    required String to,
    required String grain,
  }) {
    return _client.get(
      ApiEndpoints.dashboardAggregates,
      query: {'from': from, 'to': to, 'grain': grain},
    );
  }
}
