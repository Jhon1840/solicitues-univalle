import 'package:dio/dio.dart';

import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../models/comentario.dart';
import '../models/json_helpers.dart';

class ComentarioRepository {
  final ApiClient _api;

  ComentarioRepository(this._api);

  Future<List<Comentario>> listar(int solicitudId) async {
    try {
      final res = await _api.dio.get('/solicitudes/$solicitudId/comentarios');
      final lista = unwrap(res.data) as List;
      return lista.map((e) => Comentario.fromJson(asMap(e))).toList();
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<Comentario> crear(int solicitudId, String contenido) async {
    try {
      final res = await _api.dio.post(
        '/solicitudes/$solicitudId/comentarios',
        data: {'contenido': contenido},
      );
      return Comentario.fromJson(asMap(unwrap(res.data)));
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }
}
