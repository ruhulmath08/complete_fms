export 'cow.dart' show PagedResult;

enum LedgerEntryType { income, expense }

enum LedgerEntryCategory {
  labour,
  feedOrSupplies,
  utilities,
  transport,
  equipment,
  livestockSale,
  productSale,
  subsidy,
  other,
}

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

class PeriodTotals {
  const PeriodTotals({
    required this.from,
    required this.to,
    required this.totalIncome,
    required this.totalExpenses,
    required this.net,
  });

  final String from;
  final String to;
  final String totalIncome;
  final String totalExpenses;
  final String net;
}

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
