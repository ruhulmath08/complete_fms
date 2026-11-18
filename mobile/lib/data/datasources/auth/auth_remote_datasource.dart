import 'package:dio/dio.dart';

abstract class AuthRemoteDatasource {
  Future<Map<String, dynamic>> signUp(FormData formData);

  Future<Map<String, dynamic>> signIn(String email, String password);

  Future<void> signOut(String? refreshToken);

  Future<Map<String, dynamic>> getMe();

  Future<Map<String, dynamic>> patchMe(FormData formData);

  Future<Map<String, dynamic>> getFarmSettings();

  Future<Map<String, dynamic>> patchFarmSettings(String currencyCode);

  Future<List<int>> getProfileImageBytes();
}
