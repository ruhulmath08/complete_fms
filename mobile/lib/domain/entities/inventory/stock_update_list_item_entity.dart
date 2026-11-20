import 'package:mobile/domain/entities/inventory/inventory_category_entity.dart';
import 'package:mobile/domain/entities/inventory/stock_change_type_entity.dart';

class StockUpdateListItemEntity {
  const StockUpdateListItemEntity({
    required this.id,
    required this.inventoryItemId,
    required this.itemName,
    required this.itemUnit,
    required this.itemCategory,
    required this.occurredAt,
    required this.changeType,
    required this.quantityChange,
    required this.createdAt,
    this.reason,
  });

  final String id;
  final String inventoryItemId;
  final String itemName;
  final String itemUnit;
  final InventoryCategoryEntity itemCategory;
  final String occurredAt;
  final StockChangeTypeEntity changeType;
  final String quantityChange;
  final String? reason;
  final String createdAt;
}
