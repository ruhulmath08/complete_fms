import 'package:mobile/data/datasources/inventory/inventory_datasource.dart';
import 'package:mobile/data/network/api_client.dart';
import 'package:mobile/data/network/api_endpoints.dart';

class InventoryDatasourceImpl implements InventoryDatasource {
  InventoryDatasourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> listItems({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  }) {
    return _client.get(
      ApiEndpoints.inventoryItems,
      query: {
        'limit': limit,
        'offset': offset,
        if (includeArchived) 'include_archived': true,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getItem(String itemId) {
    return _client.get(ApiEndpoints.inventoryItem(itemId));
  }

  @override
  Future<Map<String, dynamic>> createItem(Map<String, dynamic> body) {
    return _client.post(ApiEndpoints.inventoryItems, data: body);
  }

  @override
  Future<Map<String, dynamic>> updateItem(
    String itemId,
    Map<String, dynamic> body,
  ) {
    return _client.patch(ApiEndpoints.inventoryItem(itemId), data: body);
  }

  @override
  Future<Map<String, dynamic>> archiveItem(String itemId) {
    return _client.post(ApiEndpoints.inventoryItemArchive(itemId));
  }

  @override
  Future<Map<String, dynamic>> listStockUpdates(
    String itemId, {
    int limit = 50,
    int offset = 0,
  }) {
    return _client.get(
      ApiEndpoints.itemStockUpdates(itemId),
      query: {'limit': limit, 'offset': offset},
    );
  }

  @override
  Future<Map<String, dynamic>> addStockUpdate(
    String itemId,
    Map<String, dynamic> body,
  ) {
    return _client.post(ApiEndpoints.itemStockUpdates(itemId), data: body);
  }

  @override
  Future<Map<String, dynamic>> listStockUpdatesByCategory({
    required String category,
    int limit = 10,
    int offset = 0,
  }) {
    return _client.get(
      ApiEndpoints.inventoryStockUpdates,
      query: {'category': category, 'limit': limit, 'offset': offset},
    );
  }
}
