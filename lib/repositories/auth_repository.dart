import 'package:dio/dio.dart';

import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../core/storage/token_storage.dart';
import '../models/json_helpers.dart';
import '../models/usuario.dart';

class AuthRepository {
  final ApiClient _api;
  final TokenStorage _tokens;

  AuthRepository(this._api, this._tokens);

  /// POST /login -> { token, user }. Guarda el token de forma segura.
  Future<Usuario> login(String email, String password) async {
    try {
      final res = await _api.dio.post('/login', data: {
        'email': email,
        'password': password,
        'device_name': 'movil',
      });
      final data = res.data as Map;
      final token = data['token'];
      final user = data['user'] ?? data['data'];
      if (token is! String || user == null) {
        throw const ApiException('Respuesta inesperada del servidor.');
      }
      await _tokens.save(token);
      return Usuario.fromJson(asMap(user));
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  /// Si hay token guardado, valida la sesión con GET /me. Devuelve null si no hay sesión.
  Future<Usuario?> restaurarSesion() async {
    final token = await _tokens.read();
    if (token == null) return null;
    try {
      final res = await _api.dio.get('/me');
      return Usuario.fromJson(asMap(unwrap(res.data)));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokens.clear();
        return null;
      }
      throw ApiException.from(e);
    }
  }

  /// POST /logout. Aunque falle la red, el token local siempre se elimina.
  Future<void> logout() async {
    try {
      await _api.dio.post('/logout');
    } on DioException catch (_) {
      // Se ignora: lo importante es cerrar la sesión en el dispositivo.
    } finally {
      await _tokens.clear();
    }
  }
}
