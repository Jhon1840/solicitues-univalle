/// Validaciones de formularios (reutilizables y fáciles de probar).
class Validators {
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'El correo es obligatorio';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'Ingresa un correo válido';
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'La contraseña es obligatoria';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  static String? titulo(String? v) {
    if (v == null || v.trim().isEmpty) return 'El título es obligatorio';
    if (v.trim().length < 5) return 'Mínimo 5 caracteres';
    if (v.trim().length > 100) return 'Máximo 100 caracteres';
    return null;
  }

  static String? descripcion(String? v) {
    if (v == null || v.trim().isEmpty) return 'La descripción es obligatoria';
    if (v.trim().length < 10) return 'Describe mejor el problema (mínimo 10 caracteres)';
    if (v.trim().length > 1000) return 'Máximo 1000 caracteres';
    return null;
  }

  static String? ubicacion(String? v) {
    if (v == null || v.trim().isEmpty) return 'La ubicación es obligatoria';
    if (v.trim().length < 3) return 'Mínimo 3 caracteres';
    if (v.trim().length > 150) return 'Máximo 150 caracteres';
    return null;
  }

  static String? seleccion(Object? valor, String mensaje) =>
      valor == null ? mensaje : null;

  static String? comentario(String? v) {
    if (v == null || v.trim().isEmpty) return 'Escribe un comentario';
    if (v.trim().length > 500) return 'Máximo 500 caracteres';
    return null;
  }
}

/// Reglas para las imágenes de evidencia (HU-06).
class ImageRules {
  static const int maxBytes = 5 * 1024 * 1024; // 5 MB
  static const int maxFotos = 5;
  static const List<String> extensiones = ['jpg', 'jpeg', 'png'];

  /// Devuelve un mensaje de error o null si la imagen es válida.
  static String? validar({required String nombre, required int bytes}) {
    final ext = nombre.contains('.') ? nombre.split('.').last.toLowerCase() : '';
    if (!extensiones.contains(ext)) {
      return 'Formato no permitido. Usa una imagen JPG o PNG.';
    }
    if (bytes > maxBytes) return 'La imagen supera el máximo de 5 MB.';
    return null;
  }
}
