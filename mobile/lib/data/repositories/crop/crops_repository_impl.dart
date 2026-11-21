import 'package:mobile/data/datasources/crop/crops_datasource.dart';
import 'package:mobile/data/mappers/crop/crops_mappers.dart';
import 'package:mobile/data/models/crop/crop_cycle_model.dart';
import 'package:mobile/data/models/crop/crop_expense_model.dart';
import 'package:mobile/data/models/crop/crop_name_model.dart';
import 'package:mobile/data/models/crop/cycle_summary_model.dart';
import 'package:mobile/data/models/crop/harvest_model.dart';
import 'package:mobile/data/repositories/common/page_result_mapper.dart';
import 'package:mobile/domain/entities/common/paged_result_entity.dart';
import 'package:mobile/domain/entities/crop/crop_cycle_entity.dart';
import 'package:mobile/domain/entities/crop/crop_cycle_write_params_entity.dart';
import 'package:mobile/domain/entities/crop/crop_expense_entity.dart';
import 'package:mobile/domain/entities/crop/crop_name_entity.dart';
import 'package:mobile/domain/entities/crop/crop_name_write_params_entity.dart';
import 'package:mobile/domain/entities/crop/cycle_summary_entity.dart';
import 'package:mobile/domain/entities/crop/expense_category_entity.dart';
import 'package:mobile/domain/entities/crop/harvest_entity.dart';
import 'package:mobile/domain/repositories/crop/crops_repository.dart';

class CropsRepositoryImpl implements CropsRepository {
  CropsRepositoryImpl(this._datasource);

  final CropsDatasource _datasource;

  @override
  Future<PagedResultEntity<CropNameEntity>> listNames({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  }) async {
    final json = await _datasource.listNames(
      limit: limit,
      offset: offset,
      includeArchived: includeArchived,
    );
    return mapPageResult(json, CropNameModel.fromJson, mapCropNameModel);
  }

  @override
  Future<CropNameEntity> getName(String cropNameId) async {
    final model = CropNameModel.fromJson(await _datasource.getName(cropNameId));
    return mapCropNameModel(model);
  }

  @override
  Future<CropNameEntity> createName(CropNameWriteParamsEntity params) async {
    final model = CropNameModel.fromJson(
      await _datasource.createName(cropNameWriteToJson(params)),
    );
    return mapCropNameModel(model);
  }

  @override
  Future<CropNameEntity> updateName(
    String cropNameId,
    CropNameWriteParamsEntity params,
  ) async {
    final model = CropNameModel.fromJson(
      await _datasource.updateName(cropNameId, cropNameWriteToJson(params)),
    );
    return mapCropNameModel(model);
  }

  @override
  Future<CropNameEntity> archiveName(String cropNameId) async {
    final model = CropNameModel.fromJson(await _datasource.archiveName(cropNameId));
    return mapCropNameModel(model);
  }

  @override
  Future<PagedResultEntity<CropCycleEntity>> listCycles({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  }) async {
    final json = await _datasource.listCycles(
      limit: limit,
      offset: offset,
      includeArchived: includeArchived,
    );
    return mapPageResult(json, CropCycleModel.fromJson, mapCropCycleModel);
  }

  @override
  Future<CropCycleEntity> getCycle(String cycleId) async {
    final model = CropCycleModel.fromJson(await _datasource.getCycle(cycleId));
    return mapCropCycleModel(model);
  }

  @override
  Future<CropCycleEntity> createCycle(CropCycleWriteParamsEntity params) async {
    final model = CropCycleModel.fromJson(
      await _datasource.createCycle(cropCycleWriteToJson(params)),
    );
    return mapCropCycleModel(model);
  }

  @override
  Future<CropCycleEntity> updateCycle(
    String cycleId,
    CropCycleWriteParamsEntity params,
  ) async {
    final model = CropCycleModel.fromJson(
      await _datasource.updateCycle(cycleId, cropCycleWriteToJson(params)),
    );
    return mapCropCycleModel(model);
  }

  @override
  Future<CropCycleEntity> archiveCycle(String cycleId) async {
    final model = CropCycleModel.fromJson(await _datasource.archiveCycle(cycleId));
    return mapCropCycleModel(model);
  }

  @override
  Future<CycleSummaryEntity> getCycleSummary(String cycleId) async {
    final model = CycleSummaryModel.fromJson(
      await _datasource.getCycleSummary(cycleId),
    );
    return mapCycleSummaryModel(model);
  }

  @override
  Future<PagedResultEntity<CropExpenseEntity>> listExpenses(
    String cycleId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final json = await _datasource.listExpenses(cycleId, limit: limit, offset: offset);
    return mapPageResult(json, CropExpenseModel.fromJson, mapCropExpenseModel);
  }

  @override
  Future<CropExpenseEntity> addExpense({
    required String cycleId,
    required String spentAt,
    required ExpenseCategoryEntity category,
    required String amount,
    String? note,
  }) async {
    final model = CropExpenseModel.fromJson(
      await _datasource.addExpense(cycleId, {
        'spent_at': spentAt,
        'category': expenseCategoryToApi(category),
        'amount': amount,
        'note': note,
      }),
    );
    return mapCropExpenseModel(model);
  }

  @override
  Future<PagedResultEntity<HarvestEntity>> listHarvests(
    String cycleId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final json = await _datasource.listHarvests(cycleId, limit: limit, offset: offset);
    return mapPageResult(json, HarvestModel.fromJson, mapHarvestModel);
  }

  @override
  Future<HarvestEntity> addHarvest({
    required String cycleId,
    required String harvestedAt,
    required String quantity,
    required String unit,
    String? saleAmount,
    String? note,
  }) async {
    final model = HarvestModel.fromJson(
      await _datasource.addHarvest(cycleId, {
        'harvested_at': harvestedAt,
        'quantity': quantity,
        'unit': unit,
        'sale_amount': saleAmount,
        'note': note,
      }),
    );
    return mapHarvestModel(model);
  }

  @override
  Future<CropExpenseEntity> updateExpense({
    required String cycleId,
    required String expenseId,
    required String spentAt,
    required ExpenseCategoryEntity category,
    required String amount,
    String? note,
  }) async {
    final model = CropExpenseModel.fromJson(
      await _datasource.updateExpense(cycleId, expenseId, {
        'spent_at': spentAt,
        'category': expenseCategoryToApi(category),
        'amount': amount,
        'note': note,
      }),
    );
    return mapCropExpenseModel(model);
  }

  @override
  Future<void> deleteExpense(String cycleId, String expenseId) =>
      _datasource.deleteExpense(cycleId, expenseId);

  @override
  Future<HarvestEntity> updateHarvest({
    required String cycleId,
    required String harvestId,
    required String harvestedAt,
    required String quantity,
    required String unit,
    String? saleAmount,
    String? note,
  }) async {
    final model = HarvestModel.fromJson(
      await _datasource.updateHarvest(cycleId, harvestId, {
        'harvested_at': harvestedAt,
        'quantity': quantity,
        'unit': unit,
        'sale_amount': saleAmount,
        'note': note,
      }),
    );
    return mapHarvestModel(model);
  }

  @override
  Future<void> deleteHarvest(String cycleId, String harvestId) =>
      _datasource.deleteHarvest(cycleId, harvestId);
}
