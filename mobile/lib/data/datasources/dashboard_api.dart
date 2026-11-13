import 'package:dio/dio.dart';
import 'api_client.dart';

class DashboardApi {
  DashboardApi(this._client);

  final ApiClient _client;

  Dio get _dio => _client.dio;

  Future<Map<String, dynamic>> getAggregates({
    required String from,
    required String to,
    required String grain,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/dashboard/aggregates',
        queryParameters: {'from': from, 'to': to, 'grain': grain},
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }
}
