import 'package:mobile/domain/entities/common/paged_result_entity.dart';
import 'package:mobile/domain/entities/cow/cow_entity.dart';
import 'package:mobile/domain/entities/cow/cow_feeding_entity.dart';
import 'package:mobile/domain/entities/cow/cow_write_params_entity.dart';
import 'package:mobile/domain/entities/cow/milk_production_entity.dart';

abstract class CowsRepository {
  Future<PagedResultEntity<CowEntity>> listCows({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  });

  Future<CowEntity> getCow(String cowId);

  Future<CowEntity> createCow(CowWriteParamsEntity params);

  Future<CowEntity> updateCow(String cowId, CowWriteParamsEntity params);

  Future<CowEntity> archiveCow(String cowId);

  Future<CowEntity> uploadCowImage(String cowId, String imagePath);

  Future<List<int>> getCowImageBytes(String cowId);

  Future<PagedResultEntity<MilkProductionEntity>> listMilk(
    String cowId, {
    int limit = 10,
    int offset = 0,
  });

  Future<MilkProductionEntity> addMilk({
    required String cowId,
    required String producedAt,
    required String quantity,
    required String unit,
    required String pricePerUnit,
    String? note,
  });

  Future<MilkProductionEntity> updateMilk({
    required String cowId,
    required String milkId,
    required String producedAt,
    required String quantity,
    required String unit,
    required String pricePerUnit,
    String? note,
  });

  Future<void> deleteMilk(String cowId, String milkId);

  Future<PagedResultEntity<CowFeedingEntity>> listFeedings(
    String cowId, {
    int limit = 10,
    int offset = 0,
  });

  Future<CowFeedingEntity> addFeeding({
    required String cowId,
    required String fedAt,
    required String feedName,
    required String quantity,
    required String unit,
    required String unitCost,
    String? note,
  });

  Future<CowFeedingEntity> updateFeeding({
    required String cowId,
    required String feedingId,
    required String fedAt,
    required String feedName,
    required String quantity,
    required String unit,
    required String unitCost,
    String? note,
  });

  Future<void> deleteFeeding(String cowId, String feedingId);
}
