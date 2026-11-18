import 'package:mobile/data/models/common/json_parsers.dart';

class CowFeedingModel {
  const CowFeedingModel({
    required this.id,
    required this.cowId,
    required this.fedAt,
    required this.feedName,
    required this.quantity,
    required this.unit,
    required this.unitCost,
    required this.createdAt,
    this.note,
    this.total,
  });

  factory CowFeedingModel.fromJson(Map<String, dynamic> json) =>
      CowFeedingModel(
        id: requireString(json['id'], 'id'),
        cowId: requireString(json['cow_id'], 'cow_id'),
        fedAt: requireString(json['fed_at'], 'fed_at'),
        feedName: requireString(json['feed_name'], 'feed_name'),
        quantity: requireDecimalString(json['quantity'], 'quantity'),
        unit: requireString(json['unit'], 'unit'),
        unitCost: requireDecimalString(json['unit_cost'], 'unit_cost'),
        total: optionalDecimalString(json['total']),
        note: optionalString(json['note']),
        createdAt: requireString(json['created_at'], 'created_at'),
      );

  final String id;
  final String cowId;
  final String fedAt;
  final String feedName;
  final String quantity;
  final String unit;
  final String unitCost;
  final String? total;
  final String? note;
  final String createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'cow_id': cowId,
        'fed_at': fedAt,
        'feed_name': feedName,
        'quantity': quantity,
        'unit': unit,
        'unit_cost': unitCost,
        'total': total,
        'note': note,
        'created_at': createdAt,
      };
}
