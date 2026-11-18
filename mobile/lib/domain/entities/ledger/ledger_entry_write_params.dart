import 'package:mobile/domain/entities/ledger/ledger_entry_category.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry_type.dart';

class LedgerEntryWriteParams {
  const LedgerEntryWriteParams({
    required this.entryType,
    required this.occurredAt,
    required this.category,
    required this.amount,
    this.unit,
    this.note,
  });

  final LedgerEntryType entryType;
  final String occurredAt;
  final LedgerEntryCategory category;
  final String amount;
  final String? unit;
  final String? note;
}
