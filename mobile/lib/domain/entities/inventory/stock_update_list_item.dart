import 'package:mobile/domain/entities/inventory/inventory_category.dart';
import 'package:mobile/domain/entities/inventory/stock_change_type.dart';

class StockUpdateListItem {
  const StockUpdateListItem({
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
  final InventoryCategory itemCategory;
  final String occurredAt;
  final StockChangeType changeType;
  final String quantityChange;
  final String? reason;
  final String createdAt;
}
