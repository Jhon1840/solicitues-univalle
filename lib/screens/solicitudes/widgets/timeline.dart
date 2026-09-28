import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../../../models/historial_item.dart';

/// HU-11: línea de tiempo con cada cambio de estado.
class Timeline extends StatelessWidget {
  final List<HistorialItem> items;

  const Timeline({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text('Todavía no hay movimientos registrados.');
    }
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          _Fila(item: items[i], ultimo: i == items.length - 1),
      ],
    );
  }
}

class _Fila extends StatelessWidget {
  final HistorialItem item;
  final bool ultimo;

  const _Fila({required this.item, required this.ultimo});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: tema.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!ultimo)
                  Expanded(
                    child: Container(width: 2, color: tema.colorScheme.outlineVariant),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.estado,
                      style: tema.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  if (item.descripcion.isNotEmpty) Text(item.descripcion),
                  Text(
                    '${item.autor} - ${formatearFecha(item.createdAt)}',
                    style: tema.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
