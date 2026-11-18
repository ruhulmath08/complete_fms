import 'package:mobile/data/datasources/poultry/poultry_datasource.dart';
import 'package:mobile/data/mappers/poultry/poultry_mappers.dart';
import 'package:mobile/data/models/poultry/egg_production_model.dart';
import 'package:mobile/data/models/poultry/poultry_feeding_model.dart';
import 'package:mobile/data/models/poultry/poultry_group_model.dart';
import 'package:mobile/data/repositories/common/page_result_mapper.dart';
import 'package:mobile/domain/entities/common/paged_result.dart';
import 'package:mobile/domain/entities/poultry/egg_production.dart';
import 'package:mobile/domain/entities/poultry/poultry_feeding.dart';
import 'package:mobile/domain/entities/poultry/poultry_group.dart';
import 'package:mobile/domain/entities/poultry/poultry_group_write_params.dart';
import 'package:mobile/domain/repositories/poultry/poultry_repository.dart';

class PoultryRepositoryImpl implements PoultryRepository {
  PoultryRepositoryImpl(this._datasource);

  final PoultryDatasource _datasource;

  @override
  Future<PagedResult<PoultryGroup>> listGroups({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  }) async {
    final json = await _datasource.listGroups(
      limit: limit,
      offset: offset,
      includeArchived: includeArchived,
    );
    return mapPageResult(
      json,
      PoultryGroupModel.fromJson,
      mapPoultryGroupModel,
    );
  }

  @override
  Future<PoultryGroup> getGroup(String groupId) async {
    final model = PoultryGroupModel.fromJson(await _datasource.getGroup(groupId));
    return mapPoultryGroupModel(model);
  }

  @override
  Future<PoultryGroup> createGroup(PoultryGroupWriteParams params) async {
    final model = PoultryGroupModel.fromJson(
      await _datasource.createGroup(poultryGroupWriteToJson(params)),
    );
    return mapPoultryGroupModel(model);
  }

  @override
  Future<PoultryGroup> updateGroup(
    String groupId,
    PoultryGroupWriteParams params,
  ) async {
    final model = PoultryGroupModel.fromJson(
      await _datasource.updateGroup(groupId, poultryGroupWriteToJson(params)),
    );
    return mapPoultryGroupModel(model);
  }

  @override
  Future<PoultryGroup> archiveGroup(String groupId) async {
    final model = PoultryGroupModel.fromJson(await _datasource.archiveGroup(groupId));
    return mapPoultryGroupModel(model);
  }

  @override
  Future<PagedResult<EggProduction>> listEggs(
    String groupId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final json = await _datasource.listEggs(groupId, limit: limit, offset: offset);
    return mapPageResult(json, EggProductionModel.fromJson, mapEggModel);
  }

  @override
  Future<EggProduction> addEgg({
    required String groupId,
    required String producedAt,
    required String quantity,
    required String unit,
    required String pricePerUnit,
    String? note,
  }) async {
    final model = EggProductionModel.fromJson(
      await _datasource.addEgg(groupId, {
        'produced_at': producedAt,
        'quantity': quantity,
        'unit': unit,
        'price_per_unit': pricePerUnit,
        'note': note,
      }),
    );
    return mapEggModel(model);
  }

  @override
  Future<EggProduction> updateEgg({
    required String groupId,
    required String eggId,
    required String producedAt,
    required String quantity,
    required String unit,
    required String pricePerUnit,
    String? note,
  }) async {
    final model = EggProductionModel.fromJson(
      await _datasource.updateEgg(groupId, eggId, {
        'produced_at': producedAt,
        'quantity': quantity,
        'unit': unit,
        'price_per_unit': pricePerUnit,
        'note': note,
      }),
    );
    return mapEggModel(model);
  }

  @override
  Future<void> deleteEgg(String groupId, String eggId) =>
      _datasource.deleteEgg(groupId, eggId);

  @override
  Future<PagedResult<PoultryFeeding>> listFeedings(
    String groupId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final json = await _datasource.listFeedings(groupId, limit: limit, offset: offset);
    return mapPageResult(
      json,
      PoultryFeedingModel.fromJson,
      mapPoultryFeedingModel,
    );
  }

  @override
  Future<PoultryFeeding> addFeeding({
    required String groupId,
    required String fedAt,
    required String feedName,
    required String quantity,
    required String unit,
    String? note,
  }) async {
    final model = PoultryFeedingModel.fromJson(
      await _datasource.addFeeding(groupId, {
        'fed_at': fedAt,
        'feed_name': feedName,
        'quantity': quantity,
        'unit': unit,
        'note': note,
      }),
    );
    return mapPoultryFeedingModel(model);
  }

  @override
  Future<PoultryFeeding> updateFeeding({
    required String groupId,
    required String feedingId,
    required String fedAt,
    required String feedName,
    required String quantity,
    required String unit,
    String? note,
  }) async {
    final model = PoultryFeedingModel.fromJson(
      await _datasource.updateFeeding(groupId, feedingId, {
        'fed_at': fedAt,
        'feed_name': feedName,
        'quantity': quantity,
        'unit': unit,
        'note': note,
      }),
    );
    return mapPoultryFeedingModel(model);
  }

  @override
  Future<void> deleteFeeding(String groupId, String feedingId) =>
      _datasource.deleteFeeding(groupId, feedingId);
}
