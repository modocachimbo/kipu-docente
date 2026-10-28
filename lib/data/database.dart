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

class CursoConColegio {
  final Curso curso;
  final Colegio colegio;
  final int totalEstudiantes;
  CursoConColegio(this.curso, this.colegio, this.totalEstudiantes);
}

@DriftDatabase(tables: [Ajustes, Colegios, Cursos, Estudiantes])
class KipuDb extends _$KipuDb {
  KipuDb([QueryExecutor? executor]) : super(executor ?? _abrir());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
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
