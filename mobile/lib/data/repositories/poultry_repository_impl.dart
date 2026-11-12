import '../../domain/entities/poultry.dart';
import '../../domain/repositories/poultry_repository.dart';
import '../datasources/poultry_api.dart';
import '../mappers/poultry_mappers.dart';

class PoultryRepositoryImpl implements PoultryRepository {
  PoultryRepositoryImpl(this._api);

  final PoultryApi _api;

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
  Future<PagedResult<PoultryGroup>> listGroups({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  }) async {
    final json = await _api.listGroups(
      limit: limit,
      offset: offset,
      includeArchived: includeArchived,
    );
    return _page(json, mapPoultryGroup);
  }

  @override
  Future<PoultryGroup> getGroup(String groupId) async =>
      mapPoultryGroup(await _api.getGroup(groupId));

  @override
  Future<PoultryGroup> createGroup(PoultryGroupWriteParams params) async =>
      mapPoultryGroup(await _api.createGroup(poultryGroupWriteToJson(params)));

  @override
  Future<PoultryGroup> updateGroup(
    String groupId,
    PoultryGroupWriteParams params,
  ) async =>
      mapPoultryGroup(
        await _api.updateGroup(groupId, poultryGroupWriteToJson(params)),
      );

  @override
  Future<PoultryGroup> archiveGroup(String groupId) async =>
      mapPoultryGroup(await _api.archiveGroup(groupId));

  @override
  Future<PagedResult<EggProduction>> listEggs(
    String groupId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final json = await _api.listEggs(groupId, limit: limit, offset: offset);
    return _page(json, mapEgg);
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
    final json = await _api.addEgg(groupId, {
      'produced_at': producedAt,
      'quantity': quantity,
      'unit': unit,
      'price_per_unit': pricePerUnit,
      'note': note,
    });
    return mapEgg(json);
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
    final json = await _api.updateEgg(groupId, eggId, {
      'produced_at': producedAt,
      'quantity': quantity,
      'unit': unit,
      'price_per_unit': pricePerUnit,
      'note': note,
    });
    return mapEgg(json);
  }

  @override
  Future<void> deleteEgg(String groupId, String eggId) =>
      _api.deleteEgg(groupId, eggId);

  @override
  Future<PagedResult<PoultryFeeding>> listFeedings(
    String groupId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final json = await _api.listFeedings(groupId, limit: limit, offset: offset);
    return _page(json, mapPoultryFeeding);
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
    final json = await _api.addFeeding(groupId, {
      'fed_at': fedAt,
      'feed_name': feedName,
      'quantity': quantity,
      'unit': unit,
      'note': note,
    });
    return mapPoultryFeeding(json);
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
    final json = await _api.updateFeeding(groupId, feedingId, {
      'fed_at': fedAt,
      'feed_name': feedName,
      'quantity': quantity,
      'unit': unit,
      'note': note,
    });
    return mapPoultryFeeding(json);
  }

  @override
  Future<void> deleteFeeding(String groupId, String feedingId) =>
      _api.deleteFeeding(groupId, feedingId);
}
