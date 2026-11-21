import 'package:mobile/domain/repositories/inventory/inventory_repository.dart';
import 'package:mobile/domain/entities/common/paged_result_entity.dart';
import 'package:mobile/domain/entities/inventory/inventory_category_entity.dart';
import 'package:mobile/domain/entities/inventory/inventory_item_entity.dart';
import 'package:mobile/domain/entities/inventory/inventory_item_create_params_entity.dart';
import 'package:mobile/domain/entities/inventory/inventory_item_update_params_entity.dart';
import 'package:mobile/domain/entities/inventory/stock_change_type_entity.dart';
import 'package:mobile/domain/entities/inventory/stock_update_entity.dart';
import 'package:mobile/domain/entities/inventory/stock_update_list_item_entity.dart';

class ListInventoryItems {
  ListInventoryItems(this._repository);
  final InventoryRepository _repository;
  Future<PagedResultEntity<InventoryItemEntity>> call({bool includeArchived = false}) =>
      _repository.listItems(includeArchived: includeArchived);
}

class GetInventoryItem {
  GetInventoryItem(this._repository);
  final InventoryRepository _repository;
  Future<InventoryItemEntity> call(String itemId) => _repository.getItem(itemId);
}

class CreateInventoryItem {
  CreateInventoryItem(this._repository);
  final InventoryRepository _repository;
  Future<InventoryItemEntity> call(InventoryItemCreateParamsEntity params) =>
      _repository.createItem(params);
}

class UpdateInventoryItem {
  UpdateInventoryItem(this._repository);
  final InventoryRepository _repository;
  Future<InventoryItemEntity> call(String itemId, InventoryItemUpdateParamsEntity params) =>
      _repository.updateItem(itemId, params);
}

class ArchiveInventoryItem {
  ArchiveInventoryItem(this._repository);
  final InventoryRepository _repository;
  Future<InventoryItemEntity> call(String itemId) => _repository.archiveItem(itemId);
}

class ListStockUpdates {
  ListStockUpdates(this._repository);
  final InventoryRepository _repository;
  Future<PagedResultEntity<StockUpdateEntity>> call(String itemId) =>
      _repository.listStockUpdates(itemId);
}

class AddStockUpdate {
  AddStockUpdate(this._repository);
  final InventoryRepository _repository;
  Future<StockUpdateEntity> call({
    required String itemId,
    required String occurredAt,
    required StockChangeTypeEntity changeType,
    required String quantityChange,
    String? reason,
  }) =>
      _repository.addStockUpdate(
        itemId: itemId,
        occurredAt: occurredAt,
        changeType: changeType,
        quantityChange: quantityChange,
        reason: reason,
      );
}

class ListFertilizerStockUpdates {
  ListFertilizerStockUpdates(this._repository);
  final InventoryRepository _repository;
  Future<PagedResultEntity<StockUpdateListItemEntity>> call({
    int limit = 10,
    int offset = 0,
  }) =>
      _repository.listStockUpdatesByCategory(
        category: InventoryCategoryEntity.fertilizer,
        limit: limit,
        offset: offset,
      );
}
