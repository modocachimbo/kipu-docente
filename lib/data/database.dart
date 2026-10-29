import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Pares clave-valor: perfil del docente y preferencias.
class Ajustes extends Table {
  TextColumn get clave => text()();
  TextColumn get valor => text()();

  @override
  Set<Column> get primaryKey => {clave};
}

class Colegios extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 120)();
  TextColumn get lugar => text().nullable()();
  IntColumn get color => integer().nullable()(); // ARGB; null = automático
  TextColumn get pais =>
      text().withDefault(const Constant('PE'))(); // código, ver paises.dart
  DateTimeColumn get creado => dateTime().withDefault(currentDateAndTime)();
}

class Cursos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get colegioId =>
      integer().references(Colegios, #id, onDelete: KeyAction.cascade)();
  TextColumn get nivel => text()(); // Inicial, Primaria, Secundaria
  TextColumn get grado => text()(); // 1.° grado, 4.° año, 5 años...
  TextColumn get seccion => text()(); // A, B, C...
  TextColumn get nombre => text().withLength(min: 1, max: 120)();
  TextColumn get area => text().nullable()(); // Ciencia y Tecnología...
  // Tutor/a del aula: se guarda igual en todos los cursos de la misma sección.
  TextColumn get tutor => text().nullable()();
  TextColumn get tutorCelular => text().nullable()();
  DateTimeColumn get creado => dateTime().withDefault(currentDateAndTime)();
}

class Estudiantes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cursoId =>
      integer().references(Cursos, #id, onDelete: KeyAction.cascade)();
  TextColumn get apellidos => text()();
  TextColumn get nombres => text()();
  TextColumn get dni => text().nullable()();
  TextColumn get apoderado => text().nullable()();
  TextColumn get parentesco => text().nullable()(); // Madre, Padre...
  TextColumn get telefono => text().nullable()();
  TextColumn get apoderado2 => text().nullable()();
  TextColumn get parentesco2 => text().nullable()();
  TextColumn get telefono2 => text().nullable()();
  TextColumn get nacimiento => text().nullable()(); // yyyy-MM-dd
  TextColumn get observaciones => text().nullable()();
  // Acceso a la app de estudio: ID solo de números y contraseña inicial.
  TextColumn get codigo => text().nullable()();
  TextColumn get clave => text().nullable()();
  BlobColumn get foto => blob().nullable()(); // JPG o PNG pequeño
  // Periodo en que entró al curso y, si se retiró, desde cuál ya no está.
  IntColumn get desde => integer().withDefault(const Constant(1))();
  IntColumn get hasta => integer().nullable()();
  DateTimeColumn get creado => dateTime().withDefault(currentDateAndTime)();
}

