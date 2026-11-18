import 'package:mobile/data/models/common/json_parsers.dart';

class StockUpdateListItemModel {
  const StockUpdateListItemModel({
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

  factory StockUpdateListItemModel.fromJson(Map<String, dynamic> json) =>
      StockUpdateListItemModel(
        id: requireString(json['id'], 'id'),
        inventoryItemId:
            requireString(json['inventory_item_id'], 'inventory_item_id'),
        itemName: requireString(json['item_name'], 'item_name'),
        itemUnit: requireString(json['item_unit'], 'item_unit'),
        itemCategory: requireString(json['item_category'], 'item_category'),
        occurredAt: requireString(json['occurred_at'], 'occurred_at'),
        changeType: requireString(json['change_type'], 'change_type'),
        quantityChange:
            requireDecimalString(json['quantity_change'], 'quantity_change'),
        reason: optionalString(json['reason']),
        createdAt: requireString(json['created_at'], 'created_at'),
      );

  final String id;
  final String inventoryItemId;
  final String itemName;
  final String itemUnit;
  final String itemCategory;
  final String occurredAt;
  final String changeType;
  final String quantityChange;
  final String? reason;
  final String createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'inventory_item_id': inventoryItemId,
        'item_name': itemName,
        'item_unit': itemUnit,
        'item_category': itemCategory,
        'occurred_at': occurredAt,
        'change_type': changeType,
        'quantity_change': quantityChange,
        'reason': reason,
        'created_at': createdAt,
      };
}
