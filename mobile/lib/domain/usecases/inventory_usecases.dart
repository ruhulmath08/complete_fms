import '../entities/inventory.dart';
import '../repositories/inventory_repository.dart';

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
