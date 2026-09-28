import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/solicitud.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/solicitudes/detalle_solicitud_screen.dart';
import '../../screens/solicitudes/lista_solicitudes_screen.dart';
import '../../screens/solicitudes/solicitud_form_screen.dart';

/// Rutas protegidas: sin sesión siempre se redirige al login.
class AppRouter {
  static GoRouter create(AuthProvider auth) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: auth,
      redirect: (context, state) {
        final ruta = state.matchedLocation;
        switch (auth.status) {
          case AuthStatus.desconocido:
            return ruta == '/splash' ? null : '/splash';
          case AuthStatus.noAutenticado:
            return ruta == '/login' ? null : '/login';
          case AuthStatus.autenticado:
            return (ruta == '/login' || ruta == '/splash') ? '/' : null;
        }
      },
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const _Splash()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/', builder: (_, __) => const ListaSolicitudesScreen()),
        // "nueva" va antes de ":id" para que no se interprete como un id.
        GoRoute(
          path: '/solicitudes/nueva',
          builder: (_, __) => const SolicitudFormScreen(),
        ),
        GoRoute(
          path: '/solicitudes/:id',
          builder: (_, state) => DetalleSolicitudScreen(
            id: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/solicitudes/:id/editar',
          builder: (_, state) {
            final solicitud = state.extra;
            if (solicitud is Solicitud) {
              return SolicitudFormScreen(solicitud: solicitud);
            }
            return const _NoDisponible();
          },
        ),
      ],
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _NoDisponible extends StatelessWidget {
  const _NoDisponible();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Editar solicitud')),
        body: const Center(child: Text('La solicitud no está disponible.')),
      );
}
