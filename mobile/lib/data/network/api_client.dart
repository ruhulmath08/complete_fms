import 'package:dio/dio.dart';
import 'package:mobile/data/datasources/auth/auth_local_datasource.dart';
import 'package:mobile/data/network/api_activity.dart';
import 'package:mobile/data/network/dio/dio_config.dart';
import 'package:mobile/data/network/dio/interceptors/auth_interceptor.dart';
import 'package:mobile/data/network/dio/interceptors/connectivity_interceptor.dart';
import 'package:mobile/data/network/dio/interceptors/json_log_interceptor.dart';
import 'package:mobile/data/network/dio/interceptors/retry_interceptor.dart';
import 'package:mobile/data/network/dio/request_extra.dart';
import 'package:mobile/data/network/error_handler.dart';
import 'package:mobile/data/network/network_info.dart';
import 'package:mobile/domain/failures.dart';
import 'package:mobile/infrastructure/config/api_config.dart';

/// Log HTTP calls as JSON in debug mode only.
const bool _httpLogEnabled =
    !bool.fromEnvironment('dart.vm.product') &&
    !bool.fromEnvironment('dart.vm.profile');

/// App HTTP client.
///
/// [get], [post], [postVoid], [patch], [put], [delete], and [getBytes]
/// throw a [Failure] instead of a [DioException]. Auth, connectivity, and
/// retries run inside [dio] before that mapping.
class ApiClient {
  ApiClient(
    AuthLocalDatasource localDatasource,
    NetworkInfo networkInfo, {
    ApiActivity? activity,
  }) : _activity = activity ?? ApiActivity(),
       dio = _create(localDatasource, networkInfo);

  final Dio dio;
  final ApiActivity _activity;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    bool auth = true,
  }) {
    return _json(
      () => dio.get<Map<String, dynamic>>(
        path,
        queryParameters: query,
        options: _options(auth),
      ),
    );
  }

  Future<List<int>> getBytes(String path) {
    return _send(() async {
      final response = await dio.get<List<int>>(
        path,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data ?? const <int>[];
    });
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? data,
    bool auth = true,
  }) {
    return _json(
      () => dio.post<Map<String, dynamic>>(
        path,
        data: data,
        options: _options(auth),
      ),
      track: true,
    );
  }

  /// POST whose response has no JSON body, such as sign-out (204).
  Future<void> postVoid(String path, {Object? data, bool auth = true}) {
    return _send(
      () => dio.post<void>(path, data: data, options: _options(auth)),
      track: true,
    );
  }

  Future<Map<String, dynamic>> patch(String path, {Object? data}) {
    return _json(
      () => dio.patch<Map<String, dynamic>>(path, data: data),
      track: true,
    );
  }

  Future<Map<String, dynamic>> put(String path, {Object? data}) {
    return _json(
      () => dio.put<Map<String, dynamic>>(path, data: data),
      track: true,
    );
  }

  Future<void> delete(String path) {
    return _send(() => dio.delete<void>(path), track: true);
  }

  static Dio _create(
    AuthLocalDatasource localDatasource,
    NetworkInfo networkInfo,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: DioConfig.connectTimeout,
        receiveTimeout: DioConfig.receiveTimeout,
        headers: const {'Accept': 'application/json'},
      ),
    );

    // Connectivity, then auth, then retry, then the debug log.
    // Auth is before retry so a 401 is refreshed and replayed before a
    // transient retry. Both the replay and each retry are new fetches, so a
    // gateway error after refresh is still retried, and a 401 on a retry
    // still refreshes.
    dio.interceptors.addAll([
      ConnectivityInterceptor(networkInfo),
      AuthInterceptor(dio: dio, localDatasource: localDatasource),
      RetryInterceptor(dio: dio),
      if (_httpLogEnabled) JsonLogInterceptor(),
    ]);

    return dio;
  }

  Options? _options(bool auth) {
    if (auth) return null;
    return Options(extra: const {RequestExtra.auth: false});
  }

  Future<Map<String, dynamic>> _json(
    Future<Response<Map<String, dynamic>>> Function() call, {
    bool track = false,
  }) {
    return _send(() async {
      final response = await call();
      return response.data!;
    }, track: track);
  }

  Future<T> _send<T>(Future<T> Function() call, {bool track = false}) async {
    if (track) _activity.begin();
    try {
      return await call();
    } on DioException catch (error) {
      throw failureFromDio(error);
    } finally {
      if (track) _activity.end();
    }
  }
}
