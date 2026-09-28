import 'package:flutter/material.dart';

/// Etiqueta de color según el estado de la solicitud.
class EstadoChip extends StatelessWidget {
  final String estado;

  const EstadoChip({super.key, required this.estado});

  Color _color() {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange.shade800;
      case 'en atención':
      case 'en atencion':
        return Colors.blue.shade700;
      case 'resuelta':
        return Colors.green.shade700;
      case 'cerrada':
        return Colors.grey.shade700;
      case 'rechazada':
      case 'cancelada':
        return Colors.red.shade700;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
