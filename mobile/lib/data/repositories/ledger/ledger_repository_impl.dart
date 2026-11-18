import 'package:mobile/data/datasources/ledger/ledger_datasource.dart';
import 'package:mobile/data/mappers/ledger/ledger_mappers.dart';
import 'package:mobile/data/models/ledger/ledger_entry_model.dart';
import 'package:mobile/data/models/ledger/ledger_series_model.dart';
import 'package:mobile/data/models/ledger/period_totals_model.dart';
import 'package:mobile/data/repositories/common/page_result_mapper.dart';
import 'package:mobile/domain/entities/common/paged_result.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry_write_params.dart';
import 'package:mobile/domain/entities/ledger/ledger_series.dart';
import 'package:mobile/domain/entities/ledger/period_totals.dart';
import 'package:mobile/domain/repositories/ledger/ledger_repository.dart';

class LedgerRepositoryImpl implements LedgerRepository {
  LedgerRepositoryImpl(this._datasource);

  final LedgerDatasource _datasource;

  @override
  Future<PagedResult<LedgerEntry>> listEntries({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
    String? from,
    String? to,
  }) async {
    final json = await _datasource.listEntries(
      limit: limit,
      offset: offset,
      includeArchived: includeArchived,
      from: from,
      to: to,
    );
    return mapPageResult(json, LedgerEntryModel.fromJson, mapLedgerEntryModel);
  }

  @override
  Future<LedgerEntry> getEntry(String entryId) async {
    final model = LedgerEntryModel.fromJson(await _datasource.getEntry(entryId));
    return mapLedgerEntryModel(model);
  }

  @override
  Future<LedgerEntry> createEntry(LedgerEntryWriteParams params) async {
    final model = LedgerEntryModel.fromJson(
      await _datasource.createEntry(ledgerEntryWriteToJson(params)),
    );
    return mapLedgerEntryModel(model);
  }

  @override
  Future<LedgerEntry> updateEntry(
    String entryId,
    LedgerEntryWriteParams params,
  ) async {
    final model = LedgerEntryModel.fromJson(
      await _datasource.updateEntry(entryId, ledgerEntryWriteToJson(params)),
    );
    return mapLedgerEntryModel(model);
  }

  @override
  Future<LedgerEntry> archiveEntry(String entryId) async {
    final model = LedgerEntryModel.fromJson(await _datasource.archiveEntry(entryId));
    return mapLedgerEntryModel(model);
  }

  @override
  Future<PeriodTotals> getPeriodTotals({
    required String from,
    required String to,
  }) async {
    final model = PeriodTotalsModel.fromJson(
      await _datasource.getPeriodTotals(from: from, to: to),
    );
    return mapPeriodTotalsModel(model);
  }

  @override
  Future<LedgerSeries> getSeries({
    required String from,
    required String to,
    required String grain,
  }) async {
    final model = LedgerSeriesModel.fromJson(
      await _datasource.getSeries(from: from, to: to, grain: grain),
    );
    return mapLedgerSeriesModel(model);
  }
}
