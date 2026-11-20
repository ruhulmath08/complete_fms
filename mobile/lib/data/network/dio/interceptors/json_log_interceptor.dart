import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Prints one JSON object for each request, response, and error.
///
/// Passwords and tokens are replaced before encoding. Install this only in
/// debug builds.
class JsonLogInterceptor extends Interceptor {
  JsonLogInterceptor({this.logPrint = _developerLog});

  final void Function(String message) logPrint;

  static const _redacted = '<redacted>';
  static const _secretKeys = {
    'authorization',
    'password',
    'confirm_password',
    'access_token',
    'refresh_token',
  };

  static const _encoder = JsonEncoder.withIndent('  ');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _write({
      'kind': 'request',
      'method': options.method,
      'uri': options.uri.toString(),
      'headers': _sanitize(options.headers),
      'data': _sanitize(options.data),
    });
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _write({
      'kind': 'response',
      'statusCode': response.statusCode,
      'uri': response.realUri.toString(),
      'data': _sanitize(response.data),
    });
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _write({
      'kind': 'error',
      'type': err.type.name,
      'statusCode': err.response?.statusCode,
      'uri': err.requestOptions.uri.toString(),
      'message': err.message,
      'data': _sanitize(err.response?.data),
    });
    handler.next(err);
  }

  void _write(Map<String, Object?> record) {
    try {
      logPrint(_encoder.convert(record));
    } catch (error) {
      logPrint('{"kind":"logError","type":"${error.runtimeType}"}');
    }
  }

  Object? _sanitize(Object? value) {
    if (value == null || value is num || value is bool || value is String) {
      return value;
    }
    if (value is FormData) {
      return {
        'fields': {
          for (final field in value.fields)
            field.key: _field(field.key, field.value),
        },
        'files': [
          for (final file in value.files)
            {
              'field': file.key,
              'filename': file.value.filename,
              'length': file.value.length,
            },
        ],
      };
    }
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _field(entry.key.toString(), entry.value),
      };
    }
    if (value is List<int>) {
      return {'bytes': value.length};
    }
    if (value is List) {
      return value.map(_sanitize).toList();
    }
    return value.toString();
  }

  Object? _field(String key, Object? value) {
    if (_secretKeys.contains(key.toLowerCase())) return _redacted;
    return _sanitize(value);
  }
}

void _developerLog(String message) {
  developer.log(message, name: 'dio');
}
