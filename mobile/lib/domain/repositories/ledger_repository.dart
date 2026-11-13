import '../entities/ledger.dart';

abstract class LedgerRepository {
  Future<PagedResult<LedgerEntry>> listEntries({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
    String? from,
    String? to,
  });

  Future<LedgerEntry> getEntry(String entryId);

  Future<LedgerEntry> createEntry(LedgerEntryWriteParams params);

  Future<LedgerEntry> updateEntry(String entryId, LedgerEntryWriteParams params);

  Future<LedgerEntry> archiveEntry(String entryId);

  Future<PeriodTotals> getPeriodTotals({
    required String from,
    required String to,
  });

  Future<LedgerSeries> getSeries({
    required String from,
    required String to,
    required String grain,
  });
}
