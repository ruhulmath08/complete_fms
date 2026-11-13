import 'package:dio/dio.dart';
import 'api_client.dart';

class CropsApi {
  CropsApi(this._client);

  final ApiClient _client;

  Dio get _dio => _client.dio;

  Future<Map<String, dynamic>> listNames({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/crop-names',
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

  Future<Map<String, dynamic>> getName(String cropNameId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/crop-names/$cropNameId',
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> createName(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/crop-names',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> updateName(
    String cropNameId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/v1/crop-names/$cropNameId',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> archiveName(String cropNameId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/crop-names/$cropNameId/archive',
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> listCycles({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/crop-cycles',
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

  Future<Map<String, dynamic>> getCycle(String cycleId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/crop-cycles/$cycleId',
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> createCycle(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/crop-cycles',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> updateCycle(
    String cycleId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/v1/crop-cycles/$cycleId',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> archiveCycle(String cycleId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/crop-cycles/$cycleId/archive',
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> getCycleSummary(String cycleId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/crop-cycles/$cycleId/summary',
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> listExpenses(
    String cycleId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/crop-cycles/$cycleId/expenses',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> addExpense(
    String cycleId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/crop-cycles/$cycleId/expenses',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> listHarvests(
    String cycleId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/crop-cycles/$cycleId/harvests',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> addHarvest(
    String cycleId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/crop-cycles/$cycleId/harvests',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> updateExpense(
    String cycleId,
    String expenseId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/v1/crop-cycles/$cycleId/expenses/$expenseId',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<void> deleteExpense(String cycleId, String expenseId) async {
    try {
      await _dio.delete<void>(
        '/api/v1/crop-cycles/$cycleId/expenses/$expenseId',
      );
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> updateHarvest(
    String cycleId,
    String harvestId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/v1/crop-cycles/$cycleId/harvests/$harvestId',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<void> deleteHarvest(String cycleId, String harvestId) async {
    try {
      await _dio.delete<void>(
        '/api/v1/crop-cycles/$cycleId/harvests/$harvestId',
      );
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }
}
