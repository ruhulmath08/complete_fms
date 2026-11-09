class ApiConfig {
  /// Android emulator → host machine. Override for iOS simulator (`localhost`)
  /// or a physical device (LAN IP).
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
}
