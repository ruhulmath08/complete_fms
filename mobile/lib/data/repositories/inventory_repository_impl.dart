import '../../domain/entities/inventory.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_api.dart';
import '../mappers/inventory_mappers.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl(this._api);

  final InventoryApi _api;

  PagedResult<T> _page<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) mapItem,
  ) {
    final items = (json['items'] as List<dynamic>)
        .map((e) => mapItem(e as Map<String, dynamic>))
        .toList();
    final meta = json['meta'] as Map<String, dynamic>;
    return PagedResult(
      items: items,
      total: meta['total'] as int,
      limit: meta['limit'] as int,
      offset: meta['offset'] as int,
    );
  }

  @override
  Future<PagedResult<InventoryItem>> listItems({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  }) async {
    final json = await _api.listItems(
      limit: limit,
      offset: offset,
      includeArchived: includeArchived,
    );
    return _page(json, mapInventoryItem);
  }

  @override
  Future<InventoryItem> getItem(String itemId) async =>
      mapInventoryItem(await _api.getItem(itemId));

  @override
  Future<InventoryItem> createItem(InventoryItemCreateParams params) async =>
      mapInventoryItem(await _api.createItem(inventoryItemCreateToJson(params)));

  @override
  Future<InventoryItem> updateItem(
    String itemId,
    InventoryItemUpdateParams params,
  ) async =>
      mapInventoryItem(
        await _api.updateItem(itemId, inventoryItemUpdateToJson(params)),
      );

  @override
  Future<InventoryItem> archiveItem(String itemId) async =>
      mapInventoryItem(await _api.archiveItem(itemId));

  @override
  Future<PagedResult<StockUpdate>> listStockUpdates(
    String itemId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final json = await _api.listStockUpdates(
      itemId,
      limit: limit,
      offset: offset,
    );
    return _page(json, mapStockUpdate);
  }

  @override
  Future<StockUpdate> addStockUpdate({
    required String itemId,
    required String occurredAt,
    required StockChangeType changeType,
    required String quantityChange,
    String? reason,
  }) async {
    final json = await _api.addStockUpdate(itemId, {
      'occurred_at': occurredAt,
      'change_type': stockChangeTypeToApi(changeType),
      'quantity_change': quantityChange,
      'reason': reason,
    });
    return mapStockUpdate(json);
  }
}
