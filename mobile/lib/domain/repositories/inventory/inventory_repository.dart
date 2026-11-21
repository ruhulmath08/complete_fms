import 'package:mobile/domain/entities/common/paged_result_entity.dart';
import 'package:mobile/domain/entities/inventory/inventory_category_entity.dart';
import 'package:mobile/domain/entities/inventory/inventory_item_entity.dart';
import 'package:mobile/domain/entities/inventory/inventory_item_create_params_entity.dart';
import 'package:mobile/domain/entities/inventory/inventory_item_update_params_entity.dart';
import 'package:mobile/domain/entities/inventory/stock_change_type_entity.dart';
import 'package:mobile/domain/entities/inventory/stock_update_entity.dart';
import 'package:mobile/domain/entities/inventory/stock_update_list_item_entity.dart';

abstract class InventoryRepository {
  Future<PagedResultEntity<InventoryItemEntity>> listItems({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  });

  Future<InventoryItemEntity> getItem(String itemId);

  Future<InventoryItemEntity> createItem(InventoryItemCreateParamsEntity params);

  Future<InventoryItemEntity> updateItem(String itemId, InventoryItemUpdateParamsEntity params);

  Future<InventoryItemEntity> archiveItem(String itemId);

  Future<PagedResultEntity<StockUpdateEntity>> listStockUpdates(
    String itemId, {
    int limit = 50,
    int offset = 0,
  });

  Future<StockUpdateEntity> addStockUpdate({
    required String itemId,
    required String occurredAt,
    required StockChangeTypeEntity changeType,
    required String quantityChange,
    String? reason,
  });

  Future<PagedResultEntity<StockUpdateListItemEntity>> listStockUpdatesByCategory({
    required InventoryCategoryEntity category,
    int limit = 10,
    int offset = 0,
  });
}
