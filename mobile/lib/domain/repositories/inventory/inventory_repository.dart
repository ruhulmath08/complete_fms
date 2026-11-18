import 'package:mobile/domain/entities/common/paged_result.dart';
import 'package:mobile/domain/entities/inventory/inventory_category.dart';
import 'package:mobile/domain/entities/inventory/inventory_item.dart';
import 'package:mobile/domain/entities/inventory/inventory_item_create_params.dart';
import 'package:mobile/domain/entities/inventory/inventory_item_update_params.dart';
import 'package:mobile/domain/entities/inventory/stock_change_type.dart';
import 'package:mobile/domain/entities/inventory/stock_update.dart';
import 'package:mobile/domain/entities/inventory/stock_update_list_item.dart';

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
