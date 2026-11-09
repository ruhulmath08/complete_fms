import '../../domain/entities/crop.dart';
import '../../domain/repositories/crops_repository.dart';
import '../datasources/crops_api.dart';
import '../mappers/crops_mappers.dart';

class CropsRepositoryImpl implements CropsRepository {
  CropsRepositoryImpl(this._api);

  final CropsApi _api;

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
  Future<PagedResult<CropName>> listNames({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  }) async {
    final json = await _api.listNames(
      limit: limit,
      offset: offset,
      includeArchived: includeArchived,
    );
    return _page(json, mapCropName);
  }

  @override
  Future<CropName> getName(String cropNameId) async =>
      mapCropName(await _api.getName(cropNameId));

  @override
  Future<CropName> createName(CropNameWriteParams params) async =>
      mapCropName(await _api.createName(cropNameWriteToJson(params)));

  @override
  Future<CropName> updateName(
    String cropNameId,
    CropNameWriteParams params,
  ) async =>
      mapCropName(
        await _api.updateName(cropNameId, cropNameWriteToJson(params)),
      );

  @override
  Future<CropName> archiveName(String cropNameId) async =>
      mapCropName(await _api.archiveName(cropNameId));

  @override
  Future<PagedResult<CropCycle>> listCycles({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  }) async {
    final json = await _api.listCycles(
      limit: limit,
      offset: offset,
      includeArchived: includeArchived,
    );
    return _page(json, mapCropCycle);
  }

  @override
  Future<CropCycle> getCycle(String cycleId) async =>
      mapCropCycle(await _api.getCycle(cycleId));

  @override
  Future<CropCycle> createCycle(CropCycleWriteParams params) async =>
      mapCropCycle(await _api.createCycle(cropCycleWriteToJson(params)));

  @override
  Future<CropCycle> updateCycle(
    String cycleId,
    CropCycleWriteParams params,
  ) async =>
      mapCropCycle(
        await _api.updateCycle(cycleId, cropCycleWriteToJson(params)),
      );

  @override
  Future<CropCycle> archiveCycle(String cycleId) async =>
      mapCropCycle(await _api.archiveCycle(cycleId));

  @override
  Future<CycleSummary> getCycleSummary(String cycleId) async =>
      mapCycleSummary(await _api.getCycleSummary(cycleId));

  @override
  Future<PagedResult<CropExpense>> listExpenses(
    String cycleId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final json = await _api.listExpenses(cycleId, limit: limit, offset: offset);
    return _page(json, mapCropExpense);
  }

  @override
  Future<CropExpense> addExpense({
    required String cycleId,
    required String spentAt,
    required ExpenseCategory category,
    required String amount,
    String? note,
  }) async {
    final json = await _api.addExpense(cycleId, {
      'spent_at': spentAt,
      'category': expenseCategoryToApi(category),
      'amount': amount,
      'note': note,
    });
    return mapCropExpense(json);
  }

  @override
  Future<PagedResult<Harvest>> listHarvests(
    String cycleId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final json = await _api.listHarvests(cycleId, limit: limit, offset: offset);
    return _page(json, mapHarvest);
  }

  @override
  Future<Harvest> addHarvest({
    required String cycleId,
    required String harvestedAt,
    required String quantity,
    required String unit,
    String? saleAmount,
    String? note,
  }) async {
    final json = await _api.addHarvest(cycleId, {
      'harvested_at': harvestedAt,
      'quantity': quantity,
      'unit': unit,
      'sale_amount': saleAmount,
      'note': note,
    });
    return mapHarvest(json);
  }
}
