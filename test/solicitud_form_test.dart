import 'package:campus_connect/models/catalogo.dart';
import 'package:campus_connect/providers/solicitud_provider.dart';
import 'package:campus_connect/repositories/solicitud_repository.dart';
import 'package:campus_connect/screens/solicitudes/solicitud_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockSolicitudRepository extends Mock implements SolicitudRepository {}

void main() {
  late MockSolicitudRepository repo;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    repo = MockSolicitudRepository();
    when(() => repo.catalogos()).thenAnswer(
      (_) async => const Catalogos(
        tipos: [CatalogoItem(id: 1, nombre: 'Mantenimiento')],
        prioridades: [CatalogoItem(id: 1, nombre: 'Alta')],
        estados: [CatalogoItem(id: 1, nombre: 'Pendiente')],
      ),
    );
  });

  testWidgets('W2 - crear solicitud incompleta no envía y muestra validaciones',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SolicitudProvider(repo),
        child: const MaterialApp(home: SolicitudFormScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar solicitud'));
    await tester.pump();

    expect(find.text('Selecciona un tipo de solicitud'), findsOneWidget);
    expect(find.text('El título es obligatorio'), findsOneWidget);
    expect(find.text('La descripción es obligatoria'), findsOneWidget);
    expect(find.text('La ubicación es obligatoria'), findsOneWidget);
    expect(find.text('Selecciona una prioridad'), findsOneWidget);
    verifyNever(() => repo.crear(any(), any()));
  });
}
