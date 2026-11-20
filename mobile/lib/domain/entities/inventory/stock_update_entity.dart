import 'package:mobile/domain/entities/inventory/stock_change_type_entity.dart';

class StockUpdateEntity {
  const StockUpdateEntity({
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
  final StockChangeTypeEntity changeType;
  final String quantityChange;
  final String? reason;
  final String createdAt;
}
