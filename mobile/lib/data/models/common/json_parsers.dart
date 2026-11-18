/// Shared helpers for decoding API JSON into typed Dart values.
String requireString(Object? value, String key) {
  if (value == null) {
    throw FormatException('Missing required field "$key"');
  }
  return value.toString();
}

String? optionalString(Object? value) => value?.toString();

int requireInt(Object? value, String key) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.parse(value);
  throw FormatException('Expected int for "$key", got $value');
}

double requireDouble(Object? value, String key) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.parse(value);
  throw FormatException('Expected double for "$key", got $value');
}

bool requireBool(Object? value, String key, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  throw FormatException('Expected bool for "$key", got $value');
}

/// API decimals/numbers are kept as strings to match domain entities.
String requireDecimalString(Object? value, String key) {
  if (value == null) {
    throw FormatException('Missing required field "$key"');
  }
  return value.toString();
}

String? optionalDecimalString(Object? value) => value?.toString();
