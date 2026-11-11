import 'dart:convert';

import 'package:drift/drift.dart';

import 'academico.dart' show claveFecha;
import 'cneb.dart';
import 'columnas.dart' show codigoLibre;
import 'database.dart';

/// Planificación curricular: unidades (o experiencias de aprendizaje) por
/// periodo y sus sesiones. En un colegio público se planifica con el CNEB
/// completo (situación significativa, propósitos y enfoques); en uno privado,
/// solo lo esencial, que se descarga en Excel para subir.

// ───────────────────────── CNEB ─────────────────────────

/// Capacidades de cada competencia del CNEB (Minedu).
const capacidadesCneb = <String, List<String>>{
  'identidad': [
    'Se valora a sí mismo',
    'Autorregula sus emociones',
    'Reflexiona y argumenta éticamente',
    'Vive su sexualidad de manera integral y responsable',
  ],
  'motricidad': ['Comprende su cuerpo', 'Se expresa corporalmente'],
  'saludable': [
    'Comprende las relaciones entre la actividad física, alimentación, postura e higiene y la salud',
    'Incorpora prácticas que mejoran su calidad de vida',
  ],
  'sociomotriz': [
    'Se relaciona utilizando sus habilidades sociomotrices',
    'Crea y aplica estrategias y tácticas de juego',
  ],
  'aprecia': [
    'Percibe manifestaciones artístico-culturales',
    'Contextualiza manifestaciones artístico-culturales',
    'Reflexiona creativa y críticamente',
  ],
  'crea': [
    'Explora y experimenta los lenguajes del arte',
    'Aplica procesos creativos',
    'Evalúa y comunica sus procesos y proyectos',
  ],
  'oral': _oral,
  'oral-l2': _oral,
  'oral-ing': _oral,
  'lee': _lee,
  'lee-ing': _lee,
  'escribe': _escribe,
  'escribe-ing': _escribe,
  'convive': [
    'Interactúa con todas las personas',
    'Construye normas y asume acuerdos y leyes',
    'Maneja conflictos de manera constructiva',
    'Delibera sobre asuntos públicos',
    'Participa en acciones que promueven el bienestar común',
  ],
  'historia': [
    'Interpreta críticamente fuentes diversas',
    'Comprende el tiempo histórico',
    'Elabora explicaciones sobre procesos históricos',
  ],
  'ambiente': [
    'Comprende las relaciones entre los elementos naturales y sociales',
    'Maneja fuentes de información para comprender el espacio geográfico y el ambiente',
    'Genera acciones para conservar el ambiente local y global',
  ],
  'economia': [
    'Comprende las relaciones entre los elementos del sistema económico y financiero',
    'Toma decisiones económicas y financieras',
  ],
  'indaga': [
    'Problematiza situaciones para hacer indagación',
    'Diseña estrategias para hacer indagación',
    'Genera y registra datos o información',
    'Analiza datos e información',
    'Evalúa y comunica el proceso y resultados de su indagación',
  ],
  'explica': [
    'Comprende y usa conocimientos sobre los seres vivos, materia y energía, biodiversidad, Tierra y universo',
    'Evalúa las implicancias del saber y del quehacer científico y tecnológico',
  ],
  'disena': [
    'Determina una alternativa de solución tecnológica',
    'Diseña la alternativa de solución tecnológica',
    'Implementa y valida la alternativa de solución tecnológica',
    'Evalúa y comunica el funcionamiento y los impactos de su alternativa',
  ],
  'cantidad': [
    'Traduce cantidades a expresiones numéricas',
    'Comunica su comprensión sobre los números y las operaciones',
    'Usa estrategias y procedimientos de estimación y cálculo',
    'Argumenta afirmaciones sobre las relaciones numéricas y las operaciones',
  ],
  'regularidad': [
    'Traduce datos y condiciones a expresiones algebraicas y gráficas',
    'Comunica su comprensión sobre las relaciones algebraicas',
    'Usa estrategias y procedimientos para encontrar equivalencias y reglas generales',
    'Argumenta afirmaciones sobre relaciones de cambio y equivalencia',
  ],
  'forma': [
    'Modela objetos con formas geométricas y sus transformaciones',
    'Comunica su comprensión sobre las formas y relaciones geométricas',
    'Usa estrategias y procedimientos para medir y orientarse en el espacio',
    'Argumenta afirmaciones sobre relaciones geométricas',
  ],
  'datos': [
    'Representa datos con gráficos y medidas estadísticas o probabilísticas',
    'Comunica su comprensión de los conceptos estadísticos y probabilísticos',
    'Usa estrategias y procedimientos para recopilar y procesar datos',
    'Sustenta conclusiones o decisiones con base en la información obtenida',
  ],
  'emprende': [
    'Crea propuestas de valor',
    'Aplica habilidades técnicas',
    'Trabaja cooperativamente para lograr objetivos y metas',
    'Evalúa los resultados del proyecto de emprendimiento',
  ],
  'fe-identidad': [
    'Conoce a Dios y asume su identidad religiosa y espiritual',
    'Cultiva y valora las manifestaciones religiosas de su entorno',
  ],
  'fe-encuentro': [
    'Transforma su entorno desde el encuentro personal y comunitario con Dios',
    'Actúa coherentemente en razón de su fe',
  ],
  'tic': [
    'Personaliza entornos virtuales',
    'Gestiona información del entorno virtual',
    'Interactúa en entornos virtuales',
    'Crea objetos virtuales en diversos formatos',
  ],
  'autonomo': [
    'Define metas de aprendizaje',
    'Organiza acciones estratégicas para alcanzar sus metas',
    'Monitorea y ajusta su desempeño durante el proceso de aprendizaje',
  ],
};

