import 'package:drift/drift.dart';

import 'academico.dart';
import 'columnas.dart';
import 'database.dart';
import 'evaluacion_db.dart';
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

  /// Recalcula las columnas de asistencia y participación del periodo y
  /// guarda las notas que cambiaron. Usa las fechas del periodo si están
  /// configuradas; si no, todo lo registrado.
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
                  c.tipo.isIn(tiposAutomaticos),
            ))
            .get();
    if (cols.isEmpty) return;

    final p = periodo >= 1 && periodo <= config.periodos.length
        ? config.periodos[periodo - 1]
        : null;
    final desde = p?.inicio, hasta = p?.fin;
    final ests = [
      for (final e in await (select(
        estudiantes,
      )..where((e) => e.cursoId.equals(cursoId))).get())
        if (estaEnPeriodo(e, periodo)) e,
    ];
    if (ests.isEmpty) return;
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
    if (cols.any((c) => c.tipo == 'asistencia')) {
      final filas = await (select(
        asistencias,
      )..where((a) => enRango(a.estudianteId, a.fecha))).get();
      for (final a in filas) {
        (estados[a.estudianteId] ??= []).add(a.estado);
      }
    }
    final conducta = <int, (int, int)>{};
    if (cols.any((c) => c.tipo == 'participacion')) {
      final filas = await (select(
        conductas,
      )..where((c) => enRango(c.estudianteId, c.fecha))).get();
      for (final c in filas) {
        final (mas, menos) = conducta[c.estudianteId] ?? (0, 0);
        conducta[c.estudianteId] = c.positiva ? (mas + 1, menos) : (mas, menos + 1);
      }
    }

    final escalas = {for (final e in config.escalas) e.id: e};
    final actuales = await verNotasRegistro(cursoId, periodo).first;
    for (final col in cols) {
      final escala =
          escalas[col.escala] ??
          escalas[config.escalaPorDefecto] ??
          config.escalas.first;
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
}
