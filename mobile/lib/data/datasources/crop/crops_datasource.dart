abstract class CropsDatasource {
  Future<Map<String, dynamic>> listNames({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  });

  Future<Map<String, dynamic>> getName(String cropNameId);

  Future<Map<String, dynamic>> createName(Map<String, dynamic> body);

  Future<Map<String, dynamic>> updateName(
    String cropNameId,
    Map<String, dynamic> body,
  );

  Future<Map<String, dynamic>> archiveName(String cropNameId);

  Future<Map<String, dynamic>> listCycles({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  });

  Future<Map<String, dynamic>> getCycle(String cycleId);

  Future<Map<String, dynamic>> createCycle(Map<String, dynamic> body);

  Future<Map<String, dynamic>> updateCycle(
    String cycleId,
    Map<String, dynamic> body,
  );

  Future<Map<String, dynamic>> archiveCycle(String cycleId);

  Future<Map<String, dynamic>> getCycleSummary(String cycleId);

  Future<Map<String, dynamic>> listExpenses(
    String cycleId, {
    int limit = 50,
    int offset = 0,
  });

  Future<Map<String, dynamic>> addExpense(
    String cycleId,
    Map<String, dynamic> body,
  );

  Future<Map<String, dynamic>> listHarvests(
    String cycleId, {
    int limit = 50,
    int offset = 0,
  });

  Future<Map<String, dynamic>> addHarvest(
    String cycleId,
    Map<String, dynamic> body,
  );

  Future<Map<String, dynamic>> updateExpense(
    String cycleId,
    String expenseId,
    Map<String, dynamic> body,
  );

  Future<void> deleteExpense(String cycleId, String expenseId);

  Future<Map<String, dynamic>> updateHarvest(
    String cycleId,
    String harvestId,
    Map<String, dynamic> body,
  );

  Future<void> deleteHarvest(String cycleId, String harvestId);
}
