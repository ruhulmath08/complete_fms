import 'package:mobile/domain/entities/inventory/inventory_category.dart';

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
