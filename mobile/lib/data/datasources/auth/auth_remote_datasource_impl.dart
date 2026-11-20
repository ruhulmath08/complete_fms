import 'package:dio/dio.dart';
import 'package:mobile/data/datasources/auth/auth_remote_datasource.dart';
import 'package:mobile/data/network/api_client.dart';
import 'package:mobile/data/network/api_endpoints.dart';

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  AuthRemoteDatasourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> signUp(FormData formData) {
    return _client.post(ApiEndpoints.signUp, data: formData, auth: false);
  }

  @override
  Future<Map<String, dynamic>> signIn(String email, String password) {
    return _client.post(
      ApiEndpoints.signIn,
      data: {'email': email, 'password': password},
      auth: false,
    );
  }

  @override
  Future<void> signOut(String? refreshToken) {
    return _client.postVoid(
      ApiEndpoints.signOut,
      data: {'refresh_token': refreshToken},
    );
  }

  @override
  Future<Map<String, dynamic>> getMe() {
    return _client.get(ApiEndpoints.me);
  }

  @override
  Future<Map<String, dynamic>> patchMe(FormData formData) {
    return _client.patch(ApiEndpoints.me, data: formData);
  }

  @override
  Future<Map<String, dynamic>> getFarmSettings() {
    return _client.get(ApiEndpoints.farmSettings);
  }

  @override
  Future<Map<String, dynamic>> patchFarmSettings(String currencyCode) {
    return _client.patch(
      ApiEndpoints.farmSettings,
      data: {'currency_code': currencyCode},
    );
  }

  @override
  Future<List<int>> getProfileImageBytes() {
    return _client.getBytes(ApiEndpoints.profileImage);
  }
}