const _oral = [
  'Obtiene información del texto oral',
  'Infiere e interpreta información del texto oral',
  'Adecúa, organiza y desarrolla las ideas de forma coherente y cohesionada',
  'Utiliza recursos no verbales y paraverbales de forma estratégica',
  'Interactúa estratégicamente con distintos interlocutores',
  'Reflexiona y evalúa la forma, el contenido y contexto del texto oral',
];
const _lee = [
  'Obtiene información del texto escrito',
  'Infiere e interpreta información del texto',
  'Reflexiona y evalúa la forma, el contenido y contexto del texto',
];
const _escribe = [
  'Adecúa el texto a la situación comunicativa',
  'Organiza y desarrolla las ideas de forma coherente y cohesionada',
  'Utiliza convenciones del lenguaje escrito de forma pertinente',
  'Reflexiona y evalúa la forma, el contenido y contexto del texto escrito',
];

/// Enfoques transversales del CNEB.
const enfoquesTransversales = [
  'De derechos',
  'Inclusivo o de atención a la diversidad',
  'Intercultural',
  'Igualdad de género',
  'Ambiental',
  'Orientación al bien común',
  'Búsqueda de la excelencia',
];

/// Competencias del área y nivel del curso (más las transversales). Si el
/// área no es del CNEB, todas las del nivel.
List<Competencia> competenciasDelCurso(Curso c) {
  final delNivel = [
    for (final k in competenciasCneb)
      if (k.areas.containsKey(c.nivel)) k,
  ];
  final delArea = [
    for (final k in delNivel)
      if (k.areas[c.nivel] == c.area || k.transversal) k,
  ];
  return delArea.any((k) => !k.transversal) ? delArea : delNivel;
}

/// Letra corta de una competencia para las fichas: I, E, D…
String letraCompetencia(String id) {
  final c = competenciaPorId(id);
  if (c == null) return '?';
  if (id == 'tic') return 'T';
  return c.corto.substring(0, 1).toUpperCase();
}

// ───────────────────────── Modelo ─────────────────────────

/// Un propósito de aprendizaje de la unidad: la competencia con sus
/// capacidades, criterios, evidencia e instrumento.
class Proposito {
  final String competencia;
  final List<String> capacidades;
  final String criterios;
  final String evidencia;
  final String instrumento;

  const Proposito(
    this.competencia, {
    this.capacidades = const [],
    this.criterios = '',
    this.evidencia = '',
    this.instrumento = '',
  });

  Proposito copiar({
    List<String>? capacidades,
    String? criterios,
    String? evidencia,
    String? instrumento,
  }) => Proposito(
    competencia,
    capacidades: capacidades ?? this.capacidades,
    criterios: criterios ?? this.criterios,
    evidencia: evidencia ?? this.evidencia,
    instrumento: instrumento ?? this.instrumento,
  );

  Map<String, dynamic> aJson() => {
    'c': competencia,
    if (capacidades.isNotEmpty) 'cap': capacidades,
    if (criterios.isNotEmpty) 'cri': criterios,
    if (evidencia.isNotEmpty) 'ev': evidencia,
    if (instrumento.isNotEmpty) 'ins': instrumento,
  };

