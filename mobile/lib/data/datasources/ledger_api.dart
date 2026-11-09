import 'package:dio/dio.dart';
import 'api_client.dart';

class LedgerApi {
  LedgerApi(this._client);

  final ApiClient _client;

  Dio get _dio => _client.dio;

  Future<Map<String, dynamic>> listEntries({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
    String? from,
    String? to,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/ledger-entries',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          if (includeArchived) 'include_archived': true,
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        },
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> getEntry(String entryId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/ledger-entries/$entryId',
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> createEntry(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/ledger-entries',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> updateEntry(
    String entryId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/v1/ledger-entries/$entryId',
        data: body,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> archiveEntry(String entryId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/ledger-entries/$entryId/archive',
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> getPeriodTotals({
    required String from,
    required String to,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/ledger-entries/totals',
        queryParameters: {'from': from, 'to': to},
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }
}
