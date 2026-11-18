import 'package:mobile/data/models/common/json_parsers.dart';

class PoultryFeedingModel {
  const PoultryFeedingModel({
    required this.id,
    required this.poultryGroupId,
    required this.fedAt,
    required this.feedName,
    required this.quantity,
    required this.unit,
    required this.createdAt,
    this.note,
  });

  factory PoultryFeedingModel.fromJson(Map<String, dynamic> json) =>
      PoultryFeedingModel(
        id: requireString(json['id'], 'id'),
        poultryGroupId:
            requireString(json['poultry_group_id'], 'poultry_group_id'),
        fedAt: requireString(json['fed_at'], 'fed_at'),
        feedName: requireString(json['feed_name'], 'feed_name'),
        quantity: requireDecimalString(json['quantity'], 'quantity'),
        unit: requireString(json['unit'], 'unit'),
        note: optionalString(json['note']),
        createdAt: requireString(json['created_at'], 'created_at'),
      );

  final String id;
  final String poultryGroupId;
  final String fedAt;
  final String feedName;
  final String quantity;
  final String unit;
  final String? note;
  final String createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'poultry_group_id': poultryGroupId,
        'fed_at': fedAt,
        'feed_name': feedName,
        'quantity': quantity,
        'unit': unit,
        'note': note,
        'created_at': createdAt,
      };
}
