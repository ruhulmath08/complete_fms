import 'package:dio/dio.dart';

import '../../domain/entities/cow.dart';
import '../../domain/repositories/cows_repository.dart';
import '../datasources/cows_api.dart';
import '../mappers/cows_mappers.dart';

class CowsRepositoryImpl implements CowsRepository {
  CowsRepositoryImpl(this._api);

  final CowsApi _api;

  PagedResult<T> _page<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) mapItem,
  ) {
    final items = (json['items'] as List<dynamic>)
        .map((e) => mapItem(e as Map<String, dynamic>))
        .toList();
    final meta = json['meta'] as Map<String, dynamic>;
    return PagedResult(
      items: items,
      total: meta['total'] as int,
      limit: meta['limit'] as int,
      offset: meta['offset'] as int,
    );
  }

  @override
  Future<PagedResult<Cow>> listCows({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  }) async {
    final json = await _api.listCows(
      limit: limit,
      offset: offset,
      includeArchived: includeArchived,
    );
    return _page(json, mapCow);
  }

  @override
  Future<Cow> getCow(String cowId) async => mapCow(await _api.getCow(cowId));

  @override
  Future<Cow> createCow(CowWriteParams params) async =>
      mapCow(await _api.createCow(cowWriteToJson(params)));

  @override
  Future<Cow> updateCow(String cowId, CowWriteParams params) async =>
      mapCow(await _api.updateCow(cowId, cowWriteToJson(params)));

  @override
  Future<Cow> archiveCow(String cowId) async =>
      mapCow(await _api.archiveCow(cowId));

  @override
  Future<Cow> uploadCowImage(String cowId, String imagePath) async {
    final form = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath),
    });
    return mapCow(await _api.uploadCowImage(cowId, form));
  }

  @override
  Future<List<int>> getCowImageBytes(String cowId) =>
      _api.getCowImageBytes(cowId);

  @override
  Future<PagedResult<MilkProduction>> listMilk(
    String cowId, {
    int limit = 10,
    int offset = 0,
  }) async {
    final json = await _api.listMilk(cowId, limit: limit, offset: offset);
    return _page(json, mapMilk);
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
    final json = await _api.addMilk(cowId, {
      'produced_at': producedAt,
      'quantity': quantity,
      'unit': unit,
      'price_per_unit': pricePerUnit,
      'note': note,
    });
    return mapMilk(json);
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
    final json = await _api.updateMilk(cowId, milkId, {
      'produced_at': producedAt,
      'quantity': quantity,
      'unit': unit,
      'price_per_unit': pricePerUnit,
      'note': note,
    });
    return mapMilk(json);
  }

  @override
  Future<void> deleteMilk(String cowId, String milkId) =>
      _api.deleteMilk(cowId, milkId);

  @override
  Future<PagedResult<CowFeeding>> listFeedings(
    String cowId, {
    int limit = 10,
    int offset = 0,
  }) async {
    final json = await _api.listFeedings(cowId, limit: limit, offset: offset);
    return _page(json, mapFeeding);
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
    final json = await _api.addFeeding(cowId, {
      'fed_at': fedAt,
      'feed_name': feedName,
      'quantity': quantity,
      'unit': unit,
      'unit_cost': unitCost,
      'note': note,
    });
    return mapFeeding(json);
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
    final json = await _api.updateFeeding(cowId, feedingId, {
      'fed_at': fedAt,
      'feed_name': feedName,
      'quantity': quantity,
      'unit': unit,
      'unit_cost': unitCost,
      'note': note,
    });
    return mapFeeding(json);
  }

  @override
  Future<void> deleteFeeding(String cowId, String feedingId) =>
      _api.deleteFeeding(cowId, feedingId);
}
