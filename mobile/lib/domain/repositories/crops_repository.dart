import '../entities/crop.dart';

abstract class CropsRepository {
  Future<PagedResult<CropName>> listNames({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  });

  Future<CropName> getName(String cropNameId);

  Future<CropName> createName(CropNameWriteParams params);

  Future<CropName> updateName(String cropNameId, CropNameWriteParams params);

  Future<CropName> archiveName(String cropNameId);

  Future<PagedResult<CropCycle>> listCycles({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  });

  Future<CropCycle> getCycle(String cycleId);

  Future<CropCycle> createCycle(CropCycleWriteParams params);

  Future<CropCycle> updateCycle(String cycleId, CropCycleWriteParams params);

  Future<CropCycle> archiveCycle(String cycleId);

  Future<CycleSummary> getCycleSummary(String cycleId);

  Future<PagedResult<CropExpense>> listExpenses(
    String cycleId, {
    int limit = 50,
    int offset = 0,
  });

  Future<CropExpense> addExpense({
    required String cycleId,
    required String spentAt,
    required ExpenseCategory category,
    required String amount,
    String? note,
  });

  Future<PagedResult<Harvest>> listHarvests(
    String cycleId, {
    int limit = 50,
    int offset = 0,
  });

  Future<Harvest> addHarvest({
    required String cycleId,
    required String harvestedAt,
    required String quantity,
    required String unit,
    String? saleAmount,
    String? note,
  });

  Future<CropExpense> updateExpense({
    required String cycleId,
    required String expenseId,
    required String spentAt,
    required ExpenseCategory category,
    required String amount,
    String? note,
  });

  Future<void> deleteExpense(String cycleId, String expenseId);

  Future<Harvest> updateHarvest({
    required String cycleId,
    required String harvestId,
    required String harvestedAt,
    required String quantity,
    required String unit,
    String? saleAmount,
    String? note,
  });

  Future<void> deleteHarvest(String cycleId, String harvestId);
}
