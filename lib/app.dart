import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/comentario_provider.dart';
import 'providers/solicitud_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/comentario_repository.dart';
import 'repositories/solicitud_repository.dart';

/// Raíz de la aplicación: crea repositorios, providers y el router una sola vez.
class CampusConnectApp extends StatefulWidget {
  final ApiClient api;
  final TokenStorage tokens;

  const CampusConnectApp({super.key, required this.api, required this.tokens});

  @override
  State<CampusConnectApp> createState() => _CampusConnectAppState();
}

class _CampusConnectAppState extends State<CampusConnectApp> {
  late final AuthProvider _auth;
  late final SolicitudProvider _solicitudes;
  late final ComentarioProvider _comentarios;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _auth = AuthProvider(AuthRepository(widget.api, widget.tokens));
    _solicitudes = SolicitudProvider(SolicitudRepository(widget.api));
    _comentarios = ComentarioProvider(ComentarioRepository(widget.api));

    // Si la API responde 401 en cualquier llamada, se cierra la sesión.
    widget.api.onUnauthorized = _auth.manejarSesionExpirada;
    _auth.addListener(_alCambiarSesion);

    _router = AppRouter.create(_auth);
    _auth.iniciar();
  }

  /// Al cerrar sesión se borran los datos del usuario anterior.
  void _alCambiarSesion() {
    if (_auth.status == AuthStatus.noAutenticado) {
      _solicitudes.limpiar();
      _comentarios.limpiar();
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_alCambiarSesion);
    _router.dispose();
    _auth.dispose();
    _solicitudes.dispose();
    _comentarios.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _auth),
        ChangeNotifierProvider<SolicitudProvider>.value(value: _solicitudes),
        ChangeNotifierProvider<ComentarioProvider>.value(value: _comentarios),
      ],
      child: MaterialApp.router(
        title: 'CAMPUS CONNECT',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
