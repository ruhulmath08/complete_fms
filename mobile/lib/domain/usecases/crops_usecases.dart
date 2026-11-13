import '../entities/crop.dart';
import '../repositories/crops_repository.dart';

class ListCropNames {
  ListCropNames(this._repository);
  final CropsRepository _repository;
  Future<PagedResult<CropName>> call({bool includeArchived = false}) =>
      _repository.listNames(includeArchived: includeArchived);
}

class GetCropName {
  GetCropName(this._repository);
  final CropsRepository _repository;
  Future<CropName> call(String cropNameId) => _repository.getName(cropNameId);
}

class CreateCropName {
  CreateCropName(this._repository);
  final CropsRepository _repository;
  Future<CropName> call(CropNameWriteParams params) =>
      _repository.createName(params);
}

class UpdateCropName {
  UpdateCropName(this._repository);
  final CropsRepository _repository;
  Future<CropName> call(String cropNameId, CropNameWriteParams params) =>
      _repository.updateName(cropNameId, params);
}

class ArchiveCropName {
  ArchiveCropName(this._repository);
  final CropsRepository _repository;
  Future<CropName> call(String cropNameId) =>
      _repository.archiveName(cropNameId);
}

class ListCropCycles {
  ListCropCycles(this._repository);
  final CropsRepository _repository;
  Future<PagedResult<CropCycle>> call({bool includeArchived = false}) =>
      _repository.listCycles(includeArchived: includeArchived);
}

class GetCropCycle {
  GetCropCycle(this._repository);
  final CropsRepository _repository;
  Future<CropCycle> call(String cycleId) => _repository.getCycle(cycleId);
}

class CreateCropCycle {
  CreateCropCycle(this._repository);
  final CropsRepository _repository;
  Future<CropCycle> call(CropCycleWriteParams params) =>
      _repository.createCycle(params);
}

class UpdateCropCycle {
  UpdateCropCycle(this._repository);
  final CropsRepository _repository;
  Future<CropCycle> call(String cycleId, CropCycleWriteParams params) =>
      _repository.updateCycle(cycleId, params);
}

class ArchiveCropCycle {
  ArchiveCropCycle(this._repository);
  final CropsRepository _repository;
  Future<CropCycle> call(String cycleId) => _repository.archiveCycle(cycleId);
}

class GetCropCycleSummary {
  GetCropCycleSummary(this._repository);
  final CropsRepository _repository;
  Future<CycleSummary> call(String cycleId) =>
      _repository.getCycleSummary(cycleId);
}

class ListCropExpenses {
  ListCropExpenses(this._repository);
  final CropsRepository _repository;
  Future<PagedResult<CropExpense>> call(String cycleId) =>
      _repository.listExpenses(cycleId);
}

class AddCropExpense {
  AddCropExpense(this._repository);
  final CropsRepository _repository;
  Future<CropExpense> call({
    required String cycleId,
    required String spentAt,
    required ExpenseCategory category,
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
  Future<PagedResult<Harvest>> call(String cycleId) =>
      _repository.listHarvests(cycleId);
}

class AddHarvest {
  AddHarvest(this._repository);
  final CropsRepository _repository;
  Future<Harvest> call({
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
  Future<CropExpense> call({
    required String cycleId,
    required String expenseId,
    required String spentAt,
    required ExpenseCategory category,
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
  Future<Harvest> call({
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
