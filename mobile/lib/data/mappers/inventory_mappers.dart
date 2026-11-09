import '../../domain/entities/inventory.dart';

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

InventoryItem mapInventoryItem(Map<String, dynamic> json) => InventoryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: mapInventoryCategory(json['category'] as String),
      quantity: json['quantity'].toString(),
      unit: json['unit'] as String,
      pricePerUnit: json['price_per_unit'].toString(),
      totalPrice: json['total_price'].toString(),
      note: json['note'] as String?,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

StockUpdate mapStockUpdate(Map<String, dynamic> json) => StockUpdate(
      id: json['id'] as String,
      inventoryItemId: json['inventory_item_id'] as String,
      occurredAt: json['occurred_at'] as String,
      changeType: mapStockChangeType(json['change_type'] as String),
      quantityChange: json['quantity_change'].toString(),
      reason: json['reason'] as String?,
      createdAt: json['created_at'] as String,
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
