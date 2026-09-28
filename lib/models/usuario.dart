import 'json_helpers.dart';

class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String rol;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.rol = 'estudiante',
  });

  factory Usuario.fromJson(Map<String, dynamic> j) => Usuario(
        id: toInt(j['id']) ?? 0,
        nombre: (j['name'] ?? j['nombre'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        rol: nombreDe(j['rol'] ?? j['role'], 'estudiante'),
      );
}
