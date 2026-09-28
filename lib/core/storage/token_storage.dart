import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda el token de sesión de forma segura (Keystore / Keychain).
class TokenStorage {
  static const _clave = 'auth_token';
  final FlutterSecureStorage _storage;

  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> read() => _storage.read(key: _clave);
  Future<void> save(String token) => _storage.write(key: _clave, value: token);
  Future<void> clear() => _storage.delete(key: _clave);
}
