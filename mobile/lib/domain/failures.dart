class Failure implements Exception {
  Failure({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => message;
}
