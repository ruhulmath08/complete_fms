import '../entities/cow.dart';
import '../repositories/cows_repository.dart';

class ListCows {
  ListCows(this._repository);
  final CowsRepository _repository;
  Future<PagedResult<Cow>> call({bool includeArchived = false}) =>
      _repository.listCows(includeArchived: includeArchived);
}

class GetCow {
  GetCow(this._repository);
  final CowsRepository _repository;
  Future<Cow> call(String cowId) => _repository.getCow(cowId);
}

class CreateCow {
  CreateCow(this._repository);
  final CowsRepository _repository;
  Future<Cow> call(CowWriteParams params) => _repository.createCow(params);
}

class UpdateCow {
  UpdateCow(this._repository);
  final CowsRepository _repository;
  Future<Cow> call(String cowId, CowWriteParams params) =>
      _repository.updateCow(cowId, params);
}

class ArchiveCow {
  ArchiveCow(this._repository);
  final CowsRepository _repository;
  Future<Cow> call(String cowId) => _repository.archiveCow(cowId);
}

class UploadCowImage {
  UploadCowImage(this._repository);
  final CowsRepository _repository;
  Future<Cow> call(String cowId, String imagePath) =>
      _repository.uploadCowImage(cowId, imagePath);
}

class GetCowImageBytes {
  GetCowImageBytes(this._repository);
  final CowsRepository _repository;
  Future<List<int>> call(String cowId) => _repository.getCowImageBytes(cowId);
}

class ListMilkProductions {
  ListMilkProductions(this._repository);
  final CowsRepository _repository;
  Future<PagedResult<MilkProduction>> call(
    String cowId, {
    int limit = 10,
    int offset = 0,
  }) =>
      _repository.listMilk(cowId, limit: limit, offset: offset);
}

class AddMilkProduction {
  AddMilkProduction(this._repository);
  final CowsRepository _repository;
  Future<MilkProduction> call({
    required String cowId,
    required String producedAt,
    required String quantity,
    required String unit,
    required String pricePerUnit,
    String? note,
  }) =>
      _repository.addMilk(
        cowId: cowId,
        producedAt: producedAt,
        quantity: quantity,
        unit: unit,
        pricePerUnit: pricePerUnit,
        note: note,
      );
}

class UpdateMilkProduction {
  UpdateMilkProduction(this._repository);
  final CowsRepository _repository;
  Future<MilkProduction> call({
    required String cowId,
    required String milkId,
    required String producedAt,
    required String quantity,
    required String unit,
    required String pricePerUnit,
    String? note,
  }) =>
      _repository.updateMilk(
        cowId: cowId,
        milkId: milkId,
        producedAt: producedAt,
        quantity: quantity,
        unit: unit,
        pricePerUnit: pricePerUnit,
        note: note,
      );
}

class DeleteMilkProduction {
  DeleteMilkProduction(this._repository);
  final CowsRepository _repository;
  Future<void> call(String cowId, String milkId) =>
      _repository.deleteMilk(cowId, milkId);
}

class ListCowFeedings {
  ListCowFeedings(this._repository);
  final CowsRepository _repository;
  Future<PagedResult<CowFeeding>> call(
    String cowId, {
    int limit = 10,
    int offset = 0,
  }) =>
      _repository.listFeedings(cowId, limit: limit, offset: offset);
}

class AddCowFeeding {
  AddCowFeeding(this._repository);
  final CowsRepository _repository;
  Future<CowFeeding> call({
    required String cowId,
    required String fedAt,
    required String feedName,
    required String quantity,
    required String unit,
    required String unitCost,
    String? note,
  }) =>
      _repository.addFeeding(
        cowId: cowId,
        fedAt: fedAt,
        feedName: feedName,
        quantity: quantity,
        unit: unit,
        unitCost: unitCost,
        note: note,
      );
}

class UpdateCowFeeding {
  UpdateCowFeeding(this._repository);
  final CowsRepository _repository;
  Future<CowFeeding> call({
    required String cowId,
    required String feedingId,
    required String fedAt,
    required String feedName,
    required String quantity,
    required String unit,
    required String unitCost,
    String? note,
  }) =>
      _repository.updateFeeding(
        cowId: cowId,
        feedingId: feedingId,
        fedAt: fedAt,
        feedName: feedName,
        quantity: quantity,
        unit: unit,
        unitCost: unitCost,
        note: note,
      );
}

class DeleteCowFeeding {
  DeleteCowFeeding(this._repository);
  final CowsRepository _repository;
  Future<void> call(String cowId, String feedingId) =>
      _repository.deleteFeeding(cowId, feedingId);
}
