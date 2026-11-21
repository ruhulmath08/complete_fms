import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/datasources/auth/auth_local_datasource.dart';
import 'package:mobile/data/network/api_activity.dart';
import 'package:mobile/data/network/api_endpoints.dart';
import 'package:mobile/data/network/api_client.dart';
import 'package:mobile/data/network/dio/interceptors/auth_interceptor.dart';
import 'package:mobile/data/network/dio/interceptors/connectivity_interceptor.dart';
import 'package:mobile/data/network/dio/interceptors/json_log_interceptor.dart';
import 'package:mobile/data/network/dio/interceptors/retry_interceptor.dart';
import 'package:mobile/data/network/dio/request_extra.dart';
import 'package:mobile/data/network/error_handler.dart';
import 'package:mobile/data/network/network_info.dart';
import 'package:mobile/domain/failures.dart';

void main() {
  test('client installs interceptors in chain order', () {
    final dio = ApiClient(_MemoryAuthLocal(), _FakeNetwork(true)).dio;

    final types = dio.interceptors
        .map((interceptor) => interceptor.runtimeType.toString())
        .where((name) => name != 'ImplyContentTypeInterceptor')
        .toList();
    expect(types, [
      'ConnectivityInterceptor',
      'AuthInterceptor',
      'RetryInterceptor',
      'JsonLogInterceptor',
    ]);
  });

  test('writes report activity and reads do not', () async {
    final activity = ApiActivity();
    final counts = <int>[];
    final subscription = activity.stream.listen(counts.add);
    final client = ApiClient(
      _MemoryAuthLocal(),
      _FakeNetwork(true),
      activity: activity,
    );
    client.dio.httpClientAdapter = _ScriptedAdapter(
      (_) async => _body(200, '{"ok":true}'),
    );

    await client.get('/api/v1/me');
    expect(activity.count, 0);
    expect(counts, isEmpty);

    await client.post('/api/v1/cows', data: {'name': 'A'});
    expect(activity.count, 0);
    expect(counts, [1, 0]);

    client.dio.httpClientAdapter = _ScriptedAdapter(
      (_) async => _body(400, '{"code":"BAD_REQUEST","message":"No."}'),
    );
    await expectLater(client.delete('/api/v1/cows/1'), throwsA(isA<Failure>()));
    expect(activity.count, 0);
    expect(counts, [1, 0, 1, 0]);

    await subscription.cancel();
  });

  test('get throws the failure from the API body', () async {
    final client = ApiClient(_MemoryAuthLocal(), _FakeNetwork(true));
    client.dio.httpClientAdapter = _ScriptedAdapter(
      (_) async =>
          _body(400, '{"code":"BAD_REQUEST","message":"Missing field."}'),
    );

    await expectLater(
      client.get('/api/v1/me'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 'BAD_REQUEST')
            .having((failure) => failure.message, 'message', 'Missing field.'),
      ),
    );
  });

  test('debug log is json and redacts secrets', () async {
    final lines = <String>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dio.httpClientAdapter = _ScriptedAdapter(
      (_) async => _body(200, '{"access_token":"secret-access","ok":true}'),
    );
    dio.interceptors.add(JsonLogInterceptor(logPrint: lines.add));

    await dio.post<Map<String, dynamic>>(
      '/api/v1/auth/signin',
      data: {'email': 'a@b.co', 'password': 'secret-pass'},
      options: Options(headers: {'Authorization': 'Bearer secret-token'}),
    );

    final request = jsonDecode(lines[0]) as Map<String, dynamic>;
    final requestData = request['data'] as Map<String, dynamic>;
    final requestHeaders = request['headers'] as Map<String, dynamic>;
    expect(request['kind'], 'request');
    expect(requestData['email'], 'a@b.co');
    expect(requestData['password'], '<redacted>');
    expect(requestHeaders['Authorization'], '<redacted>');

    final response = jsonDecode(lines[1]) as Map<String, dynamic>;
    final responseData = response['data'] as Map<String, dynamic>;
    expect(response['kind'], 'response');
    expect(response['statusCode'], 200);
    expect(responseData['ok'], true);
    expect(responseData['access_token'], '<redacted>');
  });

  test('retries an idempotent request and then succeeds', () async {
    var attempts = 0;
    final adapter = _ScriptedAdapter((_) async {
      attempts += 1;
      if (attempts < 3) return _body(503, '{}');
      return _body(200, '{"ok":true}');
    });
    final dio = _dio(adapter, retry: true);

    final response = await dio.get<Map<String, dynamic>>('/api/v1/cows');

    expect(response.data?['ok'], true);
    expect(adapter.calls, [
      'GET /api/v1/cows',
      'GET /api/v1/cows',
      'GET /api/v1/cows',
    ]);
  });

  test('waits once for a slow response instead of retrying it', () async {
    final adapter = _ScriptedAdapter((options) async {
      throw DioException.receiveTimeout(
        timeout: const Duration(seconds: 60),
        requestOptions: options,
      );
    });
    final dio = _dio(adapter, retry: true);

    final error = await _throwsDio(dio.get<void>('/api/v1/cows'));

    expect(error.type, DioExceptionType.receiveTimeout);
    expect(adapter.calls, ['GET /api/v1/cows']);
  });

  test('does not retry a POST unless the call opts in', () async {
    final adapter = _ScriptedAdapter((_) async => _body(503, '{}'));
    final dio = _dio(adapter, retry: true);

    await expectLater(
      dio.post<Map<String, dynamic>>('/api/v1/cows'),
      throwsA(isA<DioException>()),
    );
    expect(adapter.calls, ['POST /api/v1/cows']);

    adapter.calls.clear();
    await expectLater(
      dio.post<Map<String, dynamic>>(
        '/api/v1/cows',
        options: Options(extra: {RequestExtra.retry: true}),
      ),
      throwsA(isA<DioException>()),
    );
    expect(adapter.calls, [
      'POST /api/v1/cows',
      'POST /api/v1/cows',
      'POST /api/v1/cows',
    ]);
  });

  test('does not send a request when the device is offline', () async {
    final adapter = _ScriptedAdapter((_) async => _body(200, '{}'));
    final dio = _dio(adapter, connected: false);

    final error = await _throwsDio(dio.get<void>('/api/v1/cows'));

    expect(adapter.calls, isEmpty);
    expect(error.type, DioExceptionType.connectionError);
    expect(error.requestOptions.extra[RequestExtra.offline], true);
    expect(failureFromDio(error).code, '-7');
    expect(
      failureFromDio(error).message,
      'Please check your internet connection',
    );
  });

  test(
    'refreshes once and retries the original request with the new token',
    () async {
      final local = _MemoryAuthLocal()
        ..access = 'old-access'
        ..refresh = 'refresh-1';
      final adapter = _ScriptedAdapter((options) async {
        if (options.path == ApiEndpoints.refresh) {
          return _body(
            200,
            '{"access_token":"new-access","refresh_token":"new-refresh"}',
          );
        }
        final authorization = options.headers['Authorization'];
        if (authorization == 'Bearer new-access') {
          return _body(200, '{"ok":true}');
        }
        return _body(401, '{"code":"UNAUTHORIZED","message":"expired"}');
      });
      final dio = _dio(adapter, local: local);

      final response = await dio.get<Map<String, dynamic>>('/api/v1/me');

      expect(response.data?['ok'], true);
      expect(local.access, 'new-access');
      expect(local.refresh, 'new-refresh');
      expect(local.clears, 0);
      expect(adapter.calls, [
        'GET /api/v1/me',
        'POST ${ApiEndpoints.refresh}',
        'GET /api/v1/me',
      ]);
      expect(adapter.authorizations.first, 'Bearer old-access');
      expect(adapter.authorizations[1], isNull);
      expect(adapter.authorizations[2], 'Bearer new-access');
    },
  );

  test('shares one refresh across overlapping 401s', () async {
    final local = _MemoryAuthLocal()
      ..access = 'old-access'
      ..refresh = 'refresh-1';
    var refreshCalls = 0;
    final adapter = _ScriptedAdapter((options) async {
      if (options.path == ApiEndpoints.refresh) {
        refreshCalls += 1;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return _body(
          200,
          '{"access_token":"new-access","refresh_token":"new-refresh"}',
        );
      }
      if (options.headers['Authorization'] == 'Bearer new-access') {
        return _body(200, '{"ok":true}');
      }
      return _body(401, '{}');
    });
    final dio = _dio(adapter, local: local);

    final results = await Future.wait([
      dio.get<Map<String, dynamic>>('/api/v1/me'),
      dio.get<Map<String, dynamic>>('/api/v1/cows'),
    ]);

    expect(results, hasLength(2));
    expect(refreshCalls, 1);
    expect(local.clears, 0);
  });

  test(
    'clears the session when refresh is rejected and keeps it on timeout',
    () async {
      final rejected = _MemoryAuthLocal()
        ..access = 'old-access'
        ..refresh = 'refresh-1';
      final rejectedAdapter = _ScriptedAdapter((options) async {
        if (options.path == ApiEndpoints.refresh) {
          return _body(401, '{"message":"expired"}');
        }
        return _body(401, '{}');
      });
      final rejectedDio = _dio(rejectedAdapter, local: rejected);

      await expectLater(
        rejectedDio.get<void>('/api/v1/me'),
        throwsA(isA<DioException>()),
      );
      expect(rejected.clears, 1);
      expect(rejected.access, isNull);

      final timedOut = _MemoryAuthLocal()
        ..access = 'old-access'
        ..refresh = 'refresh-1';
      final timeoutAdapter = _ScriptedAdapter((options) async {
        if (options.path == ApiEndpoints.refresh) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
          );
        }
        return _body(401, '{}');
      });
      final timeoutDio = _dio(timeoutAdapter, local: timedOut);

      await expectLater(
        timeoutDio.get<void>('/api/v1/me'),
        throwsA(isA<DioException>()),
      );
      expect(timedOut.clears, 0);
      expect(timedOut.access, 'old-access');
    },
  );

  test('failureFromDio prefers the API body, then an attached failure', () {
    final request = RequestOptions(path: '/api/v1/me');
    final fromBody = failureFromDio(
      DioException(
        requestOptions: request,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: request,
          statusCode: 400,
          data: {'code': 'BAD_REQUEST', 'message': 'Missing field.'},
        ),
      ),
    );
    expect(fromBody.code, 'BAD_REQUEST');
    expect(fromBody.message, 'Missing field.');

    final attached = Failure(code: 'OFFLINE', message: 'Offline.');
    final kept = failureFromDio(
      DioException(
        requestOptions: request,
        type: DioExceptionType.connectionError,
        error: attached,
      ),
    );
    expect(kept, same(attached));
  });
}

