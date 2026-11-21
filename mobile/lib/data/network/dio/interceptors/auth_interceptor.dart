import 'package:dio/dio.dart';
import 'package:mobile/data/datasources/auth/auth_local_datasource.dart';
import 'package:mobile/data/network/api_endpoints.dart';
import 'package:mobile/data/network/dio/request_extra.dart';

/// Attaches the access token and, on 401, refreshes it once.
///
/// Concurrent 401s share a single refresh call.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.dio, required this.localDatasource});

  final Dio dio;
  final AuthLocalDatasource localDatasource;
  Future<bool>? _refreshing;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[RequestExtra.auth] != false) {
      final token = await localDatasource.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final shouldRefresh =
        err.response?.statusCode == 401 &&
        request.extra[RequestExtra.auth] != false &&
        request.extra[RequestExtra.retried] != true;

    if (!shouldRefresh) {
      handler.next(err);
      return;
    }

    final refreshed = await _refresh();
    if (!refreshed) {
      handler.next(err);
      return;
    }

    final token = await localDatasource.readAccessToken();
    if (token == null || token.isEmpty) {
      handler.next(err);
      return;
    }

    final options = request.copyWith(
      headers: Map<String, dynamic>.from(request.headers)
        ..['Authorization'] = 'Bearer $token',
      extra: Map<String, dynamic>.from(request.extra)
        ..[RequestExtra.retried] = true,
    );

    try {
      final response = await dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (error) {
      handler.next(error);
    }
  }

  Future<bool> _refresh() {
    return _refreshing ??= _refreshTokens().whenComplete(() {
      _refreshing = null;
    });
  }

  Future<bool> _refreshTokens() async {
    final refresh = await localDatasource.readRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;

    try {
      final response = await dio.post<Map<String, dynamic>>(
        ApiEndpoints.refresh,
        data: {'refresh_token': refresh},
        options: Options(extra: {RequestExtra.auth: false}),
      );
      final data = response.data;
      if (data == null) return false;
      await localDatasource.saveTokens(
        access: data['access_token'] as String,
        refresh: data['refresh_token'] as String,
      );
      return true;
    } on DioException catch (error) {
      // A transport failure (offline, timeout) should not wipe a still-valid
      // session. An HTTP error from the refresh endpoint means the session
      // is no longer usable.
      if (error.response != null) {
        await localDatasource.clearTokens();
      }
      return false;
    } catch (_) {
      await localDatasource.clearTokens();
      return false;
    }
  }
}
