import 'dart:math';

import 'package:drift/drift.dart';
import 'package:intl/intl.dart';

import 'academico.dart';
import 'calculo.dart';
import 'columnas.dart';
import 'columnas_db.dart';
import 'database.dart';
import 'evaluacion_db.dart';
import 'paises.dart';
import 'registro.dart';

/// Datos inventados para probar la app sin tener que llenar nada.
Future<void> cargarDatosDeEjemplo(KipuDb db) async {
  final azar = Random(7);
  String fecha(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  T elegir<T>(List<T> l) => l[azar.nextInt(l.length)];

  await db.borrarTodo();
  // Opciones de columnas de una carga anterior (los ids se reutilizan).
  await (db.delete(db.ajustes)..where(
        (a) =>
            a.clave.like('columna_cfg_%') |
            a.clave.like('nota_coment_%') |
            a.clave.like('calculo_manual_%'),
      ))
      .go();

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
  final ayer = fecha(hoy.subtract(const Duration(days: 1)));
  final dias = <DateTime>[];
  for (var d = hoy; dias.length < 12; d = d.subtract(const Duration(days: 1))) {
    if (d.weekday <= DateTime.friday) dias.add(d);
  }

  // Año escolar con sus cuatro bimestres y vacaciones de medio año. Antes de
  // abril se muestra el año que acaba de terminar, para que haya datos.
  final anio = hoy.month < 4 ? hoy.year - 1 : hoy.year;
  final periodos = [
    Periodo('1.° bimestre', inicio: '$anio-03-16', fin: '$anio-05-15'),
    Periodo('2.° bimestre', inicio: '$anio-05-25', fin: '$anio-07-24'),
    Periodo('3.° bimestre', inicio: '$anio-08-10', fin: '$anio-10-09'),
    Periodo('4.° bimestre', inicio: '$anio-10-19', fin: '$anio-12-18'),
  ];
  final feriados = peru.feriadosDe(anio);
  // Días de clase de cada periodo hasta ayer (hoy aún no se toma lista).
  final diasDeClase = <int, List<DateTime>>{};
  for (var p = 0; p < periodos.length; p++) {
    final l = <DateTime>[];
    for (
      var d = DateTime.parse(periodos[p].inicio!);
      fecha(d).compareTo(periodos[p].fin!) <= 0 &&
          fecha(d).compareTo(ayer) <= 0;
      d = DateTime(d.year, d.month, d.day + 1)
    ) {
      if (d.weekday <= DateTime.friday && !feriados.containsKey(fecha(d))) {
        l.add(d);
      }
    }
    diasDeClase[p + 1] = l;
  }

  // Cada colegio tiene sus propias horas y recreos: (inicio, fin, recreo).
  const franjas = {
    'Elite School': [
      ('07:50', '09:20', false),
      ('09:20', '09:35', true),
      ('09:35', '11:05', false),
      ('11:05', '11:20', true),
      ('11:20', '12:50', false),
      ('12:50', '13:00', true),
      ('13:00', '14:30', false),
    ],
    'I.E. Nikola Tesla': [
      ('08:00', '09:30', false),
      ('09:30', '09:50', true),
      ('09:50', '11:20', false),
      ('11:20', '11:40', true),
      ('11:40', '13:10', false),
      ('13:10', '13:30', true),
      ('13:30', '15:00', false),
    ],
    'I.E. José Carlos Mariátegui': [
      ('08:15', '09:45', false),
      ('09:45', '10:00', true),
      ('10:00', '11:30', false),
      ('11:30', '11:45', true),
      ('11:45', '13:15', false),
      ('13:15', '14:45', false),
    ],
  };

  // Horario semanal: (curso, día, inicio, fin)
  const bloques = [
    (0, 1, '07:50', '09:20'),
    (1, 1, '09:35', '11:05'),
    (2, 1, '11:20', '12:50'),
    (3, 2, '08:00', '09:30'),
    (4, 2, '09:50', '11:20'),
    (5, 2, '13:15', '14:45'),
    (0, 3, '07:50', '09:20'),
    (2, 3, '09:35', '11:05'),
    (1, 3, '11:20', '12:50'),
    (3, 3, '13:30', '15:00'),
    (4, 4, '08:00', '09:30'),
    (5, 4, '10:00', '11:30'),
    (0, 4, '13:00', '14:30'),
    (1, 5, '07:50', '09:20'),
    (2, 5, '09:35', '11:05'),
    (3, 5, '11:40', '13:10'),
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
      // Elite School es privado; los demás, estatales.
      await db.guardarGestion(
        idColegio[c.key]!,
        c.key == 'Elite School' ? gestionPrivada : gestionPublica,
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
          tutor: const Value('Prof. Ana Ríos'),
          tutorCelular: const Value('987123456'),
        ),
      );
      final indice = idCursos.length;
      idCursos.add(cursoId);
      // La lista se toma solo los días que hay clase con ese curso.
      final diasCurso = {
        for (final x in bloques)
          if (x.$1 == indice) x.$2,
      };
      final alumnos = <Perfil>[];
      final cantidad = 22 + azar.nextInt(10);
      for (var i = 0; i < cantidad; i++) {
        final ape = '${elegir(apellidos)} ${elegir(apellidos)}';
        final madre = azar.nextInt(3) > 0;
        final apoderado =
            '${madre ? elegir(const ['Rosa', 'María', 'Carmen', 'Ana', 'Lucía']) : elegir(const ['Jorge', 'Luis', 'Carlos', 'Pedro', 'Juan'])} '
            '${tituloNombre(ape.split(' ')[madre ? 1 : 0])}';
        final id = await db.guardarEstudiante(
          EstudiantesCompanion.insert(
            cursoId: cursoId,
            apellidos: ape,
            nombres: elegir(nombres),
            nacimiento: Value(
              fecha(
                DateTime(
                  hoy.year - 13 - azar.nextInt(3),
                  1 + azar.nextInt(12),
                  1 + azar.nextInt(28),
                ),
              ),
            ),
            apoderado: Value(apoderado),
            parentesco: Value(madre ? 'Madre' : 'Padre'),
            telefono: Value('9${10000000 + azar.nextInt(89999999)}'),
          ),
        );
        idEstudiantes.add(id);
        // Cada estudiante tiene su propio nivel para que las notas sean
        // coherentes, y algunos suben o bajan con los bimestres.
        final r = azar.nextDouble();
        final perfil = Perfil(
          id: id,
          apoderado: '$apoderado (${madre ? 'madre' : 'padre'})',
          nivel: azar.nextDouble() * 0.5 - 0.15,
          tendencia: r < .16 ? -.09 : (r < .32 ? .07 : 0),
          ausentista: i % 11 == 4,
          inquieto: i % 9 == 6,
        );
        alumnos.add(perfil);
        await db.batch((b) {
          for (var p = 1; p <= 3; p++) {
            for (final comp in competencias) {
              b.insert(
                db.notas,
                NotasCompanion.insert(
                  estudianteId: id,
                  periodo: p,
                  competencia: comp,
                  nota: nota(perfil.nivelEn(p)),
                ),
              );
            }
          }
          for (final MapEntry(key: p, value: lista) in diasDeClase.entries) {
            for (final d in lista) {
              if (!diasCurso.contains(d.weekday)) continue;
              final r = azar.nextDouble();
              // Quien falta mucho empeora en el 3.er y 4.° bimestre.
              final faltas = perfil.ausentista ? (p >= 3 ? .36 : .14) : .035;
              final estado = r < faltas
                  ? 'F'
                  : (r < faltas + .06 ? 'T' : (r < faltas + .085 ? 'J' : 'P'));
              // Algunas faltas y tardanzas llevan su notita.
              final (motivo, nota) = switch (estado) {
                'J' => elegir(const [
                  ('Salud', 'Trajo certificado médico'),
                  ('Viaje', 'Viaje familiar, avisó con anticipación'),
                  ('Salud', 'Cita en el centro de salud'),
                ]),
                'F' when azar.nextInt(3) == 0 => (
                  'Cita médica',
                  'Avisó la mamá por WhatsApp',
                ),
                'T' when azar.nextBool() => (null, 'Llegó 8:15, tráfico'),
                _ => (null, null),
              };
              b.insert(
                db.asistencias,
                AsistenciasCompanion.insert(
                  estudianteId: id,
                  fecha: fecha(d),
                  estado: estado,
                  motivo: Value(motivo),
                  nota: Value(nota),
                ),
              );
            }
          }
          // Participaciones (+) y (−) de todo el año para la columna de
          // participación y la conducta del informe.
          final todos = [
            for (final l in diasDeClase.values)
              for (final d in l)
                if (diasCurso.contains(d.weekday)) d,
          ];
          if (todos.isEmpty) return;
          final positivas = (4 + (perfil.nivel + .15) * 30 + azar.nextInt(8))
              .round();
          for (var k = 0; k < positivas; k++) {
            b.insert(
              db.conductas,
              ConductasCompanion.insert(
                estudianteId: id,
                fecha: fecha(elegir(todos)),
                positiva: true,
                motivo: elegir(const [
                  'Participa',
                  'Participa',
                  'Ayuda a un compañero',
                  'Trabaja en equipo',
                  'Trae su material',
                ]),
              ),
            );
          }
          final negativas = perfil.inquieto
              ? 14 + azar.nextInt(8)
              : azar.nextInt(4);
          for (var k = 0; k < negativas; k++) {
            b.insert(
              db.conductas,
              ConductasCompanion.insert(
                estudianteId: id,
                fecha: fecha(elegir(todos)),
                positiva: false,
                motivo: elegir(const [
                  'No trae material',
                  'Interrumpe',
                  'Sin tarea',
                  'Usa el celular',
                ]),
              ),
            );
          }
        });
      }
      await _registroDeEjemplo(
        db,
        cursoId,
        c.$5,
        primaria: c.$2 == 'Primaria',
        alumnos: alumnos,
        periodos: periodos,
        azar: azar,
        hoy: fecha(hoy),
      );
      await _anecdotasDeEjemplo(db, alumnos, periodos, azar, ayer);
    }

    await db.batch(
      (b) => b.insertAll(db.franjas, [
        for (final MapEntry(key: colegio, value: lista) in franjas.entries)
          for (final (inicio, fin, recreo) in lista)
            FranjasCompanion.insert(
              colegioId: idColegio[colegio]!,
              inicio: inicio,
              fin: fin,
              recreo: Value(recreo),
            ),
      ]),
    );
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
    // Cumpleaños de algunos estudiantes: salen solos en el calendario.
    final cumpleaneros = await (db.select(db.estudiantes)..limit(4)).get();
    for (var i = 0; i < cumpleaneros.length; i++) {
      final d = hoy.add(Duration(days: i < 2 ? 0 : i));
      await (db.update(
        db.estudiantes,
      )..where((x) => x.id.equals(cumpleaneros[i].id))).write(
        EstudiantesCompanion(
          nacimiento: Value(fecha(DateTime(hoy.year - 13, d.month, d.day))),
        ),
      );
    }
    await db.batch((b) => b.insertAll(db.eventos, eventos));

    // Año escolar configurado con fechas para que los reportes separen bien
    // cada bimestre.
    final config = ConfigAcademica.delPais(anio, peru).copiar(
      inicio: periodos.first.inicio,
      fin: periodos.last.fin,
      periodos: periodos,
      configurado: true,
    );
    await db.guardarConfigAcademica(config);
    await db.guardarAjuste('anio_activo', '$anio');
    // Asistencia, participación y promedios ya calculados, para que el
    // registro y los reportes no tengan que escribirlos al abrir.
    for (final id in idCursos) {
      for (var p = 1; p <= periodos.length; p++) {
        await db.actualizarAutomaticas(cursoId: id, periodo: p, config: config);
      }
    }
  });
}

