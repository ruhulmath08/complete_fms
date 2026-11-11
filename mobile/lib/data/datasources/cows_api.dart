import 'package:dio/dio.dart';
import 'api_client.dart';

class CowsApi {
  CowsApi(this._client);

  final ApiClient _client;

  Dio get _dio => _client.dio;

  Future<Map<String, dynamic>> listCows({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/cows',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          if (includeArchived) 'include_archived': true,
        },
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> getCow(String cowId) async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('/api/v1/cows/$cowId');
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> createCow(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/cows',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> updateCow(
    String cowId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/v1/cows/$cowId',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> archiveCow(String cowId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/cows/$cowId/archive',
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> uploadCowImage(
    String cowId,
    FormData formData,
  ) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/api/v1/cows/$cowId/image',
        data: formData,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<List<int>> getCowImageBytes(String cowId) async {
    try {
      final response = await _dio.get<List<int>>(
        '/api/v1/cows/$cowId/image',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data ?? <int>[];
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> listMilk(
    String cowId, {
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/cows/$cowId/milk-productions',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> addMilk(
    String cowId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/cows/$cowId/milk-productions',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> listFeedings(
    String cowId, {
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/cows/$cowId/feedings',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> addFeeding(
    String cowId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/cows/$cowId/feedings',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }
}