/// Un registro por estudiante y día. Estado: P presente, T tarde, F falta, J justificada.
class Asistencias extends Table {
  IntColumn get estudianteId =>
      integer().references(Estudiantes, #id, onDelete: KeyAction.cascade)();
  TextColumn get fecha => text()(); // yyyy-MM-dd
  TextColumn get estado => text().withLength(min: 1, max: 1)();

  @override
  Set<Column> get primaryKey => {estudianteId, fecha};
}

/// Calificación de una competencia en un periodo, con la escala del MINEDU.
class Notas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get estudianteId =>
      integer().references(Estudiantes, #id, onDelete: KeyAction.cascade)();
  IntColumn get periodo => integer()(); // 1..4 (bimestre) o 1..3 (trimestre)
  TextColumn get competencia => text()();
  TextColumn get nota => text()(); // AD, A, B, C
}

/// Columna del registro auxiliar de un curso en un periodo. Tipo 'nota' se
/// llena a mano con su escala; 'calculada' (promedios) se configurará después.
class RegistroColumnas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cursoId =>
      integer().references(Cursos, #id, onDelete: KeyAction.cascade)();
  IntColumn get periodo => integer()(); // posición del periodo, desde 1
  IntColumn get orden => integer()();
  TextColumn get codigo => text()(); // F1, T1, Prom.
  TextColumn get tema => text().nullable()();
  TextColumn get fecha => text().nullable()(); // yyyy-MM-dd
  TextColumn get tipo => text().withDefault(const Constant('nota'))();
  TextColumn get escala => text().nullable()(); // id de la escala
  BoolColumn get enEquipo => boolean().withDefault(const Constant(false))();

  /// Qué equipos usa una columna en equipo (id del grupo de equipos del curso).
  IntColumn get grupo => integer().nullable()();

  /// Queda fija a la derecha al deslizar (solo una por curso y periodo).
  BoolColumn get fijada => boolean().withDefault(const Constant(false))();
}

/// Nota de un estudiante en una columna: '17', '15.5', 'AD', 'Logrado'...
class RegistroNotas extends Table {
  IntColumn get columnaId => integer().references(
    RegistroColumnas,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get estudianteId =>
      integer().references(Estudiantes, #id, onDelete: KeyAction.cascade)();
  TextColumn get valor => text()();

  @override
  Set<Column> get primaryKey => {columnaId, estudianteId};
}

/// Conducta anotada en clase: positiva o por mejorar.
class Conductas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get estudianteId =>
      integer().references(Estudiantes, #id, onDelete: KeyAction.cascade)();
  TextColumn get fecha => text()(); // yyyy-MM-dd
  BoolColumn get positiva => boolean()();
  TextColumn get motivo => text()();
}

/// Fechas del calendario del docente (entregas, reuniones, cumpleaños...).
class Eventos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fecha => text()(); // yyyy-MM-dd
  TextColumn get hora => text().nullable()(); // null = todo el día
  TextColumn get titulo => text()();
  TextColumn get etiqueta => text().nullable()();
  TextColumn get tipo =>
      text().withDefault(const Constant('tarea'))(); // tarea, cumple
}

/// Bloques del horario semanal: un curso en un día y rango de horas.
class Horarios extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cursoId =>
      integer().references(Cursos, #id, onDelete: KeyAction.cascade)();
  IntColumn get dia => integer()(); // 1 = lunes ... 7 = domingo
  TextColumn get inicio => text()(); // HH:mm
  TextColumn get fin => text()(); // HH:mm
}

final _azar = Random.secure();

/// Contraseña inicial fácil de dictar: dos letras y cuatro cifras, sin las
/// que se confunden (I, O, 0, 1).
String nuevaClave() {
  const letras = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  String l() => letras[_azar.nextInt(letras.length)];
  return '${l()}${l()}-${2000 + _azar.nextInt(8000)}'.replaceAllMapped(
    RegExp(r'[01]'),
    (_) => '${2 + _azar.nextInt(8)}',
  );
}

class IndicadoresCurso {
  final int presentes;
  final int registros;
  final int enC;
  final List<Horario> horario;
  const IndicadoresCurso({
    required this.presentes,
    required this.registros,
    required this.enC,
    required this.horario,
  });

  int? get pctAsistencia =>
      registros == 0 ? null : (presentes * 100 / registros).round();

