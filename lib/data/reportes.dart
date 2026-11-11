import 'package:drift/drift.dart';

import 'academico.dart';
import 'calculo.dart' show enVeinte;
import 'colores_notas.dart';
import 'columnas.dart' show esAutomatica;
import 'columnas_db.dart';
import 'database.dart';
import 'diario_db.dart';
import 'evaluacion_db.dart';
import 'paises.dart';

/// Una evaluación del registro (columna) con sus notas llevadas a 0–20.
class EvaluacionDato {
  final RegistroColumna columna;
  final Map<int, double> notas;
  const EvaluacionDato(this.columna, this.notas);

  double? get promedio => promedioDe(notas.values);
}

/// Todo lo que necesitan los reportes de un curso.
class DatosCurso {
  final CursoConColegio curso;

  /// Estudiantes que siguen en el curso.
  final List<Estudiante> estudiantes;
  final List<Periodo> periodos;

  /// Nota de cada periodo en 0–20: {periodo: {estudiante: nota}}.
  final Map<int, Map<int, double>> notaPeriodo;

  /// La misma nota tal como se ve en el registro (15, A, AD…).
  final Map<int, Map<int, String>> textoPeriodo;

  /// La nota del periodo es en letras (CNEB).
  final bool letras;

  /// Evaluaciones de cada periodo (sin calculadas ni automáticas).
  final Map<int, List<EvaluacionDato>> evaluaciones;
  final List<Asistencia> asistencia;
  final List<Conducta> conductas;
  final List<AnecdotaCompleta> anecdotas;

  const DatosCurso({
    required this.curso,
    required this.estudiantes,
    required this.periodos,
    required this.notaPeriodo,
    required this.textoPeriodo,
    required this.letras,
    required this.evaluaciones,
    required this.asistencia,
    required this.conductas,
    required this.anecdotas,
  });

  String get nombre =>
      '${curso.curso.nombre} · ${curso.curso.grado} ${curso.curso.seccion}';

  /// Notas de un periodo (null = promedio anual).
  Map<int, double> notas(int? periodo) => periodo == null
      ? {
          for (final e in estudiantes)
            if (anual(e.id) case final n?) e.id: n,
        }
      : notaPeriodo[periodo] ?? const {};

  /// Promedio de los periodos que tienen nota.
  double? anual(int estudianteId) => promedioDe([
    for (var p = 1; p <= periodos.length; p++)
      ?notaPeriodo[p]?[estudianteId],
  ]);

  /// Nota anual como se muestra: en letras es la del último periodo con nota
  /// (como pide el Minedu); en números, el promedio redondeado.
  String? textoAnual(int estudianteId, {List<double> tramos = const []}) {
    if (letras) {
      for (var p = periodos.length; p >= 1; p--) {
        final t = textoPeriodo[p]?[estudianteId];
        if (t != null) return t;
      }
      return null;
    }
    final n = anual(estudianteId);
    return n == null ? null : numeroCorto(n, 0);
  }

  /// Texto de la nota de un periodo o del año.
  String? texto(int? periodo, int estudianteId) => periodo == null
      ? textoAnual(estudianteId)
      : (textoPeriodo[periodo]?[estudianteId] ??
            (notaPeriodo[periodo]?[estudianteId] == null
                ? null
                : numeroCorto(notaPeriodo[periodo]![estudianteId]!, 0)));

  /// Rango de fechas de un periodo (o del año).
  (String, String) rango(int? periodo, int anio) {
    if (periodo != null && periodo >= 1 && periodo <= periodos.length) {
      final p = periodos[periodo - 1];
      return (p.inicio ?? '$anio-01-01', p.fin ?? '$anio-12-31');
    }
    return (
      periodos.firstOrNull?.inicio ?? '$anio-01-01',
      periodos.lastOrNull?.fin ?? '$anio-12-31',
    );
  }

  List<Asistencia> asistenciaEn(int? periodo, int anio) {
    final (d, h) = rango(periodo, anio);
    return [
      for (final a in asistencia)
        if (a.fecha.compareTo(d) >= 0 && a.fecha.compareTo(h) <= 0) a,
    ];
  }

  List<Conducta> conductasEn(int? periodo, int anio) {
    final (d, h) = rango(periodo, anio);
    return [
      for (final c in conductas)
        if (c.fecha.compareTo(d) >= 0 && c.fecha.compareTo(h) <= 0) c,
    ];
  }
}

// ───────────────────────── Cálculos ─────────────────────────

double? promedioDe(Iterable<double> l) {
  if (l.isEmpty) return null;
  var s = 0.0;
  for (final x in l) {
    s += x;
  }
  return s / l.length;
}

