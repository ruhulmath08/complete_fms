import 'package:mobile/data/models/common/json_parsers.dart';

class StockUpdateModel {
  const StockUpdateModel({
    required this.id,
    required this.inventoryItemId,
    required this.occurredAt,
    required this.changeType,
    required this.quantityChange,
    required this.createdAt,
    this.reason,
  });

  factory StockUpdateModel.fromJson(Map<String, dynamic> json) =>
      StockUpdateModel(
        id: requireString(json['id'], 'id'),
        inventoryItemId:
            requireString(json['inventory_item_id'], 'inventory_item_id'),
        occurredAt: requireString(json['occurred_at'], 'occurred_at'),
        changeType: requireString(json['change_type'], 'change_type'),
        quantityChange:
            requireDecimalString(json['quantity_change'], 'quantity_change'),
        reason: optionalString(json['reason']),
        createdAt: requireString(json['created_at'], 'created_at'),
      );

  final String id;
  final String inventoryItemId;
  final String occurredAt;
  final String changeType;
  final String quantityChange;
  final String? reason;
  final String createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'inventory_item_id': inventoryItemId,
        'occurred_at': occurredAt,
        'change_type': changeType,
        'quantity_change': quantityChange,
        'reason': reason,
        'created_at': createdAt,
      };
}
