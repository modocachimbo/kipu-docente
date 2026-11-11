import 'dart:convert';

import 'package:drift/drift.dart';

import 'database.dart';

/// Tipos de evento de la agenda: (id, nombre, color).
const tiposEvento = <(String, String, int)>[
  ('tarea', 'Tarea', 0xFF5B5BD6),
  ('reunion', 'Reunión', 0xFFE07B1F),
  ('entrega', 'Entrega de notas', 0xFFC2334A),
  ('examen', 'Examen', 0xFF2F4FD6),
  ('actividad', 'Actividad del colegio', 0xFF16A37F),
  ('feriado', 'Feriado / sin clases', 0xFF8E8AA0),
  ('otro', 'Otro', 0xFF1A9BD7),
];

String nombreTipoEvento(String t) =>
    tiposEvento.where((x) => x.$1 == t).firstOrNull?.$2 ??
    (t == 'cumple' ? 'Cumpleaños' : 'Otro');

int colorTipoEvento(String t) =>
    tiposEvento.where((x) => x.$1 == t).firstOrNull?.$3 ??
    (t == 'cumple' ? 0xFFE5508E : 0xFF1A9BD7);

/// Cuándo avisar: minutos antes (0 = a la hora).
const opcionesRecordar = <(int?, String)>[
  (null, 'Sin aviso'),
  (0, 'A la hora'),
  (10, '10 min antes'),
  (30, '30 min antes'),
  (60, '1 hora antes'),
  (1440, '1 día antes'),
  (10080, '1 semana antes'),
];

const opcionesRepetir = <(String?, String)>[
  (null, 'No se repite'),
  ('semanal', 'Cada semana'),
  ('mensual', 'Cada mes'),
  ('anual', 'Cada año'),
];

/// Avisos automáticos que el profesor puede encender o apagar.
class AjustesAvisos {
  /// Avisar antes de cada clase del horario.
  final bool clases;
  final int minutosClase;

  /// Avisar los cumpleaños de los estudiantes (7:00 a. m.).
  final bool cumples;

  /// Avisar que se acerca el cierre del periodo (3 días antes y el día).
  final bool cierre;

  /// Avisar los pendientes el día que vencen (8:00 a. m.).
  final bool pendientes;

  const AjustesAvisos({
    this.clases = false,
    this.minutosClase = 10,
    this.cumples = true,
    this.cierre = true,
    this.pendientes = true,
  });

  AjustesAvisos copiar({
    bool? clases,
    int? minutosClase,
    bool? cumples,
    bool? cierre,
    bool? pendientes,
  }) => AjustesAvisos(
    clases: clases ?? this.clases,
    minutosClase: minutosClase ?? this.minutosClase,
    cumples: cumples ?? this.cumples,
    cierre: cierre ?? this.cierre,
    pendientes: pendientes ?? this.pendientes,
  );

  String aTexto() => jsonEncode({
    'clases': clases,
    'minutosClase': minutosClase,
    'cumples': cumples,
    'cierre': cierre,
    'pendientes': pendientes,
  });

  static AjustesAvisos deTexto(String? s) {
    if (s == null || s.isEmpty) return const AjustesAvisos();
    try {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return AjustesAvisos(
        clases: m['clases'] == true,
        minutosClase: (m['minutosClase'] as num?)?.toInt() ?? 10,
        cumples: m['cumples'] != false,
        cierre: m['cierre'] != false,
        pendientes: m['pendientes'] != false,
      );
    } catch (_) {
      return const AjustesAvisos();
    }
  }
}

const claveAvisos = 'diario_avisos';

extension DiarioDb on KipuDb {
  // Eventos

  Future<int> guardarEvento(EventosCompanion e) async {
    if (e.id.present) {
      await (update(eventos)..where((x) => x.id.equals(e.id.value))).write(e);
      return e.id.value;
    }
    return into(eventos).insert(e);
  }

  Future<void> borrarEvento(int id) =>
      (delete(eventos)..where((e) => e.id.equals(id))).go();

  Future<Evento?> leerEvento(int id) =>
      (select(eventos)..where((e) => e.id.equals(id))).getSingleOrNull();

  /// Todos los eventos (para calcular los avisos).
  Stream<List<Evento>> verTodosEventos() => select(eventos).watch();

  // Pendientes

  Stream<List<Pendiente>> verPendientes() =>
      (select(pendientes)..orderBy([
            (p) => OrderingTerm.asc(p.hecho),
            (p) => OrderingTerm(
              expression: p.vence.isNull(),
              mode: OrderingMode.asc,
            ),
            (p) => OrderingTerm.asc(p.vence),
            (p) => OrderingTerm.desc(p.creado),
          ]))
          .watch();

  Future<int> agregarPendiente(
    String texto, {
    String? vence,
    int? cursoId,
    int? estudianteId,
  }) => into(pendientes).insert(
    PendientesCompanion.insert(
      texto: texto,
      vence: Value(vence),
      cursoId: Value(cursoId),
      estudianteId: Value(estudianteId),
    ),
  );

  Future<void> editarPendiente(
    int id, {
    required String texto,
    String? vence,
    int? cursoId,
  }) => (update(pendientes)..where((p) => p.id.equals(id))).write(
    PendientesCompanion(
      texto: Value(texto),
      vence: Value(vence),
      cursoId: Value(cursoId),
    ),
  );

