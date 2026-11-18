import 'package:mobile/data/models/ledger/ledger_entry_model.dart';
import 'package:mobile/data/models/ledger/ledger_series_model.dart';
import 'package:mobile/data/models/ledger/period_totals_model.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry_category.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry_type.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry_write_params.dart';
import 'package:mobile/domain/entities/ledger/ledger_series.dart';
import 'package:mobile/domain/entities/ledger/ledger_series_point.dart';
import 'package:mobile/domain/entities/ledger/period_totals.dart';

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

LedgerEntry mapLedgerEntry(Map<String, dynamic> json) =>
    mapLedgerEntryModel(LedgerEntryModel.fromJson(json));

LedgerEntry mapLedgerEntryModel(LedgerEntryModel model) => LedgerEntry(
      id: model.id,
      entryType: mapLedgerEntryType(model.entryType),
      occurredAt: model.occurredAt,
      category: mapLedgerEntryCategory(model.category),
      amount: model.amount,
      unit: model.unit,
      totalPrice: model.totalPrice,
      note: model.note,
      isArchived: model.isArchived,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );

PeriodTotals mapPeriodTotals(Map<String, dynamic> json) =>
    mapPeriodTotalsModel(PeriodTotalsModel.fromJson(json));

PeriodTotals mapPeriodTotalsModel(PeriodTotalsModel model) => PeriodTotals(
      from: model.from,
      to: model.to,
      totalIncome: model.totalIncome,
      totalExpenses: model.totalExpenses,
      net: model.net,
    );

Map<String, dynamic> ledgerEntryWriteToJson(LedgerEntryWriteParams params) => {
      'entry_type': ledgerEntryTypeToApi(params.entryType),
      'occurred_at': params.occurredAt,
      'category': ledgerEntryCategoryToApi(params.category),
      'amount': params.amount,
      'unit': params.unit,
      'note': params.note,
    };

LedgerSeries mapLedgerSeries(Map<String, dynamic> json) =>
    mapLedgerSeriesModel(LedgerSeriesModel.fromJson(json));

LedgerSeries mapLedgerSeriesModel(LedgerSeriesModel model) => LedgerSeries(
      from: model.from,
      to: model.to,
      grain: model.grain,
      points: model.points
          .map(
            (p) => LedgerSeriesPoint(
              bucketStart: p.bucketStart,
              income: p.income,
              expenses: p.expenses,
              net: p.net,
            ),
          )
          .toList(),
    );
