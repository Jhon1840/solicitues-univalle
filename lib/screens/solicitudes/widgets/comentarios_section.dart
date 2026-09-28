import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../models/comentario.dart';
import '../../../models/solicitud.dart';
import '../../../providers/comentario_provider.dart';

/// HU-12: leer y enviar comentarios de una solicitud.
class ComentariosSection extends StatefulWidget {
  final Solicitud solicitud;

  const ComentariosSection({super.key, required this.solicitud});

  @override
  State<ComentariosSection> createState() => _ComentariosSectionState();
}

class _ComentariosSectionState extends State<ComentariosSection> {
  final _formKey = GlobalKey<FormState>();
  final _texto = TextEditingController();

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final provider = context.read<ComentarioProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await provider.enviar(widget.solicitud.id, _texto.text.trim());
    if (!mounted) return;
    if (ok) {
      _texto.clear();
      FocusScope.of(context).unfocus();
    } else {
      messenger.showSnackBar(SnackBar(
        content: Text(provider.error ?? 'No se pudo enviar el comentario.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<ComentarioProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (cp.cargando && cp.comentarios.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (cp.comentarios.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Aún no hay comentarios en esta solicitud.'),
          )
        else
          for (final c in cp.comentarios) _Burbuja(comentario: c),
        const SizedBox(height: 12),
        if (!widget.solicitud.permiteComentarios)
          const Text('Esta solicitud está cerrada y ya no admite comentarios.')
        else
          Form(
            key: _formKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _texto,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un comentario',
                    ),
                    validator: Validators.comentario,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Enviar comentario',
                  onPressed: cp.enviando ? null : _enviar,
                  icon: cp.enviando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Burbuja extends StatelessWidget {
  final Comentario comentario;

  const _Burbuja({required this.comentario});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(comentario.autor,
                      style: tema.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                Text(formatearFecha(comentario.createdAt),
                    style: tema.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 4),
            Text(comentario.contenido),
          ],
        ),
      ),
    );
  }
}
