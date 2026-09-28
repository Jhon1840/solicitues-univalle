import 'package:flutter/foundation.dart';

import '../core/api/api_exception.dart';
import '../models/comentario.dart';
import '../repositories/comentario_repository.dart';

class ComentarioProvider extends ChangeNotifier {
  final ComentarioRepository _repo;

  ComentarioProvider(this._repo);

  List<Comentario> comentarios = [];
  bool cargando = false;
  bool enviando = false;
  String? error;
  int? _solicitudId;

  Future<void> cargar(int solicitudId) async {
    if (_solicitudId != solicitudId) comentarios = [];
    _solicitudId = solicitudId;
    cargando = true;
    error = null;
    notifyListeners();
    try {
      comentarios = await _repo.listar(solicitudId);
    } catch (e) {
      error = ApiException.from(e).detalle;
    }
    cargando = false;
    notifyListeners();
  }

  /// HU-12. Devuelve true si el comentario se guardó.
  Future<bool> enviar(int solicitudId, String contenido) async {
    enviando = true;
    error = null;
    notifyListeners();
    try {
      final nuevo = await _repo.crear(solicitudId, contenido);
      comentarios = [...comentarios, nuevo];
      enviando = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = ApiException.from(e).detalle;
      enviando = false;
      notifyListeners();
      return false;
    }
  }

  void limpiar() {
    comentarios = [];
    cargando = false;
    enviando = false;
    error = null;
    _solicitudId = null;
    notifyListeners();
  }
}
