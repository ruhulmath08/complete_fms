abstract class AuthLocalDatasource {
  Future<void> saveTokens({required String access, required String refresh});

  Future<String?> readAccessToken();

  Future<String?> readRefreshToken();

  Future<bool> hasAccessToken();

  Future<void> clearTokens();
}
