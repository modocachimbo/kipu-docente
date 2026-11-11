import 'package:flutter_test/flutter_test.dart';
import 'package:kipu/data/academico.dart';
import 'package:kipu/data/avisos.dart';
import 'package:kipu/data/database.dart';
import 'package:kipu/data/diario_db.dart';

void main() {
  test('eventos que se repiten', () {
    expect(ocurreEl('2026-11-10', null, '2026-11-10'), isTrue);
    expect(ocurreEl('2026-11-10', null, '2026-11-17'), isFalse);
    expect(ocurreEl('2026-11-10', 'semanal', '2026-11-17'), isTrue);
    expect(ocurreEl('2026-11-10', 'semanal', '2026-11-18'), isFalse);
    expect(ocurreEl('2026-11-10', 'semanal', '2026-11-03'), isFalse);
    expect(ocurreEl('2026-11-10', 'mensual', '2026-12-10'), isTrue);
    expect(ocurreEl('2026-11-10', 'anual', '2027-11-10'), isTrue);
    expect(ocurreEl('2026-11-10', 'anual', '2027-12-10'), isFalse);
  });

  Evento ev(int id, String fecha, {String? hora, int? recordar, String? repetir, String tipo = 'tarea'}) => Evento(
        id: id,
        fecha: fecha,
        hora: hora,
        titulo: 'Evento $id',
        tipo: tipo,
        recordar: recordar,
        repetir: repetir,
      );

  test('aviso del evento con minutos antes', () {
    final d = DatosAvisos(
      eventos: [
        ev(1, '2026-11-12', hora: '15:30', recordar: 10),
        ev(2, '2026-11-12', recordar: 1440), // todo el día, 1 día antes → 11 a las 7:00
        ev(3, '2026-11-12', hora: '09:00'), // sin aviso
      ],
      ajustes: const AjustesAvisos(cumples: false, cierre: false, pendientes: false),
    );
    final r = calcularAvisos(d, DateTime(2026, 11, 10), DateTime(2026, 11, 20));
    expect(r.map((a) => a.cuando), [DateTime(2026, 11, 11, 7), DateTime(2026, 11, 12, 15, 20)]);
    expect(r.last.cuerpo, 'Tarea · Hoy a las 3:30 p. m.');
    expect(r.first.cuerpo, 'Tarea · Mañana, todo el día');
  });

  test('repetidos, cierre de periodo y fuera de rango', () {
    final d = DatosAvisos(
      eventos: [ev(1, '2026-11-02', hora: '08:00', recordar: 0, repetir: 'semanal')],
      periodos: const [Periodo('4.° bimestre', fin: '2026-11-13')],
      ajustes: const AjustesAvisos(cumples: false, pendientes: false),
    );
    final r = calcularAvisos(d, DateTime(2026, 11, 10), DateTime(2026, 11, 17));
    expect(r.map((a) => a.clave), ['p:4.° bimestre:2026-11-10', 'p:4.° bimestre:2026-11-13', 'e:1:2026-11-16']);
    expect(r.first.titulo, 'Faltan 3 días para cerrar el 4.° bimestre');
  });

  test('ajustes de avisos se guardan', () {
    const a = AjustesAvisos(clases: true, minutosClase: 5, cumples: false);
    final b = AjustesAvisos.deTexto(a.aTexto());
    expect([b.clases, b.minutosClase, b.cumples, b.cierre], [true, 5, false, true]);
    expect(AjustesAvisos.deTexto('x').cumples, isTrue);
    expect(horaBonita('00:05'), '12:05 a. m.');
    expect(horaBonita('12:00'), '12:00 p. m.');
  });

  test('feriado de un colegio no quita las clases de otro', () {
    final t = DateTime(2026);
    Colegio col(int id) => Colegio(id: id, nombre: 'Colegio $id', pais: 'PE', creado: t);
    Curso cur(int id, int colegio) => Curso(
          id: id,
          colegioId: colegio,
          nivel: 'Secundaria',
          grado: '1.°',
          seccion: 'A',
          nombre: 'Curso $id',
          creado: t,
        );
    // 2026-11-12 es jueves (4).
    final clases = [
      (Horario(id: 1, cursoId: 1, dia: 4, inicio: '08:00', fin: '09:00'), CursoConColegio(cur(1, 1), col(1), 0)),
      (Horario(id: 2, cursoId: 2, dia: 4, inicio: '14:00', fin: '15:00'), CursoConColegio(cur(2, 2), col(2), 0)),
    ];
    final feriado = Evento(id: 9, fecha: '2026-11-12', titulo: 'Aniversario', tipo: 'feriado', colegioId: 1);
    final d = DatosAvisos(
      clases: clases,
      eventos: [feriado],
      colegios: const {1: 'Colegio 1', 2: 'Colegio 2'},
      ajustes: const AjustesAvisos(clases: true, cumples: false, cierre: false, pendientes: false),
    );
    final r = calcularAvisos(d, DateTime(2026, 11, 12), DateTime(2026, 11, 13));
    expect(r.map((a) => a.clave), ['c:2:2026-11-12']);
    expect(r.single.cuerpo, contains('Colegio 2'));
    // Feriado para todos: ninguna clase.
    final todos = Evento(id: 9, fecha: '2026-11-12', titulo: 'Feriado', tipo: 'feriado');
    final d2 = DatosAvisos(clases: clases, eventos: [todos], ajustes: d.ajustes);
    expect(calcularAvisos(d2, DateTime(2026, 11, 12), DateTime(2026, 11, 13)), isEmpty);
  });
}