  Future<void> marcarPendiente(int id, bool hecho) =>
      (update(pendientes)..where((p) => p.id.equals(id))).write(
        PendientesCompanion(hecho: Value(hecho)),
      );

  Future<void> borrarPendiente(int id) =>
      (delete(pendientes)..where((p) => p.id.equals(id))).go();

  Future<int> borrarPendientesHechos() =>
      (delete(pendientes)..where((p) => p.hecho.equals(true))).go();

  // Estudiantes con cumpleaños (para los avisos)

  Future<List<(Estudiante, Curso)>> estudiantesConCumple() async {
    final q =
        select(estudiantes).join([
          innerJoin(cursos, cursos.id.equalsExp(estudiantes.cursoId)),
        ])..where(
          estudiantes.nacimiento.isNotNull() & estudiantes.hasta.isNull(),
        );
    return [
      for (final r in await q.get())
        (r.readTable(estudiantes), r.readTable(cursos)),
    ];
  }
}

/// Tipo de una anotación del anecdotario: (id, nombre, color).
const tiposAnecdota = <(String, String, int)>[
  ('positivo', 'Positivo', 0xFF16A37F),
  ('negativo', 'Por mejorar', 0xFFC2334A),
  ('neutro', 'Neutro', 0xFF6E6A80),
];

const categoriasAnecdota = <(String, String)>[
  ('conducta', 'Conducta'),
  ('logro', 'Logro'),
  ('academico', 'Académico'),
  ('salud', 'Salud'),
  ('familia', 'Familia'),
  ('otro', 'Otro'),
];

int colorTipoAnecdota(String t) =>
    tiposAnecdota.where((x) => x.$1 == t).firstOrNull?.$3 ?? 0xFF6E6A80;

String nombreCategoria(String c) => c == 'reunion'
    ? 'Reunión con padres'
    : categoriasAnecdota.where((x) => x.$1 == c).firstOrNull?.$2 ?? 'Otro';

/// Una anotación con su estudiante y curso.
typedef AnecdotaCompleta = (Anecdota, Estudiante, Curso);

extension DiarioEstudiantesDb on KipuDb {
  /// Anecdotario (sin reuniones) o solo reuniones, del más nuevo al más viejo.
  Stream<List<AnecdotaCompleta>> verAnecdotas({
    int? cursoId,
    int? estudianteId,
    bool reuniones = false,
  }) {
    final q = select(anecdotas).join([
      innerJoin(estudiantes, estudiantes.id.equalsExp(anecdotas.estudianteId)),
      innerJoin(cursos, cursos.id.equalsExp(estudiantes.cursoId)),
    ]);
    Expression<bool> w = reuniones
        ? anecdotas.categoria.equals('reunion')
        : anecdotas.categoria.equals('reunion').not();
    if (cursoId != null) w = w & estudiantes.cursoId.equals(cursoId);
    if (estudianteId != null) w = w & anecdotas.estudianteId.equals(estudianteId);
    q
      ..where(w)
      ..orderBy([
        OrderingTerm.desc(anecdotas.fecha),
        OrderingTerm.desc(anecdotas.id),
      ]);
    return q.watch().map(
      (filas) => [
        for (final r in filas)
          (r.readTable(anecdotas), r.readTable(estudiantes), r.readTable(cursos)),
      ],
    );
  }

  Future<int> guardarAnecdota(AnecdotasCompanion a) async {
    if (a.id.present) {
      await (update(anecdotas)..where((x) => x.id.equals(a.id.value))).write(a);
      return a.id.value;
    }
    return into(anecdotas).insert(a);
  }

  Future<void> borrarAnecdota(int id) =>
      (delete(anecdotas)..where((a) => a.id.equals(id))).go();

  // Diario de clase

  Stream<List<(ClaseDiario, Curso)>> verClasesDiario({int? cursoId}) {
    final q = select(clasesDiario).join([
      innerJoin(cursos, cursos.id.equalsExp(clasesDiario.cursoId)),
    ]);
    if (cursoId != null) q.where(clasesDiario.cursoId.equals(cursoId));
    q.orderBy([
      OrderingTerm.desc(clasesDiario.fecha),
      OrderingTerm.desc(clasesDiario.id),
    ]);
    return q.watch().map(
      (filas) => [
        for (final r in filas) (r.readTable(clasesDiario), r.readTable(cursos)),
      ],
    );
  }

  Future<ClaseDiario?> leerClaseDiario(int cursoId, String fecha) =>
      (select(clasesDiario)
            ..where((c) => c.cursoId.equals(cursoId) & c.fecha.equals(fecha))
            ..limit(1))
          .getSingleOrNull();

  Future<int> guardarClaseDiario(ClasesDiarioCompanion c) async {
    if (c.id.present) {
      await (update(clasesDiario)..where((x) => x.id.equals(c.id.value)))
          .write(c);
      return c.id.value;
    }
    return into(clasesDiario).insert(c);
  }

  Future<void> borrarClaseDiario(int id) =>
      (delete(clasesDiario)..where((c) => c.id.equals(id))).go();
}
