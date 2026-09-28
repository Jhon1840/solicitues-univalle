import 'json_helpers.dart';

class Evidencia {
  final int id;
  final String url;

  const Evidencia({required this.id, required this.url});

  factory Evidencia.fromJson(Map<String, dynamic> j) => Evidencia(
        id: toInt(j['id']) ?? 0,
        url: (j['url'] ?? '').toString(),
      );
}
