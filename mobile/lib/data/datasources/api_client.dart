import 'package:dio/dio.dart';
import '../../domain/failures.dart';
import '../../infrastructure/config/api_config.dart';
import 'token_store.dart';

class ApiClient {
  ApiClient(this._tokenStore) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Accept': 'application/json'},
      ),
    );
    dio.interceptors.add(
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
                final response = await dio.fetch(opts);
                return handler.resolve(response);
              } catch (_) {
                return handler.next(error);
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  late final Dio dio;
  final TokenStore _tokenStore;

  Future<bool> _refresh() async {
    final refresh = await _tokenStore.readRefresh();
    if (refresh == null) return false;
    try {
      final response = await dio.post<Map<String, dynamic>>(
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

  Never throwDio(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      throw AppFailure(
        code: data['code'] as String? ?? 'HTTP_ERROR',
        message: data['message'] as String? ?? 'Request failed.',
      );
    }
    throw AppFailure(code: 'HTTP_ERROR', message: e.message ?? 'Request failed.');
  }
}
