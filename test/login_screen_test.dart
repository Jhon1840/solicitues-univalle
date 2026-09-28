import 'package:campus_connect/models/usuario.dart';
import 'package:campus_connect/providers/auth_provider.dart';
import 'package:campus_connect/repositories/auth_repository.dart';
import 'package:campus_connect/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;
  late AuthProvider auth;

  setUpAll(() {
    registerFallbackValue('');
  });

  setUp(() {
    repo = MockAuthRepository();
    auth = AuthProvider(repo);
  });

  Widget app() => ChangeNotifierProvider<AuthProvider>.value(
        value: auth,
        child: const MaterialApp(home: LoginScreen()),
      );

  group('W1 - Login', () {
    testWidgets('con campos vacíos muestra errores y no llama a la API',
        (tester) async {
      await tester.pumpWidget(app());

      await tester.tap(find.text('Ingresar'));
      await tester.pump();

      expect(find.text('El correo es obligatorio'), findsOneWidget);
      expect(find.text('La contraseña es obligatoria'), findsOneWidget);
      verifyNever(() => repo.login(any(), any()));
    });

    testWidgets('con datos válidos llama a login y queda autenticado',
        (tester) async {
      when(() => repo.login('ana@univ.edu', '123456')).thenAnswer(
        (_) async => const Usuario(id: 1, nombre: 'Ana', email: 'ana@univ.edu'),
      );

      await tester.pumpWidget(app());
      await tester.enterText(find.byType(TextFormField).at(0), 'ana@univ.edu');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');
      await tester.tap(find.text('Ingresar'));
      await tester.pump();
      await tester.pump();

      verify(() => repo.login('ana@univ.edu', '123456')).called(1);
      expect(auth.status, AuthStatus.autenticado);
    });
  });
}
