export 'cow.dart' show PagedResult;

enum InventoryCategory {
  feed,
  fertilizer,
  pesticide,
  seed,
  medicine,
  equipment,
  fuel,
  other,
}

enum StockChangeType { add, use }

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.totalPrice,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.note,
  });

  final String id;
  final String name;
  final InventoryCategory category;
  final String quantity;
  final String unit;
  final String pricePerUnit;
  final String totalPrice;
  final String? note;
  final bool isArchived;
  final String createdAt;
  final String updatedAt;
}

class StockUpdate {
  const StockUpdate({
    required this.id,
    required this.inventoryItemId,
    required this.occurredAt,
    required this.changeType,
    required this.quantityChange,
    required this.createdAt,
    this.reason,
  });

  final String id;
  final String inventoryItemId;
  final String occurredAt;
  final StockChangeType changeType;
  final String quantityChange;
  final String? reason;
  final String createdAt;
}

class InventoryItemCreateParams {
  const InventoryItemCreateParams({
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    this.note,
  });

  final String name;
  final InventoryCategory category;
  final String quantity;
  final String unit;
  final String pricePerUnit;
  final String? note;
}

class InventoryItemUpdateParams {
  const InventoryItemUpdateParams({
    required this.name,
    required this.category,
    required this.unit,
    required this.pricePerUnit,
    this.note,
  });

  final String name;
  final InventoryCategory category;
  final String unit;
  final String pricePerUnit;
  final String? note;
}
