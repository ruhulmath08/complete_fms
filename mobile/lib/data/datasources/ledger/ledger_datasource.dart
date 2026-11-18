abstract class LedgerDatasource {
  Future<Map<String, dynamic>> listEntries({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
    String? from,
    String? to,
  });

  Future<Map<String, dynamic>> getEntry(String entryId);

  Future<Map<String, dynamic>> createEntry(Map<String, dynamic> body);

  Future<Map<String, dynamic>> updateEntry(
    String entryId,
    Map<String, dynamic> body,
  );

  Future<Map<String, dynamic>> archiveEntry(String entryId);

  Future<Map<String, dynamic>> getPeriodTotals({
    required String from,
    required String to,
  });

  Future<Map<String, dynamic>> getSeries({
    required String from,
    required String to,
    required String grain,
  });
}
