import 'package:mobile/domain/entities/inventory/inventory_category_entity.dart';

class InventoryItemUpdateParamsEntity {
  const InventoryItemUpdateParamsEntity({
    required this.name,
    required this.category,
    required this.unit,
    required this.pricePerUnit,
    this.note,
  });

  final String name;
  final InventoryCategoryEntity category;
  final String unit;
  final String pricePerUnit;
  final String? note;
}
