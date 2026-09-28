import 'package:dio/dio.dart';

import '../config.dart';
import '../storage/token_storage.dart';

/// Cliente HTTP único de la app. Agrega el token a cada petición y
/// avisa cuando la API responde 401 (sesión expirada).
class ApiClient {
  final Dio dio;
  final TokenStorage tokenStorage;

  /// Se ejecuta cuando una petición (distinta de /login) recibe 401.
  void Function()? onUnauthorized;

  ApiClient(this.tokenStorage, {Dio? dio, String? baseUrl})
      : dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl ?? AppConfig.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              headers: {'Accept': 'application/json'},
            )) {
    this.dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.read();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final esLogin = error.requestOptions.path == '/login';
        if (error.response?.statusCode == 401 && !esLogin) {
          await tokenStorage.clear();
          onUnauthorized?.call();
        }
        handler.next(error);
      },
    ));
  }
}
