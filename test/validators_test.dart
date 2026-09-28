import 'package:campus_connect/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('U1 - Validators', () {
    test('correo vacío, inválido y válido', () {
      expect(Validators.email(''), 'El correo es obligatorio');
      expect(Validators.email(null), 'El correo es obligatorio');
      expect(Validators.email('sin-arroba'), 'Ingresa un correo válido');
      expect(Validators.email('ana@univ.edu'), isNull);
    });

    test('contraseña vacía, corta y válida', () {
      expect(Validators.password(''), 'La contraseña es obligatoria');
      expect(Validators.password('123'), 'Mínimo 6 caracteres');
      expect(Validators.password('123456'), isNull);
    });

    test('título: obligatorio, mínimo 5 y máximo 100', () {
      expect(Validators.titulo(' '), 'El título es obligatorio');
      expect(Validators.titulo('abc'), 'Mínimo 5 caracteres');
      expect(Validators.titulo('a' * 101), 'Máximo 100 caracteres');
      expect(Validators.titulo('Proyector dañado'), isNull);
    });

    test('descripción: obligatoria y mínimo 10', () {
      expect(Validators.descripcion(''), 'La descripción es obligatoria');
      expect(Validators.descripcion('corta'), isNotNull);
      expect(Validators.descripcion('El proyector no enciende'), isNull);
    });

    test('ubicación y comentario', () {
      expect(Validators.ubicacion(''), 'La ubicación es obligatoria');
      expect(Validators.ubicacion('Aula 12'), isNull);
      expect(Validators.comentario('  '), 'Escribe un comentario');
      expect(Validators.comentario('Gracias'), isNull);
    });

    test('reglas de imagen: formato y tamaño', () {
      expect(ImageRules.validar(nombre: 'foto.jpg', bytes: 1000), isNull);
      expect(ImageRules.validar(nombre: 'foto.PNG', bytes: 1000), isNull);
      expect(ImageRules.validar(nombre: 'doc.pdf', bytes: 1000), isNotNull);
      expect(
        ImageRules.validar(nombre: 'grande.jpg', bytes: ImageRules.maxBytes + 1),
        'La imagen supera el máximo de 5 MB.',
      );
    });
  });
}
