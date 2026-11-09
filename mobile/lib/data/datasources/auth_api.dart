import 'package:dio/dio.dart';
import 'api_client.dart';

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Dio get _dio => _client.dio;

  Future<Map<String, dynamic>> signUp(FormData formData) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/signup',
        data: formData,
        options: Options(extra: {'auth': false}),
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/signin',
        data: {'email': email, 'password': password},
        options: Options(extra: {'auth': false}),
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<void> signOut(String? refreshToken) async {
    try {
      await _dio.post<void>(
        '/api/v1/auth/signout',
        data: {'refresh_token': refreshToken},
      );
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/v1/me');
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> patchMe(FormData formData) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/v1/me',
        data: formData,
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> getFarmSettings() async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('/api/v1/farm-settings');
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<Map<String, dynamic>> patchFarmSettings(String currencyCode) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/v1/farm-settings',
        data: {'currency_code': currencyCode},
      );
      return response.data!;
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }

  Future<List<int>> getProfileImageBytes() async {
    try {
      final response = await _dio.get<List<int>>(
        '/api/v1/me/profile-image',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data ?? <int>[];
    } on DioException catch (e) {
      _client.throwDio(e);
    }
  }
}
