import '../../domain/entities/ledger.dart';

LedgerEntryType mapLedgerEntryType(String value) {
  switch (value) {
    case 'income':
      return LedgerEntryType.income;
    case 'expense':
      return LedgerEntryType.expense;
    default:
      return LedgerEntryType.expense;
  }
}

String ledgerEntryTypeToApi(LedgerEntryType value) => switch (value) {
      LedgerEntryType.income => 'income',
      LedgerEntryType.expense => 'expense',
    };

LedgerEntryCategory mapLedgerEntryCategory(String value) {
  switch (value) {
    case 'labour':
      return LedgerEntryCategory.labour;
    case 'feed_or_supplies':
      return LedgerEntryCategory.feedOrSupplies;
    case 'utilities':
      return LedgerEntryCategory.utilities;
    case 'transport':
      return LedgerEntryCategory.transport;
    case 'equipment':
      return LedgerEntryCategory.equipment;
    case 'livestock_sale':
      return LedgerEntryCategory.livestockSale;
    case 'product_sale':
      return LedgerEntryCategory.productSale;
    case 'subsidy':
      return LedgerEntryCategory.subsidy;
    case 'other':
      return LedgerEntryCategory.other;
    default:
      return LedgerEntryCategory.other;
  }
}

String ledgerEntryCategoryToApi(LedgerEntryCategory value) => switch (value) {
      LedgerEntryCategory.labour => 'labour',
      LedgerEntryCategory.feedOrSupplies => 'feed_or_supplies',
      LedgerEntryCategory.utilities => 'utilities',
      LedgerEntryCategory.transport => 'transport',
      LedgerEntryCategory.equipment => 'equipment',
      LedgerEntryCategory.livestockSale => 'livestock_sale',
      LedgerEntryCategory.productSale => 'product_sale',
      LedgerEntryCategory.subsidy => 'subsidy',
      LedgerEntryCategory.other => 'other',
    };

LedgerEntry mapLedgerEntry(Map<String, dynamic> json) => LedgerEntry(
      id: json['id'] as String,
      entryType: mapLedgerEntryType(json['entry_type'] as String),
      occurredAt: json['occurred_at'] as String,
      category: mapLedgerEntryCategory(json['category'] as String),
      amount: json['amount'].toString(),
      unit: json['unit'] as String?,
      totalPrice: json['total_price'].toString(),
      note: json['note'] as String?,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

PeriodTotals mapPeriodTotals(Map<String, dynamic> json) => PeriodTotals(
      from: json['from'] as String,
      to: json['to'] as String,
      totalIncome: json['total_income'].toString(),
      totalExpenses: json['total_expenses'].toString(),
      net: json['net'].toString(),
    );

Map<String, dynamic> ledgerEntryWriteToJson(LedgerEntryWriteParams params) => {
      'entry_type': ledgerEntryTypeToApi(params.entryType),
      'occurred_at': params.occurredAt,
      'category': ledgerEntryCategoryToApi(params.category),
      'amount': params.amount,
      'unit': params.unit,
      'note': params.note,
    };
