import 'package:dio/dio.dart';
import 'package:mobile/domain/failures.dart';

/// Maps a [DioException] to a domain [Failure].
///
/// Prefers a failure already attached to the exception, then an API body
/// shaped as `{code, message}`, then the status and timeout mapping.
Failure failureFromDio(DioException exception) {
  final nested = exception.error;
  if (nested is Failure) return nested;

  final data = exception.response?.data;
  if (data is Map) {
    final code = data['code'];
    final message = data['message'];
    return Failure(
      code: code is String && code.isNotEmpty ? code : 'HTTP_ERROR',
      message: message is String && message.isNotEmpty
          ? message
          : 'Request failed.',
    );
  }

  return switch (exception.type) {
    DioExceptionType.connectionTimeout => _failure(
      '-2',
      'Time out error, try again later',
    ),
    DioExceptionType.sendTimeout => _failure(
      '-5',
      'Time out error, try again later',
    ),
    DioExceptionType.receiveTimeout || DioExceptionType.transformTimeout =>
      _failure('-4', 'Time out error, try again later'),
    DioExceptionType.badResponse => _fromStatus(exception.response?.statusCode),
    DioExceptionType.cancel => _failure(
      '-3',
      'Request was cancelled, try again later',
    ),
    DioExceptionType.connectionError => _failure(
      '-7',
      'Please check your internet connection',
    ),
    DioExceptionType.badCertificate ||
    DioExceptionType.unknown => _defaultFailure,
  };
}

Failure _fromStatus(int? status) {
  return switch (status) {
    400 => _failure('400', 'Bad request, try again later'),
    401 => _failure('401', 'User is unauthorised, try again later'),
    403 => _failure('403', 'Forbidden request, try again later'),
    404 => _failure('404', 'URL is not found, try again later'),
    500 => _failure('500', 'Something went wrong, try again later'),
    _ => _defaultFailure,
  };
}

Failure _failure(String code, String message) {
  return Failure(code: code, message: message);
}

final _defaultFailure = Failure(
  code: '-1',
  message: 'Something went wrong, try again later',
);
