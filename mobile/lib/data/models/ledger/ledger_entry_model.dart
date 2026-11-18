import 'package:mobile/data/models/common/json_parsers.dart';

class LedgerEntryModel {
  const LedgerEntryModel({
    required this.id,
    required this.entryType,
    required this.occurredAt,
    required this.category,
    required this.amount,
    required this.totalPrice,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.unit,
    this.note,
  });

  factory LedgerEntryModel.fromJson(Map<String, dynamic> json) =>
      LedgerEntryModel(
        id: requireString(json['id'], 'id'),
        entryType: requireString(json['entry_type'], 'entry_type'),
        occurredAt: requireString(json['occurred_at'], 'occurred_at'),
        category: requireString(json['category'], 'category'),
        amount: requireDecimalString(json['amount'], 'amount'),
        unit: optionalString(json['unit']),
        totalPrice: requireDecimalString(json['total_price'], 'total_price'),
        note: optionalString(json['note']),
        isArchived: requireBool(json['is_archived'], 'is_archived'),
        createdAt: requireString(json['created_at'], 'created_at'),
        updatedAt: requireString(json['updated_at'], 'updated_at'),
      );

  final String id;
  final String entryType;
  final String occurredAt;
  final String category;
  final String amount;
  final String? unit;
  final String totalPrice;
  final String? note;
  final bool isArchived;
  final String createdAt;
  final String updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'entry_type': entryType,
        'occurred_at': occurredAt,
        'category': category,
        'amount': amount,
        'unit': unit,
        'total_price': totalPrice,
        'note': note,
        'is_archived': isArchived,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