  factory Proposito.deJson(Map<String, dynamic> j) => Proposito(
    j['c'] as String,
    capacidades: [for (final x in (j['cap'] as List? ?? [])) x as String],
    criterios: j['cri'] as String? ?? '',
    evidencia: j['ev'] as String? ?? '',
    instrumento: j['ins'] as String? ?? '',
  );

  static List<Proposito> lista(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      return [
        for (final p in jsonDecode(json) as List)
          Proposito.deJson(p as Map<String, dynamic>),
      ];
    } catch (_) {
      return [];
    }
  }

  static String aTexto(List<Proposito> l) =>
      jsonEncode([for (final p in l) p.aJson()]);
}

extension UnidadX on Unidad {
  List<String> get listaCompetencias =>
      competencias.split(',').where((s) => s.isNotEmpty).toList();
  List<String> get listaEnfoques =>
      enfoques.split('|').where((s) => s.isNotEmpty).toList();
  List<Proposito> get listaPropositos => Proposito.lista(propositos);
}

/// Estado de una unidad según sus sesiones y fechas.
enum EstadoUnidad { porEmpezar, enCurso, terminada }

EstadoUnidad estadoUnidad(Unidad u, List<Sesion> sesiones, DateTime hoy) {
  final h = claveFecha(hoy);
  if (sesiones.isNotEmpty && sesiones.every((s) => s.hecha)) {
    return EstadoUnidad.terminada;
  }
  if (u.hasta != null && u.hasta!.compareTo(h) < 0 && sesiones.isEmpty) {
    return EstadoUnidad.terminada;
  }
  if (sesiones.any((s) => s.hecha) ||
      (u.desde != null && u.desde!.compareTo(h) <= 0)) {
    return EstadoUnidad.enCurso;
  }
  return EstadoUnidad.porEmpezar;
}

/// Una clase del horario en un día concreto.
typedef ClaseFecha = ({String fecha, String hora});

/// Próximas clases de un curso según su [horario], desde [desde] (incluido;
/// si es hoy, solo las que aún no terminan cuando se da [horaActual]) hasta
/// [hasta] (incluido). Salta las que ya están en [ocupadas] («fecha hora»).
List<ClaseFecha> proximasClases(
  List<Horario> horario,
  DateTime desde, {
  required int cantidad,
  Set<String> ocupadas = const {},
  String? hasta,
  String? horaActual,
}) {
  final r = <ClaseFecha>[];
  if (horario.isEmpty || cantidad <= 0) return r;
  final bloques = [...horario]
    ..sort((a, b) {
      final d = a.dia.compareTo(b.dia);
      return d != 0 ? d : a.inicio.compareTo(b.inicio);
    });
  var dia = DateTime(desde.year, desde.month, desde.day);
  // Un año de clases como máximo, por si el horario no alcanza.
  for (var i = 0; i < 400 && r.length < cantidad; i++) {
    final f = claveFecha(dia);
    if (hasta != null && f.compareTo(hasta) > 0) break;
    for (final b in bloques.where((b) => b.dia == dia.weekday)) {
      if (i == 0 && horaActual != null && b.fin.compareTo(horaActual) <= 0) {
        continue;
      }
      if (ocupadas.contains('$f ${b.inicio}')) continue;
      r.add((fecha: f, hora: b.inicio));
      if (r.length == cantidad) break;
    }
    dia = DateTime(dia.year, dia.month, dia.day + 1);
  }
  return r;
}

// ───────────────────────── Base de datos ─────────────────────────

class SesionConUnidad {
  final Sesion sesion;
  final Unidad unidad;
  const SesionConUnidad(this.sesion, this.unidad);
}

extension PlanificacionDb on KipuDb {
  Stream<List<Unidad>> verUnidades(int cursoId, int anio) =>
      (select(unidades)
            ..where((u) => u.cursoId.equals(cursoId) & u.anio.equals(anio))
            ..orderBy([
              (u) => OrderingTerm.asc(u.periodo),
              (u) => OrderingTerm.asc(u.orden),
            ]))
          .watch();

  Stream<Unidad?> verUnidad(int id) =>
      (select(unidades)..where((u) => u.id.equals(id))).watchSingleOrNull();

