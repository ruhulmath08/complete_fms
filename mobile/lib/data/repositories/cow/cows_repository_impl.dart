import 'package:dio/dio.dart';
import 'package:mobile/data/datasources/cow/cows_datasource.dart';
import 'package:mobile/data/mappers/cow/cows_mappers.dart';
import 'package:mobile/data/models/cow/cow_feeding_model.dart';
import 'package:mobile/data/models/cow/cow_model.dart';
import 'package:mobile/data/models/cow/milk_production_model.dart';
import 'package:mobile/data/repositories/common/page_result_mapper.dart';
import 'package:mobile/domain/entities/common/paged_result.dart';
import 'package:mobile/domain/entities/cow/cow.dart';
import 'package:mobile/domain/entities/cow/cow_feeding.dart';
import 'package:mobile/domain/entities/cow/cow_write_params.dart';
import 'package:mobile/domain/entities/cow/milk_production.dart';
import 'package:mobile/domain/repositories/cow/cows_repository.dart';

class CowsRepositoryImpl implements CowsRepository {
  CowsRepositoryImpl(this._datasource);

  final CowsDatasource _datasource;

  @override
  Future<PagedResult<Cow>> listCows({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  }) async {
    final json = await _datasource.listCows(
      limit: limit,
      offset: offset,
      includeArchived: includeArchived,
    );
    return mapPageResult(json, CowModel.fromJson, mapCowModel);
  }

  @override
  Future<Cow> getCow(String cowId) async {
    final model = CowModel.fromJson(await _datasource.getCow(cowId));
    return mapCowModel(model);
  }

  @override
  Future<Cow> createCow(CowWriteParams params) async {
    final model = CowModel.fromJson(
      await _datasource.createCow(cowWriteToJson(params)),
    );
    return mapCowModel(model);
  }

  @override
  Future<Cow> updateCow(String cowId, CowWriteParams params) async {
    final model = CowModel.fromJson(
      await _datasource.updateCow(cowId, cowWriteToJson(params)),
    );
    return mapCowModel(model);
  }

  @override
  Future<Cow> archiveCow(String cowId) async {
    final model = CowModel.fromJson(await _datasource.archiveCow(cowId));
    return mapCowModel(model);
  }

  @override
  Future<Cow> uploadCowImage(String cowId, String imagePath) async {
    final form = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath),
    });
    final model = CowModel.fromJson(await _datasource.uploadCowImage(cowId, form));
    return mapCowModel(model);
  }

  @override
  Future<List<int>> getCowImageBytes(String cowId) =>
      _datasource.getCowImageBytes(cowId);

  @override
  Future<PagedResult<MilkProduction>> listMilk(
    String cowId, {
    int limit = 10,
    int offset = 0,
  }) async {
    final json = await _datasource.listMilk(cowId, limit: limit, offset: offset);
    return mapPageResult(json, MilkProductionModel.fromJson, mapMilkModel);
  }

  @override
  Future<MilkProduction> addMilk({
    required String cowId,
    required String producedAt,
    required String quantity,
    required String unit,
    required String pricePerUnit,
    String? note,
  }) async {
    final model = MilkProductionModel.fromJson(
      await _datasource.addMilk(cowId, {
        'produced_at': producedAt,
        'quantity': quantity,
        'unit': unit,
        'price_per_unit': pricePerUnit,
        'note': note,
      }),
    );
    return mapMilkModel(model);
  }

  @override
  Future<MilkProduction> updateMilk({
    required String cowId,
    required String milkId,
    required String producedAt,
    required String quantity,
    required String unit,
    required String pricePerUnit,
    String? note,
  }) async {
    final model = MilkProductionModel.fromJson(
      await _datasource.updateMilk(cowId, milkId, {
        'produced_at': producedAt,
        'quantity': quantity,
        'unit': unit,
        'price_per_unit': pricePerUnit,
        'note': note,
      }),
    );
    return mapMilkModel(model);
  }

  @override
  Future<void> deleteMilk(String cowId, String milkId) =>
      _datasource.deleteMilk(cowId, milkId);

  @override
  Future<PagedResult<CowFeeding>> listFeedings(
    String cowId, {
    int limit = 10,
    int offset = 0,
  }) async {
    final json = await _datasource.listFeedings(cowId, limit: limit, offset: offset);
    return mapPageResult(json, CowFeedingModel.fromJson, mapFeedingModel);
  }

  @override
  Future<CowFeeding> addFeeding({
    required String cowId,
    required String fedAt,
    required String feedName,
    required String quantity,
    required String unit,
    required String unitCost,
    String? note,
  }) async {
    final model = CowFeedingModel.fromJson(
      await _datasource.addFeeding(cowId, {
        'fed_at': fedAt,
        'feed_name': feedName,
        'quantity': quantity,
        'unit': unit,
        'unit_cost': unitCost,
        'note': note,
      }),
    );
    return mapFeedingModel(model);
  }

  @override
  Future<CowFeeding> updateFeeding({
    required String cowId,
    required String feedingId,
    required String fedAt,
    required String feedName,
    required String quantity,
    required String unit,
    required String unitCost,
    String? note,
  }) async {
    final model = CowFeedingModel.fromJson(
      await _datasource.updateFeeding(cowId, feedingId, {
        'fed_at': fedAt,
        'feed_name': feedName,
        'quantity': quantity,
        'unit': unit,
        'unit_cost': unitCost,
        'note': note,
      }),
    );
    return mapFeedingModel(model);
  }

  @override
  Future<void> deleteFeeding(String cowId, String feedingId) =>
      _datasource.deleteFeeding(cowId, feedingId);
}
