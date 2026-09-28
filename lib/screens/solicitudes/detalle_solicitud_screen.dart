import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/utils/formatters.dart';
import '../../models/solicitud.dart';
import '../../providers/comentario_provider.dart';
import '../../providers/solicitud_provider.dart';
import 'widgets/comentarios_section.dart';
import 'widgets/estado_chip.dart';
import 'widgets/estado_vista.dart';
import 'widgets/timeline.dart';

/// HU-11 (detalle e historial), HU-08/09 (editar/eliminar) y HU-12 (comentarios).
class DetalleSolicitudScreen extends StatefulWidget {
  final int id;

  const DetalleSolicitudScreen({super.key, required this.id});

  @override
  State<DetalleSolicitudScreen> createState() => _DetalleSolicitudScreenState();
}

class _DetalleSolicitudScreenState extends State<DetalleSolicitudScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  Future<void> _cargar() {
    final sp = context.read<SolicitudProvider>();
    final cp = context.read<ComentarioProvider>();
    return Future.wait([sp.cargarDetalle(widget.id), cp.cargar(widget.id)]);
  }

  Future<void> _editar(Solicitud s) async {
    await context.push('/solicitudes/${s.id}/editar', extra: s);
    if (mounted) _cargar();
  }

  Future<void> _eliminar(Solicitud s) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar solicitud'),
        content: Text(
            '¿Seguro que quieres eliminar la solicitud ${s.codigo}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final provider = context.read<SolicitudProvider>();
    try {
      await provider.eliminar(s.id);
      messenger.showSnackBar(const SnackBar(content: Text('Solicitud eliminada.')));
      router.pop();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.detalle)));
    }
  }

  void _verFoto(String url) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(12),
        child: InteractiveViewer(
          child: Image.network(
            url,
            errorBuilder: (_, __, ___) => const Padding(
              padding: EdgeInsets.all(32),
              child: Text('No se pudo cargar la imagen.'),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SolicitudProvider>();
    final s = sp.detalle?.id == widget.id ? sp.detalle : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(s != null && s.codigo.isNotEmpty ? s.codigo : 'Solicitud'),
      ),
      body: s == null
          ? (sp.errorDetalle != null
              ? Center(child: VistaError(mensaje: sp.errorDetalle!, onReintentar: _cargar))
              : const Center(child: CircularProgressIndicator()))
          : RefreshIndicator(
              onRefresh: _cargar,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      EstadoChip(estado: s.estado),
                      const SizedBox(width: 8),
                      if (s.prioridad.isNotEmpty)
                        Chip(
                          label: Text('Prioridad ${s.prioridad.toLowerCase()}'),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(s.titulo, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  _Dato(icono: Icons.category_outlined, etiqueta: 'Tipo', valor: s.tipo),
                  _Dato(icono: Icons.place_outlined, etiqueta: 'Ubicación', valor: s.ubicacion),
                  _Dato(
                      icono: Icons.event_outlined,
                      etiqueta: 'Registrada',
                      valor: formatearFecha(s.createdAt)),
                  _Dato(
                      icono: Icons.person_outline,
                      etiqueta: 'Responsable',
                      valor: s.responsable ?? 'Sin asignar'),
                  const SizedBox(height: 12),
                  Text(s.descripcion),
                  if (s.evidencias.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('Evidencias', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 96,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: s.evidencias.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final url = s.evidencias[i].url;
                          return GestureDetector(
                            onTap: () => _verFoto(url),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                url,
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const SizedBox(
                                  width: 96,
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  if (s.esEditable) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _editar(s),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Editar'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _eliminar(s),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text('Seguimiento', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Timeline(items: sp.historial),
                  const SizedBox(height: 16),
                  Text('Comentarios', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ComentariosSection(solicitud: s),
                ],
              ),
            ),
    );
  }
}

class _Dato extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;

  const _Dato({required this.icono, required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 8),
          Text('$etiqueta: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(valor.isEmpty ? '-' : valor)),
        ],
      ),
    );
  }
}
