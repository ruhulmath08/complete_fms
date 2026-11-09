import '../entities/poultry.dart';
import '../repositories/poultry_repository.dart';

class ListPoultryGroups {
  ListPoultryGroups(this._repository);
  final PoultryRepository _repository;
  Future<PagedResult<PoultryGroup>> call({bool includeArchived = false}) =>
      _repository.listGroups(includeArchived: includeArchived);
}

class GetPoultryGroup {
  GetPoultryGroup(this._repository);
  final PoultryRepository _repository;
  Future<PoultryGroup> call(String groupId) => _repository.getGroup(groupId);
}

class CreatePoultryGroup {
  CreatePoultryGroup(this._repository);
  final PoultryRepository _repository;
  Future<PoultryGroup> call(PoultryGroupWriteParams params) =>
      _repository.createGroup(params);
}

class UpdatePoultryGroup {
  UpdatePoultryGroup(this._repository);
  final PoultryRepository _repository;
  Future<PoultryGroup> call(String groupId, PoultryGroupWriteParams params) =>
      _repository.updateGroup(groupId, params);
}

class ArchivePoultryGroup {
  ArchivePoultryGroup(this._repository);
  final PoultryRepository _repository;
  Future<PoultryGroup> call(String groupId) => _repository.archiveGroup(groupId);
}

class ListEggProductions {
  ListEggProductions(this._repository);
  final PoultryRepository _repository;
  Future<PagedResult<EggProduction>> call(String groupId) =>
      _repository.listEggs(groupId);
}

class AddEggProduction {
  AddEggProduction(this._repository);
  final PoultryRepository _repository;
  Future<EggProduction> call({
    required String groupId,
    required String producedAt,
    required String quantity,
    required String unit,
    required String pricePerUnit,
    String? note,
  }) =>
      _repository.addEgg(
        groupId: groupId,
        producedAt: producedAt,
        quantity: quantity,
        unit: unit,
        pricePerUnit: pricePerUnit,
        note: note,
      );
}

class ListPoultryFeedings {
  ListPoultryFeedings(this._repository);
  final PoultryRepository _repository;
  Future<PagedResult<PoultryFeeding>> call(String groupId) =>
      _repository.listFeedings(groupId);
}

class AddPoultryFeeding {
  AddPoultryFeeding(this._repository);
  final PoultryRepository _repository;
  Future<PoultryFeeding> call({
    required String groupId,
    required String fedAt,
    required String feedName,
    required String quantity,
    required String unit,
    String? note,
  }) =>
      _repository.addFeeding(
        groupId: groupId,
        fedAt: fedAt,
        feedName: feedName,
        quantity: quantity,
        unit: unit,
        note: note,
      );
}