/// Cómo es cada estudiante inventado, para que sus datos sean coherentes.
class Perfil {
  final int id;
  final String apoderado;
  final double nivel;

  /// Cuánto sube (o baja) su nivel en cada bimestre.
  final double tendencia;

  /// Falta mucho, sobre todo en la segunda mitad del año.
  final bool ausentista;

  /// Tiene muchas anotaciones de conducta por mejorar.
  final bool inquieto;

  const Perfil({
    required this.id,
    required this.apoderado,
    required this.nivel,
    required this.tendencia,
    required this.ausentista,
    required this.inquieto,
  });

  double nivelEn(int periodo) =>
      nivel +
      tendencia * (periodo - 1) -
      (ausentista && periodo >= 3 ? .12 : 0);
}

/// Temas de cada curso por bimestre (cuatro por bimestre).
const _temas = {
  'Química': [
    [
      'Materia y energía',
      'Estados de la materia',
      'Tabla periódica',
      'Modelos atómicos',
    ],
    [
      'Enlaces químicos',
      'Nomenclatura inorgánica',
      'Óxidos e hidróxidos',
      'Ácidos y sales',
    ],
    [
      'Reacciones químicas',
      'Balanceo de ecuaciones',
      'Estequiometría',
      'Soluciones',
    ],
    ['Química orgánica', 'Hidrocarburos', 'Funciones oxigenadas', 'Polímeros'],
  ],
  'Física': [
    ['Magnitudes físicas', 'Vectores', 'MRU', 'MRUV'],
    ['Caída libre', 'Leyes de Newton', 'Rozamiento', 'Trabajo y energía'],
    ['Cantidad de movimiento', 'Hidrostática', 'Temperatura y calor', 'Ondas'],
    ['Electrostática', 'Corriente eléctrica', 'Circuitos', 'Magnetismo'],
  ],
  'Biología': [
    ['La célula', 'Membrana celular', 'Mitosis y meiosis', 'Tejidos'],
    [
      'Sistema digestivo',
      'Sistema circulatorio',
      'Sistema respiratorio',
      'Sistema nervioso',
    ],
    ['Genética mendeliana', 'ADN y ARN', 'Herencia', 'Biotecnología'],
    ['Evolución', 'Ecosistemas', 'Cadenas tróficas', 'Biodiversidad del Perú'],
  ],
  'Ciencia y Tecnología': [
    ['Los seres vivos', 'Las plantas', 'Los animales', 'El cuerpo humano'],
    ['Alimentación saludable', 'El agua', 'Estados del agua', 'El aire'],
    [
      'La Tierra y el Sol',
      'Fuerzas y movimiento',
      'Máquinas simples',
      'La luz',
    ],
    ['El sonido', 'La electricidad', 'Cuidado del ambiente', 'Reciclaje'],
  ],
};

