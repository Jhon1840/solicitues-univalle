import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../../../models/solicitud.dart';
import 'estado_chip.dart';

class SolicitudCard extends StatelessWidget {
  final Solicitud solicitud;
  final VoidCallback onTap;

  const SolicitudCard({super.key, required this.solicitud, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(solicitud.codigo, style: tema.textTheme.labelMedium),
                  const Spacer(),
                  EstadoChip(estado: solicitud.estado),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                solicitud.titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tema.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                '${solicitud.tipo} - ${formatearFecha(solicitud.createdAt)}',
                style: tema.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
