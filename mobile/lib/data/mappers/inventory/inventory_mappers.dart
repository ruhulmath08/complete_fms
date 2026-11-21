import 'package:mobile/data/models/inventory/inventory_item_model.dart';
import 'package:mobile/data/models/inventory/stock_update_list_item_model.dart';
import 'package:mobile/data/models/inventory/stock_update_model.dart';
import 'package:mobile/domain/entities/inventory/inventory_category_entity.dart';
import 'package:mobile/domain/entities/inventory/inventory_item_entity.dart';
import 'package:mobile/domain/entities/inventory/inventory_item_create_params_entity.dart';
import 'package:mobile/domain/entities/inventory/inventory_item_update_params_entity.dart';
import 'package:mobile/domain/entities/inventory/stock_change_type_entity.dart';
import 'package:mobile/domain/entities/inventory/stock_update_entity.dart';
import 'package:mobile/domain/entities/inventory/stock_update_list_item_entity.dart';

InventoryCategoryEntity mapInventoryCategory(String value) {
  switch (value) {
    case 'feed':
      return InventoryCategoryEntity.feed;
    case 'fertilizer':
      return InventoryCategoryEntity.fertilizer;
    case 'pesticide':
      return InventoryCategoryEntity.pesticide;
    case 'seed':
      return InventoryCategoryEntity.seed;
    case 'medicine':
      return InventoryCategoryEntity.medicine;
    case 'equipment':
      return InventoryCategoryEntity.equipment;
    case 'fuel':
      return InventoryCategoryEntity.fuel;
    case 'other':
      return InventoryCategoryEntity.other;
    default:
      return InventoryCategoryEntity.other;
  }
}

String inventoryCategoryToApi(InventoryCategoryEntity value) => switch (value) {
      InventoryCategoryEntity.feed => 'feed',
      InventoryCategoryEntity.fertilizer => 'fertilizer',
      InventoryCategoryEntity.pesticide => 'pesticide',
      InventoryCategoryEntity.seed => 'seed',
      InventoryCategoryEntity.medicine => 'medicine',
      InventoryCategoryEntity.equipment => 'equipment',
      InventoryCategoryEntity.fuel => 'fuel',
      InventoryCategoryEntity.other => 'other',
    };

StockChangeTypeEntity mapStockChangeType(String value) {
  switch (value) {
    case 'add':
      return StockChangeTypeEntity.add;
    case 'use':
      return StockChangeTypeEntity.use;
    default:
      return StockChangeTypeEntity.add;
  }
}

String stockChangeTypeToApi(StockChangeTypeEntity value) => switch (value) {
      StockChangeTypeEntity.add => 'add',
      StockChangeTypeEntity.use => 'use',
    };

InventoryItemEntity mapInventoryItem(Map<String, dynamic> json) =>
    mapInventoryItemModel(InventoryItemModel.fromJson(json));

InventoryItemEntity mapInventoryItemModel(InventoryItemModel model) => InventoryItemEntity(
      id: model.id,
      name: model.name,
      category: mapInventoryCategory(model.category),
      quantity: model.quantity,
      unit: model.unit,
      pricePerUnit: model.pricePerUnit,
      totalPrice: model.totalPrice,
      note: model.note,
      isArchived: model.isArchived,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );

StockUpdateEntity mapStockUpdate(Map<String, dynamic> json) =>
    mapStockUpdateModel(StockUpdateModel.fromJson(json));

StockUpdateEntity mapStockUpdateModel(StockUpdateModel model) => StockUpdateEntity(
      id: model.id,
      inventoryItemId: model.inventoryItemId,
      occurredAt: model.occurredAt,
      changeType: mapStockChangeType(model.changeType),
      quantityChange: model.quantityChange,
      reason: model.reason,
      createdAt: model.createdAt,
    );

Map<String, dynamic> inventoryItemCreateToJson(InventoryItemCreateParamsEntity params) => {
      'name': params.name,
      'category': inventoryCategoryToApi(params.category),
      'quantity': params.quantity,
      'unit': params.unit,
      'price_per_unit': params.pricePerUnit,
      'note': params.note,
    };

Map<String, dynamic> inventoryItemUpdateToJson(InventoryItemUpdateParamsEntity params) => {
      'name': params.name,
      'category': inventoryCategoryToApi(params.category),
      'unit': params.unit,
      'price_per_unit': params.pricePerUnit,
      'note': params.note,
    };

StockUpdateListItemEntity mapStockUpdateListItem(Map<String, dynamic> json) =>
    mapStockUpdateListItemModel(StockUpdateListItemModel.fromJson(json));

StockUpdateListItemEntity mapStockUpdateListItemModel(StockUpdateListItemModel model) =>
    StockUpdateListItemEntity(
      id: model.id,
      inventoryItemId: model.inventoryItemId,
      itemName: model.itemName,
      itemUnit: model.itemUnit,
      itemCategory: mapInventoryCategory(model.itemCategory),
      occurredAt: model.occurredAt,
      changeType: mapStockChangeType(model.changeType),
      quantityChange: model.quantityChange,
      reason: model.reason,
      createdAt: model.createdAt,
    );
