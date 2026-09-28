// Pruebas de INTEGRACIÓN Móvil -> API Laravel -> PostgreSQL.
//
// Requisitos:
//  1) API Laravel corriendo con una BD de pruebas y un usuario estudiante creado.
//  2) Ejecutar en emulador o celular:
//     flutter test integration_test/app_flow_test.dart \
//       --dart-define=API_BASE_URL=http://10.0.2.2:8000/api \
//       --dart-define=TEST_EMAIL=estudiante@test.com \
//       --dart-define=TEST_PASSWORD=password
import 'dart:convert';
import 'dart:io';

import 'package:campus_connect/app.dart';
import 'package:campus_connect/core/api/api_client.dart';
import 'package:campus_connect/core/api/api_exception.dart';
import 'package:campus_connect/core/storage/token_storage.dart';
import 'package:campus_connect/repositories/auth_repository.dart';
import 'package:campus_connect/repositories/comentario_repository.dart';
import 'package:campus_connect/repositories/solicitud_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _email = String.fromEnvironment('TEST_EMAIL', defaultValue: 'estudiante@test.com');
const _password = String.fromEnvironment('TEST_PASSWORD', defaultValue: 'password');

// PNG de 1x1 píxel, válido para probar la subida de evidencia.
const _pngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late TokenStorage tokens;
  late ApiClient api;
  late AuthRepository auth;
  late SolicitudRepository solicitudes;
  late ComentarioRepository comentarios;

  setUp(() async {
    tokens = TokenStorage();
    await tokens.clear();
    api = ApiClient(tokens);
    auth = AuthRepository(api, tokens);
    solicitudes = SolicitudRepository(api);
    comentarios = ComentarioRepository(api);
  });

  Future<Map<String, dynamic>> datosBase() async {
    await auth.login(_email, _password);
    final cat = await solicitudes.catalogos();
    return {
      'tipo_id': cat.tipos.first.id,
      'prioridad_id': cat.prioridades.first.id,
      'titulo': 'Proyector dañado ${DateTime.now().millisecondsSinceEpoch}',
      'descripcion': 'El proyector del aula 12 no enciende desde ayer.',
      'ubicacion': 'Aula 12',
    };
  }

  testWidgets('I1 - Login desde la UI y carga de "Mis solicitudes"', (tester) async {
    await tester.pumpWidget(CampusConnectApp(api: api, tokens: tokens));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), _email);
    await tester.enterText(find.byType(TextFormField).at(1), _password);
    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle(
      const Duration(seconds: 1),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 20),
    );

    expect(find.text('Mis solicitudes'), findsOneWidget);
  });

  test('I2 - Crear solicitud con evidencia (Móvil-API-BD)', () async {
    final datos = await datosBase();
    final archivo = File('${Directory.systemTemp.path}/evidencia_test.png')
      ..writeAsBytesSync(base64Decode(_pngBase64));

    final (creada, fallidas) = await solicitudes.crear(datos, [archivo.path]);
    expect(fallidas, 0);
    expect(creada.estado.toLowerCase(), 'pendiente');

    final guardada = await solicitudes.obtener(creada.id);
    expect(guardada.titulo, datos['titulo']);
    expect(guardada.evidencias.length, 1);

    final lista = await solicitudes.listar();
    expect(lista.items.any((s) => s.id == creada.id), isTrue);
  });

  test('I3 - Editar y eliminar una solicitud pendiente', () async {
    final datos = await datosBase();
    final (creada, _) = await solicitudes.crear(datos, []);

    final (editada, _) =
        await solicitudes.actualizar(creada.id, {...datos, 'titulo': 'Título editado 123'}, []);
    expect(editada.titulo, 'Título editado 123');

    await solicitudes.eliminar(creada.id);
    expect(
      () => solicitudes.obtener(creada.id),
      throwsA(isA<ApiException>()),
    );
  });

  test('I4 - Comentar una solicitud', () async {
    final datos = await datosBase();
    final (creada, _) = await solicitudes.crear(datos, []);

    await comentarios.crear(creada.id, 'Buen día, adjunto más detalles.');
    final lista = await comentarios.listar(creada.id);
    expect(lista.any((c) => c.contenido == 'Buen día, adjunto más detalles.'), isTrue);
  });
}
