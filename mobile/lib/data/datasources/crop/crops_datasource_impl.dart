import 'package:mobile/data/datasources/crop/crops_datasource.dart';
import 'package:mobile/data/network/api_client.dart';
import 'package:mobile/data/network/api_endpoints.dart';

class CropsDatasourceImpl implements CropsDatasource {
  CropsDatasourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> listNames({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  }) {
    return _client.get(
      ApiEndpoints.cropNames,
      query: {
        'limit': limit,
        'offset': offset,
        if (includeArchived) 'include_archived': true,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getName(String cropNameId) {
    return _client.get(ApiEndpoints.cropName(cropNameId));
  }

  @override
  Future<Map<String, dynamic>> createName(Map<String, dynamic> body) {
    return _client.post(ApiEndpoints.cropNames, data: body);
  }

  @override
  Future<Map<String, dynamic>> updateName(
    String cropNameId,
    Map<String, dynamic> body,
  ) {
    return _client.patch(ApiEndpoints.cropName(cropNameId), data: body);
  }

  @override
  Future<Map<String, dynamic>> archiveName(String cropNameId) {
    return _client.post(ApiEndpoints.cropNameArchive(cropNameId));
  }

  @override
  Future<Map<String, dynamic>> listCycles({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  }) {
    return _client.get(
      ApiEndpoints.cropCycles,
      query: {
        'limit': limit,
        'offset': offset,
        if (includeArchived) 'include_archived': true,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getCycle(String cycleId) {
    return _client.get(ApiEndpoints.cropCycle(cycleId));
  }

  @override
  Future<Map<String, dynamic>> createCycle(Map<String, dynamic> body) {
    return _client.post(ApiEndpoints.cropCycles, data: body);
  }

  @override
  Future<Map<String, dynamic>> updateCycle(
    String cycleId,
    Map<String, dynamic> body,
  ) {
    return _client.patch(ApiEndpoints.cropCycle(cycleId), data: body);
  }

  @override
  Future<Map<String, dynamic>> archiveCycle(String cycleId) {
    return _client.post(ApiEndpoints.cropCycleArchive(cycleId));
  }

  @override
  Future<Map<String, dynamic>> getCycleSummary(String cycleId) {
    return _client.get(ApiEndpoints.cropCycleSummary(cycleId));
  }

  @override
  Future<Map<String, dynamic>> listExpenses(
    String cycleId, {
    int limit = 50,
    int offset = 0,
  }) {
    return _client.get(
      ApiEndpoints.cropExpenses(cycleId),
      query: {'limit': limit, 'offset': offset},
    );
  }

  @override
  Future<Map<String, dynamic>> addExpense(
    String cycleId,
    Map<String, dynamic> body,
  ) {
    return _client.post(ApiEndpoints.cropExpenses(cycleId), data: body);
  }

  @override
  Future<Map<String, dynamic>> updateExpense(
    String cycleId,
    String expenseId,
    Map<String, dynamic> body,
  ) {
    return _client.patch(
      ApiEndpoints.cropExpense(cycleId, expenseId),
      data: body,
    );
  }

  @override
  Future<void> deleteExpense(String cycleId, String expenseId) {
    return _client.delete(ApiEndpoints.cropExpense(cycleId, expenseId));
  }

  @override
  Future<Map<String, dynamic>> listHarvests(
    String cycleId, {
    int limit = 50,
    int offset = 0,
  }) {
    return _client.get(
      ApiEndpoints.harvests(cycleId),
      query: {'limit': limit, 'offset': offset},
    );
  }

  @override
  Future<Map<String, dynamic>> addHarvest(
    String cycleId,
    Map<String, dynamic> body,
  ) {
    return _client.post(ApiEndpoints.harvests(cycleId), data: body);
  }

  @override
  Future<Map<String, dynamic>> updateHarvest(
    String cycleId,
    String harvestId,
    Map<String, dynamic> body,
  ) {
    return _client.patch(ApiEndpoints.harvest(cycleId, harvestId), data: body);
  }

  @override
  Future<void> deleteHarvest(String cycleId, String harvestId) {
    return _client.delete(ApiEndpoints.harvest(cycleId, harvestId));
  }
}
