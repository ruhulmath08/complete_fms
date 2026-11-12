import '../entities/cow.dart';

abstract class CowsRepository {
  Future<PagedResult<Cow>> listCows({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  });

  Future<Cow> getCow(String cowId);

  Future<Cow> createCow(CowWriteParams params);

  Future<Cow> updateCow(String cowId, CowWriteParams params);

  Future<Cow> archiveCow(String cowId);

  Future<Cow> uploadCowImage(String cowId, String imagePath);

  Future<List<int>> getCowImageBytes(String cowId);

  Future<PagedResult<MilkProduction>> listMilk(
    String cowId, {
    int limit = 10,
    int offset = 0,
  });

  Future<MilkProduction> addMilk({
    required String cowId,
    required String producedAt,
    required String quantity,
    required String unit,
    required String pricePerUnit,
    String? note,
  });

  Future<MilkProduction> updateMilk({
    required String cowId,
    required String milkId,
    required String producedAt,
    required String quantity,
    required String unit,
    required String pricePerUnit,
    String? note,
  });

  Future<void> deleteMilk(String cowId, String milkId);

  Future<PagedResult<CowFeeding>> listFeedings(
    String cowId, {
    int limit = 10,
    int offset = 0,
  });

  Future<CowFeeding> addFeeding({
    required String cowId,
    required String fedAt,
    required String feedName,
    required String quantity,
    required String unit,
    required String unitCost,
    String? note,
  });

  Future<CowFeeding> updateFeeding({
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