Dio _dio(
  _ScriptedAdapter adapter, {
  bool retry = false,
  bool connected = true,
  _MemoryAuthLocal? local,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
  dio.httpClientAdapter = adapter;
  if (!connected) {
    dio.interceptors.add(ConnectivityInterceptor(_FakeNetwork(false)));
  }
  if (local != null) {
    dio.interceptors.add(AuthInterceptor(dio: dio, localDatasource: local));
  }
  if (retry) {
    dio.interceptors.add(
      RetryInterceptor(dio: dio, delays: const [Duration.zero, Duration.zero]),
    );
  }
  return dio;
}

Future<DioException> _throwsDio(Future<Response<void>> call) async {
  try {
    await call;
  } on DioException catch (error) {
    return error;
  }
  fail('expected DioException');
}

ResponseBody _body(int status, String json) {
  return ResponseBody.fromString(
    json,
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._handle);

  final Future<ResponseBody> Function(RequestOptions options) _handle;
  final calls = <String>[];
  final authorizations = <String?>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    calls.add('${options.method} ${options.path}');
    authorizations.add(options.headers['Authorization'] as String?);
    return _handle(options);
  }

  @override
  void close({bool force = false}) {}
}

class _FakeNetwork implements NetworkInfo {
  _FakeNetwork(this.connected);

  final bool connected;

  @override
  Future<bool> get isConnected async => connected;
}

class _MemoryAuthLocal implements AuthLocalDatasource {
  String? access;
  String? refresh;
  int clears = 0;

  @override
  Future<void> clearTokens() async {
    clears += 1;
    access = null;
    refresh = null;
  }

  @override
  Future<bool> hasAccessToken() async => access?.isNotEmpty == true;

  @override
  Future<String?> readAccessToken() async => access;

  @override
  Future<String?> readRefreshToken() async => refresh;

  @override
  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    this.access = access;
    this.refresh = refresh;
  }
}
