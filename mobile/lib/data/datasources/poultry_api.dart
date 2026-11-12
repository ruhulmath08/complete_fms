import 'package:dio/dio.dart';
import 'api_client.dart';

class PoultryApi {
  PoultryApi(this._client);

  final ApiClient _client;

  Dio get _dio => _client.dio;

  Future<Map<String, dynamic>> listGroups({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/poultry-groups',
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

  Future<Map<String, dynamic>> getGroup(String groupId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/poultry-groups/$groupId',
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> createGroup(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/poultry-groups',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> updateGroup(
    String groupId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/v1/poultry-groups/$groupId',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> archiveGroup(String groupId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/poultry-groups/$groupId/archive',
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> listEggs(
    String groupId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/poultry-groups/$groupId/egg-productions',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> addEgg(
    String groupId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/poultry-groups/$groupId/egg-productions',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> updateEgg(
    String groupId,
    String eggId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/v1/poultry-groups/$groupId/egg-productions/$eggId',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<void> deleteEgg(String groupId, String eggId) async {
    try {
      await _dio.delete<void>(
        '/api/v1/poultry-groups/$groupId/egg-productions/$eggId',
      );
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> listFeedings(
    String groupId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/poultry-groups/$groupId/feedings',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> addFeeding(
    String groupId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/poultry-groups/$groupId/feedings',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> updateFeeding(
    String groupId,
    String feedingId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/v1/poultry-groups/$groupId/feedings/$feedingId',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<void> deleteFeeding(String groupId, String feedingId) async {
    try {
      await _dio.delete<void>(
        '/api/v1/poultry-groups/$groupId/feedings/$feedingId',
      );
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }
}
