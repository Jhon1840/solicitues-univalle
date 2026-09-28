import 'evidencia.dart';
import 'json_helpers.dart';

class Solicitud {
  final int id;
  final String codigo;
  final String titulo;
  final String descripcion;
  final String ubicacion;
  final int? tipoId;
  final String tipo;
  final int? prioridadId;
  final String prioridad;
  final String estado;
  final String? responsable;
  final List<Evidencia> evidencias;
  final DateTime? createdAt;

  const Solicitud({
    required this.id,
    this.codigo = '',
    required this.titulo,
    this.descripcion = '',
    this.ubicacion = '',
    this.tipoId,
    this.tipo = '',
    this.prioridadId,
    this.prioridad = '',
    required this.estado,
    this.responsable,
    this.evidencias = const [],
    this.createdAt,
  });

  factory Solicitud.fromJson(Map<String, dynamic> j) {
    final id = toInt(j['id']) ?? 0;
    final resp = j['responsable'];
    return Solicitud(
      id: id,
      codigo: (j['codigo'] ?? 'SOL-${id.toString().padLeft(5, '0')}').toString(),
      titulo: (j['titulo'] ?? '').toString(),
      descripcion: (j['descripcion'] ?? '').toString(),
      ubicacion: (j['ubicacion'] ?? '').toString(),
      tipoId: toInt(j['tipo_id']) ?? idDe(j['tipo']),
      tipo: nombreDe(j['tipo']),
      prioridadId: toInt(j['prioridad_id']) ?? idDe(j['prioridad']),
      prioridad: nombreDe(j['prioridad']),
      estado: nombreDe(j['estado']),
      responsable: resp == null ? null : nombreDe(resp),
      evidencias: (j['evidencias'] as List? ?? [])
          .map((e) => Evidencia.fromJson(asMap(e)))
          .toList(),
      createdAt: fechaDe(j['created_at']),
    );
  }

  /// HU-08 / HU-09: solo se puede editar o eliminar mientras esté pendiente.
  bool get esEditable => estado.toLowerCase() == 'pendiente';

  /// HU-12: no se comenta en solicitudes cerradas, rechazadas o canceladas.
  bool get permiteComentarios =>
      !['cerrada', 'rechazada', 'cancelada'].contains(estado.toLowerCase());
}
