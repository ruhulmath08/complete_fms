import 'package:dio/dio.dart';
import 'package:mobile/data/network/dio/request_extra.dart';
import 'package:mobile/data/network/network_info.dart';

/// Rejects the request before it is sent when the device is offline.
class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor(this._networkInfo);

  final NetworkInfo _networkInfo;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!await _networkInfo.isConnected) {
      final offlineOptions = options.copyWith(
        extra: Map<String, dynamic>.from(options.extra)
          ..[RequestExtra.offline] = true,
      );
      handler.reject(
        DioException(
          requestOptions: offlineOptions,
          type: DioExceptionType.connectionError,
        ),
      );
      return;
    }
    handler.next(options);
  }
}
