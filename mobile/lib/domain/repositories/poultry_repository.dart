import '../entities/poultry.dart';

abstract class PoultryRepository {
  Future<PagedResult<PoultryGroup>> listGroups({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  });

  Future<PoultryGroup> getGroup(String groupId);

  Future<PoultryGroup> createGroup(PoultryGroupWriteParams params);

  Future<PoultryGroup> updateGroup(String groupId, PoultryGroupWriteParams params);

  Future<PoultryGroup> archiveGroup(String groupId);

  Future<PagedResult<EggProduction>> listEggs(
    String groupId, {
    int limit = 50,
    int offset = 0,
  });

  Future<EggProduction> addEgg({
    required String groupId,
    required String producedAt,
    required String quantity,
    required String unit,
    required String pricePerUnit,
    String? note,
  });

  Future<PagedResult<PoultryFeeding>> listFeedings(
    String groupId, {
    int limit = 50,
    int offset = 0,
  });

  Future<PoultryFeeding> addFeeding({
    required String groupId,
    required String fedAt,
    required String feedName,
    required String quantity,
    required String unit,
    String? note,
  });
}
