import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/validators.dart';
import '../../../models/evidencia.dart';

/// HU-06: adjuntar fotos (cámara o galería) con validación de formato y tamaño.
class EvidenciaPicker extends StatelessWidget {
  final List<XFile> fotos;
  final List<Evidencia> existentes;
  final ValueChanged<List<XFile>> onChanged;

  EvidenciaPicker({
    super.key,
    required this.fotos,
    required this.onChanged,
    this.existentes = const [],
  });

  final ImagePicker _picker = ImagePicker();

  Future<void> _agregar(BuildContext context, ImageSource origen) async {
    final messenger = ScaffoldMessenger.of(context);
    if (fotos.length + existentes.length >= ImageRules.maxFotos) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Puedes adjuntar hasta 5 fotos por solicitud.'),
      ));
      return;
    }
    final XFile? foto = await _picker.pickImage(
      source: origen,
      imageQuality: 70,
      maxWidth: 1600,
    );
    if (foto == null) return;

    final error = ImageRules.validar(nombre: foto.name, bytes: await foto.length());
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    onChanged([...fotos, foto]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => _agregar(context, ImageSource.camera),
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Cámara'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () => _agregar(context, ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Galería'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'JPG o PNG, máximo 5 MB por foto (hasta ${ImageRules.maxFotos}).',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (existentes.isNotEmpty || fotos.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in existentes)
                _Miniatura(
                  imagen: Image.network(
                    e.url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image_outlined),
                  ),
                ),
              for (final f in fotos)
                _Miniatura(
                  imagen: Image.file(File(f.path), fit: BoxFit.cover),
                  onQuitar: () => onChanged(fotos.where((x) => x != f).toList()),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Miniatura extends StatelessWidget {
  final Widget imagen;
  final VoidCallback? onQuitar;

  const _Miniatura({required this.imagen, this.onQuitar});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: imagen),
          if (onQuitar != null)
            Positioned(
              top: 2,
              right: 2,
              child: InkWell(
                onTap: onQuitar,
                child: const CircleAvatar(
                  radius: 11,
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
