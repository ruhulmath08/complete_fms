import '../entities/inventory.dart';

abstract class InventoryRepository {
  Future<PagedResult<InventoryItem>> listItems({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  });

  Future<InventoryItem> getItem(String itemId);

  Future<InventoryItem> createItem(InventoryItemCreateParams params);

  Future<InventoryItem> updateItem(String itemId, InventoryItemUpdateParams params);

  Future<InventoryItem> archiveItem(String itemId);

  Future<PagedResult<StockUpdate>> listStockUpdates(
    String itemId, {
    int limit = 50,
    int offset = 0,
  });

  Future<StockUpdate> addStockUpdate({
    required String itemId,
    required String occurredAt,
    required StockChangeType changeType,
    required String quantityChange,
    String? reason,
  });

  Future<PagedResult<StockUpdateListItem>> listStockUpdatesByCategory({
    required InventoryCategory category,
    int limit = 10,
    int offset = 0,
  });
}