  /// Próxima clase a partir de [ahora] (hoy si aún no termina).
  ({DateTime dia, Horario bloque})? proximaClase(DateTime ahora) {
    if (horario.isEmpty) return null;
    final hora =
        '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';
    for (var i = 0; i < 7; i++) {
      final dia = ahora.add(Duration(days: i));
      final delDia = horario.where((h) => h.dia == dia.weekday).toList()
        ..sort((a, b) => a.inicio.compareTo(b.inicio));
      for (final h in delDia) {
        if (i > 0 || h.fin.compareTo(hora) > 0) return (dia: dia, bloque: h);
      }
    }
    return null;
  }
}

class CursoConColegio {
  final Curso curso;
  final Colegio colegio;
  final int totalEstudiantes;
  CursoConColegio(this.curso, this.colegio, this.totalEstudiantes);
}

@DriftDatabase(
  tables: [
    Ajustes,
    Colegios,
    Cursos,
    Estudiantes,
    Asistencias,
    Notas,
    Eventos,
    Horarios,
    RegistroColumnas,
    RegistroNotas,
    Conductas,
  ],
)
class KipuDb extends _$KipuDb {
  KipuDb([QueryExecutor? executor]) : super(executor ?? _abrir());

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(asistencias);
      if (from < 3) {
        await m.createTable(notas);
        await m.createTable(eventos);
      }
      if (from < 4) await m.createTable(horarios);
      if (from < 5) await m.addColumn(colegios, colegios.color);
      if (from < 6) await m.addColumn(colegios, colegios.pais);
      if (from < 7) {
        await m.addColumn(estudiantes, estudiantes.foto);
        await m.createTable(registroColumnas);
        await m.createTable(registroNotas);
        await m.createTable(conductas);
      }
      if (from < 8) {
        await m.addColumn(estudiantes, estudiantes.desde);
        await m.addColumn(estudiantes, estudiantes.hasta);
      }
      if (from < 9) {
        await m.addColumn(cursos, cursos.tutor);
        await m.addColumn(cursos, cursos.tutorCelular);
        await m.addColumn(registroColumnas, registroColumnas.grupo);
        for (final c in [
          estudiantes.parentesco,
          estudiantes.apoderado2,
          estudiantes.parentesco2,
          estudiantes.telefono2,
          estudiantes.nacimiento,
          estudiantes.observaciones,
          estudiantes.codigo,
          estudiantes.clave,
        ]) {
          await m.addColumn(estudiantes, c);
        }
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await completarAccesos();
    },
  );

  static QueryExecutor _abrir() => driftDatabase(
    name: 'kipu',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );

  // Ajustes

  Stream<String?> verAjuste(String clave) =>
      (select(ajustes)..where((a) => a.clave.equals(clave)))
          .watchSingleOrNull()
          .map((a) => a?.valor);

  Future<String?> leerAjuste(String clave) async => (await (select(
    ajustes,
  )..where((a) => a.clave.equals(clave))).getSingleOrNull())?.valor;

  Future<void> guardarAjuste(String clave, String valor) => into(
    ajustes,
  ).insertOnConflictUpdate(AjustesCompanion.insert(clave: clave, valor: valor));

  // Colegios

  Stream<List<Colegio>> verColegios() =>
      (select(colegios)..orderBy([(c) => OrderingTerm.asc(c.nombre)])).watch();

  Future<int> crearColegio(
    String nombre,
    String? lugar, {
    int? color,
    String pais = 'PE',
  }) => into(colegios).insert(
    ColegiosCompanion.insert(
      nombre: nombre,
      lugar: Value(lugar),
      color: Value(color),
      pais: Value(pais),
    ),
  );

  Future<void> editarColegio(
    int id,
    String nombre,
    String? lugar, {
    int? color,
    String pais = 'PE',
  }) => (update(colegios)..where((c) => c.id.equals(id))).write(
    ColegiosCompanion(
      nombre: Value(nombre),
      lugar: Value(lugar),
      color: Value(color),
      pais: Value(pais),
    ),
  );

  Future<void> borrarColegio(int id) =>
      (delete(colegios)..where((c) => c.id.equals(id))).go();

  // Cursos

  Stream<List<CursoConColegio>> verCursos() {
    final total = estudiantes.id.count();
    final q =
        select(cursos).join([
            innerJoin(colegios, colegios.id.equalsExp(cursos.colegioId)),
            leftOuterJoin(
              estudiantes,
              estudiantes.cursoId.equalsExp(cursos.id),
            ),
          ])
          ..addColumns([total])
          ..groupBy([cursos.id])
          ..orderBy([
            OrderingTerm.asc(colegios.nombre),
            OrderingTerm.asc(cursos.nivel),
            OrderingTerm.asc(cursos.grado),
            OrderingTerm.asc(cursos.seccion),
          ]);
    return q.watch().map(
      (filas) => filas
          .map(
            (f) => CursoConColegio(
              f.readTable(cursos),
              f.readTable(colegios),
              f.read(total) ?? 0,
            ),
          )
          .toList(),
    );
  }

  Future<int> crearCurso(CursosCompanion c) => into(cursos).insert(c);

