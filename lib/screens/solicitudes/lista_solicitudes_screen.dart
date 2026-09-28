import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/solicitud_provider.dart';
import 'widgets/estado_vista.dart';
import 'widgets/solicitud_card.dart';

/// HU-10: lista de mis solicitudes con filtros, refresco y paginación.
class ListaSolicitudesScreen extends StatefulWidget {
  const ListaSolicitudesScreen({super.key});

  @override
  State<ListaSolicitudesScreen> createState() => _ListaSolicitudesScreenState();
}

class _ListaSolicitudesScreenState extends State<ListaSolicitudesScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_alDesplazar);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<SolicitudProvider>();
      p.cargarCatalogos();
      p.cargarLista();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _alDesplazar() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      context.read<SolicitudProvider>().cargarMas();
    }
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Quieres cerrar tu sesión en este dispositivo?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Cerrar sesión')),
        ],
      ),
    );
    if (confirmar == true && mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SolicitudProvider>();
    final usuario = context.watch<AuthProvider>().usuario;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis solicitudes'),
        actions: [
          IconButton(
            tooltip: usuario != null ? 'Cerrar sesión (${usuario.nombre})' : 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/solicitudes/nueva'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva solicitud'),
      ),
      body: Column(
        children: [
          _Filtros(provider: sp),
          Expanded(child: _Contenido(provider: sp, scroll: _scroll)),
        ],
      ),
    );
  }
}

class _Filtros extends StatelessWidget {
  final SolicitudProvider provider;

  const _Filtros({required this.provider});

  @override
  Widget build(BuildContext context) {
    final cat = provider.catalogos;
    if (cat == null) return const SizedBox(height: 8);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<int?>(
              isExpanded: true,
              value: provider.filtroEstadoId,
              hint: const Text('Estado'),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('Todos los estados')),
                for (final e in cat.estados)
                  DropdownMenuItem<int?>(value: e.id, child: Text(e.nombre)),
              ],
              onChanged: (v) => provider.aplicarFiltros(
                estadoId: v,
                tipoId: provider.filtroTipoId,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<int?>(
              isExpanded: true,
              value: provider.filtroTipoId,
              hint: const Text('Tipo'),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('Todos los tipos')),
                for (final t in cat.tipos)
                  DropdownMenuItem<int?>(value: t.id, child: Text(t.nombre)),
              ],
              onChanged: (v) => provider.aplicarFiltros(
                estadoId: provider.filtroEstadoId,
                tipoId: v,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  final SolicitudProvider provider;
  final ScrollController scroll;

  const _Contenido({required this.provider, required this.scroll});

  @override
  Widget build(BuildContext context) {
    if (provider.cargando && provider.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null && provider.items.isEmpty) {
      return Center(
        child: VistaError(mensaje: provider.error!, onReintentar: provider.cargarLista),
      );
    }

    final hayFiltros = provider.filtroEstadoId != null || provider.filtroTipoId != null;

    return RefreshIndicator(
      onRefresh: provider.cargarLista,
      child: provider.items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 80),
                VistaVacia(
                  icono: Icons.inbox_outlined,
                  titulo: hayFiltros
                      ? 'Sin resultados con estos filtros'
                      : 'Aún no tienes solicitudes',
                  mensaje: hayFiltros
                      ? 'Cambia los filtros para ver otras solicitudes.'
                      : 'Registra tu primera solicitud y sigue su avance desde aquí.',
                  accion: hayFiltros
                      ? null
                      : FilledButton(
                          onPressed: () => context.push('/solicitudes/nueva'),
                          child: const Text('Crear solicitud'),
                        ),
                ),
              ],
            )
          : ListView.builder(
              controller: scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 96, top: 4),
              itemCount: provider.items.length + (provider.cargandoMas ? 1 : 0),
              itemBuilder: (context, i) {
                if (i >= provider.items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final s = provider.items[i];
                return SolicitudCard(
                  solicitud: s,
                  onTap: () => context.push('/solicitudes/${s.id}'),
                );
              },
            ),
    );
  }
}
