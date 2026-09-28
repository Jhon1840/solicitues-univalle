import 'json_helpers.dart';

class Comentario {
  final int id;
  final String contenido;
  final String autor;
  final DateTime? createdAt;

  const Comentario({
    required this.id,
    required this.contenido,
    required this.autor,
    this.createdAt,
  });

  factory Comentario.fromJson(Map<String, dynamic> j) => Comentario(
        id: toInt(j['id']) ?? 0,
        contenido:
            (j['contenido'] ?? j['texto'] ?? j['comentario'] ?? '').toString(),
        autor: nombreDe(j['autor'] ?? j['usuario'] ?? j['user'], 'Usuario'),
        createdAt: fechaDe(j['created_at']),
      );
}