  /// Datos rápidos de cada curso para sus tarjetas: % de asistencia,
  /// alumnos con C en el último periodo y sus bloques de horario.
  Stream<Map<int, IndicadoresCurso>> verIndicadoresCursos() {
    final q = customSelect(
      'SELECT c.id AS id, '
      '(SELECT COUNT(*) FROM asistencias a JOIN estudiantes e ON e.id = a.estudiante_id '
      " WHERE e.curso_id = c.id AND a.estado = 'P') AS p, "
      '(SELECT COUNT(*) FROM asistencias a JOIN estudiantes e ON e.id = a.estudiante_id '
      ' WHERE e.curso_id = c.id) AS tot, '
      '(SELECT COUNT(DISTINCT n.estudiante_id) FROM notas n JOIN estudiantes e ON e.id = n.estudiante_id '
      " WHERE e.curso_id = c.id AND n.nota = 'C' AND n.periodo = "
      '  (SELECT MAX(n2.periodo) FROM notas n2 JOIN estudiantes e2 ON e2.id = n2.estudiante_id '
      '   WHERE e2.curso_id = c.id)) AS enc '
      'FROM cursos c',
      readsFrom: {cursos, estudiantes, asistencias, notas},
    ).watch();
    return q.asyncMap((filas) async {
      final bloques = await select(horarios).get();
      return {
        for (final f in filas)
          f.read<int>('id'): IndicadoresCurso(
            presentes: f.read<int>('p'),
            registros: f.read<int>('tot'),
            enC: f.read<int>('enc'),
            horario: bloques
                .where((h) => h.cursoId == f.read<int>('id'))
                .toList(),
          ),
      };
    });
  }

  Future<void> borrarCurso(int id) =>
      (delete(cursos)..where((c) => c.id.equals(id))).go();

  // Estudiantes

  Stream<List<Estudiante>> verEstudiantes(int cursoId) =>
      (select(estudiantes)
            ..where((e) => e.cursoId.equals(cursoId))
            ..orderBy([
              (e) => OrderingTerm.asc(e.apellidos),
              (e) => OrderingTerm.asc(e.nombres),
            ]))
          .watch();

  /// Guarda el estudiante. Si es nuevo y no trae ID o contraseña, se los
  /// genera para la app de estudio.
  Future<int> guardarEstudiante(EstudiantesCompanion e) async {
    if (!e.id.present) {
      final codigo = e.codigo.present ? e.codigo.value : null;
      e = e.copyWith(
        codigo: Value(codigo ?? await nuevoCodigo()),
        clave: e.clave.present && e.clave.value != null
            ? e.clave
            : Value(nuevaClave()),
      );
    }
    return into(estudiantes).insertOnConflictUpdate(e);
  }

  /// ID de 6 cifras que ningún otro estudiante tiene.
  Future<String> nuevoCodigo({Set<String> ocupados = const {}}) async {
    final usados = {
      ...ocupados,
      for (final f
          in await (selectOnly(estudiantes)
                ..addColumns([estudiantes.codigo])
                ..where(estudiantes.codigo.isNotNull()))
              .get())
        f.read(estudiantes.codigo)!,
    };
    while (true) {
      final c = '${100000 + _azar.nextInt(900000)}';
      if (!usados.contains(c)) return c;
    }
  }

  /// ¿Otro estudiante ya usa este ID?
  Future<bool> codigoOcupado(String codigo, {int? salvo}) async {
    final q = select(estudiantes)..where((e) => e.codigo.equals(codigo));
    if (salvo != null) q.where((e) => e.id.equals(salvo).not());
    return (await q.get()).isNotEmpty;
  }

  /// Da ID y contraseña a los estudiantes que aún no los tienen.
  Future<void> completarAccesos() async {
    final faltan = await (select(
      estudiantes,
    )..where((e) => e.codigo.isNull() | e.clave.isNull())).get();
    if (faltan.isEmpty) return;
    final nuevos = <String>{};
    for (final e in faltan) {
      final codigo = e.codigo ?? await nuevoCodigo(ocupados: nuevos);
      nuevos.add(codigo);
      await (update(estudiantes)..where((x) => x.id.equals(e.id))).write(
        EstudiantesCompanion(
          codigo: Value(codigo),
          clave: Value(e.clave ?? nuevaClave()),
        ),
      );
    }
  }

