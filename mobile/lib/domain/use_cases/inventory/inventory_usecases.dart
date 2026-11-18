import 'package:mobile/domain/repositories/inventory/inventory_repository.dart';
import 'package:mobile/domain/entities/common/paged_result.dart';
import 'package:mobile/domain/entities/inventory/inventory_category.dart';
import 'package:mobile/domain/entities/inventory/inventory_item.dart';
import 'package:mobile/domain/entities/inventory/inventory_item_create_params.dart';
import 'package:mobile/domain/entities/inventory/inventory_item_update_params.dart';
import 'package:mobile/domain/entities/inventory/stock_change_type.dart';
import 'package:mobile/domain/entities/inventory/stock_update.dart';
import 'package:mobile/domain/entities/inventory/stock_update_list_item.dart';

class ListInventoryItems {
  ListInventoryItems(this._repository);
  final InventoryRepository _repository;
  Future<PagedResult<InventoryItem>> call({bool includeArchived = false}) =>
      _repository.listItems(includeArchived: includeArchived);
}

class GetInventoryItem {
  GetInventoryItem(this._repository);
  final InventoryRepository _repository;
  Future<InventoryItem> call(String itemId) => _repository.getItem(itemId);
}

class CreateInventoryItem {
  CreateInventoryItem(this._repository);
  final InventoryRepository _repository;
  Future<InventoryItem> call(InventoryItemCreateParams params) =>
      _repository.createItem(params);
}

class UpdateInventoryItem {
  UpdateInventoryItem(this._repository);
  final InventoryRepository _repository;
  Future<InventoryItem> call(String itemId, InventoryItemUpdateParams params) =>
      _repository.updateItem(itemId, params);
}

class ArchiveInventoryItem {
  ArchiveInventoryItem(this._repository);
  final InventoryRepository _repository;
  Future<InventoryItem> call(String itemId) => _repository.archiveItem(itemId);
}

class ListStockUpdates {
  ListStockUpdates(this._repository);
  final InventoryRepository _repository;
  Future<PagedResult<StockUpdate>> call(String itemId) =>
      _repository.listStockUpdates(itemId);
}

class AddStockUpdate {
  AddStockUpdate(this._repository);
  final InventoryRepository _repository;
  Future<StockUpdate> call({
    required String itemId,
    required String occurredAt,
    required StockChangeType changeType,
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
  Future<PagedResult<StockUpdateListItem>> call({
    int limit = 10,
    int offset = 0,
  }) =>
      _repository.listStockUpdatesByCategory(
        category: InventoryCategory.fertilizer,
        limit: limit,
        offset: offset,
      );
}
