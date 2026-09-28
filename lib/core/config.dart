class AppConfig {
  /// URL base de la API Laravel.
  ///
  /// - Emulador Android: 10.0.2.2 apunta al localhost de tu PC.
  /// - Celular real: usa la IP de tu PC en la red, por ejemplo:
  ///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );
}
