import 'package:mobile/domain/entities/inventory/inventory_category_entity.dart';

class InventoryItemEntity {
  const InventoryItemEntity({
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
  final InventoryCategoryEntity category;
  final String quantity;
  final String unit;
  final String pricePerUnit;
  final String totalPrice;
  final String? note;
  final bool isArchived;
  final String createdAt;
  final String updatedAt;
}
