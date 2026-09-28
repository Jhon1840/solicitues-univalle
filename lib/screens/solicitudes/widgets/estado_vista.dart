import 'package:flutter/material.dart';

/// Pantalla vacía: invita a hacer algo.
class VistaVacia extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String mensaje;
  final Widget? accion;

  const VistaVacia({
    super.key,
    required this.icono,
    required this.titulo,
    required this.mensaje,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 64, color: tema.colorScheme.outline),
          const SizedBox(height: 12),
          Text(titulo, style: tema.textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(mensaje, textAlign: TextAlign.center),
          if (accion != null) ...[const SizedBox(height: 16), accion!],
        ],
      ),
    );
  }
}

/// Error con opción de reintentar: dice qué pasó y qué hacer.
class VistaError extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const VistaError({super.key, required this.mensaje, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return VistaVacia(
      icono: Icons.cloud_off_outlined,
      titulo: 'No se pudo cargar la información',
      mensaje: mensaje,
      accion: FilledButton.tonal(
        onPressed: onReintentar,
        child: const Text('Reintentar'),
      ),
    );
  }
}
