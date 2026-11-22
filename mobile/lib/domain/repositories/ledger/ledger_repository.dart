import 'package:mobile/domain/entities/common/paged_result_entity.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry_entity.dart';
import 'package:mobile/domain/entities/ledger/ledger_entry_write_params_entity.dart';
import 'package:mobile/domain/entities/ledger/ledger_series_entity.dart';
import 'package:mobile/domain/entities/ledger/period_totals_entity.dart';

abstract class LedgerRepository {
  Future<PagedResultEntity<LedgerEntryEntity>> listEntries({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
    String? from,
    String? to,
  });

  Future<LedgerEntryEntity> getEntry(String entryId);

  Future<LedgerEntryEntity> createEntry(LedgerEntryWriteParamsEntity params);

  Future<LedgerEntryEntity> updateEntry(String entryId, LedgerEntryWriteParamsEntity params);

  Future<LedgerEntryEntity> archiveEntry(String entryId);

  Future<PeriodTotalsEntity> getPeriodTotals({
    required String from,
    required String to,
  });

  Future<LedgerSeriesEntity> getSeries({
    required String from,
    required String to,
    required String grain,
  });
}
