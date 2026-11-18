import 'package:mobile/data/models/common/json_parsers.dart';

class CropExpenseModel {
  const CropExpenseModel({
    required this.id,
    required this.cropCycleId,
    required this.spentAt,
    required this.category,
    required this.amount,
    required this.createdAt,
    this.note,
  });

  factory CropExpenseModel.fromJson(Map<String, dynamic> json) =>
      CropExpenseModel(
        id: requireString(json['id'], 'id'),
        cropCycleId: requireString(json['crop_cycle_id'], 'crop_cycle_id'),
        spentAt: requireString(json['spent_at'], 'spent_at'),
        category: requireString(json['category'], 'category'),
        amount: requireDecimalString(json['amount'], 'amount'),
        note: optionalString(json['note']),
        createdAt: requireString(json['created_at'], 'created_at'),
      );

  final String id;
  final String cropCycleId;
  final String spentAt;
  final String category;
  final String amount;
  final String? note;
  final String createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'crop_cycle_id': cropCycleId,
        'spent_at': spentAt,
        'category': category,
        'amount': amount,
        'note': note,
        'created_at': createdAt,
      };
}
