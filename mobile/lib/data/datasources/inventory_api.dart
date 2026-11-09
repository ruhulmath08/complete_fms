import 'package:dio/dio.dart';
import 'api_client.dart';

class InventoryApi {
  InventoryApi(this._client);

  final ApiClient _client;

  Dio get _dio => _client.dio;

  Future<Map<String, dynamic>> listItems({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/inventory-items',
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

  Future<Map<String, dynamic>> getItem(String itemId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/inventory-items/$itemId',
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> createItem(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/inventory-items',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> updateItem(
    String itemId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/v1/inventory-items/$itemId',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> archiveItem(String itemId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/inventory-items/$itemId/archive',
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> listStockUpdates(
    String itemId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/inventory-items/$itemId/stock-updates',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> addStockUpdate(
    String itemId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/inventory-items/$itemId/stock-updates',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }
}
