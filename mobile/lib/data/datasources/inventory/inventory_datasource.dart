abstract class InventoryDatasource {
  Future<Map<String, dynamic>> listItems({
    int limit = 100,
    int offset = 0,
    bool includeArchived = false,
  });

  Future<Map<String, dynamic>> getItem(String itemId);

  Future<Map<String, dynamic>> createItem(Map<String, dynamic> body);

  Future<Map<String, dynamic>> updateItem(
    String itemId,
    Map<String, dynamic> body,
  );

  Future<Map<String, dynamic>> archiveItem(String itemId);

  Future<Map<String, dynamic>> listStockUpdates(
    String itemId, {
    int limit = 50,
    int offset = 0,
  });

  Future<Map<String, dynamic>> addStockUpdate(
    String itemId,
    Map<String, dynamic> body,
  );

  Future<Map<String, dynamic>> listStockUpdatesByCategory({
    required String category,
    int limit = 10,
    int offset = 0,
  });
}
