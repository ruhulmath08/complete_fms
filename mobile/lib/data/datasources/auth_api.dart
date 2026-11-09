import 'package:dio/dio.dart';
import '../../domain/failures.dart';
import '../../infrastructure/config/api_config.dart';
import 'token_store.dart';

class AuthApi {
  AuthApi(this._tokenStore) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Accept': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.extra['auth'] != false) {
            final token = await _tokenStore.readAccess();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final status = error.response?.statusCode;
          final request = error.requestOptions;
          if (status == 401 &&
              request.extra['auth'] != false &&
              request.extra['retried'] != true) {
            final refreshed = await _refresh();
            if (refreshed) {
              final token = await _tokenStore.readAccess();
              final opts = request.copyWith(
                headers: Map<String, dynamic>.from(request.headers)
                  ..['Authorization'] = 'Bearer $token',
                extra: Map<String, dynamic>.from(request.extra)
                  ..['retried'] = true,
              );
              try {
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  late final Dio _dio;
  final TokenStore _tokenStore;

  Future<bool> _refresh() async {
    final refresh = await _tokenStore.readRefresh();
    if (refresh == null) return false;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/refresh',
        data: {'refresh_token': refresh},
        options: Options(extra: {'auth': false}),
      );
      final data = response.data!;
      await _tokenStore.save(
        access: data['access_token'] as String,
        refresh: data['refresh_token'] as String,
      );
      return true;
    } catch (_) {
      await _tokenStore.clear();
      return false;
    }
  }

  Never _throwDio(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      throw AppFailure(
        code: data['code'] as String? ?? 'HTTP_ERROR',
        message: data['message'] as String? ?? 'Request failed.',
      );
    }
    throw AppFailure(code: 'HTTP_ERROR', message: e.message ?? 'Request failed.');
  }

  Future<Map<String, dynamic>> signUp(FormData formData) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/signup',
        data: formData,
        options: Options(extra: {'auth': false}),
      );
      return response.data!;
    } on DioException catch (e) {
      _throwDio(e);
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
      _throwDio(e);
    }
  }

  Future<void> signOut(String? refreshToken) async {
    try {
      await _dio.post<void>(
        '/api/v1/auth/signout',
        data: {'refresh_token': refreshToken},
      );
    } on DioException catch (e) {
      _throwDio(e);
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/v1/me');
      return response.data!;
    } on DioException catch (e) {
      _throwDio(e);
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
      _throwDio(e);
    }
  }

  Future<Map<String, dynamic>> getFarmSettings() async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('/api/v1/farm-settings');
      return response.data!;
    } on DioException catch (e) {
      _throwDio(e);
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
      _throwDio(e);
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
      _throwDio(e);
    }
  }
}
