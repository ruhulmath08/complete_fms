import 'package:mobile/data/datasources/poultry/poultry_datasource.dart';
import 'package:mobile/data/network/api_client.dart';
import 'package:mobile/data/network/api_endpoints.dart';

class PoultryDatasourceImpl implements PoultryDatasource {
  PoultryDatasourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> listGroups({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  }) {
    return _client.get(
      ApiEndpoints.poultryGroups,
      query: {
        'limit': limit,
        'offset': offset,
        if (includeArchived) 'include_archived': true,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getGroup(String groupId) {
    return _client.get(ApiEndpoints.poultryGroup(groupId));
  }

  @override
  Future<Map<String, dynamic>> createGroup(Map<String, dynamic> body) {
    return _client.post(ApiEndpoints.poultryGroups, data: body);
  }

  @override
  Future<Map<String, dynamic>> updateGroup(
    String groupId,
    Map<String, dynamic> body,
  ) {
    return _client.patch(ApiEndpoints.poultryGroup(groupId), data: body);
  }

  @override
  Future<Map<String, dynamic>> archiveGroup(String groupId) {
    return _client.post(ApiEndpoints.poultryGroupArchive(groupId));
  }

  @override
  Future<Map<String, dynamic>> listEggs(
    String groupId, {
    int limit = 50,
    int offset = 0,
  }) {
    return _client.get(
      ApiEndpoints.eggProductions(groupId),
      query: {'limit': limit, 'offset': offset},
    );
  }

  @override
  Future<Map<String, dynamic>> addEgg(
    String groupId,
    Map<String, dynamic> body,
  ) {
    return _client.post(ApiEndpoints.eggProductions(groupId), data: body);
  }

  @override
  Future<Map<String, dynamic>> updateEgg(
    String groupId,
    String eggId,
    Map<String, dynamic> body,
  ) {
    return _client.patch(
      ApiEndpoints.eggProduction(groupId, eggId),
      data: body,
    );
  }

  @override
  Future<void> deleteEgg(String groupId, String eggId) {
    return _client.delete(ApiEndpoints.eggProduction(groupId, eggId));
  }

  @override
  Future<Map<String, dynamic>> listFeedings(
    String groupId, {
    int limit = 50,
    int offset = 0,
  }) {
    return _client.get(
      ApiEndpoints.poultryFeedings(groupId),
      query: {'limit': limit, 'offset': offset},
    );
  }

  @override
  Future<Map<String, dynamic>> addFeeding(
    String groupId,
    Map<String, dynamic> body,
  ) {
    return _client.post(ApiEndpoints.poultryFeedings(groupId), data: body);
  }

  @override
  Future<Map<String, dynamic>> updateFeeding(
    String groupId,
    String feedingId,
    Map<String, dynamic> body,
  ) {
    return _client.patch(
      ApiEndpoints.poultryFeeding(groupId, feedingId),
      data: body,
    );
  }

  @override
  Future<void> deleteFeeding(String groupId, String feedingId) {
    return _client.delete(ApiEndpoints.poultryFeeding(groupId, feedingId));
  }
}
