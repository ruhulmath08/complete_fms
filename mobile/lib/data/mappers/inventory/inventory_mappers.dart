import 'package:mobile/data/models/inventory/inventory_item_model.dart';
import 'package:mobile/data/models/inventory/stock_update_list_item_model.dart';
import 'package:mobile/data/models/inventory/stock_update_model.dart';
import 'package:mobile/domain/entities/inventory/inventory_category.dart';
import 'package:mobile/domain/entities/inventory/inventory_item.dart';
import 'package:mobile/domain/entities/inventory/inventory_item_create_params.dart';
import 'package:mobile/domain/entities/inventory/inventory_item_update_params.dart';
import 'package:mobile/domain/entities/inventory/stock_change_type.dart';
import 'package:mobile/domain/entities/inventory/stock_update.dart';
import 'package:mobile/domain/entities/inventory/stock_update_list_item.dart';

InventoryCategory mapInventoryCategory(String value) {
  switch (value) {
    case 'feed':
      return InventoryCategory.feed;
    case 'fertilizer':
      return InventoryCategory.fertilizer;
    case 'pesticide':
      return InventoryCategory.pesticide;
    case 'seed':
      return InventoryCategory.seed;
    case 'medicine':
      return InventoryCategory.medicine;
    case 'equipment':
      return InventoryCategory.equipment;
    case 'fuel':
      return InventoryCategory.fuel;
    case 'other':
      return InventoryCategory.other;
    default:
      return InventoryCategory.other;
  }
}

String inventoryCategoryToApi(InventoryCategory value) => switch (value) {
      InventoryCategory.feed => 'feed',
      InventoryCategory.fertilizer => 'fertilizer',
      InventoryCategory.pesticide => 'pesticide',
      InventoryCategory.seed => 'seed',
      InventoryCategory.medicine => 'medicine',
      InventoryCategory.equipment => 'equipment',
      InventoryCategory.fuel => 'fuel',
      InventoryCategory.other => 'other',
    };

StockChangeType mapStockChangeType(String value) {
  switch (value) {
    case 'add':
      return StockChangeType.add;
    case 'use':
      return StockChangeType.use;
    default:
      return StockChangeType.add;
  }
}

String stockChangeTypeToApi(StockChangeType value) => switch (value) {
      StockChangeType.add => 'add',
      StockChangeType.use => 'use',
    };

InventoryItem mapInventoryItem(Map<String, dynamic> json) =>
    mapInventoryItemModel(InventoryItemModel.fromJson(json));

InventoryItem mapInventoryItemModel(InventoryItemModel model) => InventoryItem(
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

StockUpdate mapStockUpdate(Map<String, dynamic> json) =>
    mapStockUpdateModel(StockUpdateModel.fromJson(json));

StockUpdate mapStockUpdateModel(StockUpdateModel model) => StockUpdate(
      id: model.id,
      inventoryItemId: model.inventoryItemId,
      occurredAt: model.occurredAt,
      changeType: mapStockChangeType(model.changeType),
      quantityChange: model.quantityChange,
      reason: model.reason,
      createdAt: model.createdAt,
    );

Map<String, dynamic> inventoryItemCreateToJson(InventoryItemCreateParams params) => {
      'name': params.name,
      'category': inventoryCategoryToApi(params.category),
      'quantity': params.quantity,
      'unit': params.unit,
      'price_per_unit': params.pricePerUnit,
      'note': params.note,
    };

Map<String, dynamic> inventoryItemUpdateToJson(InventoryItemUpdateParams params) => {
      'name': params.name,
      'category': inventoryCategoryToApi(params.category),
      'unit': params.unit,
      'price_per_unit': params.pricePerUnit,
      'note': params.note,
    };

StockUpdateListItem mapStockUpdateListItem(Map<String, dynamic> json) =>
    mapStockUpdateListItemModel(StockUpdateListItemModel.fromJson(json));

StockUpdateListItem mapStockUpdateListItemModel(StockUpdateListItemModel model) =>
    StockUpdateListItem(
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
