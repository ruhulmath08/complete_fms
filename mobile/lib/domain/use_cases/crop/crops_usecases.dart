import 'package:mobile/domain/repositories/crop/crops_repository.dart';
import 'package:mobile/domain/entities/common/paged_result_entity.dart';
import 'package:mobile/domain/entities/crop/crop_cycle_entity.dart';
import 'package:mobile/domain/entities/crop/crop_cycle_write_params_entity.dart';
import 'package:mobile/domain/entities/crop/crop_expense_entity.dart';
import 'package:mobile/domain/entities/crop/crop_name_entity.dart';
import 'package:mobile/domain/entities/crop/crop_name_write_params_entity.dart';
import 'package:mobile/domain/entities/crop/cycle_summary_entity.dart';
import 'package:mobile/domain/entities/crop/expense_category_entity.dart';
import 'package:mobile/domain/entities/crop/harvest_entity.dart';

class ListCropNames {
  ListCropNames(this._repository);
  final CropsRepository _repository;
  Future<PagedResultEntity<CropNameEntity>> call({bool includeArchived = false}) =>
      _repository.listNames(includeArchived: includeArchived);
}

class GetCropName {
  GetCropName(this._repository);
  final CropsRepository _repository;
  Future<CropNameEntity> call(String cropNameId) => _repository.getName(cropNameId);
}

class CreateCropName {
  CreateCropName(this._repository);
  final CropsRepository _repository;
  Future<CropNameEntity> call(CropNameWriteParamsEntity params) =>
      _repository.createName(params);
}

class UpdateCropName {
  UpdateCropName(this._repository);
  final CropsRepository _repository;
  Future<CropNameEntity> call(String cropNameId, CropNameWriteParamsEntity params) =>
      _repository.updateName(cropNameId, params);
}

class ArchiveCropName {
  ArchiveCropName(this._repository);
  final CropsRepository _repository;
  Future<CropNameEntity> call(String cropNameId) =>
      _repository.archiveName(cropNameId);
}

class ListCropCycles {
  ListCropCycles(this._repository);
  final CropsRepository _repository;
  Future<PagedResultEntity<CropCycleEntity>> call({bool includeArchived = false}) =>
      _repository.listCycles(includeArchived: includeArchived);
}

class GetCropCycle {
  GetCropCycle(this._repository);
  final CropsRepository _repository;
  Future<CropCycleEntity> call(String cycleId) => _repository.getCycle(cycleId);
}

class CreateCropCycle {
  CreateCropCycle(this._repository);
  final CropsRepository _repository;
  Future<CropCycleEntity> call(CropCycleWriteParamsEntity params) =>
      _repository.createCycle(params);
}

class UpdateCropCycle {
  UpdateCropCycle(this._repository);
  final CropsRepository _repository;
  Future<CropCycleEntity> call(String cycleId, CropCycleWriteParamsEntity params) =>
      _repository.updateCycle(cycleId, params);
}

class ArchiveCropCycle {
  ArchiveCropCycle(this._repository);
  final CropsRepository _repository;
  Future<CropCycleEntity> call(String cycleId) => _repository.archiveCycle(cycleId);
}

class GetCropCycleSummary {
  GetCropCycleSummary(this._repository);
  final CropsRepository _repository;
  Future<CycleSummaryEntity> call(String cycleId) =>
      _repository.getCycleSummary(cycleId);
}

class ListCropExpenses {
  ListCropExpenses(this._repository);
  final CropsRepository _repository;
  Future<PagedResultEntity<CropExpenseEntity>> call(String cycleId) =>
      _repository.listExpenses(cycleId);
}

class AddCropExpense {
  AddCropExpense(this._repository);
  final CropsRepository _repository;
  Future<CropExpenseEntity> call({
    required String cycleId,
    required String spentAt,
    required ExpenseCategoryEntity category,
    required String amount,
    String? note,
  }) =>
      _repository.addExpense(
        cycleId: cycleId,
        spentAt: spentAt,
        category: category,
        amount: amount,
        note: note,
      );
}

class ListHarvests {
  ListHarvests(this._repository);
  final CropsRepository _repository;
  Future<PagedResultEntity<HarvestEntity>> call(String cycleId) =>
      _repository.listHarvests(cycleId);
}

class AddHarvest {
  AddHarvest(this._repository);
  final CropsRepository _repository;
  Future<HarvestEntity> call({
    required String cycleId,
    required String harvestedAt,
    required String quantity,
    required String unit,
    String? saleAmount,
    String? note,
  }) =>
      _repository.addHarvest(
        cycleId: cycleId,
        harvestedAt: harvestedAt,
        quantity: quantity,
        unit: unit,
        saleAmount: saleAmount,
        note: note,
      );
}

class UpdateCropExpense {
  UpdateCropExpense(this._repository);
  final CropsRepository _repository;
  Future<CropExpenseEntity> call({
    required String cycleId,
    required String expenseId,
    required String spentAt,
    required ExpenseCategoryEntity category,
    required String amount,
    String? note,
  }) =>
      _repository.updateExpense(
        cycleId: cycleId,
        expenseId: expenseId,
        spentAt: spentAt,
        category: category,
        amount: amount,
        note: note,
      );
}

class DeleteCropExpense {
  DeleteCropExpense(this._repository);
  final CropsRepository _repository;
  Future<void> call(String cycleId, String expenseId) =>
      _repository.deleteExpense(cycleId, expenseId);
}

class UpdateHarvest {
  UpdateHarvest(this._repository);
  final CropsRepository _repository;
  Future<HarvestEntity> call({
    required String cycleId,
    required String harvestId,
    required String harvestedAt,
    required String quantity,
    required String unit,
    String? saleAmount,
    String? note,
  }) =>
      _repository.updateHarvest(
        cycleId: cycleId,
        harvestId: harvestId,
        harvestedAt: harvestedAt,
        quantity: quantity,
        unit: unit,
        saleAmount: saleAmount,
        note: note,
      );
}

class DeleteHarvest {
  DeleteHarvest(this._repository);
  final CropsRepository _repository;
  Future<void> call(String cycleId, String harvestId) =>
      _repository.deleteHarvest(cycleId, harvestId);
}
