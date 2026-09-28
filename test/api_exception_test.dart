import 'package:campus_connect/core/api/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _respuesta(int codigo, {dynamic data}) {
  final req = RequestOptions(path: '/x');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: req, statusCode: codigo, data: data),
  );
}

void main() {
  group('U3 - ApiException', () {
    test('401 se traduce a credenciales inválidas', () {
      final e = ApiException.from(_respuesta(401));
      expect(e.statusCode, 401);
      expect(e.message, 'Credenciales inválidas o sesión expirada.');
    });

    test('403 usa el mensaje del servidor si existe', () {
      final e = ApiException.from(
          _respuesta(403, data: {'message': 'Solo se puede editar una solicitud pendiente.'}));
      expect(e.message, 'Solo se puede editar una solicitud pendiente.');
    });

    test('404 se traduce a mensaje claro', () {
      final e = ApiException.from(_respuesta(404));
      expect(e.message, 'No se encontró la información solicitada.');
    });

    test('422 conserva los errores por campo', () {
      final e = ApiException.from(_respuesta(422, data: {
        'message': 'The given data was invalid.',
        'errors': {
          'email': ['Correo no válido']
        },
      }));
      expect(e.message, 'Revisa los datos ingresados.');
      expect(e.fieldErrors['email'], ['Correo no válido']);
      expect(e.detalle, 'Correo no válido');
    });

    test('sin conexión se traduce a mensaje de red', () {
      final e = ApiException.from(DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      ));
      expect(e.message, contains('Sin conexión'));
    });
  });
}
