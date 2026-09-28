import 'package:flutter/foundation.dart';

import '../core/api/api_exception.dart';
import '../models/catalogo.dart';
import '../models/historial_item.dart';
import '../models/solicitud.dart';
import '../repositories/solicitud_repository.dart';

class SolicitudProvider extends ChangeNotifier {
  final SolicitudRepository _repo;

  SolicitudProvider(this._repo);

  // Catálogos (tipos, prioridades, estados)
  Catalogos? catalogos;
  String? errorCatalogos;

  // Lista
  List<Solicitud> items = [];
  bool cargando = false;
  bool cargandoMas = false;
  String? error;
  bool hayMas = false;
  int? filtroEstadoId;
  int? filtroTipoId;
  int _pagina = 1;

  // Detalle
  Solicitud? detalle;
  List<HistorialItem> historial = [];
  bool cargandoDetalle = false;
  String? errorDetalle;

  Future<void> cargarCatalogos({bool forzar = false}) async {
    if (catalogos != null && !forzar) return;
    errorCatalogos = null;
    try {
      catalogos = await _repo.catalogos();
    } catch (e) {
      errorCatalogos = ApiException.from(e).detalle;
    }
    notifyListeners();
  }

  Future<void> cargarLista() async {
    cargando = true;
    error = null;
    notifyListeners();
    try {
      final p = await _repo.listar(
        page: 1,
        estadoId: filtroEstadoId,
        tipoId: filtroTipoId,
      );
      items = p.items;
      _pagina = p.paginaActual;
      hayMas = p.hayMas;
    } catch (e) {
      error = ApiException.from(e).detalle;
    }
    cargando = false;
    notifyListeners();
  }

  Future<void> cargarMas() async {
    if (cargando || cargandoMas || !hayMas) return;
    cargandoMas = true;
    notifyListeners();
    try {
      final p = await _repo.listar(
        page: _pagina + 1,
        estadoId: filtroEstadoId,
        tipoId: filtroTipoId,
      );
      items = [...items, ...p.items];
      _pagina = p.paginaActual;
      hayMas = p.hayMas;
    } catch (_) {
      // Si falla la paginación, se conserva lo ya cargado.
    }
    cargandoMas = false;
    notifyListeners();
  }

  Future<void> aplicarFiltros({int? estadoId, int? tipoId}) {
    filtroEstadoId = estadoId;
    filtroTipoId = tipoId;
    return cargarLista();
  }

  Future<void> cargarDetalle(int id) async {
    if (detalle?.id != id) {
      detalle = null;
      historial = [];
    }
    cargandoDetalle = true;
    errorDetalle = null;
    notifyListeners();
    try {
      detalle = await _repo.obtener(id);
      try {
        historial = await _repo.historial(id);
      } catch (_) {
        historial = [];
      }
    } catch (e) {
      errorDetalle = ApiException.from(e).detalle;
    }
    cargandoDetalle = false;
    notifyListeners();
  }

  /// HU-05/06. Lanza [ApiException] si falla.
  Future<(Solicitud, int)> crear(
    Map<String, dynamic> datos,
    List<String> rutasFotos,
  ) async {
    final resultado = await _repo.crear(datos, rutasFotos);
    await cargarLista();
    return resultado;
  }

  /// HU-08. Lanza [ApiException] si falla.
  Future<(Solicitud, int)> actualizar(
    int id,
    Map<String, dynamic> datos,
    List<String> rutasFotosNuevas,
  ) async {
    final resultado = await _repo.actualizar(id, datos, rutasFotosNuevas);
    await cargarLista();
    return resultado;
  }

  /// HU-09. Lanza [ApiException] si falla.
  Future<void> eliminar(int id) async {
    await _repo.eliminar(id);
    items = items.where((s) => s.id != id).toList();
    detalle = null;
    historial = [];
    notifyListeners();
  }

  /// HU-07. Si la consulta falla no bloquea el registro: devuelve lista vacía.
  Future<List<Solicitud>> buscarSimilares({
    required int tipoId,
    required String ubicacion,
  }) async {
    try {
      return await _repo.similares(tipoId: tipoId, ubicacion: ubicacion);
    } catch (_) {
      return [];
    }
  }

  void limpiar() {
    catalogos = null;
    errorCatalogos = null;
    items = [];
    cargando = false;
    cargandoMas = false;
    error = null;
    hayMas = false;
    filtroEstadoId = null;
    filtroTipoId = null;
    _pagina = 1;
    detalle = null;
    historial = [];
    cargandoDetalle = false;
    errorDetalle = null;
    notifyListeners();
  }
}
