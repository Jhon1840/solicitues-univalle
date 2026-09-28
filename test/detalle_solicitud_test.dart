import 'package:campus_connect/models/comentario.dart';
import 'package:campus_connect/models/historial_item.dart';
import 'package:campus_connect/models/solicitud.dart';
import 'package:campus_connect/providers/comentario_provider.dart';
import 'package:campus_connect/providers/solicitud_provider.dart';
import 'package:campus_connect/repositories/comentario_repository.dart';
import 'package:campus_connect/repositories/solicitud_repository.dart';
import 'package:campus_connect/screens/solicitudes/detalle_solicitud_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockSolicitudRepository extends Mock implements SolicitudRepository {}

class MockComentarioRepository extends Mock implements ComentarioRepository {}

void main() {
  late MockSolicitudRepository solRepo;
  late MockComentarioRepository comRepo;

  setUp(() {
    solRepo = MockSolicitudRepository();
    comRepo = MockComentarioRepository();
    when(() => solRepo.historial(1)).thenAnswer((_) async => <HistorialItem>[]);
    when(() => comRepo.listar(1)).thenAnswer((_) async => <Comentario>[]);
  });

  Future<void> abrir(WidgetTester tester, String estado) async {
    when(() => solRepo.obtener(1)).thenAnswer(
      (_) async => Solicitud(id: 1, titulo: 'Proyector dañado', estado: estado),
    );
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SolicitudProvider(solRepo)),
          ChangeNotifierProvider(create: (_) => ComentarioProvider(comRepo)),
        ],
        child: const MaterialApp(home: DetalleSolicitudScreen(id: 1)),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('W3 - Detalle de solicitud', () {
    testWidgets('en estado "En atención" no aparecen Editar ni Eliminar',
        (tester) async {
      await abrir(tester, 'En atención');

      expect(find.text('Proyector dañado'), findsOneWidget);
      expect(find.text('Editar'), findsNothing);
      expect(find.text('Eliminar'), findsNothing);
    });

    testWidgets('en estado "Pendiente" sí aparecen Editar y Eliminar',
        (tester) async {
      await abrir(tester, 'Pendiente');

      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Eliminar'), findsOneWidget);
    });
  });
}
