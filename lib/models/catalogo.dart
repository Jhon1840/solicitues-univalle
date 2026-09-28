import 'json_helpers.dart';

class CatalogoItem {
  final int id;
  final String nombre;

  const CatalogoItem({required this.id, required this.nombre});

  factory CatalogoItem.fromJson(Map<String, dynamic> j) => CatalogoItem(
        id: toInt(j['id']) ?? 0,
        nombre: nombreDe(j),
      );
}

/// Listas de opciones que vienen de la API (GET /catalogos).
class Catalogos {
  final List<CatalogoItem> tipos;
  final List<CatalogoItem> prioridades;
  final List<CatalogoItem> estados;

  const Catalogos({
    this.tipos = const [],
    this.prioridades = const [],
    this.estados = const [],
  });

  factory Catalogos.fromJson(Map<String, dynamic> j) {
    List<CatalogoItem> lista(dynamic v) => (v as List? ?? [])
        .map((e) => CatalogoItem.fromJson(asMap(e)))
        .toList();
    return Catalogos(
      tipos: lista(j['tipos']),
      prioridades: lista(j['prioridades']),
      estados: lista(j['estados']),
    );
  }
}
