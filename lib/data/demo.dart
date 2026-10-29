import 'dart:math';

import 'package:drift/drift.dart';
import 'package:intl/intl.dart';

import 'database.dart';
import 'registro.dart';

/// Datos inventados para probar la app sin tener que llenar nada.
Future<void> cargarDatosDeEjemplo(KipuDb db) async {
  final azar = Random(7);
  String fecha(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  T elegir<T>(List<T> l) => l[azar.nextInt(l.length)];

  await db.borrarTodo();

  final colegios = {
    'Elite School': ('Huacho', 0xFFF07A2D),
    'I.E. Nikola Tesla': ('Huaura', 0xFF16A37F),
    'I.E. José Carlos Mariátegui': ('Végueta', 0xFF8B5CF6),
  };
  final cursos = [
    ('Elite School', 'Secundaria', '1.° año', 'A', 'Química'),
    ('Elite School', 'Secundaria', '4.° año', 'C', 'Física'),
    ('Elite School', 'Secundaria', '5.° año', 'B', 'Química'),
    ('I.E. Nikola Tesla', 'Secundaria', '5.° año', 'A', 'Biología'),
    ('I.E. Nikola Tesla', 'Secundaria', '3.° año', 'B', 'Química'),
    (
      'I.E. José Carlos Mariátegui',
      'Primaria',
      '5.° grado',
      'C',
      'Ciencia y Tecnología',
    ),
  ];
  const apellidos = [
    'QUISPE',
    'MAMANI',
    'FLORES',
    'RODRÍGUEZ',
    'SÁNCHEZ',
    'GARCÍA',
    'ROJAS',
    'HUAMÁN',
    'CHÁVEZ',
    'RAMOS',
    'TORRES',
    'DÍAZ',
    'MENDOZA',
    'CASTILLO',
    'VARGAS',
    'ESPINOZA',
    'RIVERA',
    'FERNÁNDEZ',
    'TREBEJO',
    'HUSUPOMA',
    'DE LA CRUZ',
    'PAREDES',
    'CÓRDOVA',
    'SALAZAR',
    'VILLANUEVA',
    'PALOMINO',
  ];
  const nombres = [
    'Luz Angélica',
    'Luna',
    'Fernanda',
    'Mateo',
    'Thiago',
    'Valentina',
    'Camila',
    'Sebastián',
    'Adrián',
    'Lucía',
    'Ximena',
    'Diego',
    'Gael',
    'Mía',
    'Rodrigo',
    'Alessandra',
    'Joaquín',
    'Daniela',
    'Santiago',
    'Ariana',
    'Fabricio',
    'Nicole',
    'Leonardo',
    'Brenda',
  ];
  const competencias = [
    'Indaga mediante métodos científicos',
    'Explica el mundo físico',
    'Diseña y construye soluciones tecnológicas',
  ];
  // Reparto aproximado: 20 % AD, 50 % A, 22 % B, 8 % C.
  String nota(double nivel) {
    final r = azar.nextDouble() + nivel;
    if (r > 1.0) return 'AD';
    if (r > 0.42) return 'A';
    if (r > 0.12) return 'B';
    return 'C';
  }

  final hoy = DateTime.now();
  final dias = <DateTime>[];
  for (var d = hoy; dias.length < 12; d = d.subtract(const Duration(days: 1))) {
    if (d.weekday <= DateTime.friday) dias.add(d);
  }

  // Horario semanal: (curso, día, inicio, fin)
  const bloques = [
    (0, 1, '07:50', '09:20'),
    (1, 1, '09:35', '11:05'),
    (2, 1, '11:20', '12:50'),
    (3, 2, '07:50', '09:20'),
    (4, 2, '09:35', '11:05'),
    (5, 2, '13:00', '14:30'),
    (0, 3, '07:50', '09:20'),
    (2, 3, '09:35', '11:05'),
    (1, 3, '11:20', '12:50'),
    (3, 3, '13:00', '14:30'),
    (4, 4, '07:50', '09:20'),
    (5, 4, '09:35', '11:05'),
    (0, 4, '11:20', '12:50'),
    (1, 5, '07:50', '09:20'),
    (2, 5, '09:35', '11:05'),
    (3, 5, '11:20', '12:50'),
  ];
  final idCursos = <int>[];

  final idColegio = <String, int>{};
  final idEstudiantes = <int>[];
  await db.transaction(() async {
    for (final c in colegios.entries) {
      idColegio[c.key] = await db.crearColegio(
        c.key,
        c.value.$1,
        color: c.value.$2,
      );
    }
    for (final c in cursos) {
      final cursoId = await db.crearCurso(
        CursosCompanion.insert(
          colegioId: idColegio[c.$1]!,
          nivel: c.$2,
          grado: c.$3,
          seccion: c.$4,
          nombre: c.$5,
          area: const Value('Ciencia y Tecnología'),
        ),
      );
      idCursos.add(cursoId);
      final alumnos = <(int, double)>[];
      final cantidad = 22 + azar.nextInt(10);
      for (var i = 0; i < cantidad; i++) {
        final id = await db
            .into(db.estudiantes)
            .insert(
              EstudiantesCompanion.insert(
                cursoId: cursoId,
                apellidos: '${elegir(apellidos)} ${elegir(apellidos)}',
                nombres: elegir(nombres),
              ),
            );
        idEstudiantes.add(id);
        // Cada estudiante tiene su propio nivel para que las notas sean coherentes.
        final nivel = azar.nextDouble() * 0.5 - 0.15;
        alumnos.add((id, nivel));
        await db.batch((b) {
          for (var p = 1; p <= 3; p++) {
            for (final comp in competencias) {
              b.insert(
                db.notas,
                NotasCompanion.insert(
                  estudianteId: id,
                  periodo: p,
                  competencia: comp,
                  nota: nota(nivel),
                ),
              );
            }
          }
          for (final d in dias.skip(1)) {
            final r = azar.nextDouble();
            b.insert(
              db.asistencias,
              AsistenciasCompanion.insert(
                estudianteId: id,
                fecha: fecha(d),
                estado: r < 0.86
                    ? 'P'
                    : (r < 0.93 ? 'T' : (r < 0.97 ? 'F' : 'J')),
              ),
            );
          }
        });
      }
      await _registroDeEjemplo(db, cursoId, alumnos, azar, fecha(hoy));
    }

    await db.batch(
      (b) => b.insertAll(db.horarios, [
        for (final (curso, dia, inicio, fin) in bloques)
          HorariosCompanion.insert(
            cursoId: idCursos[curso],
            dia: dia,
            inicio: inicio,
            fin: fin,
          ),
      ]),
    );

    final eventos = <EventosCompanion>[
      EventosCompanion.insert(
        fecha: fecha(hoy),
        hora: const Value('08:00'),
        titulo: 'Entrega de libretas',
        etiqueta: const Value('5.° B · Química'),
      ),
      EventosCompanion.insert(
        fecha: fecha(hoy),
        hora: const Value('12:00'),
        titulo: 'Entrega de carpeta pedagógica a dirección',
        etiqueta: const Value('Elite School'),
      ),
      EventosCompanion.insert(
        fecha: fecha(hoy),
        hora: const Value('15:30'),
        titulo: 'Simulacro de evaluación',
        etiqueta: const Value('1.° a 5.° · Nikola Tesla'),
      ),
      EventosCompanion.insert(
        fecha: fecha(hoy.add(const Duration(days: 1))),
        hora: const Value('18:00'),
        titulo: 'Reunión con padres de familia',
        etiqueta: const Value('4.° C · Física'),
      ),
      EventosCompanion.insert(
        fecha: fecha(hoy.add(const Duration(days: 3))),
        titulo: 'Feria de ciencias',
        etiqueta: const Value('Elite School'),
      ),
      EventosCompanion.insert(
        fecha: fecha(hoy.add(const Duration(days: 5))),
        hora: const Value('10:00'),
        titulo: 'Cierre de registro del bimestre',
      ),
    ];
    // Cumpleaños de algunos estudiantes.
    final cumpleaneros = await (db.select(db.estudiantes)..limit(4)).get();
    for (var i = 0; i < cumpleaneros.length; i++) {
      final e = cumpleaneros[i];
      final c = cursos[0];
      eventos.add(
        EventosCompanion.insert(
          fecha: fecha(hoy.add(Duration(days: i < 2 ? 0 : i))),
          titulo:
              '${e.apellidos.split(' ').first} ${e.nombres.split(' ').first}',
          etiqueta: Value('${c.$3} ${c.$4} · ${c.$1}'),
          tipo: const Value('cumple'),
        ),
      );
    }
    await db.batch((b) => b.insertAll(db.eventos, eventos));
  });
}

/// Registro auxiliar del 1.° bimestre: columnas mezcladas, una en equipo, un
/// promedio (calculada, aún vacía) y algo de conducta de hoy.
Future<void> _registroDeEjemplo(
  KipuDb db,
  int cursoId,
  List<(int, double)> alumnos,
  Random azar,
  String hoy,
) async {
  final inicio = DateTime(DateTime.now().year, 3, 16);
  String dia(int n) =>
      DateFormat('yyyy-MM-dd').format(inicio.add(Duration(days: n)));
  final columnas = [
    ('F1', 'Materia y energía', 'vigesimal', false, 'nota', 2),
    ('T1', 'Informe de laboratorio', 'cneb', false, 'nota', 6),
    ('F2', 'Tabla periódica', 'vigesimal', false, 'nota', 13),
    ('FB', 'Feedback de la práctica', 'logrado', false, 'nota', 15),
    ('Exp.', 'Exposición', 'vigesimal', true, 'nota', 20),
    ('F3', 'Enlaces químicos', 'vigesimal', false, 'nota', 27),
    ('Prom.', null, null, false, 'calculada', null),
  ];
  // Equipos de cuatro en el orden de la lista.
  final equipos = {
    for (var i = 0; i < alumnos.length; i++) alumnos[i].$1: i ~/ 4 + 1,
  };
  await db.guardarEquipos(cursoId, equipos);
  final notaEquipo = <int, String>{};
  for (final (codigo, tema, escala, enEquipo, tipo, d) in columnas) {
    final col = await db.crearColumna(
      RegistroColumnasCompanion.insert(
        cursoId: cursoId,
        periodo: 1,
        orden: 0,
        codigo: codigo,
        tema: Value(tema),
        fecha: Value(d == null ? null : dia(d)),
        tipo: Value(tipo),
        escala: Value(escala),
        enEquipo: Value(enEquipo),
      ),
    );
    if (tipo != 'nota') continue;
    await db.batch((b) {
      for (final (id, nivel) in alumnos) {
        // F3 todavía se está calificando: quedan varias vacías.
        if (codigo == 'F3' && azar.nextDouble() < .45) continue;
        final puntaje = 13 + nivel * 11 + azar.nextDouble() * 6 - 3;
        final String valor;
        switch (escala) {
          case 'cneb':
            valor = puntaje >= 17.5
                ? 'AD'
                : (puntaje >= 13.5 ? 'A' : (puntaje >= 10.5 ? 'B' : 'C'));
          case 'logrado':
            valor = puntaje >= 11 ? 'Logrado' : 'No logrado';
          default:
            final n = puntaje.clamp(5, 20).round();
            valor = enEquipo
                ? notaEquipo.putIfAbsent(equipos[id]!, () => '$n')
                : '$n';
        }
        b.insert(
          db.registroNotas,
          RegistroNotasCompanion.insert(
            columnaId: col,
            estudianteId: id,
            valor: valor,
          ),
        );
      }
    });
  }
  const buenas = ['Participa', 'Ayuda a un compañero', 'Trabaja en equipo'];
  const malas = ['No trae material', 'Interrumpe', 'Sin tarea'];
  for (final (id, _) in alumnos) {
    final r = azar.nextDouble();
    if (r < .22) {
      await db.anotarConducta(id, hoy, true, buenas[azar.nextInt(3)]);
    } else if (r < .3) {
      await db.anotarConducta(id, hoy, false, malas[azar.nextInt(3)]);
    }
  }
}
