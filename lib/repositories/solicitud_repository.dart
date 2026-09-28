import 'package:dio/dio.dart';

import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../models/catalogo.dart';
import '../models/historial_item.dart';
import '../models/json_helpers.dart';
import '../models/pagina.dart';
import '../models/solicitud.dart';

class SolicitudRepository {
  final ApiClient _api;

  SolicitudRepository(this._api);

  Future<Catalogos> catalogos() async {
    try {
      final res = await _api.dio.get('/catalogos');
      return Catalogos.fromJson(asMap(unwrap(res.data)));
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  /// HU-10: mis solicitudes, paginadas y con filtros opcionales.
  Future<Pagina<Solicitud>> listar({
    int page = 1,
    int? estadoId,
    int? tipoId,
  }) async {
    try {
      final res = await _api.dio.get('/solicitudes', queryParameters: {
        'page': page,
        if (estadoId != null) 'estado_id': estadoId,
        if (tipoId != null) 'tipo_id': tipoId,
      });
      final body = res.data as Map;
      final items = (body['data'] as List)
          .map((e) => Solicitud.fromJson(asMap(e)))
          .toList();
      final meta = body['meta'] as Map?;
      return Pagina(
        items: items,
        paginaActual: toInt(meta?['current_page']) ?? page,
        ultimaPagina: toInt(meta?['last_page']) ?? page,
      );
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<Solicitud> obtener(int id) async {
    try {
      final res = await _api.dio.get('/solicitudes/$id');
      return Solicitud.fromJson(asMap(unwrap(res.data)));
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  /// HU-05 + HU-06: crea la solicitud y sube las fotos una por una.
  /// Devuelve la solicitud y cuántas fotos no se pudieron subir.
  Future<(Solicitud, int)> crear(
    Map<String, dynamic> datos,
    List<String> rutasFotos,
  ) async {
    try {
      final res = await _api.dio.post('/solicitudes', data: datos);
      final solicitud = Solicitud.fromJson(asMap(unwrap(res.data)));
      final fallidas = await _subirFotos(solicitud.id, rutasFotos);
      return (solicitud, fallidas);
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  /// HU-08: la API rechaza (403) si la solicitud ya no está pendiente.
  Future<(Solicitud, int)> actualizar(
    int id,
    Map<String, dynamic> datos,
    List<String> rutasFotosNuevas,
  ) async {
    try {
      final res = await _api.dio.put('/solicitudes/$id', data: datos);
      final solicitud = Solicitud.fromJson(asMap(unwrap(res.data)));
      final fallidas = await _subirFotos(solicitud.id, rutasFotosNuevas);
      return (solicitud, fallidas);
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  /// HU-09: en el backend se recomienda eliminación lógica (estado cancelada).
  Future<void> eliminar(int id) async {
    try {
      await _api.dio.delete('/solicitudes/$id');
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<void> subirEvidencia(int solicitudId, String ruta) async {
    try {
      final form = FormData.fromMap({
        'imagen': await MultipartFile.fromFile(ruta),
      });
      await _api.dio.post('/solicitudes/$solicitudId/evidencias', data: form);
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  /// HU-07: solicitudes activas parecidas (mismo tipo y ubicación).
  Future<List<Solicitud>> similares({
    required int tipoId,
    required String ubicacion,
  }) async {
    try {
      final res = await _api.dio.get('/solicitudes/similares', queryParameters: {
        'tipo_id': tipoId,
        'ubicacion': ubicacion,
      });
      final lista = unwrap(res.data) as List;
      return lista.map((e) => Solicitud.fromJson(asMap(e))).toList();
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  /// HU-11: línea de tiempo de cambios.
  Future<List<HistorialItem>> historial(int id) async {
    try {
      final res = await _api.dio.get('/solicitudes/$id/historial');
      final lista = unwrap(res.data) as List;
      return lista.map((e) => HistorialItem.fromJson(asMap(e))).toList();
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<int> _subirFotos(int solicitudId, List<String> rutas) async {
    var fallidas = 0;
    for (final ruta in rutas) {
      try {
        await subirEvidencia(solicitudId, ruta);
      } on ApiException {
        fallidas++;
      }
    }
    return fallidas;
  }
}
