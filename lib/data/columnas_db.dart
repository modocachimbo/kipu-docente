import 'dart:convert';

import 'package:drift/drift.dart';

import 'academico.dart';
import 'calculo.dart';
import 'columnas.dart';
import 'database.dart';
import 'evaluacion_db.dart';
import 'paises.dart';
import 'registro.dart';

extension ColumnasDb on KipuDb {
  static const _prefijo = 'columna_cfg_';

  Future<ConfigColumna> leerConfigColumna(int columnaId) async =>
      ConfigColumna.deTexto(await leerAjuste('$_prefijo$columnaId'));

  Future<void> guardarConfigColumna(int columnaId, ConfigColumna c) =>
      guardarAjuste('$_prefijo$columnaId', c.aTexto());

  /// Opciones de todas las columnas que tienen alguna: {columnaId: config}.
  Stream<Map<int, ConfigColumna>> verConfigsColumnas() =>
      (select(ajustes)..where((a) => a.clave.like('$_prefijo%'))).watch().map(
        (filas) => {
          for (final f in filas)
            ?int.tryParse(f.clave.substring(_prefijo.length)):
                ConfigColumna.deTexto(f.valor),
        },
      );

  // Notas puestas a mano en una calculada «Kipu sugiere y tú confirmas».

  Future<Map<int, String>> leerNotasConfirmadas(int columnaId) async {
    final v = await leerAjuste('calculo_manual_$columnaId');
    if (v == null || v.isEmpty) return {};
    try {
      return {
        for (final e in (jsonDecode(v) as Map<String, dynamic>).entries)
          int.parse(e.key): '${e.value}',
      };
    } catch (_) {
      return {};
    }
  }

  Future<void> confirmarNota(int columnaId, int estudianteId, String? valor) async {
    final m = await leerNotasConfirmadas(columnaId);
    if (valor == null) {
      m.remove(estudianteId);
    } else {
      m[estudianteId] = valor;
    }
    await guardarAjuste(
      'calculo_manual_$columnaId',
      jsonEncode({for (final e in m.entries) '${e.key}': e.value}),
    );
  }

  /// Recalcula las columnas automáticas del periodo (asistencia,
  /// participación y calculadas) y guarda las notas que cambiaron. Usa las
  /// fechas del periodo si están configuradas; si no, todo lo registrado.
  Future<void> actualizarAutomaticas({
    required int cursoId,
    required int periodo,
    required ConfigAcademica config,
  }) async {
    final cols =
        await (select(registroColumnas)..where(
              (c) =>
                  c.cursoId.equals(cursoId) &
                  c.periodo.equals(periodo) &
                  c.tipo.isIn([...tiposAutomaticos, 'calculada']),
            ))
            .get();
    if (cols.isEmpty) return;
    final ests = await _estudiantesDelPeriodo(cursoId, periodo);
    if (ests.isEmpty) return;
    final escalas = {for (final e in config.escalas) e.id: e};
    Escala escalaDe(RegistroColumna c) =>
        escalas[c.escala] ??
        escalas[config.escalaPorDefecto] ??
        config.escalas.first;

    // 1. Asistencia y participación.
    final autos = cols.where((c) => esAutomatica(c.tipo)).toList();
    if (autos.isNotEmpty) {
      final p = periodo >= 1 && periodo <= config.periodos.length
          ? config.periodos[periodo - 1]
          : null;
      final desde = p?.inicio, hasta = p?.fin;
      final ids = [for (final e in ests) e.id];
      Expression<bool> enRango(
        GeneratedColumn<int> est,
        GeneratedColumn<String> fecha,
      ) {
        Expression<bool> c = est.isIn(ids);
        if (desde != null) c = c & fecha.isBiggerOrEqualValue(desde);
        if (hasta != null) c = c & fecha.isSmallerOrEqualValue(hasta);
        return c;
      }

      final estados = <int, List<String>>{};
      if (autos.any((c) => c.tipo == 'asistencia')) {
        final filas = await (select(
          asistencias,
        )..where((a) => enRango(a.estudianteId, a.fecha))).get();
        for (final a in filas) {
          (estados[a.estudianteId] ??= []).add(a.estado);
        }
      }
      final conducta = <int, (int, int)>{};
      if (autos.any((c) => c.tipo == 'participacion')) {
        final filas = await (select(
          conductas,
        )..where((c) => enRango(c.estudianteId, c.fecha))).get();
        for (final c in filas) {
          final (mas, menos) = conducta[c.estudianteId] ?? (0, 0);
          conducta[c.estudianteId] = c.positiva
              ? (mas + 1, menos)
              : (mas, menos + 1);
        }
      }
      final actuales = await verNotasRegistro(cursoId, periodo).first;
      for (final col in autos) {
        final escala = escalaDe(col);
        final cfg = await leerConfigColumna(col.id);
        final tramos = escala.numerica ? null : await leerTramos(escala);
        for (final e in ests) {
          final pct = col.tipo == 'asistencia'
              ? porcentajeAsistencia(estados[e.id] ?? const [])
              : porcentajeParticipacion(
                  conducta[e.id]?.$1 ?? 0,
                  conducta[e.id]?.$2 ?? 0,
                  cfg.meta,
                );
          final valor = pct == null
              ? null
              : valorDePorcentaje(
                  pct,
                  escala,
                  tramos: tramos,
                  decimales: cfg.decimales,
                  redondeo: cfg.redondeo,
                );
          if (valor != actuales[col.id]?[e.id]) {
            await ponerNota(col.id, e.id, valor);
          }
        }
      }
    }

    // 2. Calculadas (después, porque pueden usar asistencia y participación).
    final calcs = cols.where((c) => c.tipo == 'calculada').toList();
    if (calcs.isEmpty) return;
    final ctx = await _contexto(cursoId, config);
    final actuales = await verNotasRegistro(cursoId, periodo).first;
    for (final col in calcs) {
      final cfg = ctx.configs[col.id] ?? const ConfigColumna();
      final r = await ctx.calcular(
        propia: ctx.dato(col),
        calculo: cfg.calculo ?? const Calculo(),
        cfg: cfg,
        estudiantes: ests,
      );
      final confirmadas = (cfg.calculo?.tipo == TipoCalculo.nivel &&
              cfg.calculo?.nivel == ModoNivel.sugerida)
          ? await leerNotasConfirmadas(col.id)
          : const <int, String>{};
      for (final e in ests) {
        final valor = confirmadas[e.id] ?? r[e.id]?.valor;
        if (valor != actuales[col.id]?[e.id]) {
          await ponerNota(col.id, e.id, valor);
        }
      }
    }
  }

