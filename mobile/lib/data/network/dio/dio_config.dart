/// Shared Dio timeouts and retry budget.
abstract final class DioConfig {
  static const Duration connectTimeout = Duration(seconds: 15);

  /// Wait for response headers. A response that arrives inside this window
  /// is accepted, so keep it above the slowest backend response the app
  /// should still show. A 55s response needs more than 55s here.
  static const Duration receiveTimeout = Duration(seconds: 60);

  /// Extra attempts after the first failure.
  static const int maxRetries = 2;

  static const List<Duration> retryDelays = [
    Duration(milliseconds: 400),
    Duration(milliseconds: 800),
  ];
}
