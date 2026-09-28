/// Utilidades para leer JSON de forma tolerante (la API puede variar ligeramente).

int? toInt(dynamic v) => v is int ? v : int.tryParse('$v');

/// Laravel Resources envuelven la respuesta en {"data": ...}.
dynamic unwrap(dynamic body) =>
    body is Map && body.containsKey('data') ? body['data'] : body;

Map<String, dynamic> asMap(dynamic v) => Map<String, dynamic>.from(v as Map);

/// Acepta "Pendiente" o {"id": 1, "nombre": "Pendiente"} (o "name").
String nombreDe(dynamic v, [String porDefecto = '']) {
  if (v == null) return porDefecto;
  if (v is String) return v;
  if (v is Map) return (v['nombre'] ?? v['name'] ?? porDefecto).toString();
  return v.toString();
}

int? idDe(dynamic v) => v is Map ? toInt(v['id']) : null;

DateTime? fechaDe(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString())?.toLocal();