  /// Cómo sale la nota calculada de un estudiante, para mostrársela al
  /// docente (y al estudiante o su familia).
  Future<Desglose?> desgloseCalculo({
    required RegistroColumna columna,
    required Estudiante estudiante,
    required ConfigAcademica config,
  }) async {
    final ctx = await _contexto(columna.cursoId, config);
    final cfg = ctx.configs[columna.id] ?? const ConfigColumna();
    final r = await ctx.calcular(
      propia: ctx.dato(columna),
      calculo: cfg.calculo ?? const Calculo(),
      cfg: cfg,
      estudiantes: [estudiante],
    );
    return r[estudiante.id];
  }

  /// Vista previa de un cálculo que todavía no se guarda.
  Future<List<(Estudiante, Desglose)>> simularCalculo({
    required int cursoId,
    required int periodo,
    int? columnaId,
    required Calculo calculo,
    required ConfigColumna cfg,
    required String escala,
    required ConfigAcademica config,
    int cuantos = 3,
  }) async {
    final ests = await _estudiantesDelPeriodo(cursoId, periodo);
    final ctx = await _contexto(cursoId, config);
    // Una columna nueva va al final: todas quedan antes que ella.
    final yo = ctx.todas.where((c) => c.id == columnaId).firstOrNull;
    final propia = ColumnaDato(
      id: columnaId ?? -1,
      codigo: '',
      periodo: periodo,
      orden: yo?.orden ?? 1 << 30,
      fijada: yo?.fijada ?? false,
      tipo: 'calculada',
      escala: ctx.escalaPorId(escala),
    );
    // Los primeros estudiantes que tienen alguna nota.
    final conNotas = [
      for (final e in ests)
        if (ctx.notas.values.any((m) => m[e.id] != null)) e,
    ];
    final muestra = (conNotas.isEmpty ? ests : conNotas).take(cuantos).toList();
    final r = await ctx.calcular(
      propia: propia,
      calculo: calculo,
      cfg: cfg,
      estudiantes: muestra,
    );
    return [
      for (final e in muestra)
        if (r[e.id] case final d?) (e, d),
    ];
  }

