import 'package:mobile/data/models/ledger/ledger_entry_model.dart';
import 'package:mobile/data/models/ledger/ledger_series_model.dart';
import 'package:mobile/data/models/ledger/period_totals_model.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry_entity.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry_category_entity.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry_type_entity.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry_write_params_entity.dart';
import 'package:mobile/domain/entities/ledger/ledger_series_entity.dart';
import 'package:mobile/domain/entities/ledger/ledger_series_point_entity.dart';
import 'package:mobile/domain/entities/ledger/period_totals_entity.dart';

LedgerEntryTypeEntity mapLedgerEntryType(String value) {
  switch (value) {
    case 'income':
      return LedgerEntryTypeEntity.income;
    case 'expense':
      return LedgerEntryTypeEntity.expense;
    default:
      return LedgerEntryTypeEntity.expense;
  }
}

String ledgerEntryTypeToApi(LedgerEntryTypeEntity value) => switch (value) {
      LedgerEntryTypeEntity.income => 'income',
      LedgerEntryTypeEntity.expense => 'expense',
    };

LedgerEntryCategoryEntity mapLedgerEntryCategory(String value) {
  switch (value) {
    case 'labour':
      return LedgerEntryCategoryEntity.labour;
    case 'feed_or_supplies':
      return LedgerEntryCategoryEntity.feedOrSupplies;
    case 'utilities':
      return LedgerEntryCategoryEntity.utilities;
    case 'transport':
      return LedgerEntryCategoryEntity.transport;
    case 'equipment':
      return LedgerEntryCategoryEntity.equipment;
    case 'livestock_sale':
      return LedgerEntryCategoryEntity.livestockSale;
    case 'product_sale':
      return LedgerEntryCategoryEntity.productSale;
    case 'subsidy':
      return LedgerEntryCategoryEntity.subsidy;
    case 'other':
      return LedgerEntryCategoryEntity.other;
    default:
      return LedgerEntryCategoryEntity.other;
  }
}

String ledgerEntryCategoryToApi(LedgerEntryCategoryEntity value) => switch (value) {
      LedgerEntryCategoryEntity.labour => 'labour',
      LedgerEntryCategoryEntity.feedOrSupplies => 'feed_or_supplies',
      LedgerEntryCategoryEntity.utilities => 'utilities',
      LedgerEntryCategoryEntity.transport => 'transport',
      LedgerEntryCategoryEntity.equipment => 'equipment',
      LedgerEntryCategoryEntity.livestockSale => 'livestock_sale',
      LedgerEntryCategoryEntity.productSale => 'product_sale',
      LedgerEntryCategoryEntity.subsidy => 'subsidy',
      LedgerEntryCategoryEntity.other => 'other',
    };

LedgerEntryEntity mapLedgerEntry(Map<String, dynamic> json) =>
    mapLedgerEntryModel(LedgerEntryModel.fromJson(json));

LedgerEntryEntity mapLedgerEntryModel(LedgerEntryModel model) => LedgerEntryEntity(
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

PeriodTotalsEntity mapPeriodTotals(Map<String, dynamic> json) =>
    mapPeriodTotalsModel(PeriodTotalsModel.fromJson(json));

PeriodTotalsEntity mapPeriodTotalsModel(PeriodTotalsModel model) => PeriodTotalsEntity(
      from: model.from,
      to: model.to,
      totalIncome: model.totalIncome,
      totalExpenses: model.totalExpenses,
      net: model.net,
    );

Map<String, dynamic> ledgerEntryWriteToJson(LedgerEntryWriteParamsEntity params) => {
      'entry_type': ledgerEntryTypeToApi(params.entryType),
      'occurred_at': params.occurredAt,
      'category': ledgerEntryCategoryToApi(params.category),
      'amount': params.amount,
      'unit': params.unit,
      'note': params.note,
    };

LedgerSeriesEntity mapLedgerSeries(Map<String, dynamic> json) =>
    mapLedgerSeriesModel(LedgerSeriesModel.fromJson(json));

LedgerSeriesEntity mapLedgerSeriesModel(LedgerSeriesModel model) => LedgerSeriesEntity(
      from: model.from,
      to: model.to,
      grain: model.grain,
      points: model.points
          .map(
            (p) => LedgerSeriesPointEntity(
              bucketStart: p.bucketStart,
              income: p.income,
              expenses: p.expenses,
              net: p.net,
            ),
          )
          .toList(),
    );
