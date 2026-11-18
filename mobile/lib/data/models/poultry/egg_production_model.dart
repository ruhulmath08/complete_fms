import 'package:mobile/data/models/common/json_parsers.dart';

class EggProductionModel {
  const EggProductionModel({
    required this.id,
    required this.poultryGroupId,
    required this.producedAt,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.createdAt,
    this.note,
  });

  factory EggProductionModel.fromJson(Map<String, dynamic> json) =>
      EggProductionModel(
        id: requireString(json['id'], 'id'),
        poultryGroupId:
            requireString(json['poultry_group_id'], 'poultry_group_id'),
        producedAt: requireString(json['produced_at'], 'produced_at'),
        quantity: requireDecimalString(json['quantity'], 'quantity'),
        unit: requireString(json['unit'], 'unit'),
        pricePerUnit:
            requireDecimalString(json['price_per_unit'], 'price_per_unit'),
        note: optionalString(json['note']),
        createdAt: requireString(json['created_at'], 'created_at'),
      );

  final String id;
  final String poultryGroupId;
  final String producedAt;
  final String quantity;
  final String unit;
  final String pricePerUnit;
  final String? note;
  final String createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'poultry_group_id': poultryGroupId,
        'produced_at': producedAt,
        'quantity': quantity,
        'unit': unit,
        'price_per_unit': pricePerUnit,
        'note': note,
        'created_at': createdAt,
      };
}