/// 15.25 → «15,3»; 15.0 → «15».
String numeroCorto(double n, [int decimales = 1]) {
  final t = n.toStringAsFixed(decimales);
  final limpio = t.contains('.')
      ? t.replaceFirst(RegExp(r'\.?0+$'), '')
      : t;
  return limpio.replaceAll('.', ',');
}

/// Nota mínima aprobatoria en 0–20.
const aprobatoria = 10.5;

double? porcentajeAprobados(Iterable<double> notas) {
  if (notas.isEmpty) return null;
  return notas.where((n) => n >= aprobatoria).length / notas.length * 100;
}

/// Tramos para agrupar notas (los de «Color de las notas»).
List<TramoColor> tramosReporte() {
  final c = coloresNotas.value;
  return c.tramos.isEmpty ? ColoresNotas.tramosPorDefecto : c.tramos;
}

/// Nombre de cada tramo: con 4 tramos, los niveles del CNEB.
List<String> nombresTramos(List<TramoColor> t) {
  if (t.length == 4) {
    return const ['En inicio', 'En proceso', 'Logrado', 'Destacado'];
  }
  return [
    for (var i = 0; i < t.length; i++)
      '${numeroCorto(t[i].desde, 0)}–'
          '${i + 1 < t.length ? numeroCorto(t[i + 1].desde - 1, 0) : '20'}',
  ];
}

/// Cuántas notas caen en cada tramo.
List<int> distribucion(Iterable<double> notas, List<TramoColor> tramos) {
  final r = List.filled(tramos.length, 0);
  for (final n in notas) {
    var i = 0;
    for (var k = 0; k < tramos.length; k++) {
      // 10,5 se redondea a 11 como en el registro.
      if (n.roundToDouble() >= tramos[k].desde) i = k;
    }
    r[i]++;
  }
  return r;
}

/// Asistencia: {P, T, F, J: cantidad}.
Map<String, int> conteoAsistencia(Iterable<Asistencia> l) {
  final r = {'P': 0, 'T': 0, 'F': 0, 'J': 0};
  for (final a in l) {
    r[a.estado] = (r[a.estado] ?? 0) + 1;
  }
  return r;
}

/// % de asistencia: presentes y tardanzas cuentan; la justificada no entra.
double? porcentajeAsistencia(Map<String, int> c) {
  final cuenta = (c['P'] ?? 0) + (c['T'] ?? 0) + (c['F'] ?? 0);
  if (cuenta == 0) return null;
  return ((c['P'] ?? 0) + (c['T'] ?? 0)) / cuenta * 100;
}

/// Lunes de la semana de una fecha yyyy-MM-dd.
String lunesDe(String fecha) {
  final d = DateTime.parse(fecha);
  final l = DateTime(d.year, d.month, d.day - (d.weekday - 1));
  return '${l.year}-${l.month.toString().padLeft(2, '0')}-${l.day.toString().padLeft(2, '0')}';
}

/// Asistencia agrupada por semana: {lunes: % asistencia}.
Map<String, double> asistenciaPorSemana(Iterable<Asistencia> l) {
  final g = <String, List<Asistencia>>{};
  for (final a in l) {
    (g[lunesDe(a.fecha)] ??= []).add(a);
  }
  final claves = g.keys.toList()..sort();
  return {
    for (final k in claves)
      if (porcentajeAsistencia(conteoAsistencia(g[k]!)) case final p?) k: p,
  };
}

/// Por qué un estudiante necesita atención.
class Riesgo {
  final Estudiante estudiante;
  final DatosCurso curso;
  final List<String> motivos;

  /// Más alto = más urgente.
  final int peso;
  const Riesgo(this.estudiante, this.curso, this.motivos, this.peso);
}

/// Estudiantes en riesgo en un periodo (null = año).
List<Riesgo> enRiesgo(
  DatosCurso d,
  int? periodo,
  int anio, {
  double limiteFaltas = 30,
}) {
  final r = <Riesgo>[];
  final notas = d.notas(periodo);
  final antes = periodo != null && periodo > 1
      ? d.notas(periodo - 1)
      : const <int, double>{};
  final asis = d.asistenciaEn(periodo, anio);
  final cond = d.conductasEn(periodo, anio);
  for (final e in d.estudiantes) {
    final m = <String>[];
    var peso = 0;
    final n = notas[e.id];
    if (n != null && n < aprobatoria) {
      m.add('Promedio desaprobado (${d.texto(periodo, e.id) ?? numeroCorto(n)})');
      peso += 3;
    }
    final a = antes[e.id];
    if (n != null && a != null && a - n >= 2) {
      m.add('Bajó ${numeroCorto(a - n)} puntos');
      peso += 2;
    }
    final c = conteoAsistencia(asis.where((x) => x.estudianteId == e.id));
    final total = c['P']! + c['T']! + c['F']!;
    if (total >= 4) {
      final faltas = c['F']! / total * 100;
      if (faltas >= limiteFaltas) {
        m.add('${numeroCorto(faltas, 0)} % de faltas (${c['F']})');
        peso += 2;
      }
    }
    final malas = cond.where((x) => x.estudianteId == e.id && !x.positiva);
    final buenas = cond.where((x) => x.estudianteId == e.id && x.positiva);
    if (malas.length >= 3 && malas.length > buenas.length) {
      m.add('${malas.length} conductas por mejorar');
      peso += 1;
    }
    final negativas = d.anecdotas
        .where((x) => x.$2.id == e.id && x.$1.tipo == 'negativo')
        .length;
    if (negativas >= 2) {
      m.add('$negativas anotaciones por mejorar');
      peso += 1;
    }
    if (m.isNotEmpty) r.add(Riesgo(e, d, m, peso));
  }
  r.sort((x, y) => y.peso.compareTo(x.peso));
  return r;
}