/// Registro auxiliar de todo el año: en cada bimestre ya empezado hay fichas,
/// un informe en letras, una práctica Logrado / No logrado, una exposición en
/// equipo (1.° y 3.°), el examen bimestral, asistencia y participación
/// automáticas y el promedio calculado. Solo se crean las evaluaciones cuya
/// fecha ya pasó, y la última del bimestre en curso queda a medio calificar.
Future<void> _registroDeEjemplo(
  KipuDb db,
  int cursoId,
  String nombreCurso, {
  required bool primaria,
  required List<Perfil> alumnos,
  required List<Periodo> periodos,
  required Random azar,
  required String hoy,
}) async {
  final temas = _temas[nombreCurso] ?? _temas['Ciencia y Tecnología']!;
  // En primaria todo se califica con letras del CNEB.
  final num = primaria ? 'cneb' : 'vigesimal';
  final grupos = <GrupoEquipos>[];
  final orden = [for (final a in alumnos) a.id];
  for (var p = 1; p <= periodos.length; p++) {
    final inicio = DateTime.parse(periodos[p - 1].inicio!);
    if (periodos[p - 1].inicio!.compareTo(hoy) > 0) break;
    String dia(int n) =>
        DateFormat('yyyy-MM-dd').format(inicio.add(Duration(days: n)));
    final t = temas[(p - 1) % temas.length];
    final conEquipo = p == 1 || p == 3;
    if (conEquipo) {
      // Equipos de cuatro; en el 3.er bimestre se mezclan.
      if (p == 3) orden.shuffle(azar);
      grupos.add(
        GrupoEquipos(
          id: p,
          nombre: 'Exposición: ${t[2].toLowerCase()}',
          creado: dia(26),
          equipos: {
            for (var i = 0; i < orden.length; i++) orden[i]: i ~/ 4 + 1,
          },
        ),
      );
    }
    final evaluaciones = [
      ('F1', t[0], num, false, 4),
      ('T1', 'Informe: ${t[1].toLowerCase()}', 'cneb', false, 11),
      ('F2', t[1], num, false, 18),
      ('FB', 'Práctica: ${t[2].toLowerCase()}', 'logrado', false, 25),
      if (conEquipo)
        ('Exp.', 'Exposición: ${t[2].toLowerCase()}', num, true, 32),
      ('F3', t[3], num, false, 40),
      ('EB', 'Examen bimestral', num, false, 52),
    ].where((x) => dia(x.$5).compareTo(hoy) <= 0).toList();
    for (var k = 0; k < evaluaciones.length; k++) {
      final (codigo, tema, escala, enEquipo, d) = evaluaciones[k];
      final col = await db.crearColumna(
        RegistroColumnasCompanion.insert(
          cursoId: cursoId,
          periodo: p,
          orden: 0,
          codigo: codigo,
          tema: Value(tema),
          fecha: Value(dia(d)),
          escala: Value(escala),
          enEquipo: Value(enEquipo),
          grupo: Value(enEquipo ? p : null),
        ),
      );
      // La última del bimestre en curso todavía se está calificando.
      final aMedias =
          k == evaluaciones.length - 1 &&
          periodos[p - 1].fin!.compareTo(hoy) >= 0;
      final equipos = enEquipo ? grupos.last.equipos : const <int, int>{};
      final notaEquipo = <int, String>{};
      // El examen es un poco más difícil y la práctica, más fácil.
      final ajuste = switch (codigo) {
        'EB' => -1.2,
        'FB' => 1.0,
        'F3' when p == 2 => -1.8,
        _ => 0.0,
      };
      await db.batch((b) {
        for (final a in alumnos) {
          if (aMedias && azar.nextDouble() < .45) continue;
          // Quien falta mucho a veces no rinde la evaluación.
          if (a.ausentista && p >= 3 && azar.nextDouble() < .3) continue;
          final puntaje =
              13 + a.nivelEn(p) * 11 + ajuste + azar.nextDouble() * 4 - 2;
          final n = puntaje.clamp(4, 20).round();
          final String valor;
          if (enEquipo) {
            valor = notaEquipo.putIfAbsent(
              equipos[a.id]!,
              () => escala == 'cneb'
                  ? _letra(puntaje + 1)
                  : '${(n + 1).clamp(0, 20)}',
            );
          } else {
            valor = switch (escala) {
              'cneb' => _letra(puntaje),
              'logrado' => puntaje >= 11 ? 'Logrado' : 'No logrado',
              _ => '$n',
            };
          }
          b.insert(
            db.registroNotas,
            RegistroNotasCompanion.insert(
              columnaId: col,
              estudianteId: a.id,
              valor: valor,
            ),
          );
        }
      });
    }
    // El promedio se calcula con las evaluaciones de su izquierda; asistencia
    // y participación se llenan solas y se ven aparte.
    for (final (codigo, tema, escala, tipo) in [
      ('Prom.', 'Promedio del bimestre', num, 'calculada'),
      ('Asist', 'Asistencia del bimestre', 'cneb', 'asistencia'),
      ('Part', 'Participación en clase', num, 'participacion'),
    ]) {
      final id = await db.crearColumna(
        RegistroColumnasCompanion.insert(
          cursoId: cursoId,
          periodo: p,
          orden: 0,
          codigo: codigo,
          tema: Value(tema),
          tipo: Value(tipo),
          escala: Value(escala),
        ),
      );
      if (tipo == 'calculada') {
        // Lo que aún no se califica no baja el promedio.
        await db.guardarConfigColumna(
          id,
          const ConfigColumna(calculo: Calculo(sinNota: SinNota.noCuenta)),
        );
      }
    }
  }
  await db.guardarGruposEquipos(cursoId, grupos);

  const buenas = ['Participa', 'Ayuda a un compañero', 'Trabaja en equipo'];
  const malas = ['No trae material', 'Interrumpe', 'Sin tarea'];
  for (final a in alumnos) {
    final r = azar.nextDouble();
    if (r < .22) {
      await db.anotarConducta(a.id, hoy, true, buenas[azar.nextInt(3)]);
    } else if (r < .3) {
      await db.anotarConducta(a.id, hoy, false, malas[azar.nextInt(3)]);
    }
  }
}

