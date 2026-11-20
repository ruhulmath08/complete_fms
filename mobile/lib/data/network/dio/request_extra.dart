/// Keys stored on [RequestOptions.extra].
///
/// `auth` stays stable because public requests pass `auth: false` as this key.
abstract final class RequestExtra {
  /// When `false`, the access token is not attached and a 401 is not refreshed.
  static const String auth = 'auth';

  /// Set after a 401 has already been retried with a new access token.
  static const String retried = 'retried';

  /// `false` disables the retry interceptor. `true` also retries
  /// non-idempotent methods (POST, PATCH).
  static const String retry = 'retry';

  static const String retryCount = 'retryCount';

  /// Internal. Set on the options used for a retry attempt so the
  /// interceptor does not start a second retry loop.
  static const String skipRetry = 'skipRetry';

  /// Set when the connectivity interceptor rejects the call before it is sent.
  static const String offline = 'offline';
}