// ───────────────────────── Carga ─────────────────────────

extension ReportesDb on KipuDb {
  /// Lee y prepara todo lo de un curso para los reportes.
  Future<DatosCurso> datosCurso(
    CursoConColegio c,
    ConfigAcademica cfg,
  ) async {
    final id = c.curso.id;
    final escalas = {for (final e in cfg.escalas) e.id: e};
    Escala escalaDe(RegistroColumna col) =>
        escalas[col.escala ?? cfg.escalaPorDefecto] ??
        escalas[cfg.escalaPorDefecto] ??
        cfg.escalas.first;
    final equiv = <String, List<double>>{};
    Future<List<double>> eq(Escala e) async =>
        equiv[e.id] ??= await leerEquivalencias(e);

    final lista = [
      for (final e in await verEstudiantes(id).first)
        if (e.hasta == null) e,
    ];

    final notaPeriodo = <int, Map<int, double>>{};
    final textoPeriodo = <int, Map<int, String>>{};
    final evaluaciones = <int, List<EvaluacionDato>>{};
    bool? letras;

    for (var p = 1; p <= cfg.periodos.length; p++) {
      // Que las calculadas estén al día antes de leerlas.
      try {
        await actualizarAutomaticas(cursoId: id, periodo: p, config: cfg);
      } catch (_) {}
      final cols = await verColumnas(id, p).first;
      if (cols.isEmpty) continue;
      final notas = await verNotasRegistro(id, p).first;

      Future<Map<int, double>> aVeinte(RegistroColumna col) async {
        final e = escalaDe(col);
        final l = await eq(e);
        return {
          for (final x in (notas[col.id] ?? const <int, String>{}).entries)
            if (enVeinte(x.value, e, l) case final n?) x.key: n,
        };
      }

      final evs = <EvaluacionDato>[];
      for (final col in cols) {
        if (col.tipo == 'calculada' || esAutomatica(col.tipo)) continue;
        evs.add(EvaluacionDato(col, await aVeinte(col)));
      }
      evaluaciones[p] = evs;

      // Nota del periodo: la fija, si no la última calculada, si no el
      // promedio de las evaluaciones.
      final fija =
          cols.where((x) => x.fijada).firstOrNull ??
          cols.where((x) => x.tipo == 'calculada').lastOrNull;
      if (fija != null) {
        notaPeriodo[p] = await aVeinte(fija);
        textoPeriodo[p] = {...?notas[fija.id]};
        letras ??= !escalaDe(fija).numerica;
      } else {
        final m = <int, double>{};
        for (final e in lista) {
          final v = promedioDe([
            for (final x in evs) ?x.notas[e.id],
          ]);
          if (v != null) m[e.id] = v;
        }
        notaPeriodo[p] = m;
      }
    }

    final inicio = cfg.periodos.firstOrNull?.inicio ?? cfg.inicio ?? '${cfg.anio}-01-01';
    final fin = cfg.periodos.lastOrNull?.fin ?? cfg.fin ?? '${cfg.anio}-12-31';
    final asistencia = await verAsistenciaCurso(id, inicio, fin).first;
    final conds = await (select(conductas).join([
      innerJoin(estudiantes, estudiantes.id.equalsExp(conductas.estudianteId)),
    ])..where(estudiantes.cursoId.equals(id))).get();

    return DatosCurso(
      curso: c,
      estudiantes: lista,
      periodos: cfg.periodos,
      notaPeriodo: notaPeriodo,
      textoPeriodo: textoPeriodo,
      letras: letras ?? false,
      evaluaciones: evaluaciones,
      asistencia: asistencia,
      conductas: [for (final r in conds) r.readTable(conductas)],
      anecdotas: await verAnecdotas(cursoId: id).first,
    );
  }
}
