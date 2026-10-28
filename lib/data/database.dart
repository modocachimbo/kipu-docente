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
  TextColumn get telefono => text().nullable()();
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

/// Fechas del calendario del docente (entregas, reuniones, cumpleaños...).
class Eventos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fecha => text()(); // yyyy-MM-dd
  TextColumn get hora => text().nullable()(); // null = todo el día
  TextColumn get titulo => text()();
  TextColumn get etiqueta => text().nullable()();
  TextColumn get tipo => text().withDefault(const Constant('tarea'))(); // tarea, cumple
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

class CursoConColegio {
  final Curso curso;
  final Colegio colegio;
  final int totalEstudiantes;
  CursoConColegio(this.curso, this.colegio, this.totalEstudiantes);
}

@DriftDatabase(tables: [Ajustes, Colegios, Cursos, Estudiantes, Asistencias, Notas, Eventos, Horarios])
class KipuDb extends _$KipuDb {
  KipuDb([QueryExecutor? executor]) : super(executor ?? _abrir());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(asistencias);
          if (from < 3) {
            await m.createTable(notas);
            await m.createTable(eventos);
          }
          if (from < 4) await m.createTable(horarios);
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
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

  Stream<String?> verAjuste(String clave) => (select(ajustes)
        ..where((a) => a.clave.equals(clave)))
      .watchSingleOrNull()
      .map((a) => a?.valor);

  Future<String?> leerAjuste(String clave) async => (await (select(ajustes)
            ..where((a) => a.clave.equals(clave)))
          .getSingleOrNull())
      ?.valor;

  Future<void> guardarAjuste(String clave, String valor) =>
      into(ajustes).insertOnConflictUpdate(
          AjustesCompanion.insert(clave: clave, valor: valor));

  // Colegios

  Stream<List<Colegio>> verColegios() =>
      (select(colegios)..orderBy([(c) => OrderingTerm.asc(c.nombre)])).watch();

  Future<int> crearColegio(String nombre, String? lugar) => into(colegios)
      .insert(ColegiosCompanion.insert(nombre: nombre, lugar: Value(lugar)));

  Future<void> borrarColegio(int id) =>
      (delete(colegios)..where((c) => c.id.equals(id))).go();

  // Cursos

  Stream<List<CursoConColegio>> verCursos() {
    final total = estudiantes.id.count();
    final q = select(cursos).join([
      innerJoin(colegios, colegios.id.equalsExp(cursos.colegioId)),
      leftOuterJoin(estudiantes, estudiantes.cursoId.equalsExp(cursos.id)),
    ])
      ..addColumns([total])
      ..groupBy([cursos.id])
      ..orderBy([
        OrderingTerm.asc(colegios.nombre),
        OrderingTerm.asc(cursos.nivel),
        OrderingTerm.asc(cursos.grado),
        OrderingTerm.asc(cursos.seccion),
      ]);
    return q.watch().map((filas) => filas
        .map((f) => CursoConColegio(
            f.readTable(cursos), f.readTable(colegios), f.read(total) ?? 0))
        .toList());
  }

  Future<int> crearCurso(CursosCompanion c) => into(cursos).insert(c);

  Future<void> borrarCurso(int id) =>
      (delete(cursos)..where((c) => c.id.equals(id))).go();

  // Estudiantes

  Stream<List<Estudiante>> verEstudiantes(int cursoId) => (select(estudiantes)
        ..where((e) => e.cursoId.equals(cursoId))
        ..orderBy([
          (e) => OrderingTerm.asc(e.apellidos),
          (e) => OrderingTerm.asc(e.nombres),
        ]))
      .watch();

  Future<int> guardarEstudiante(EstudiantesCompanion e) =>
      into(estudiantes).insertOnConflictUpdate(e);

  Future<void> borrarEstudiante(int id) =>
      (delete(estudiantes)..where((e) => e.id.equals(id))).go();

  // Asistencia

