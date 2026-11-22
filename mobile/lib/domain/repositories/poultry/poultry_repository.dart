import 'package:mobile/domain/entities/common/paged_result_entity.dart';
import 'package:mobile/domain/entities/poultry/egg_production_entity.dart';
import 'package:mobile/domain/entities/poultry/poultry_feeding_entity.dart';
import 'package:mobile/domain/entities/poultry/poultry_group_entity.dart';
import 'package:mobile/domain/entities/poultry/poultry_group_write_params_entity.dart';

abstract class PoultryRepository {
  Future<PagedResultEntity<PoultryGroupEntity>> listGroups({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  });

  Future<PoultryGroupEntity> getGroup(String groupId);

  Future<PoultryGroupEntity> createGroup(PoultryGroupWriteParamsEntity params);

  Future<PoultryGroupEntity> updateGroup(String groupId, PoultryGroupWriteParamsEntity params);

  Future<PoultryGroupEntity> archiveGroup(String groupId);

  Future<PagedResultEntity<EggProductionEntity>> listEggs(
    String groupId, {
    int limit = 50,
    int offset = 0,
  });

  Future<EggProductionEntity> addEgg({
    required String groupId,
    required String producedAt,
    required String quantity,
    required String unit,
    required String pricePerUnit,
    String? note,
  });

  Future<EggProductionEntity> updateEgg({
    required String groupId,
    required String eggId,
    required String producedAt,
    required String quantity,
    required String unit,
    required String pricePerUnit,
    String? note,
  });

  Future<void> deleteEgg(String groupId, String eggId);

  Future<PagedResultEntity<PoultryFeedingEntity>> listFeedings(
    String groupId, {
    int limit = 50,
    int offset = 0,
  });

  Future<PoultryFeedingEntity> addFeeding({
    required String groupId,
    required String fedAt,
    required String feedName,
    required String quantity,
    required String unit,
    String? note,
  });

  Future<PoultryFeedingEntity> updateFeeding({
    required String groupId,
    required String feedingId,
    required String fedAt,
    required String feedName,
    required String quantity,
    required String unit,
    String? note,
  });

  Future<void> deleteFeeding(String groupId, String feedingId);
}
