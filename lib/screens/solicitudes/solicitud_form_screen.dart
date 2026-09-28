import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/utils/validators.dart';
import '../../models/solicitud.dart';
import '../../providers/solicitud_provider.dart';
import 'widgets/estado_vista.dart';
import 'widgets/evidencia_picker.dart';

/// HU-05, HU-06, HU-07 (crear) y HU-08 (editar). Si recibe [solicitud], edita.
class SolicitudFormScreen extends StatefulWidget {
  final Solicitud? solicitud;

  const SolicitudFormScreen({super.key, this.solicitud});

  @override
  State<SolicitudFormScreen> createState() => _SolicitudFormScreenState();
}

class _SolicitudFormScreenState extends State<SolicitudFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titulo;
  late final TextEditingController _descripcion;
  late final TextEditingController _ubicacion;
  int? _tipoId;
  int? _prioridadId;
  List<XFile> _fotos = [];
  bool _enviando = false;

  bool get _esEdicion => widget.solicitud != null;

  @override
  void initState() {
    super.initState();
    final s = widget.solicitud;
    _titulo = TextEditingController(text: s?.titulo ?? '');
    _descripcion = TextEditingController(text: s?.descripcion ?? '');
    _ubicacion = TextEditingController(text: s?.ubicacion ?? '');
    _tipoId = s?.tipoId;
    _prioridadId = s?.prioridadId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SolicitudProvider>().cargarCatalogos();
    });
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    _ubicacion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = context.read<SolicitudProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    setState(() => _enviando = true);
    try {
      // HU-07: antes de crear, avisar si ya existe una solicitud parecida.
      if (!_esEdicion) {
        final similares = await provider.buscarSimilares(
          tipoId: _tipoId!,
          ubicacion: _ubicacion.text.trim(),
        );
        if (similares.isNotEmpty && mounted) {
          final decision = await _dialogoDuplicados(similares);
          if (decision is Solicitud) {
            router.pushReplacement('/solicitudes/${decision.id}');
            return;
          }
          if (decision != true) return; // canceló
        }
      }

      final datos = {
        'tipo_id': _tipoId,
        'prioridad_id': _prioridadId,
        'titulo': _titulo.text.trim(),
        'descripcion': _descripcion.text.trim(),
        'ubicacion': _ubicacion.text.trim(),
      };
      final rutas = _fotos.map((f) => f.path).toList();

      final (solicitud, fotosFallidas) = _esEdicion
          ? await provider.actualizar(widget.solicitud!.id, datos, rutas)
          : await provider.crear(datos, rutas);

      final mensaje = _esEdicion
          ? 'Cambios guardados.'
          : 'Solicitud registrada. Código: ${solicitud.codigo}';
      messenger.showSnackBar(SnackBar(
        content: Text(fotosFallidas > 0
            ? '$mensaje No se pudieron subir $fotosFallidas foto(s); puedes intentarlo de nuevo editando la solicitud.'
            : mensaje),
      ));
      router.pop(true);
    } on ApiException catch (e) {
      // Los datos escritos se conservan para poder corregir y reintentar.
      messenger.showSnackBar(SnackBar(content: Text(e.detalle)));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  /// Devuelve una [Solicitud] (ver existente), true (continuar) o null (cancelar).
  Future<Object?> _dialogoDuplicados(List<Solicitud> similares) {
    return showDialog<Object>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Posible solicitud duplicada'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ya hay solicitudes activas parecidas. Toca una para ver su seguimiento:'),
              const SizedBox(height: 8),
              for (final s in similares.take(3))
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(s.titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${s.codigo} - ${s.estado}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(ctx, s),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Es otra, continuar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SolicitudProvider>();
    final cat = sp.catalogos;

    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar solicitud' : 'Nueva solicitud')),
      body: cat == null
          ? (sp.errorCatalogos != null
              ? Center(
                  child: VistaError(
                    mensaje: sp.errorCatalogos!,
                    onReintentar: () => sp.cargarCatalogos(forzar: true),
                  ),
                )
              : const Center(child: CircularProgressIndicator()))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  DropdownButtonFormField<int>(
                    value: _tipoId,
                    decoration: const InputDecoration(labelText: 'Tipo de solicitud'),
                    items: [
                      for (final t in cat.tipos)
                        DropdownMenuItem(value: t.id, child: Text(t.nombre)),
                    ],
                    onChanged: (v) => setState(() => _tipoId = v),
                    validator: (v) =>
                        Validators.seleccion(v, 'Selecciona un tipo de solicitud'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titulo,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 100,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: Validators.titulo,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descripcion,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 3,
                    maxLines: 6,
                    maxLength: 1000,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      alignLabelWithHint: true,
                    ),
                    validator: Validators.descripcion,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _ubicacion,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Ubicación',
                      hintText: 'Ej. Bloque B, aula 12',
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                    validator: Validators.ubicacion,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _prioridadId,
                    decoration: const InputDecoration(labelText: 'Prioridad sugerida'),
                    items: [
                      for (final p in cat.prioridades)
                        DropdownMenuItem(value: p.id, child: Text(p.nombre)),
                    ],
                    onChanged: (v) => setState(() => _prioridadId = v),
                    validator: (v) =>
                        Validators.seleccion(v, 'Selecciona una prioridad'),
                  ),
                  const SizedBox(height: 24),
                  Text('Evidencia', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  EvidenciaPicker(
                    fotos: _fotos,
                    existentes: widget.solicitud?.evidencias ?? const [],
                    onChanged: (f) => setState(() => _fotos = f),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _enviando ? null : _guardar,
                    child: _enviando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_esEdicion ? 'Guardar cambios' : 'Guardar solicitud'),
                  ),
                ],
              ),
            ),
    );
  }
}
