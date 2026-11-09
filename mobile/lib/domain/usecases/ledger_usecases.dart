import '../entities/ledger.dart';
import '../repositories/ledger_repository.dart';

class ListLedgerEntries {
  ListLedgerEntries(this._repository);
  final LedgerRepository _repository;
  Future<PagedResult<LedgerEntry>> call({
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
  Future<LedgerEntry> call(String entryId) => _repository.getEntry(entryId);
}

class CreateLedgerEntry {
  CreateLedgerEntry(this._repository);
  final LedgerRepository _repository;
  Future<LedgerEntry> call(LedgerEntryWriteParams params) =>
      _repository.createEntry(params);
}

class UpdateLedgerEntry {
  UpdateLedgerEntry(this._repository);
  final LedgerRepository _repository;
  Future<LedgerEntry> call(String entryId, LedgerEntryWriteParams params) =>
      _repository.updateEntry(entryId, params);
}

class ArchiveLedgerEntry {
  ArchiveLedgerEntry(this._repository);
  final LedgerRepository _repository;
  Future<LedgerEntry> call(String entryId) => _repository.archiveEntry(entryId);
}

class GetPeriodTotals {
  GetPeriodTotals(this._repository);
  final LedgerRepository _repository;
  Future<PeriodTotals> call({required String from, required String to}) =>
      _repository.getPeriodTotals(from: from, to: to);
}