String _letra(double puntaje) => puntaje >= 17.5
    ? 'AD'
    : (puntaje >= 13.5 ? 'A' : (puntaje >= 10.5 ? 'B' : 'C'));

/// Anecdotario: logros de los mejores, conductas por mejorar de los inquietos
/// y reuniones con la familia de quienes faltan mucho.
Future<void> _anecdotasDeEjemplo(
  KipuDb db,
  List<Perfil> alumnos,
  List<Periodo> periodos,
  Random azar,
  String ayer,
) async {
  // Una fecha al azar entre los periodos que ya pasaron.
  String fechaEn(int p) {
    final d = DateTime.parse(periodos[p - 1].inicio!)
        .add(Duration(days: 3 + azar.nextInt(50)));
    final f = DateFormat('yyyy-MM-dd').format(d);
    return f.compareTo(ayer) > 0 ? ayer : f;
  }

  final empezados = [
    for (var p = 1; p <= periodos.length; p++)
      if (periodos[p - 1].inicio!.compareTo(ayer) <= 0) p,
  ];
  if (empezados.isEmpty) return;
  int alAzar() => empezados[azar.nextInt(empezados.length)];
  final ultimo = empezados.last;
  final filas = <AnecdotasCompanion>[];
  final ordenados = [...alumnos]..sort((a, b) => b.nivel.compareTo(a.nivel));
  for (final a in ordenados.take(3)) {
    filas.add(
      AnecdotasCompanion.insert(
        estudianteId: a.id,
        fecha: fechaEn(alAzar()),
        tipo: const Value('positivo'),
        categoria: const Value('logro'),
        texto: [
          'Ganó el primer puesto en la feria de ciencias con su proyecto de reciclaje.',
          'Explicó el tema a sus compañeros con mucha claridad.',
          'Ayudó a organizar el laboratorio sin que se lo pidieran.',
        ][azar.nextInt(3)],
      ),
    );
  }
  for (final a in alumnos.where((x) => x.inquieto)) {
    for (final (k, texto) in const [
      'Interrumpe la clase varias veces y no deja trabajar a su equipo.',
      'Usó el celular durante la evaluación; se le pidió guardarlo.',
      'Discutió con un compañero en el laboratorio.',
    ].indexed) {
      filas.add(
        AnecdotasCompanion.insert(
          estudianteId: a.id,
          fecha: fechaEn(k == 0 ? empezados.first : alAzar()),
          tipo: const Value('negativo'),
          categoria: const Value('conducta'),
          texto: texto,
        ),
      );
    }
  }
  for (final a in alumnos.where((x) => x.ausentista)) {
    filas.addAll([
      AnecdotasCompanion.insert(
        estudianteId: a.id,
        fecha: fechaEn(ultimo),
        tipo: const Value('negativo'),
        categoria: const Value('academico'),
        texto: 'No entregó el informe de laboratorio y faltó al examen.',
      ),
      AnecdotasCompanion.insert(
        estudianteId: a.id,
        fecha: fechaEn(ultimo),
        tipo: const Value('neutro'),
        categoria: const Value('reunion'),
        texto: 'Faltas seguidas y notas que bajaron este bimestre.',
        apoderado: Value(a.apoderado),
        acuerdos: const Value(
          'La familia revisará el cuaderno cada noche y avisará cuando falte. '
          'El estudiante recuperará las evaluaciones pendientes.',
        ),
      ),
    ]);
  }
  final otro = alumnos[azar.nextInt(alumnos.length)];
  filas.add(
    AnecdotasCompanion.insert(
      estudianteId: otro.id,
      fecha: fechaEn(alAzar()),
      categoria: const Value('salud'),
      texto: 'Se sintió mal en clase; se avisó a la familia y lo recogieron.',
    ),
  );
  await db.batch((b) => b.insertAll(db.anecdotas, filas));
}