  /// Guarda el tutor/a en todos los cursos de la misma sección.
  Future<void> guardarTutor(Curso c, String? tutor, String? celular) =>
      (update(cursos)..where(
            (x) =>
                x.colegioId.equals(c.colegioId) &
                x.nivel.equals(c.nivel) &
                x.grado.equals(c.grado) &
                x.seccion.equals(c.seccion),
          ))
          .write(
            CursosCompanion(tutor: Value(tutor), tutorCelular: Value(celular)),
          );

  Stream<Curso> verCurso(int id) =>
      (select(cursos)..where((c) => c.id.equals(id))).watchSingle();

  Future<void> borrarEstudiante(int id) =>
      (delete(estudiantes)..where((e) => e.id.equals(id))).go();

  // Asistencia

  /// Estado de cada estudiante del curso en la fecha dada (null si no se marcó).
  Stream<Map<int, String>> verAsistencia(int cursoId, String fecha) {
    final q =
        select(asistencias).join([
          innerJoin(
            estudiantes,
            estudiantes.id.equalsExp(asistencias.estudianteId),
          ),
        ])..where(
          estudiantes.cursoId.equals(cursoId) & asistencias.fecha.equals(fecha),
        );
    return q.watch().map(
      (filas) => {
        for (final f in filas)
          f.readTable(asistencias).estudianteId: f
              .readTable(asistencias)
              .estado,
      },
    );
  }

  Future<void> marcarAsistencia(
    int estudianteId,
    String fecha,
    String? estado,
  ) {
    if (estado == null) {
      return (delete(asistencias)..where(
            (a) => a.estudianteId.equals(estudianteId) & a.fecha.equals(fecha),
          ))
          .go();
    }
    return into(asistencias).insertOnConflictUpdate(
      AsistenciasCompanion.insert(
        estudianteId: estudianteId,
        fecha: fecha,
        estado: estado,
      ),
    );
  }

  Future<void> marcarTodos(
    List<int> estudianteIds,
    String fecha,
    String estado,
  ) => batch(
    (b) => b.insertAllOnConflictUpdate(asistencias, [
      for (final id in estudianteIds)
        AsistenciasCompanion.insert(
          estudianteId: id,
          fecha: fecha,
          estado: estado,
        ),
    ]),
  );

  // Notas y estadística

  /// Cantidad de calificaciones por nivel de logro, opcionalmente de un curso.
  Stream<Map<String, int>> verNiveles({int? cursoId, int? periodo}) {
    final total = notas.id.count();
    final q =
        selectOnly(notas).join([
            innerJoin(
              estudiantes,
              estudiantes.id.equalsExp(notas.estudianteId),
            ),
          ])
          ..addColumns([notas.nota, total])
          ..groupBy([notas.nota]);
    if (cursoId != null) q.where(estudiantes.cursoId.equals(cursoId));
    if (periodo != null) q.where(notas.periodo.equals(periodo));
    return q.watch().map(
      (filas) => {
        for (final f in filas) f.read(notas.nota)!: f.read(total) ?? 0,
      },
    );
  }

  /// Estudiante con más AD (para "Destacado del periodo").
  Stream<(Estudiante, CursoConColegio?)?> verDestacado() {
    final ads = notas.id.count();
    final q =
        select(estudiantes).join([
            innerJoin(notas, notas.estudianteId.equalsExp(estudiantes.id)),
          ])
          ..where(notas.nota.equals('AD'))
          ..addColumns([ads])
          ..groupBy([estudiantes.id])
          ..orderBy([OrderingTerm.desc(ads)])
          ..limit(1);
    return q.watchSingleOrNull().asyncMap((f) async {
      if (f == null) return null;
      final e = f.readTable(estudiantes);
      final cursos = await verCursos().first;
      final c = cursos.where((c) => c.curso.id == e.cursoId).firstOrNull;
      return (e, c);
    });
  }

