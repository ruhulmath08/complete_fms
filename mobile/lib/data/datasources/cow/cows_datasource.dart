import 'package:dio/dio.dart';

abstract class CowsDatasource {
  Future<Map<String, dynamic>> listCows({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  });

  Future<Map<String, dynamic>> getCow(String cowId);

  Future<Map<String, dynamic>> createCow(Map<String, dynamic> body);

  Future<Map<String, dynamic>> updateCow(
    String cowId,
    Map<String, dynamic> body,
  );

  Future<Map<String, dynamic>> archiveCow(String cowId);

  Future<Map<String, dynamic>> uploadCowImage(String cowId, FormData formData);

  Future<List<int>> getCowImageBytes(String cowId);

  Future<Map<String, dynamic>> listMilk(
    String cowId, {
    int limit = 10,
    int offset = 0,
  });

  Future<Map<String, dynamic>> addMilk(String cowId, Map<String, dynamic> body);

  Future<Map<String, dynamic>> updateMilk(
    String cowId,
    String milkId,
    Map<String, dynamic> body,
  );

  Future<void> deleteMilk(String cowId, String milkId);

  Future<Map<String, dynamic>> listFeedings(
    String cowId, {
    int limit = 10,
    int offset = 0,
  });

  Future<Map<String, dynamic>> addFeeding(
    String cowId,
    Map<String, dynamic> body,
  );

  Future<Map<String, dynamic>> updateFeeding(
    String cowId,
    String feedingId,
    Map<String, dynamic> body,
  );

  Future<void> deleteFeeding(String cowId, String feedingId);
}
