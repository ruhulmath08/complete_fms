import 'package:dio/dio.dart';
import 'package:mobile/data/network/dio/dio_config.dart';
import 'package:mobile/data/network/dio/request_extra.dart';

/// Retries connection failures and gateway errors with a short backoff.
///
/// A receive timeout means the server already has the request, so that
/// wait is not started over. GET, HEAD, OPTIONS, PUT, and DELETE are
/// retried automatically. POST and PATCH are retried only when the
/// request sets [RequestExtra.retry] to `true`. Any call can opt out
/// with `false`.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = DioConfig.maxRetries,
    this.delays = DioConfig.retryDelays,
  });

  final Dio dio;
  final int maxRetries;
  final List<Duration> delays;

  static const _idempotentMethods = {'GET', 'HEAD', 'OPTIONS', 'PUT', 'DELETE'};

  static const _retryableStatuses = {408, 429, 502, 503, 504};

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.requestOptions.extra[RequestExtra.skipRetry] == true) {
      handler.next(err);
      return;
    }

    var current = err;
    var attempt =
        (current.requestOptions.extra[RequestExtra.retryCount] as int?) ?? 0;

    while (attempt < maxRetries && _shouldRetry(current)) {
      await Future<void>.delayed(_delayFor(current, attempt));
      attempt += 1;
      try {
        final response = await dio.fetch<dynamic>(
          _retryOptions(current.requestOptions, attempt),
        );
        handler.resolve(response);
        return;
      } on DioException catch (error) {
        current = error;
      }
    }

    handler.next(current);
  }

  bool _shouldRetry(DioException error) {
    final extra = error.requestOptions.extra;
    if (extra[RequestExtra.offline] == true) return false;
    if (extra[RequestExtra.retry] == false) return false;
    if (!_isTransient(error)) return false;

    final method = error.requestOptions.method.toUpperCase();
    if (_idempotentMethods.contains(method)) return true;
    return extra[RequestExtra.retry] == true;
  }

  bool _isTransient(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        return status != null && _retryableStatuses.contains(status);
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return false;
    }
  }

  Duration _delayFor(DioException error, int attempt) {
    final header = error.response?.headers.value('retry-after');
    final seconds = header == null ? null : int.tryParse(header);
    if (seconds != null && seconds >= 0 && seconds <= 30) {
      return Duration(seconds: seconds);
    }
    if (delays.isEmpty) return Duration.zero;
    final index = attempt >= delays.length ? delays.length - 1 : attempt;
    return delays[index];
  }

  RequestOptions _retryOptions(RequestOptions request, int attempt) {
    return request.copyWith(
      extra: Map<String, dynamic>.from(request.extra)
        ..[RequestExtra.retryCount] = attempt
        ..[RequestExtra.skipRetry] = true,
    );
  }
}