  /// Estudiantes con más calificaciones en C y más faltas.
  Stream<
    List<({Estudiante estudiante, CursoConColegio? curso, int c, int faltas})>
  >
  verNecesitanApoyo({int limite = 4}) {
    final q = customSelect(
      'SELECT e.id, '
      '(SELECT COUNT(*) FROM notas n WHERE n.estudiante_id = e.id AND n.nota = \'C\') AS c, '
      '(SELECT COUNT(*) FROM asistencias a WHERE a.estudiante_id = e.id AND a.estado = \'F\') AS f '
      'FROM estudiantes e '
      'ORDER BY (c * 2 + f) DESC, e.apellidos LIMIT ?',
      variables: [Variable.withInt(limite)],
      readsFrom: {estudiantes, notas, asistencias},
    );
    return q.watch().asyncMap((filas) async {
      final cursos = await verCursos().first;
      final lista =
          <
            ({Estudiante estudiante, CursoConColegio? curso, int c, int faltas})
          >[];
      for (final f in filas) {
        final c = f.read<int>('c'), faltas = f.read<int>('f');
        if (c + faltas == 0) continue;
        final e = await (select(
          estudiantes,
        )..where((x) => x.id.equals(f.read<int>('id')))).getSingle();
        lista.add((
          estudiante: e,
          curso: cursos.where((x) => x.curso.id == e.cursoId).firstOrNull,
          c: c,
          faltas: faltas,
        ));
      }
      return lista;
    });
  }

  /// Conteo de estados de asistencia por fecha entre dos días.
  Stream<Map<String, Map<String, int>>> verAsistenciaRango(
    String desde,
    String hasta,
  ) {
    final total = asistencias.estudianteId.count();
    final q = selectOnly(asistencias)
      ..addColumns([asistencias.fecha, asistencias.estado, total])
      ..where(asistencias.fecha.isBetweenValues(desde, hasta))
      ..groupBy([asistencias.fecha, asistencias.estado]);
    return q.watch().map((filas) {
      final r = <String, Map<String, int>>{};
      for (final f in filas) {
        final fecha = f.read(asistencias.fecha)!;
        final estado = f.read(asistencias.estado)!;
        (r[fecha] ??= <String, int>{})[estado] = f.read(total) ?? 0;
      }
      return r;
    });
  }

  // Horario

  Stream<List<(Horario, CursoConColegio)>> verClasesDelDia(int dia) =>
      (select(horarios)
            ..where((h) => h.dia.equals(dia))
            ..orderBy([(h) => OrderingTerm.asc(h.inicio)]))
          .watch()
          .asyncMap((lista) async {
            final cursos = await verCursos().first;
            return [
              for (final h in lista)
                for (final c in cursos.where((c) => c.curso.id == h.cursoId))
                  (h, c),
            ];
          });

  // Eventos

  /// Eventos del día y, al inicio, los cumpleaños de los estudiantes (salen
  /// solos de su fecha de nacimiento, cada año).
  Stream<List<Evento>> verEventos(String fecha) {
    return customSelect(
      'SELECT 1',
      readsFrom: {eventos, estudiantes, cursos},
    ).watch().asyncMap((_) async {
      final cumples = await _cumpleanos(fecha.substring(5));
      return [
        for (final (e, c) in cumples)
          Evento(
            id: -e.id,
            fecha: fecha,
            titulo:
                '${e.apellidos.split(' ').first} ${e.nombres.split(' ').first}',
            etiqueta: '${c.grado} ${c.seccion} · ${c.nombre}',
            tipo: 'cumple',
          ),
        ...await (select(eventos)
              ..where((e) => e.fecha.equals(fecha))
              ..orderBy([(e) => OrderingTerm.asc(e.hora)]))
            .get(),
      ];
    });
  }

  Future<List<(Estudiante, Curso)>> _cumpleanos(String mesDia) async {
    final q =
        select(estudiantes).join([
          innerJoin(cursos, cursos.id.equalsExp(estudiantes.cursoId)),
        ])..where(
          estudiantes.nacimiento.like('%-$mesDia') & estudiantes.hasta.isNull(),
        );
    return [
      for (final r in await q.get())
        (r.readTable(estudiantes), r.readTable(cursos)),
    ];
  }

