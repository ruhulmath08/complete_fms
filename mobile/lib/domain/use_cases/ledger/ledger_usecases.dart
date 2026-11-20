import 'package:mobile/domain/repositories/ledger/ledger_repository.dart';
import 'package:mobile/domain/entities/common/paged_result_entity.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry_entity.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry_write_params_entity.dart';
import 'package:mobile/domain/entities/ledger/ledger_series_entity.dart';
import 'package:mobile/domain/entities/ledger/period_totals_entity.dart';

class ListLedgerEntries {
  ListLedgerEntries(this._repository);
  final LedgerRepository _repository;
  Future<PagedResultEntity<LedgerEntryEntity>> call({
    bool includeArchived = false,
    String? from,
    String? to,
  }) =>
      _repository.listEntries(
        includeArchived: includeArchived,
        from: from,
        to: to,
      );
}

class GetLedgerEntry {
  GetLedgerEntry(this._repository);
  final LedgerRepository _repository;
  Future<LedgerEntryEntity> call(String entryId) => _repository.getEntry(entryId);
}

class CreateLedgerEntry {
  CreateLedgerEntry(this._repository);
  final LedgerRepository _repository;
  Future<LedgerEntryEntity> call(LedgerEntryWriteParamsEntity params) =>
      _repository.createEntry(params);
}

class UpdateLedgerEntry {
  UpdateLedgerEntry(this._repository);
  final LedgerRepository _repository;
  Future<LedgerEntryEntity> call(String entryId, LedgerEntryWriteParamsEntity params) =>
      _repository.updateEntry(entryId, params);
}

class ArchiveLedgerEntry {
  ArchiveLedgerEntry(this._repository);
  final LedgerRepository _repository;
  Future<LedgerEntryEntity> call(String entryId) => _repository.archiveEntry(entryId);
}

class GetPeriodTotals {
  GetPeriodTotals(this._repository);
  final LedgerRepository _repository;
  Future<PeriodTotalsEntity> call({required String from, required String to}) =>
      _repository.getPeriodTotals(from: from, to: to);
}

class GetLedgerSeries {
  GetLedgerSeries(this._repository);
  final LedgerRepository _repository;
  Future<LedgerSeriesEntity> call({
    required String from,
    required String to,
    required String grain,
  }) =>
      _repository.getSeries(from: from, to: to, grain: grain);
}
