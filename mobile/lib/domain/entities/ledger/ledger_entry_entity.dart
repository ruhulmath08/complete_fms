import 'package:mobile/domain/entities/ledger/ledger_entry_category_entity.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry_type_entity.dart';

class LedgerEntryEntity {
  const LedgerEntryEntity({
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

  final String id;
  final LedgerEntryTypeEntity entryType;
  final String occurredAt;
  final LedgerEntryCategoryEntity category;
  final String amount;
  final String? unit;
  final String totalPrice;
  final String? note;
  final bool isArchived;
  final String createdAt;
  final String updatedAt;
}
