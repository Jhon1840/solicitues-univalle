import 'json_helpers.dart';

/// Un movimiento en la línea de tiempo de una solicitud.
class HistorialItem {
  final int id;
  final String estado;
  final String descripcion;
  final String autor;
  final DateTime? createdAt;

  const HistorialItem({
    required this.id,
    required this.estado,
    this.descripcion = '',
    this.autor = 'Sistema',
    this.createdAt,
  });

  factory HistorialItem.fromJson(Map<String, dynamic> j) => HistorialItem(
        id: toInt(j['id']) ?? 0,
        estado: nombreDe(j['estado']),
        descripcion: (j['descripcion'] ?? j['accion'] ?? '').toString(),
        autor: nombreDe(j['autor'] ?? j['usuario'], 'Sistema'),
        createdAt: fechaDe(j['created_at'] ?? j['fecha']),
      );
}
