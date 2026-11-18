import 'package:mobile/data/models/common/json_parsers.dart';

class HarvestModel {
  const HarvestModel({
    required this.id,
    required this.cropCycleId,
    required this.harvestedAt,
    required this.quantity,
    required this.unit,
    required this.createdAt,
    this.saleAmount,
    this.note,
  });

  factory HarvestModel.fromJson(Map<String, dynamic> json) => HarvestModel(
        id: requireString(json['id'], 'id'),
        cropCycleId: requireString(json['crop_cycle_id'], 'crop_cycle_id'),
        harvestedAt: requireString(json['harvested_at'], 'harvested_at'),
        quantity: requireDecimalString(json['quantity'], 'quantity'),
        unit: requireString(json['unit'], 'unit'),
        saleAmount: optionalDecimalString(json['sale_amount']),
        note: optionalString(json['note']),
        createdAt: requireString(json['created_at'], 'created_at'),
      );

  final String id;
  final String cropCycleId;
  final String harvestedAt;
  final String quantity;
  final String unit;
  final String? saleAmount;
  final String? note;
  final String createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'crop_cycle_id': cropCycleId,
        'harvested_at': harvestedAt,
        'quantity': quantity,
        'unit': unit,
        'sale_amount': saleAmount,
        'note': note,
        'created_at': createdAt,
      };
}
