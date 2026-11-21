import 'package:mobile/data/datasources/inventory/inventory_datasource.dart';
import 'package:mobile/data/mappers/inventory/inventory_mappers.dart';
import 'package:mobile/data/models/inventory/inventory_item_model.dart';
import 'package:mobile/data/models/inventory/stock_update_list_item_model.dart';
import 'package:mobile/data/models/inventory/stock_update_model.dart';
import 'package:mobile/data/repositories/common/page_result_mapper.dart';
import 'package:mobile/domain/entities/common/paged_result_entity.dart';
import 'package:mobile/domain/entities/inventory/inventory_category_entity.dart';
import 'package:mobile/domain/entities/inventory/inventory_item_entity.dart';
import 'package:mobile/domain/entities/inventory/inventory_item_create_params_entity.dart';
import 'package:mobile/domain/entities/inventory/inventory_item_update_params_entity.dart';
import 'package:mobile/domain/entities/inventory/stock_change_type_entity.dart';
import 'package:mobile/domain/entities/inventory/stock_update_entity.dart';
import 'package:mobile/domain/entities/inventory/stock_update_list_item_entity.dart';
import 'package:mobile/domain/repositories/inventory/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl(this._datasource);

  final InventoryDatasource _datasource;

  @override
  Future<PagedResultEntity<InventoryItemEntity>> listItems({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  }) async {
    final json = await _datasource.listItems(
      limit: limit,
      offset: offset,
      includeArchived: includeArchived,
    );
    return mapPageResult(
      json,
      InventoryItemModel.fromJson,
      mapInventoryItemModel,
    );
  }

  @override
  Future<InventoryItemEntity> getItem(String itemId) async {
    final model = InventoryItemModel.fromJson(await _datasource.getItem(itemId));
    return mapInventoryItemModel(model);
  }

  @override
  Future<InventoryItemEntity> createItem(InventoryItemCreateParamsEntity params) async {
    final model = InventoryItemModel.fromJson(
      await _datasource.createItem(inventoryItemCreateToJson(params)),
    );
    return mapInventoryItemModel(model);
  }

  @override
  Future<InventoryItemEntity> updateItem(
    String itemId,
    InventoryItemUpdateParamsEntity params,
  ) async {
    final model = InventoryItemModel.fromJson(
      await _datasource.updateItem(itemId, inventoryItemUpdateToJson(params)),
    );
    return mapInventoryItemModel(model);
  }

  @override
  Future<InventoryItemEntity> archiveItem(String itemId) async {
    final model = InventoryItemModel.fromJson(await _datasource.archiveItem(itemId));
    return mapInventoryItemModel(model);
  }

  @override
  Future<PagedResultEntity<StockUpdateEntity>> listStockUpdates(
    String itemId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final json = await _datasource.listStockUpdates(
      itemId,
      limit: limit,
      offset: offset,
    );
    return mapPageResult(json, StockUpdateModel.fromJson, mapStockUpdateModel);
  }

  @override
  Future<StockUpdateEntity> addStockUpdate({
    required String itemId,
    required String occurredAt,
    required StockChangeTypeEntity changeType,
    required String quantityChange,
    String? reason,
  }) async {
    final model = StockUpdateModel.fromJson(
      await _datasource.addStockUpdate(itemId, {
        'occurred_at': occurredAt,
        'change_type': stockChangeTypeToApi(changeType),
        'quantity_change': quantityChange,
        'reason': reason,
      }),
    );
    return mapStockUpdateModel(model);
  }

  @override
  Future<PagedResultEntity<StockUpdateListItemEntity>> listStockUpdatesByCategory({
    required InventoryCategoryEntity category,
    int limit = 10,
    int offset = 0,
  }) async {
    final json = await _datasource.listStockUpdatesByCategory(
      category: inventoryCategoryToApi(category),
      limit: limit,
      offset: offset,
    );
    return mapPageResult(
      json,
      StockUpdateListItemModel.fromJson,
      mapStockUpdateListItemModel,
    );
  }
}
