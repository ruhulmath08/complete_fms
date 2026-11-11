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
  Future<PagedResult<MilkProduction>> call(String cowId) =>
      _repository.listMilk(cowId);
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

class ListCowFeedings {
  ListCowFeedings(this._repository);
  final CowsRepository _repository;
  Future<PagedResult<CowFeeding>> call(String cowId) =>
      _repository.listFeedings(cowId);
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
    String? note,
  }) =>
      _repository.addFeeding(
        cowId: cowId,
        fedAt: fedAt,
        feedName: feedName,
        quantity: quantity,
        unit: unit,
        note: note,
      );
}
