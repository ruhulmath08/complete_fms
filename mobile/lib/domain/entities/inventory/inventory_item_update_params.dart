import 'package:mobile/domain/entities/inventory/inventory_category.dart';

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
