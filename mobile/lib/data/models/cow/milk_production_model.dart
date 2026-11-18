import 'package:mobile/data/models/common/json_parsers.dart';

class MilkProductionModel {
  const MilkProductionModel({
    required this.id,
    required this.cowId,
    required this.producedAt,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.createdAt,
    this.note,
    this.total,
  });

  factory MilkProductionModel.fromJson(Map<String, dynamic> json) =>
      MilkProductionModel(
        id: requireString(json['id'], 'id'),
        cowId: requireString(json['cow_id'], 'cow_id'),
        producedAt: requireString(json['produced_at'], 'produced_at'),
        quantity: requireDecimalString(json['quantity'], 'quantity'),
        unit: requireString(json['unit'], 'unit'),
        pricePerUnit:
            requireDecimalString(json['price_per_unit'], 'price_per_unit'),
        total: optionalDecimalString(json['total']),
        note: optionalString(json['note']),
        createdAt: requireString(json['created_at'], 'created_at'),
      );

  final String id;
  final String cowId;
  final String producedAt;
  final String quantity;
  final String unit;
  final String pricePerUnit;
  final String? total;
  final String? note;
  final String createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'cow_id': cowId,
        'produced_at': producedAt,
        'quantity': quantity,
        'unit': unit,
        'price_per_unit': pricePerUnit,
        'total': total,
        'note': note,
        'created_at': createdAt,
      };
}