  Stream<Set<String>> verFechasConEventos(String desde, String hasta) =>
      customSelect(
        'SELECT 1',
        readsFrom: {eventos, estudiantes},
      ).watch().asyncMap((_) async {
        final fechas = {
          for (final r
              in await (selectOnly(eventos, distinct: true)
                    ..addColumns([eventos.fecha])
                    ..where(eventos.fecha.isBetweenValues(desde, hasta)))
                  .get())
            r.read(eventos.fecha)!,
        };
        final cumples = {
          for (final r
              in await (selectOnly(estudiantes)
                    ..addColumns([estudiantes.nacimiento])
                    ..where(
                      estudiantes.nacimiento.isNotNull() &
                          estudiantes.hasta.isNull(),
                    ))
                  .get())
            r.read(estudiantes.nacimiento)!.substring(5),
        };
        for (
          var d = DateTime.parse(desde);
          !d.isAfter(DateTime.parse(hasta));
          d = d.add(const Duration(days: 1))
        ) {
          final k =
              '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
          if (cumples.contains(k.substring(5))) fechas.add(k);
        }
        return fechas;
      });

  // Búsqueda

  Future<List<(Estudiante, CursoConColegio?)>> buscarEstudiantes(
    String texto,
  ) async {
    final t = '%${texto.trim()}%';
    final lista =
        await (select(estudiantes)
              ..where((e) => e.apellidos.like(t) | e.nombres.like(t))
              ..orderBy([(e) => OrderingTerm.asc(e.apellidos)])
              ..limit(30))
            .get();
    final cursos = await verCursos().first;
    return [
      for (final e in lista)
        (e, cursos.where((c) => c.curso.id == e.cursoId).firstOrNull),
    ];
  }

  // Registro auxiliar

  Stream<List<RegistroColumna>> verColumnas(int cursoId, int periodo) =>
      (select(registroColumnas)
            ..where(
              (c) => c.cursoId.equals(cursoId) & c.periodo.equals(periodo),
            )
            ..orderBy([(c) => OrderingTerm.asc(c.orden)]))
          .watch();

  /// Notas del periodo: {columnaId: {estudianteId: valor}}.
  Stream<Map<int, Map<int, String>>> verNotasRegistro(
    int cursoId,
    int periodo,
  ) {
    final q =
        select(registroNotas).join([
          innerJoin(
            registroColumnas,
            registroColumnas.id.equalsExp(registroNotas.columnaId),
          ),
        ])..where(
          registroColumnas.cursoId.equals(cursoId) &
              registroColumnas.periodo.equals(periodo),
        );
    return q.watch().map((filas) {
      final r = <int, Map<int, String>>{};
      for (final f in filas) {
        final n = f.readTable(registroNotas);
        (r[n.columnaId] ??= {})[n.estudianteId] = n.valor;
      }
      return r;
    });
  }

  Future<int> crearColumna(RegistroColumnasCompanion c) async {
    final ultimo =
        await (selectOnly(registroColumnas)
              ..addColumns([registroColumnas.orden.max()])
              ..where(
                registroColumnas.cursoId.equals(c.cursoId.value) &
                    registroColumnas.periodo.equals(c.periodo.value),
              ))
            .map((f) => f.read(registroColumnas.orden.max()))
            .getSingle();
    return into(registroColumnas)
        .insert(c.copyWith(orden: Value((ultimo ?? 0) + 1)));
  }

  Future<void> editarColumna(int id, RegistroColumnasCompanion c) =>
      (update(registroColumnas)..where((x) => x.id.equals(id))).write(c);

  Future<void> borrarColumna(int id) =>
      (delete(registroColumnas)..where((x) => x.id.equals(id))).go();

  /// Fija una columna a la derecha y suelta la que estaba fijada.
  Future<void> fijarColumna(RegistroColumna col, bool fijar) =>
      transaction(() async {
        await (update(registroColumnas)..where(
              (x) =>
                  x.cursoId.equals(col.cursoId) & x.periodo.equals(col.periodo),
            ))
            .write(const RegistroColumnasCompanion(fijada: Value(false)));
        if (fijar) {
          await editarColumna(
            col.id,
            const RegistroColumnasCompanion(fijada: Value(true)),
          );
        }
      });

