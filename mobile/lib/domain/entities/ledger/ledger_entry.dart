import 'package:mobile/domain/entities/ledger/ledger_entry_category.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry_type.dart';

class LedgerEntry {
  const LedgerEntry({
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
  final LedgerEntryType entryType;
  final String occurredAt;
  final LedgerEntryCategory category;
  final String amount;
  final String? unit;
  final String totalPrice;
  final String? note;
  final bool isArchived;
  final String createdAt;
  final String updatedAt;
}