  /// Sesiones del curso en el año: {unidadId: [sesiones en orden]}.
  Stream<Map<int, List<Sesion>>> verSesionesCurso(int cursoId, int anio) {
    final q =
        select(sesiones).join([
            innerJoin(unidades, unidades.id.equalsExp(sesiones.unidadId)),
          ])
          ..where(unidades.cursoId.equals(cursoId) & unidades.anio.equals(anio))
          ..orderBy([OrderingTerm.asc(sesiones.orden)]);
    return q.watch().map((filas) {
      final r = <int, List<Sesion>>{};
      for (final f in filas) {
        final s = f.readTable(sesiones);
        (r[s.unidadId] ??= []).add(s);
      }
      return r;
    });
  }

  Stream<List<Sesion>> verSesiones(int unidadId) =>
      (select(sesiones)
            ..where((s) => s.unidadId.equals(unidadId))
            ..orderBy([(s) => OrderingTerm.asc(s.orden)]))
          .watch();

  /// Sesiones con fecha entre [desde] y [hasta] (yyyy-MM-dd), de todos los
  /// cursos.
  Stream<List<SesionConUnidad>> verSesionesEntre(String desde, String hasta) {
    final q =
        select(sesiones).join([
            innerJoin(unidades, unidades.id.equalsExp(sesiones.unidadId)),
          ])
          ..where(
            sesiones.fecha.isBiggerOrEqualValue(desde) &
                sesiones.fecha.isSmallerOrEqualValue(hasta),
          )
          ..orderBy([
            OrderingTerm.asc(sesiones.fecha),
            OrderingTerm.asc(sesiones.hora),
          ]);
    return q.watch().map(
      (filas) => [
        for (final f in filas)
          SesionConUnidad(f.readTable(sesiones), f.readTable(unidades)),
      ],
    );
  }

  /// Sesiones sin hacer y sin fecha del curso, en orden de unidad.
  Future<List<SesionConUnidad>> sesionesSinFecha(int cursoId, int anio) async {
    final q =
        select(sesiones).join([
            innerJoin(unidades, unidades.id.equalsExp(sesiones.unidadId)),
          ])
          ..where(
            unidades.cursoId.equals(cursoId) &
                unidades.anio.equals(anio) &
                sesiones.fecha.isNull() &
                sesiones.hecha.equals(false),
          )
          ..orderBy([
            OrderingTerm.asc(unidades.periodo),
            OrderingTerm.asc(unidades.orden),
            OrderingTerm.asc(sesiones.orden),
          ]);
    return [
      for (final f in await q.get())
        SesionConUnidad(f.readTable(sesiones), f.readTable(unidades)),
    ];
  }

  Future<int> crearUnidad(UnidadesCompanion u) async {
    final ultimo =
        await (selectOnly(unidades)
              ..addColumns([unidades.orden.max()])
              ..where(
                unidades.cursoId.equals(u.cursoId.value) &
                    unidades.anio.equals(u.anio.value) &
                    unidades.periodo.equals(u.periodo.value),
              ))
            .map((f) => f.read(unidades.orden.max()))
            .getSingle();
    return into(unidades).insert(u.copyWith(orden: Value((ultimo ?? 0) + 1)));
  }

  Future<void> editarUnidad(int id, UnidadesCompanion u) =>
      (update(unidades)..where((x) => x.id.equals(id))).write(u);

  Future<void> borrarUnidad(int id) =>
      (delete(unidades)..where((x) => x.id.equals(id))).go();

  Future<int> crearSesion(SesionesCompanion s) async {
    final ultimo =
        await (selectOnly(sesiones)
              ..addColumns([sesiones.orden.max()])
              ..where(sesiones.unidadId.equals(s.unidadId.value)))
            .map((f) => f.read(sesiones.orden.max()))
            .getSingle();
    return into(sesiones).insert(s.copyWith(orden: Value((ultimo ?? 0) + 1)));
  }

  Future<void> editarSesion(int id, SesionesCompanion s) =>
      (update(sesiones)..where((x) => x.id.equals(id))).write(s);

  Future<void> borrarSesion(int id) =>
      (delete(sesiones)..where((x) => x.id.equals(id))).go();

  Future<void> marcarSesion(int id, bool hecha) =>
      editarSesion(id, SesionesCompanion(hecha: Value(hecha)));

