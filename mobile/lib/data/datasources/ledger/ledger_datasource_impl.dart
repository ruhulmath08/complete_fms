import 'package:mobile/data/datasources/ledger/ledger_datasource.dart';
import 'package:mobile/data/network/api_client.dart';
import 'package:mobile/data/network/api_endpoints.dart';

class LedgerDatasourceImpl implements LedgerDatasource {
  LedgerDatasourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> listEntries({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
    String? from,
    String? to,
  }) {
    return _client.get(
      ApiEndpoints.ledgerEntries,
      query: {
        'limit': limit,
        'offset': offset,
        if (includeArchived) 'include_archived': true,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getEntry(String entryId) {
    return _client.get(ApiEndpoints.ledgerEntry(entryId));
  }

  @override
  Future<Map<String, dynamic>> createEntry(Map<String, dynamic> body) {
    return _client.post(ApiEndpoints.ledgerEntries, data: body);
  }

  @override
  Future<Map<String, dynamic>> updateEntry(
    String entryId,
    Map<String, dynamic> body,
  ) {
    return _client.patch(ApiEndpoints.ledgerEntry(entryId), data: body);
  }

  @override
  Future<Map<String, dynamic>> archiveEntry(String entryId) {
    return _client.post(ApiEndpoints.ledgerEntryArchive(entryId));
  }

  @override
  Future<Map<String, dynamic>> getPeriodTotals({
    required String from,
    required String to,
  }) {
    return _client.get(
      ApiEndpoints.ledgerTotals,
      query: {'from': from, 'to': to},
    );
  }

  @override
  Future<Map<String, dynamic>> getSeries({
    required String from,
    required String to,
    required String grain,
  }) {
    return _client.get(
      ApiEndpoints.ledgerSeries,
      query: {'from': from, 'to': to, 'grain': grain},
    );
  }
}
