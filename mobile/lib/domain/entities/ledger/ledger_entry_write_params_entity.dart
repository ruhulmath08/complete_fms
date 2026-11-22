import 'package:mobile/domain/entities/ledger/ledger_entry_category_entity.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry_type_entity.dart';

class LedgerEntryWriteParamsEntity {
  const LedgerEntryWriteParamsEntity({
    required this.entryType,
    required this.occurredAt,
    required this.category,
    required this.amount,
    this.unit,
    this.note,
  });

  final LedgerEntryTypeEntity entryType;
  final String occurredAt;
  final LedgerEntryCategoryEntity category;
  final String amount;
  final String? unit;
  final String? note;
}