  Future<void> fecharSesion(int id, String? fecha, String? hora) =>
      editarSesion(
        id,
        SesionesCompanion(fecha: Value(fecha), hora: Value(hora)),
      );

  /// Sube o baja una sesión dentro de su unidad.
  Future<void> moverSesion(List<Sesion> lista, int i, int paso) =>
      transaction(() async {
        final j = i + paso;
        if (j < 0 || j >= lista.length) return;
        await editarSesion(
          lista[i].id,
          SesionesCompanion(orden: Value(lista[j].orden)),
        );
        await editarSesion(
          lista[j].id,
          SesionesCompanion(orden: Value(lista[i].orden)),
        );
      });

  /// Crea en el registro la columna de la sesión (tema y fecha) y la vincula.
  Future<int> columnaDeSesion(
    Sesion s,
    Unidad u, {
    required String? escala,
  }) async {
    final cols = await verColumnas(u.cursoId, u.periodo).first;
    final id = await crearColumna(
      RegistroColumnasCompanion.insert(
        cursoId: u.cursoId,
        periodo: u.periodo,
        orden: 0,
        codigo: codigoLibre('N', [for (final c in cols) c.codigo]),
        tema: Value(s.titulo),
        fecha: Value(s.fecha),
        escala: Value(escala),
      ),
    );
    await editarSesion(s.id, SesionesCompanion(columnaId: Value(id)));
    return id;
  }

  /// Pone fecha a las sesiones sin fecha de la unidad, en orden, en las
  /// próximas clases libres del curso. Devuelve cuántas se programaron.
  Future<int> repartirSesiones(
    Unidad u,
    List<Horario> horario,
    DateTime desde, {
    String? horaActual,
  }) => transaction(() async {
    final todas =
        await (select(sesiones)
              ..where((s) => s.unidadId.equals(u.id))
              ..orderBy([(s) => OrderingTerm.asc(s.orden)]))
            .get();
    final pendientes = [
      for (final s in todas)
        if (s.fecha == null && !s.hecha) s,
    ];
    if (pendientes.isEmpty) return 0;
    final delCurso =
        await (select(sesiones).join([
              innerJoin(unidades, unidades.id.equalsExp(sesiones.unidadId)),
            ])..where(
              unidades.cursoId.equals(u.cursoId) & sesiones.fecha.isNotNull(),
            ))
            .get();
    final ocupadas = {
      for (final f in delCurso)
        '${f.readTable(sesiones).fecha} ${f.readTable(sesiones).hora}',
    };
    // Después de la última sesión ya programada de la unidad.
    var inicio = desde;
    for (final s in todas) {
      if (s.fecha != null) {
        final d = DateTime.parse(s.fecha!);
        if (!d.isBefore(inicio)) inicio = d;
      }
    }
    final clases = proximasClases(
      horario,
      inicio,
      cantidad: pendientes.length,
      ocupadas: ocupadas,
      horaActual: claveFecha(inicio) == claveFecha(desde) ? horaActual : null,
    );
    for (var i = 0; i < clases.length; i++) {
      await fecharSesion(pendientes[i].id, clases[i].fecha, clases[i].hora);
    }
    return clases.length;
  });

  /// Copia las unidades y sesiones de un curso a otro (sin fechas, sin
  /// marcas de hecha ni columnas).
  Future<int> copiarPlanificacion(int origen, int destino, int anio) =>
      transaction(() async {
        final us =
            await (select(unidades)
                  ..where((u) => u.cursoId.equals(origen) & u.anio.equals(anio))
                  ..orderBy([
                    (u) => OrderingTerm.asc(u.periodo),
                    (u) => OrderingTerm.asc(u.orden),
                  ]))
                .get();
        for (final u in us) {
          final nueva = await crearUnidad(
            u
                .toCompanion(false)
                .copyWith(id: const Value.absent(), cursoId: Value(destino)),
          );
          final ss =
              await (select(sesiones)
                    ..where((s) => s.unidadId.equals(u.id))
                    ..orderBy([(s) => OrderingTerm.asc(s.orden)]))
                  .get();
          for (final s in ss) {
            await into(sesiones).insert(
              s
                  .toCompanion(false)
                  .copyWith(
                    id: const Value.absent(),
                    unidadId: Value(nueva),
                    fecha: const Value(null),
                    hora: const Value(null),
                    hecha: const Value(false),
                    columnaId: const Value(null),
                  ),
            );
          }
        }
        return us.length;
      });
}
