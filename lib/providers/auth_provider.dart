import 'package:flutter/foundation.dart';

import '../core/api/api_exception.dart';
import '../models/usuario.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { desconocido, autenticado, noAutenticado }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;

  AuthProvider(this._repo);

  AuthStatus status = AuthStatus.desconocido;
  Usuario? usuario;
  bool cargando = false;
  String? error;

  /// Se llama al abrir la app: restaura la sesión si hay token válido.
  Future<void> iniciar() async {
    try {
      final u = await _repo.restaurarSesion();
      usuario = u;
      status = u != null ? AuthStatus.autenticado : AuthStatus.noAutenticado;
    } catch (_) {
      status = AuthStatus.noAutenticado;
    }
    notifyListeners();
  }

  /// HU-01. Devuelve true si el inicio de sesión fue exitoso.
  Future<bool> login(String email, String password) async {
    cargando = true;
    error = null;
    notifyListeners();
    try {
      usuario = await _repo.login(email, password);
      status = AuthStatus.autenticado;
      cargando = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = ApiException.from(e).detalle;
      cargando = false;
      notifyListeners();
      return false;
    }
  }

  /// HU-02.
  Future<void> logout() async {
    await _repo.logout();
    usuario = null;
    error = null;
    status = AuthStatus.noAutenticado;
    notifyListeners();
  }

  /// La API respondió 401: el token ya no sirve.
  void manejarSesionExpirada() {
    if (status == AuthStatus.noAutenticado) return;
    usuario = null;
    status = AuthStatus.noAutenticado;
    notifyListeners();
  }
}
