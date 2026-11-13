import '../../domain/entities/ledger.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../datasources/ledger_api.dart';
import '../mappers/ledger_mappers.dart';

class LedgerRepositoryImpl implements LedgerRepository {
  LedgerRepositoryImpl(this._api);

  final LedgerApi _api;

  PagedResult<T> _page<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) mapItem,
  ) {
    final items = (json['items'] as List<dynamic>)
        .map((e) => mapItem(e as Map<String, dynamic>))
        .toList();
    final meta = json['meta'] as Map<String, dynamic>;
    return PagedResult(
      items: items,
      total: meta['total'] as int,
      limit: meta['limit'] as int,
      offset: meta['offset'] as int,
    );
  }

  @override
  Future<PagedResult<LedgerEntry>> listEntries({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
    String? from,
    String? to,
  }) async {
    final json = await _api.listEntries(
      limit: limit,
      offset: offset,
      includeArchived: includeArchived,
      from: from,
      to: to,
    );
    return _page(json, mapLedgerEntry);
  }

  @override
  Future<LedgerEntry> getEntry(String entryId) async =>
      mapLedgerEntry(await _api.getEntry(entryId));

  @override
  Future<LedgerEntry> createEntry(LedgerEntryWriteParams params) async =>
      mapLedgerEntry(await _api.createEntry(ledgerEntryWriteToJson(params)));

  @override
  Future<LedgerEntry> updateEntry(
    String entryId,
    LedgerEntryWriteParams params,
  ) async =>
      mapLedgerEntry(
        await _api.updateEntry(entryId, ledgerEntryWriteToJson(params)),
      );

  @override
  Future<LedgerEntry> archiveEntry(String entryId) async =>
      mapLedgerEntry(await _api.archiveEntry(entryId));

  @override
  Future<PeriodTotals> getPeriodTotals({
    required String from,
    required String to,
  }) async =>
      mapPeriodTotals(await _api.getPeriodTotals(from: from, to: to));

  @override
  Future<LedgerSeries> getSeries({
    required String from,
    required String to,
    required String grain,
  }) async =>
      mapLedgerSeries(await _api.getSeries(from: from, to: to, grain: grain));
}