  /// Estado de cada estudiante del curso en la fecha dada (null si no se marcó).
  Stream<Map<int, String>> verAsistencia(int cursoId, String fecha) {
    final q = select(asistencias).join([
      innerJoin(estudiantes, estudiantes.id.equalsExp(asistencias.estudianteId)),
    ])
      ..where(estudiantes.cursoId.equals(cursoId) &
          asistencias.fecha.equals(fecha));
    return q.watch().map((filas) => {
          for (final f in filas)
            f.readTable(asistencias).estudianteId: f.readTable(asistencias).estado
        });
  }

  Future<void> marcarAsistencia(int estudianteId, String fecha, String? estado) {
    if (estado == null) {
      return (delete(asistencias)
            ..where((a) =>
                a.estudianteId.equals(estudianteId) & a.fecha.equals(fecha)))
          .go();
    }
    return into(asistencias).insertOnConflictUpdate(AsistenciasCompanion.insert(
        estudianteId: estudianteId, fecha: fecha, estado: estado));
  }

  Future<void> marcarTodos(List<int> estudianteIds, String fecha, String estado) =>
      batch((b) => b.insertAllOnConflictUpdate(asistencias, [
            for (final id in estudianteIds)
              AsistenciasCompanion.insert(
                  estudianteId: id, fecha: fecha, estado: estado),
          ]));

  // Notas y estadística

  /// Cantidad de calificaciones por nivel de logro, opcionalmente de un curso.
  Stream<Map<String, int>> verNiveles({int? cursoId, int? periodo}) {
    final total = notas.id.count();
    final q = selectOnly(notas).join([
      innerJoin(estudiantes, estudiantes.id.equalsExp(notas.estudianteId)),
    ])
      ..addColumns([notas.nota, total])
      ..groupBy([notas.nota]);
    if (cursoId != null) q.where(estudiantes.cursoId.equals(cursoId));
    if (periodo != null) q.where(notas.periodo.equals(periodo));
    return q.watch().map((filas) => {
          for (final f in filas) f.read(notas.nota)!: f.read(total) ?? 0
        });
  }

  /// Estudiante con más AD (para "Destacado del periodo").
  Stream<(Estudiante, CursoConColegio?)?> verDestacado() {
    final ads = notas.id.count();
    final q = select(estudiantes).join([
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
  Stream<List<({Estudiante estudiante, CursoConColegio? curso, int c, int faltas})>>
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
      final lista = <({Estudiante estudiante, CursoConColegio? curso, int c, int faltas})>[];
      for (final f in filas) {
        final c = f.read<int>('c'), faltas = f.read<int>('f');
        if (c + faltas == 0) continue;
        final e = await (select(estudiantes)
              ..where((x) => x.id.equals(f.read<int>('id'))))
            .getSingle();
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
      String desde, String hasta) {
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
              (h, c)
        ];
      });

  // Eventos

  Stream<List<Evento>> verEventos(String fecha) => (select(eventos)
        ..where((e) => e.fecha.equals(fecha))
        ..orderBy([(e) => OrderingTerm.asc(e.hora)]))
      .watch();

  Stream<Set<String>> verFechasConEventos(String desde, String hasta) =>
      (selectOnly(eventos, distinct: true)
            ..addColumns([eventos.fecha])
            ..where(eventos.fecha.isBetweenValues(desde, hasta)))
          .watch()
          .map((f) => {for (final r in f) r.read(eventos.fecha)!});

  // Búsqueda

  Future<List<(Estudiante, CursoConColegio?)>> buscarEstudiantes(
      String texto) async {
    final t = '%${texto.trim()}%';
    final lista = await (select(estudiantes)
          ..where((e) => e.apellidos.like(t) | e.nombres.like(t))
          ..orderBy([(e) => OrderingTerm.asc(e.apellidos)])
          ..limit(30))
        .get();
    final cursos = await verCursos().first;
    return [
      for (final e in lista)
        (e, cursos.where((c) => c.curso.id == e.cursoId).firstOrNull)
    ];
  }

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
    return query.watchSingle().map((r) => (
          colegios: r.read<int>('col'),
          cursos: r.read<int>('cur'),
          secciones: r.read<int>('sec'),
          estudiantes: r.read<int>('est'),
        ));
  }
}
