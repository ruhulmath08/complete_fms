class AppFailure implements Exception {
  AppFailure({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => message;
}
