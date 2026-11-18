abstract class PoultryDatasource {
  Future<Map<String, dynamic>> listGroups({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  });

  Future<Map<String, dynamic>> getGroup(String groupId);

  Future<Map<String, dynamic>> createGroup(Map<String, dynamic> body);

  Future<Map<String, dynamic>> updateGroup(
    String groupId,
    Map<String, dynamic> body,
  );

  Future<Map<String, dynamic>> archiveGroup(String groupId);

  Future<Map<String, dynamic>> listEggs(
    String groupId, {
    int limit = 50,
    int offset = 0,
  });

  Future<Map<String, dynamic>> addEgg(
    String groupId,
    Map<String, dynamic> body,
  );

  Future<Map<String, dynamic>> updateEgg(
    String groupId,
    String eggId,
    Map<String, dynamic> body,
  );

  Future<void> deleteEgg(String groupId, String eggId);

  Future<Map<String, dynamic>> listFeedings(
    String groupId, {
    int limit = 50,
    int offset = 0,
  });

  Future<Map<String, dynamic>> addFeeding(
    String groupId,
    Map<String, dynamic> body,
  );

  Future<Map<String, dynamic>> updateFeeding(
    String groupId,
    String feedingId,
    Map<String, dynamic> body,
  );

  Future<void> deleteFeeding(String groupId, String feedingId);
}