  /// Cambia de lugar una columna con su vecina (-1 izquierda, 1 derecha).
  Future<void> moverColumna(List<RegistroColumna> lista, int i, int paso) =>
      transaction(() async {
        final j = i + paso;
        if (j < 0 || j >= lista.length) return;
        await editarColumna(
          lista[i].id,
          RegistroColumnasCompanion(orden: Value(lista[j].orden)),
        );
        await editarColumna(
          lista[j].id,
          RegistroColumnasCompanion(orden: Value(lista[i].orden)),
        );
      });

  Future<void> ponerNota(int columnaId, int estudianteId, String? valor) {
    if (valor == null || valor.isEmpty) {
      return (delete(registroNotas)..where(
            (n) =>
                n.columnaId.equals(columnaId) &
                n.estudianteId.equals(estudianteId),
          ))
          .go();
    }
    return into(registroNotas).insertOnConflictUpdate(
      RegistroNotasCompanion.insert(
        columnaId: columnaId,
        estudianteId: estudianteId,
        valor: valor,
      ),
    );
  }

  /// Saldo de conducta de cada estudiante del curso en una fecha: {id: (+, −)}.
  Stream<Map<int, (int, int)>> verConductaDelDia(int cursoId, String fecha) {
    final q =
        select(conductas).join([
          innerJoin(
            estudiantes,
            estudiantes.id.equalsExp(conductas.estudianteId),
          ),
        ])..where(
          estudiantes.cursoId.equals(cursoId) & conductas.fecha.equals(fecha),
        );
    return q.watch().map((filas) {
      final r = <int, (int, int)>{};
      for (final f in filas) {
        final c = f.readTable(conductas);
        final (p, n) = r[c.estudianteId] ?? (0, 0);
        r[c.estudianteId] = c.positiva ? (p + 1, n) : (p, n + 1);
      }
      return r;
    });
  }

  Stream<List<Conducta>> verConductas(int estudianteId) =>
      (select(conductas)
            ..where((c) => c.estudianteId.equals(estudianteId))
            ..orderBy([(c) => OrderingTerm.desc(c.id)]))
          .watch();

  Future<int> anotarConducta(
    int estudianteId,
    String fecha,
    bool positiva,
    String motivo,
  ) => into(conductas).insert(
    ConductasCompanion.insert(
      estudianteId: estudianteId,
      fecha: fecha,
      positiva: positiva,
      motivo: motivo,
    ),
  );

  Future<void> borrarConducta(int id) =>
      (delete(conductas)..where((c) => c.id.equals(id))).go();

  Future<void> guardarFoto(int estudianteId, Uint8List? foto) =>
      (update(estudiantes)..where((e) => e.id.equals(estudianteId))).write(
        EstudiantesCompanion(foto: Value(foto)),
      );

  /// Borra todo (colegios, cursos, estudiantes, asistencia, notas, eventos).
  Future<void> borrarTodo() => transaction(() async {
    await delete(eventos).go();
    await delete(colegios).go();
  });

  // Resumen para el inicio

  Stream<({int colegios, int cursos, int secciones, int estudiantes})>
  verResumen() {
    final query = customSelect(
      'SELECT '
      '(SELECT COUNT(*) FROM colegios) AS col, '
      '(SELECT COUNT(*) FROM cursos) AS cur, '
      '(SELECT COUNT(DISTINCT colegio_id || nivel || grado || seccion) FROM cursos) AS sec, '
      '(SELECT COUNT(*) FROM estudiantes) AS est',
      readsFrom: {colegios, cursos, estudiantes},
    );
    return query.watchSingle().map(
      (r) => (
        colegios: r.read<int>('col'),
        cursos: r.read<int>('cur'),
        secciones: r.read<int>('sec'),
        estudiantes: r.read<int>('est'),
      ),
    );
  }
}
