import 'package:campus_connect/core/router/app_router.dart';
import 'package:campus_connect/providers/auth_provider.dart';
import 'package:campus_connect/repositories/auth_repository.dart';
import 'package:campus_connect/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets('W4 - sin sesión el router redirige al Login', (tester) async {
    final repo = MockAuthRepository();
    when(() => repo.restaurarSesion()).thenAnswer((_) async => null);

    final auth = AuthProvider(repo);
    final router = AppRouter.create(auth);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: auth,
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await auth.iniciar();
    await tester.pumpAndSettle();

    expect(auth.status, AuthStatus.noAutenticado);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
