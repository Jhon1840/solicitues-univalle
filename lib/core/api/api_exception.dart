import 'package:dio/dio.dart';

/// Error de API ya traducido a un mensaje entendible para el usuario.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, List<String>> fieldErrors;

  const ApiException(
    this.message, {
    this.statusCode,
    this.fieldErrors = const {},
  });

  factory ApiException.from(Object error) {
    if (error is ApiException) return error;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const ApiException(
              'Sin conexión con el servidor. Revisa tu internet e intenta de nuevo.');
        default:
          break;
      }

      final code = error.response?.statusCode;
      final data = error.response?.data;
      final mensajeServidor =
          data is Map && data['message'] != null ? data['message'].toString() : null;

      switch (code) {
        case 401:
          return const ApiException('Credenciales inválidas o sesión expirada.',
              statusCode: 401);
        case 403:
          return ApiException(
              mensajeServidor ?? 'No tienes permiso para realizar esta acción.',
              statusCode: 403);
        case 404:
          return const ApiException('No se encontró la información solicitada.',
              statusCode: 404);
        case 422:
          final errores = <String, List<String>>{};
          if (data is Map && data['errors'] is Map) {
            (data['errors'] as Map).forEach((k, v) {
              errores[k.toString()] = v is List
                  ? v.map((e) => e.toString()).toList()
                  : [v.toString()];
            });
          }
          return ApiException('Revisa los datos ingresados.',
              statusCode: 422, fieldErrors: errores);
        default:
          return ApiException(
              mensajeServidor ?? 'Ocurrió un error inesperado. Intenta de nuevo.',
              statusCode: code);
      }
    }

    return const ApiException('Ocurrió un error inesperado. Intenta de nuevo.');
  }

  /// Primer error de campo (si existe) o el mensaje general.
  String get detalle {
    for (final lista in fieldErrors.values) {
      if (lista.isNotEmpty) return lista.first;
    }
    return message;
  }

  @override
  String toString() => message;
}