  /// Las columnas del curso que puede usar un cálculo (para elegirlas).
  Future<List<ColumnaDato>> columnasParaCalculo(
    int cursoId,
    ConfigAcademica config,
  ) async => (await _contexto(cursoId, config)).columnas;

  Future<List<Estudiante>> _estudiantesDelPeriodo(
    int cursoId,
    int periodo,
  ) async => [
    for (final e in await (select(
      estudiantes,
    )..where((e) => e.cursoId.equals(cursoId))).get())
      if (estaEnPeriodo(e, periodo)) e,
  ]..sort((a, b) => claveOrden(a).compareTo(claveOrden(b)));

  /// Todo lo del curso que necesita un cálculo: columnas de todos los
  /// periodos, sus opciones, notas, equivalencias y tramos.
  Future<_Contexto> _contexto(int cursoId, ConfigAcademica config) async {
    final todas =
        await (select(registroColumnas)
              ..where((c) => c.cursoId.equals(cursoId))
              ..orderBy([
                (c) => OrderingTerm.asc(c.periodo),
                (c) => OrderingTerm.asc(c.orden),
              ]))
            .get();
    final configs = await verConfigsColumnas().first;
    final periodos = {for (final c in todas) c.periodo};
    final notas = <int, Map<int, String>>{};
    for (final p in periodos) {
      notas.addAll(await verNotasRegistro(cursoId, p).first);
    }
    final equivalencias = {
      for (final e in config.escalas)
        if (!e.numerica) e.id: await leerEquivalencias(e),
    };
    final tramos = {
      for (final e in config.escalas)
        if (!e.numerica) e.id: await leerTramos(e),
    };
    final instrumentos = await verInstrumentosDeColumnas().first;
    return _Contexto(
      config: config,
      todas: todas,
      configs: configs,
      notas: notas,
      equivalencias: equivalencias,
      tramos: tramos,
      competenciaDe: (id) {
        final c = configs[id]?.competencia ?? '';
        if (c.isNotEmpty) return c;
        final ins = instrumentos[id];
        return ins == null || ins.competencias.isEmpty
            ? ''
            : ins.competencias.first;
      },
    );
  }
}

class _Contexto {
  final ConfigAcademica config;
  final List<RegistroColumna> todas;
  final Map<int, ConfigColumna> configs;
  final Map<int, Map<int, String>> notas;
  final Map<String, List<double>> equivalencias;
  final Map<String, List<double>> tramos;
  final String Function(int) competenciaDe;

  _Contexto({
    required this.config,
    required this.todas,
    required this.configs,
    required this.notas,
    required this.equivalencias,
    required this.tramos,
    required this.competenciaDe,
  });

  Escala escalaPorId(String? id) =>
      config.escalas.where((e) => e.id == id).firstOrNull ??
      config.escalas.where((e) => e.id == config.escalaPorDefecto).firstOrNull ??
      config.escalas.first;

  ColumnaDato dato(RegistroColumna c) => ColumnaDato(
    id: c.id,
    codigo: c.codigo,
    tema: c.tema ?? '',
    periodo: c.periodo,
    orden: c.orden,
    tipo: c.tipo,
    escala: escalaPorId(c.escala),
    competencia: competenciaDe(c.id),
    fijada: c.fijada,
  );

  late final List<ColumnaDato> columnas = [for (final c in todas) dato(c)];

  Future<Map<int, Desglose>> calcular({
    required ColumnaDato propia,
    required Calculo calculo,
    required ConfigColumna cfg,
    required List<Estudiante> estudiantes,
  }) async {
    // Columna de recuperación de cada columna: {original: recuperación}.
    final recuperadaPor = <int, int>{};
    for (final e in configs.entries) {
      final r = e.value.recupera;
      if (r != null) recuperadaPor[r] = e.key;
    }
    final cols = columnasDelCalculo(
      calculo,
      propia,
      columnas,
      recuperaciones: recuperadaPor.values.toSet(),
    );
    return {
      for (final e in estudiantes)
        e.id: calcularCelda(
          c: calculo,
          salida: propia.escala,
          cfg: cfg,
          cols: cols,
          equivalencias: equivalencias,
          tramos: tramos[propia.escala.id],
          valor: (col) {
            final v = notas[col.id]?[e.id];
            final rec = recuperadaPor[col.id];
            if (rec == null) return v;
            return notaConRecuperacion(
              v,
              notas[rec]?[e.id],
              col.escala,
              masAlta: configs[rec]?.recuperaMasAlta ?? true,
            );
          },
        ),
    };
  }
}
