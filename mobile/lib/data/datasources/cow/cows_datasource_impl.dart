import 'package:dio/dio.dart';
import 'package:mobile/data/datasources/cow/cows_datasource.dart';
import 'package:mobile/data/network/api_client.dart';
import 'package:mobile/data/network/api_endpoints.dart';

class CowsDatasourceImpl implements CowsDatasource {
  CowsDatasourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> listCows({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  }) {
    return _client.get(
      ApiEndpoints.cows,
      query: {
        'limit': limit,
        'offset': offset,
        if (includeArchived) 'include_archived': true,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getCow(String cowId) {
    return _client.get(ApiEndpoints.cow(cowId));
  }

  @override
  Future<Map<String, dynamic>> createCow(Map<String, dynamic> body) {
    return _client.post(ApiEndpoints.cows, data: body);
  }

  @override
  Future<Map<String, dynamic>> updateCow(
    String cowId,
    Map<String, dynamic> body,
  ) {
    return _client.patch(ApiEndpoints.cow(cowId), data: body);
  }

  @override
  Future<Map<String, dynamic>> archiveCow(String cowId) {
    return _client.post(ApiEndpoints.cowArchive(cowId));
  }

  @override
  Future<Map<String, dynamic>> uploadCowImage(String cowId, FormData formData) {
    return _client.put(ApiEndpoints.cowImage(cowId), data: formData);
  }

  @override
  Future<List<int>> getCowImageBytes(String cowId) {
    return _client.getBytes(ApiEndpoints.cowImage(cowId));
  }

  @override
  Future<Map<String, dynamic>> listMilk(
    String cowId, {
    int limit = 10,
    int offset = 0,
  }) {
    return _client.get(
      ApiEndpoints.cowMilkProductions(cowId),
      query: {'limit': limit, 'offset': offset},
    );
  }

  @override
  Future<Map<String, dynamic>> addMilk(
    String cowId,
    Map<String, dynamic> body,
  ) {
    return _client.post(ApiEndpoints.cowMilkProductions(cowId), data: body);
  }

  @override
  Future<Map<String, dynamic>> updateMilk(
    String cowId,
    String milkId,
    Map<String, dynamic> body,
  ) {
    return _client.patch(
      ApiEndpoints.cowMilkProduction(cowId, milkId),
      data: body,
    );
  }

  @override
  Future<void> deleteMilk(String cowId, String milkId) {
    return _client.delete(ApiEndpoints.cowMilkProduction(cowId, milkId));
  }

  @override
  Future<Map<String, dynamic>> listFeedings(
    String cowId, {
    int limit = 10,
    int offset = 0,
  }) {
    return _client.get(
      ApiEndpoints.cowFeedings(cowId),
      query: {'limit': limit, 'offset': offset},
    );
  }

  @override
  Future<Map<String, dynamic>> addFeeding(
    String cowId,
    Map<String, dynamic> body,
  ) {
    return _client.post(ApiEndpoints.cowFeedings(cowId), data: body);
  }

  @override
  Future<Map<String, dynamic>> updateFeeding(
    String cowId,
    String feedingId,
    Map<String, dynamic> body,
  ) {
    return _client.patch(ApiEndpoints.cowFeeding(cowId, feedingId), data: body);
  }

  @override
  Future<void> deleteFeeding(String cowId, String feedingId) {
    return _client.delete(ApiEndpoints.cowFeeding(cowId, feedingId));
  }
}
