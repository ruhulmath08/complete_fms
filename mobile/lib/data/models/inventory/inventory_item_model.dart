import 'package:mobile/data/models/common/json_parsers.dart';

class InventoryItemModel {
  const InventoryItemModel({
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

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) =>
      InventoryItemModel(
        id: requireString(json['id'], 'id'),
        name: requireString(json['name'], 'name'),
        category: requireString(json['category'], 'category'),
        quantity: requireDecimalString(json['quantity'], 'quantity'),
        unit: requireString(json['unit'], 'unit'),
        pricePerUnit:
            requireDecimalString(json['price_per_unit'], 'price_per_unit'),
        totalPrice: requireDecimalString(json['total_price'], 'total_price'),
        note: optionalString(json['note']),
        isArchived: requireBool(json['is_archived'], 'is_archived'),
        createdAt: requireString(json['created_at'], 'created_at'),
        updatedAt: requireString(json['updated_at'], 'updated_at'),
      );

  final String id;
  final String name;
  final String category;
  final String quantity;
  final String unit;
  final String pricePerUnit;
  final String totalPrice;
  final String? note;
  final bool isArchived;
  final String createdAt;
  final String updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'quantity': quantity,
        'unit': unit,
        'price_per_unit': pricePerUnit,
        'total_price': totalPrice,
        'note': note,
        'is_archived': isArchived,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
