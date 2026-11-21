import 'package:mobile/domain/repositories/poultry/poultry_repository.dart';
import 'package:mobile/domain/entities/common/paged_result_entity.dart';
import 'package:mobile/domain/entities/poultry/egg_production_entity.dart';
import 'package:mobile/domain/entities/poultry/poultry_feeding_entity.dart';
import 'package:mobile/domain/entities/poultry/poultry_group_entity.dart';
import 'package:mobile/domain/entities/poultry/poultry_group_write_params_entity.dart';

class ListPoultryGroups {
  ListPoultryGroups(this._repository);
  final PoultryRepository _repository;
  Future<PagedResultEntity<PoultryGroupEntity>> call({bool includeArchived = false}) =>
      _repository.listGroups(includeArchived: includeArchived);
}

class GetPoultryGroup {
  GetPoultryGroup(this._repository);
  final PoultryRepository _repository;
  Future<PoultryGroupEntity> call(String groupId) => _repository.getGroup(groupId);
}

class CreatePoultryGroup {
  CreatePoultryGroup(this._repository);
  final PoultryRepository _repository;
  Future<PoultryGroupEntity> call(PoultryGroupWriteParamsEntity params) =>
      _repository.createGroup(params);
}

class UpdatePoultryGroup {
  UpdatePoultryGroup(this._repository);
  final PoultryRepository _repository;
  Future<PoultryGroupEntity> call(String groupId, PoultryGroupWriteParamsEntity params) =>
      _repository.updateGroup(groupId, params);
}

class ArchivePoultryGroup {
  ArchivePoultryGroup(this._repository);
  final PoultryRepository _repository;
  Future<PoultryGroupEntity> call(String groupId) => _repository.archiveGroup(groupId);
}

class ListEggProductions {
  ListEggProductions(this._repository);
  final PoultryRepository _repository;
  Future<PagedResultEntity<EggProductionEntity>> call(String groupId) =>
      _repository.listEggs(groupId);
}

class AddEggProduction {
  AddEggProduction(this._repository);
  final PoultryRepository _repository;
  Future<EggProductionEntity> call({
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

class UpdateEggProduction {
  UpdateEggProduction(this._repository);
  final PoultryRepository _repository;
  Future<EggProductionEntity> call({
    required String groupId,
    required String eggId,
    required String producedAt,
    required String quantity,
    required String unit,
    required String pricePerUnit,
    String? note,
  }) =>
      _repository.updateEgg(
        groupId: groupId,
        eggId: eggId,
        producedAt: producedAt,
        quantity: quantity,
        unit: unit,
        pricePerUnit: pricePerUnit,
        note: note,
      );
}

class DeleteEggProduction {
  DeleteEggProduction(this._repository);
  final PoultryRepository _repository;
  Future<void> call(String groupId, String eggId) =>
      _repository.deleteEgg(groupId, eggId);
}

class ListPoultryFeedings {
  ListPoultryFeedings(this._repository);
  final PoultryRepository _repository;
  Future<PagedResultEntity<PoultryFeedingEntity>> call(String groupId) =>
      _repository.listFeedings(groupId);
}

class AddPoultryFeeding {
  AddPoultryFeeding(this._repository);
  final PoultryRepository _repository;
  Future<PoultryFeedingEntity> call({
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

class UpdatePoultryFeeding {
  UpdatePoultryFeeding(this._repository);
  final PoultryRepository _repository;
  Future<PoultryFeedingEntity> call({
    required String groupId,
    required String feedingId,
    required String fedAt,
    required String feedName,
    required String quantity,
    required String unit,
    String? note,
  }) =>
      _repository.updateFeeding(
        groupId: groupId,
        feedingId: feedingId,
        fedAt: fedAt,
        feedName: feedName,
        quantity: quantity,
        unit: unit,
        note: note,
      );
}

class DeletePoultryFeeding {
  DeletePoultryFeeding(this._repository);
  final PoultryRepository _repository;
  Future<void> call(String groupId, String feedingId) =>
      _repository.deleteFeeding(groupId, feedingId);
}
