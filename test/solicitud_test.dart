import 'package:campus_connect/models/solicitud.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('U2 - Modelo Solicitud', () {
    test('fromJson lee tipo/prioridad/estado como objeto y genera código', () {
      final s = Solicitud.fromJson({
        'id': 7,
        'titulo': 'Proyector dañado',
        'descripcion': 'No enciende',
        'ubicacion': 'Aula 12',
        'tipo': {'id': 1, 'nombre': 'Mantenimiento'},
        'prioridad': {'id': 2, 'nombre': 'Alta'},
        'estado': {'id': 1, 'nombre': 'Pendiente'},
        'responsable': {'id': 5, 'name': 'Carlos Pérez'},
        'evidencias': [
          {'id': 1, 'url': 'http://localhost/storage/a.jpg'}
        ],
        'created_at': '2026-09-28T10:30:00Z',
      });

      expect(s.id, 7);
      expect(s.codigo, 'SOL-00007');
      expect(s.tipo, 'Mantenimiento');
      expect(s.tipoId, 1);
      expect(s.prioridadId, 2);
      expect(s.estado, 'Pendiente');
      expect(s.responsable, 'Carlos Pérez');
      expect(s.evidencias.length, 1);
      expect(s.createdAt, isNotNull);
    });

    test('fromJson acepta textos simples y responsable nulo', () {
      final s = Solicitud.fromJson({
        'id': 1,
        'codigo': 'SOL-ABC',
        'titulo': 'Wifi caído',
        'tipo': 'Soporte',
        'estado': 'En atención',
      });
      expect(s.codigo, 'SOL-ABC');
      expect(s.tipo, 'Soporte');
      expect(s.responsable, isNull);
      expect(s.evidencias, isEmpty);
    });

    test('esEditable: solo cuando está Pendiente', () {
      const pendiente = Solicitud(id: 1, titulo: 'x', estado: 'Pendiente');
      const enAtencion = Solicitud(id: 2, titulo: 'x', estado: 'En atención');
      const cerrada = Solicitud(id: 3, titulo: 'x', estado: 'Cerrada');
      expect(pendiente.esEditable, isTrue);
      expect(enAtencion.esEditable, isFalse);
      expect(cerrada.esEditable, isFalse);
    });

    test('permiteComentarios: no en cerradas ni rechazadas', () {
      const abierta = Solicitud(id: 1, titulo: 'x', estado: 'En atención');
      const cerrada = Solicitud(id: 2, titulo: 'x', estado: 'Cerrada');
      const rechazada = Solicitud(id: 3, titulo: 'x', estado: 'Rechazada');
      expect(abierta.permiteComentarios, isTrue);
      expect(cerrada.permiteComentarios, isFalse);
      expect(rechazada.permiteComentarios, isFalse);
    });
  });
}
