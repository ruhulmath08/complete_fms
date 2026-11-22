import 'package:mobile/domain/entities/common/paged_result_entity.dart';
import 'package:mobile/domain/entities/crop/crop_cycle_entity.dart';
import 'package:mobile/domain/entities/crop/crop_cycle_write_params_entity.dart';
import 'package:mobile/domain/entities/crop/crop_expense_entity.dart';
import 'package:mobile/domain/entities/crop/crop_name_entity.dart';
import 'package:mobile/domain/entities/crop/crop_name_write_params_entity.dart';
import 'package:mobile/domain/entities/crop/cycle_summary_entity.dart';
import 'package:mobile/domain/entities/crop/expense_category_entity.dart';
import 'package:mobile/domain/entities/crop/harvest_entity.dart';

abstract class CropsRepository {
  Future<PagedResultEntity<CropNameEntity>> listNames({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  });

  Future<CropNameEntity> getName(String cropNameId);

  Future<CropNameEntity> createName(CropNameWriteParamsEntity params);

  Future<CropNameEntity> updateName(String cropNameId, CropNameWriteParamsEntity params);

  Future<CropNameEntity> archiveName(String cropNameId);

  Future<PagedResultEntity<CropCycleEntity>> listCycles({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  });

  Future<CropCycleEntity> getCycle(String cycleId);

  Future<CropCycleEntity> createCycle(CropCycleWriteParamsEntity params);

  Future<CropCycleEntity> updateCycle(String cycleId, CropCycleWriteParamsEntity params);

  Future<CropCycleEntity> archiveCycle(String cycleId);

  Future<CycleSummaryEntity> getCycleSummary(String cycleId);

  Future<PagedResultEntity<CropExpenseEntity>> listExpenses(
    String cycleId, {
    int limit = 50,
    int offset = 0,
  });

  Future<CropExpenseEntity> addExpense({
    required String cycleId,
    required String spentAt,
    required ExpenseCategoryEntity category,
    required String amount,
    String? note,
  });

  Future<PagedResultEntity<HarvestEntity>> listHarvests(
    String cycleId, {
    int limit = 50,
    int offset = 0,
  });

  Future<HarvestEntity> addHarvest({
    required String cycleId,
    required String harvestedAt,
    required String quantity,
    required String unit,
    String? saleAmount,
    String? note,
  });

  Future<CropExpenseEntity> updateExpense({
    required String cycleId,
    required String expenseId,
    required String spentAt,
    required ExpenseCategoryEntity category,
    required String amount,
    String? note,
  });

  Future<void> deleteExpense(String cycleId, String expenseId);

  Future<HarvestEntity> updateHarvest({
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
