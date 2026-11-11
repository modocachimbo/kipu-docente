import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/avisos.dart';
import '../data/database.dart';
import '../data/diario_db.dart';
import '../data/recordatorios.dart';
import '../main.dart' show db;
import '../theme.dart';
import '../widgets/kipu_icono.dart';
import 'cursos.dart' show colorColegio;
import 'diario_estudiantes.dart';

/// Mi diario: agenda con calendario, recordatorios, pendientes, anecdotario,
/// diario de clase y reuniones con padres.
class PantallaDiario extends StatefulWidget {
  const PantallaDiario({super.key});

  @override
  State<PantallaDiario> createState() => _PantallaDiarioState();
}

enum _Vista { agenda, pendientes, anecdotario, clases, reuniones }

class _PantallaDiarioState extends State<PantallaDiario> {
  var _vista = _Vista.agenda;
  DateTime _dia = DateUtils.dateOnly(DateTime.now());
  final _claveAnecdotario = GlobalKey<AnecdotarioState>();
  final _claveClases = GlobalKey<DiarioClasesState>();
  final _claveReuniones = GlobalKey<ReunionesState>();
  final _colegios = db.verColegios();

  /// Colegio elegido arriba (null = todos). Se recuerda.
  int? _colegio;
  static const _claveColegio = 'diario_colegio';

  @override
  void initState() {
    super.initState();
    db.leerAjuste(_claveColegio).then((v) {
      if (mounted && v != null) setState(() => _colegio = int.tryParse(v));
    });
  }

  void _elegirColegio(int? id) {
    setState(() => _colegio = id);
    db.guardarAjuste(_claveColegio, id?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Colegio>>(
      stream: _colegios,
      builder: (context, snap) {
        final colegios = snap.data ?? const <Colegio>[];
        // Si el colegio guardado ya no existe, se ven todos.
        final sel = colegios.any((c) => c.id == _colegio) ? _colegio : null;
        return FiltroDiario(
          colegio: sel,
          colegios: colegios,
          child: Builder(builder: (context) => _pantalla(context, sel, colegios)),
        );
      },
    );
  }

  Widget _pantalla(BuildContext context, int? sel, List<Colegio> colegios) {
    final (texto, accion) = switch (_vista) {
      _Vista.agenda => (
        'Nuevo evento',
        () => editarEvento(context, fecha: _dia, colegioId: sel),
      ),
      _Vista.pendientes => (
        'Nuevo pendiente',
        () => editarPendiente(context, colegioId: sel),
      ),
      _Vista.anecdotario => (
        'Anotar',
        () => _claveAnecdotario.currentState?.nueva(),
      ),
      _Vista.clases => (
        'Anotar clase',
        () => _claveClases.currentState?.nueva(),
      ),
      _Vista.reuniones => (
        'Nueva reunión',
        () => _claveReuniones.currentState?.nueva(),
      ),
    };
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi diario'),
        actions: [
          IconButton(
            tooltip: 'Avisos',
            onPressed: () => ajustesAvisos(context),
            icon: KipuIcon(KipuIcono.campana, color: KipuColores.tinta),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: accion,
        icon: const KipuIcon(KipuIcono.agregar, color: Colors.white),
        label: Text(texto),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              if (colegios.length > 1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: _FiltroColegio(
                    colegios: colegios,
                    valor: sel,
                    onCambio: _elegirColegio,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _Pestanas(
                  actual: _vista,
                  onCambio: (v) => setState(() => _vista = v),
                ),
              ),
              Expanded(
                child: switch (_vista) {
                  _Vista.agenda => _Agenda(
                    dia: _dia,
                    onDia: (d) => setState(() => _dia = d),
                  ),
                  _Vista.pendientes => const _Pendientes(),
                  _Vista.anecdotario => Anecdotario(key: _claveAnecdotario),
                  _Vista.clases => DiarioClases(key: _claveClases),
                  _Vista.reuniones => Reuniones(key: _claveReuniones),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Colegio elegido en Mi diario y los colores de cada colegio, para que las
/// pestañas filtren y pinten sin pasar los datos de mano en mano.
class FiltroDiario extends InheritedWidget {
  final int? colegio;
  final List<Colegio> colegios;
  const FiltroDiario({
    super.key,
    required this.colegio,
    required this.colegios,
    required super.child,
  });

  static FiltroDiario? de(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FiltroDiario>();

  /// Hay más de un colegio: vale la pena decir de cuál es cada cosa.
  bool get varios => colegios.length > 1;

  Color colorDe(int? id) =>
      id == null ? KipuColores.morado : colorColegio(colegios, id);

  String? nombreDe(int? id) =>
      colegios.where((c) => c.id == id).firstOrNull?.nombre;

  /// ¿Se ve algo de [id] con el filtro actual? (null = de todos los colegios)
  bool muestra(int? id) => colegio == null || id == null || id == colegio;

  @override
  bool updateShouldNotify(FiltroDiario old) =>
      old.colegio != colegio || old.colegios != colegios;
}

/// Fila de colegios: «Todos» y uno por colegio con su color.
class _FiltroColegio extends StatelessWidget {
  final List<Colegio> colegios;
  final int? valor;
  final ValueChanged<int?> onCambio;
  const _FiltroColegio({
    required this.colegios,
    required this.valor,
    required this.onCambio,
  });

  @override
  Widget build(BuildContext context) {
    Widget chip(int? id, String texto, Color color) {
      final activo = id == valor;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Material(
          color: activo ? color : Colors.white,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => onCambio(id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (id != null) ...[
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: activo ? Colors.white : color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Text(
                      texto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: activo ? Colors.white : KipuColores.tinta,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          chip(null, 'Todos los colegios', KipuColores.tinta),
          for (final c in colegios)
            chip(c.id, c.nombre, colorColegio(colegios, c.id)),
        ],
      ),
    );
  }
}

class _Pestanas extends StatelessWidget {
  final _Vista actual;
  final ValueChanged<_Vista> onCambio;
  const _Pestanas({required this.actual, required this.onCambio});

  static const _nombres = {
    _Vista.agenda: ('Agenda', KipuIcono.calendario),
    _Vista.pendientes: ('Pendientes', KipuIcono.check),
    _Vista.anecdotario: ('Anecdotario', KipuIcono.apuntes),
    _Vista.clases: ('Clases', KipuIcono.libro),
    _Vista.reuniones: ('Reuniones', KipuIcono.familia),
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final v in _Vista.values)
              Material(
                color: v == actual ? KipuColores.morado : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => onCambio(v),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        KipuIcon(
                          _nombres[v]!.$2,
                          size: 17,
                          color: v == actual
                              ? Colors.white
                              : KipuColores.gris,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _nombres[v]!.$1,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: v == actual
                                ? Colors.white
                                : KipuColores.tinta,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _mayus(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String fechaLarga(DateTime d) =>
    _mayus(DateFormat("EEEE d 'de' MMMM", 'es_PE').format(d));

String fechaCorta(String yyyymmdd) {
  final d = DateTime.tryParse(yyyymmdd);
  if (d == null) return yyyymmdd;
  return DateFormat('d MMM', 'es_PE').format(d).replaceAll('.', '');
}

// ───────────────────────── Agenda ─────────────────────────

class _Agenda extends StatelessWidget {
  final DateTime dia;
  final ValueChanged<DateTime> onDia;
  const _Agenda({required this.dia, required this.onDia});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final ancho = c.maxWidth >= 820;
        final calendario = _Calendario(dia: dia, onDia: onDia);
        final detalle = _DetalleDia(dia: dia);
        if (ancho) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 380,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 96),
                    child: calendario,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 96),
                    child: detalle,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          children: [calendario, const SizedBox(height: 14), detalle],
        );
      },
    );
  }
}

class _Calendario extends StatefulWidget {
  final DateTime dia;
  final ValueChanged<DateTime> onDia;
  const _Calendario({required this.dia, required this.onDia});

  @override
  State<_Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<_Calendario> {
  late DateTime _mes = DateTime(widget.dia.year, widget.dia.month);

  @override
  void didUpdateWidget(covariant _Calendario old) {
    super.didUpdateWidget(old);
    if (widget.dia.month != old.dia.month || widget.dia.year != old.dia.year) {
      _mes = DateTime(widget.dia.year, widget.dia.month);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hoy = DateUtils.dateOnly(DateTime.now());
    final dias = DateUtils.getDaysInMonth(_mes.year, _mes.month);
    final vacios = _mes.weekday - 1; // lunes primero
    final filas = ((vacios + dias) / 7).ceil();
    final base = KipuColores.morado;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Mes anterior',
                onPressed: () => setState(
                  () => _mes = DateTime(_mes.year, _mes.month - 1),
                ),
                icon: KipuIcon(KipuIcono.izquierda, color: KipuColores.tinta),
              ),
              Expanded(
                child: Text(
                  _mayus(DateFormat('MMMM yyyy', 'es_PE').format(_mes)),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Mes siguiente',
                onPressed: () => setState(
                  () => _mes = DateTime(_mes.year, _mes.month + 1),
                ),
                icon: KipuIcon(KipuIcono.derecha, color: KipuColores.tinta),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() => _mes = DateTime(hoy.year, hoy.month));
                widget.onDia(hoy);
              },
              child: const Text('Hoy'),
            ),
          ),
          Row(
            children: [
              for (final l in const ['L', 'M', 'M', 'J', 'V', 'S', 'D'])
                Expanded(
                  child: Text(
                    l,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: KipuColores.gris,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          StreamBuilder<Map<String, Set<int?>>>(
            stream: db.verMarcas(
              claveFecha(_mes),
              claveFecha(DateTime(_mes.year, _mes.month, dias)),
            ),
            builder: (context, snap) {
              final filtro = FiltroDiario.de(context);
              final con = snap.data ?? const <String, Set<int?>>{};
              return Column(
                children: [
                  for (var f = 0; f < filas; f++)
                    Row(
                      children: [
                        for (var k = 0; k < 7; k++)
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                final n = f * 7 + k - vacios + 1;
                                if (n < 1 || n > dias) {
                                  return const SizedBox(height: 46);
                                }
                                final d = DateTime(_mes.year, _mes.month, n);
                                final elegido = d == widget.dia;
                                final esHoy = d == hoy;
                                // Un punto por colegio (máx. 3), en su color.
                                final marcas = [
                                  for (final id in con[claveFecha(d)] ?? const <int?>{})
                                    if (filtro?.muestra(id) ?? true) id,
                                ].take(3).toList();
                                return Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Material(
                                    color: elegido
                                        ? base
                                        : (esHoy
                                              ? Color.lerp(
                                                  base,
                                                  Colors.white,
                                                  .88,
                                                )
                                              : Colors.transparent),
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () => widget.onDia(d),
                                      child: SizedBox(
                                        height: 42,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '$n',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: esHoy || elegido
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                color: elegido
                                                    ? Colors.white
                                                    : (k >= 5
                                                          ? KipuColores.gris
                                                          : KipuColores.tinta),
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            SizedBox(
                                              height: 5,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  for (final id in marcas)
                                                    Container(
                                                      width: 5,
                                                      height: 5,
                                                      margin:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 1,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: elegido
                                                            ? Colors.white
                                                            : (filtro?.colorDe(
                                                                    id,
                                                                  ) ??
                                                                  base),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DetalleDia extends StatelessWidget {
  final DateTime dia;
  const _DetalleDia({required this.dia});

  @override
  Widget build(BuildContext context) {
    final k = claveFecha(dia);
    final filtro = FiltroDiario.de(context);
    bool ve(int? colegio) => filtro?.muestra(colegio) ?? true;
    return StreamBuilder<List<CursoConColegio>>(
      stream: db.verCursos(),
      builder: (context, cu) {
        final colegioDe = {
          for (final c in cu.data ?? const <CursoConColegio>[])
            c.curso.id: c.colegio.id,
        };
        int? colegioEvento(Evento e) =>
            e.colegioId ?? (e.cursoId == null ? null : colegioDe[e.cursoId]);
        return StreamBuilder<List<Evento>>(
      stream: db.verEventos(k),
      builder: (context, ev) {
        final todos = ev.data ?? const <Evento>[];
        final eventos = [
          for (final e in todos)
            if (ve(colegioEvento(e))) e,
        ];
        // Feriado: sin clases en su colegio (o en todos si no tiene).
        final feriados = {
          for (final e in todos)
            if (e.tipo == 'feriado') colegioEvento(e),
        };
        bool sinClases(int colegio) =>
            feriados.contains(null) || feriados.contains(colegio);
        final feriado = feriados.isNotEmpty &&
            (feriados.contains(null) ||
                (filtro?.colegio != null &&
                    feriados.contains(filtro!.colegio)));
        return StreamBuilder<List<(Horario, CursoConColegio)>>(
          stream: db.verClasesDelDia(dia.weekday),
          builder: (context, cl) {
            final clases = [
              for (final (h, c) in cl.data ?? const <(Horario, CursoConColegio)>[])
                if (ve(c.colegio.id) && !sinClases(c.colegio.id)) (h, c),
            ];
            return StreamBuilder<List<Pendiente>>(
              stream: db.verPendientes(),
              builder: (context, pe) {
                final pendientes = [
                  for (final p in pe.data ?? const <Pendiente>[])
                    if (p.vence == k &&
                        ve(p.cursoId == null ? null : colegioDe[p.cursoId]))
                      p,
                ];
                final vacio =
                    eventos.isEmpty && clases.isEmpty && pendientes.isEmpty;
                return Container(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        fechaLarga(dia),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (feriado)
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            'Sin clases',
                            style: TextStyle(color: KipuColores.gris),
                          ),
                        ),
                      if (vacio)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 28),
                          child: Column(
                            children: [
                              KipuIcon(
                                KipuIcono.calendario,
                                size: 44,
                                color: Color.lerp(
                                  KipuColores.morado,
                                  Colors.white,
                                  .5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Nada para este día',
                                style: TextStyle(color: KipuColores.gris),
                              ),
                              const SizedBox(height: 6),
                              TextButton(
                                onPressed: () =>
                                    editarEvento(context, fecha: dia),
                                child: const Text('Agregar evento'),
                              ),
                            ],
                          ),
                        ),
                      if (eventos.isNotEmpty) ...[
                        const _Titulo('Agenda'),
                        for (final e in eventos) _FilaEvento(e, dia: dia),
                      ],
                      if (clases.isNotEmpty) ...[
                        const _Titulo('Clases'),
                        for (final (h, c) in clases) _FilaClase(h, c, dia: dia),
                      ],
                      if (pendientes.isNotEmpty) ...[
                        const _Titulo('Pendientes que vencen'),
                        for (final p in pendientes) _FilaPendiente(p),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
      },
    );
  }
}

class _Titulo extends StatelessWidget {
  final String texto;
  const _Titulo(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(
      texto.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        letterSpacing: .6,
        fontWeight: FontWeight.w700,
        color: KipuColores.gris,
      ),
    ),
  );
}

class _FilaEvento extends StatelessWidget {
  final Evento e;
  final DateTime dia;
  const _FilaEvento(this.e, {required this.dia});

  @override
  Widget build(BuildContext context) {
    final color = Color(colorTipoEvento(e.tipo));
    final cumple = e.tipo == 'cumple';
    final filtro = FiltroDiario.de(context);
    final extras = [
      nombreTipoEvento(e.tipo),
      if (filtro != null && filtro.varios && filtro.colegio == null)
        ?filtro.nombreDe(e.colegioId),
      if (e.etiqueta != null) e.etiqueta!,
      if (e.repetir != null)
        opcionesRepetir.firstWhere((x) => x.$1 == e.repetir).$2,
    ].join(' · ');
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: cumple ? null : () => editarEvento(context, evento: e),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 74,
              child: Text(
                e.hora == null ? 'Todo el día' : horaBonita(e.hora!),
                style: const TextStyle(fontSize: 13, color: KipuColores.gris),
              ),
            ),
            if (cumple)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: KipuIcon(KipuIcono.cumple, size: 18, color: color),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.titulo,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    extras,
                    style: TextStyle(fontSize: 12.5, color: color),
                  ),
                  if ((e.detalle ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        e.detalle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: KipuColores.gris,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (e.recordar != null)
              Tooltip(
                message: opcionesRecordar
                    .firstWhere(
                      (x) => x.$1 == e.recordar,
                      orElse: () => (e.recordar, '${e.recordar} min antes'),
                    )
                    .$2,
                child: KipuIcon(
                  KipuIcono.campana,
                  size: 18,
                  color: KipuColores.gris,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilaClase extends StatelessWidget {
  final Horario h;
  final CursoConColegio c;
  final DateTime dia;
  const _FilaClase(this.h, this.c, {required this.dia});

  @override
  Widget build(BuildContext context) {
    final color =
        FiltroDiario.de(context)?.colorDe(c.colegio.id) ?? KipuColores.morado;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => anotarClase(context, curso: c, fecha: dia),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 74,
              child: Text(
                horaBonita(h.inicio),
                style: const TextStyle(fontSize: 13, color: KipuColores.gris),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.curso.nombre,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${c.curso.grado} ${c.curso.seccion} · ${c.colegio.nombre} · '
                    'hasta ${horaBonita(h.fin)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: KipuColores.gris,
                    ),
                  ),
                ],
              ),
            ),
            Tooltip(
              message: 'Anotar lo que se trabajó',
              child: KipuIcon(
                KipuIcono.apuntes,
                size: 18,
                color: KipuColores.gris,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Hoja ─────────────────────────

/// Ventana flotante blanca para los formularios del diario.
Future<T?> hojaDiario<T>(BuildContext context, Widget contenido) =>
    showDialog<T>(
      context: context,
      barrierColor: const Color(0x661F1B2E),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(ctx).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
              child: contenido,
            ),
          ),
        ),
      ),
    );

/// Cabecera de las hojas: icono, título y cerrar.
class CabezaDiario extends StatelessWidget {
  final KipuIcono icono;
  final String titulo;
  final String? subtitulo;
  final Color? color;
  const CabezaDiario({
    super.key,
    required this.icono,
    required this.titulo,
    this.subtitulo,
    this.color,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      KipuIcon(icono, size: 32, color: color ?? KipuColores.morado),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            if (subtitulo != null)
              Text(
                subtitulo!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: KipuColores.gris),
              ),
          ],
        ),
      ),
      IconButton(
        tooltip: 'Cerrar',
        onPressed: () => Navigator.pop(context),
        icon: const KipuIcon(KipuIcono.cerrar, size: 18, color: KipuColores.gris),
      ),
    ],
  );
}

/// Etiqueta pequeña sobre un grupo de opciones.
class RotuloDiario extends StatelessWidget {
  final String texto;
  const RotuloDiario(this.texto, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 6),
    child: Text(
      texto,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: KipuColores.gris,
      ),
    ),
  );
}

/// Chips para elegir una opción.
class ChipsDiario<T> extends StatelessWidget {
  final List<(T, String)> opciones;
  final T valor;
  final ValueChanged<T> onCambio;
  final Color? Function(T)? colorDe;
  const ChipsDiario({
    super.key,
    required this.opciones,
    required this.valor,
    required this.onCambio,
    this.colorDe,
  });

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 6,
    runSpacing: 6,
    children: [
      for (final (v, t) in opciones)
        ChoiceChip(
          label: Text(t),
          selected: v == valor,
          showCheckmark: false,
          selectedColor: colorDe?.call(v) ?? KipuColores.morado,
          labelStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: v == valor ? Colors.white : KipuColores.tinta,
          ),
          backgroundColor: KipuColores.fondo,
          side: BorderSide.none,
          onSelected: (_) => onCambio(v),
        ),
    ],
  );
}

/// Botón para elegir una fecha (yyyy-MM-dd) o dejarla vacía.
class BotonFecha extends StatelessWidget {
  final String? fecha;
  final String vacio;
  final ValueChanged<String?> onCambio;
  final bool quitable;
  const BotonFecha({
    super.key,
    required this.fecha,
    required this.onCambio,
    this.vacio = 'Elegir fecha',
    this.quitable = false,
  });

  @override
  Widget build(BuildContext context) {
    final f = fecha == null ? null : DateTime.tryParse(fecha!);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            onPressed: () async {
              final hoy = DateTime.now();
              final d = await showDatePicker(
                context: context,
                initialDate: f ?? hoy,
                firstDate: DateTime(hoy.year - 2),
                lastDate: DateTime(hoy.year + 3),
              );
              if (d != null) onCambio(claveFecha(d));
            },
            icon: KipuIcon(KipuIcono.calendario, size: 18, color: KipuColores.morado),
            label: Text(
              f == null ? vacio : fechaLarga(f),
              style: TextStyle(
                color: f == null ? KipuColores.gris : KipuColores.tinta,
              ),
            ),
          ),
        ),
        if (quitable && f != null)
          IconButton(
            tooltip: 'Quitar fecha',
            onPressed: () => onCambio(null),
            icon: const KipuIcon(KipuIcono.cerrar, size: 16, color: KipuColores.gris),
          ),
      ],
    );
  }
}

/// Lista desplegable de cursos (opcional), agrupada por colegio. Con
/// [colegioId] solo muestra los cursos de ese colegio.
class ElegirCurso extends StatelessWidget {
  final int? cursoId;
  final ValueChanged<int?> onCambio;
  final String vacio;
  final int? colegioId;

  /// Avisa el colegio del curso elegido (para completar otros campos).
  final ValueChanged<int?>? onColegio;
  const ElegirCurso({
    super.key,
    required this.cursoId,
    required this.onCambio,
    this.vacio = 'Sin curso',
    this.colegioId,
    this.onColegio,
  });

  @override
  Widget build(BuildContext context) => StreamBuilder<List<CursoConColegio>>(
    stream: db.verCursos(),
    builder: (context, snap) {
      final todos = snap.data ?? const <CursoConColegio>[];
      final cursos = [
        for (final c in todos)
          if (colegioId == null || c.colegio.id == colegioId) c,
      ]..sort((a, b) => a.colegio.nombre.compareTo(b.colegio.nombre));
      final varios = {for (final c in cursos) c.colegio.id}.length > 1;
      final valido = cursos.any((c) => c.curso.id == cursoId);
      final items = <DropdownMenuItem<int?>>[
        DropdownMenuItem(value: null, child: Text(vacio)),
      ];
      int? ultimo;
      for (final c in cursos) {
        if (varios && c.colegio.id != ultimo) {
          ultimo = c.colegio.id;
          // Encabezado del colegio (no se puede elegir).
          items.add(
            DropdownMenuItem(
              value: -c.colegio.id,
              enabled: false,
              child: Text(
                c.colegio.nombre.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .5,
                  color: KipuColores.gris,
                ),
              ),
            ),
          );
        }
        items.add(
          DropdownMenuItem(
            value: c.curso.id,
            child: Padding(
              padding: EdgeInsets.only(left: varios ? 10 : 0),
              child: Text(
                '${c.curso.nombre} · ${c.curso.grado} ${c.curso.seccion}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      }
      return DropdownButtonFormField<int?>(
        key: ValueKey('curso-$colegioId-${valido ? cursoId : null}'),
        initialValue: valido ? cursoId : null,
        isExpanded: true,
        decoration: const InputDecoration(isDense: true),
        items: items,
        selectedItemBuilder: (context) => [
          for (final i in items)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                i.value == null
                    ? vacio
                    : (() {
                        final c = cursos
                            .where((x) => x.curso.id == i.value)
                            .firstOrNull;
                        return c == null
                            ? ''
                            : '${c.curso.nombre} · ${c.curso.grado} ${c.curso.seccion}'
                                  '${varios ? ' · ${c.colegio.nombre}' : ''}';
                      })(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: (v) {
          onCambio(v);
          onColegio?.call(
            todos.where((c) => c.curso.id == v).firstOrNull?.colegio.id,
          );
        },
      );
    },
  );
}

// ───────────────────────── Evento ─────────────────────────

Future<void> editarEvento(
  BuildContext context, {
  Evento? evento,
  DateTime? fecha,
  int? colegioId,
}) => hojaDiario(
  context,
  _EditorEvento(
    evento: evento,
    fecha: fecha ?? DateTime.now(),
    colegioId: colegioId,
  ),
);

class _EditorEvento extends StatefulWidget {
  final Evento? evento;
  final DateTime fecha;
  final int? colegioId;
  const _EditorEvento({this.evento, required this.fecha, this.colegioId});

  @override
  State<_EditorEvento> createState() => _EditorEventoState();
}

class _EditorEventoState extends State<_EditorEvento> {
  Evento? get _e => widget.evento;
  late final _titulo = TextEditingController(text: _e?.titulo ?? '');
  late final _detalle = TextEditingController(text: _e?.detalle ?? '');
  late String _tipo = _e?.tipo ?? 'tarea';
  late String _fecha = _e?.fecha ?? claveFecha(widget.fecha);
  late String? _hora = _e?.hora;
  late int? _recordar = widget.evento == null ? 10 : widget.evento!.recordar;
  late String? _repetir = _e?.repetir;
  late int? _curso = _e?.cursoId;
  late int? _colegio = _e == null ? widget.colegioId : _e!.colegioId;
  String? _error;

  @override
  void dispose() {
    _titulo.dispose();
    _detalle.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final t = _titulo.text.trim();
    if (t.isEmpty) {
      setState(() => _error = 'Escribe un título');
      return;
    }
    await db.guardarEvento(
      EventosCompanion(
        id: _e == null ? const Value.absent() : Value(_e!.id),
        fecha: Value(_fecha),
        hora: Value(_hora),
        titulo: Value(t),
        tipo: Value(_tipo),
        recordar: Value(_recordar),
        repetir: Value(_repetir),
        cursoId: Value(_curso),
        colegioId: Value(_colegio),
        detalle: Value(
          _detalle.text.trim().isEmpty ? null : _detalle.text.trim(),
        ),
      ),
    );
    if (_recordar != null && mounted) await asegurarPermiso(context);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(colorTipoEvento(_tipo));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CabezaDiario(
          icono: KipuIcono.calendario,
          color: color,
          titulo: _e == null ? 'Nuevo evento' : 'Editar evento',
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _titulo,
          autofocus: _e == null,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: 'Título',
            hintText: 'Ej.: Reunión de padres de 3.° B',
            errorText: _error,
          ),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
        const RotuloDiario('Tipo'),
        ChipsDiario<String>(
          opciones: [for (final t in tiposEvento) (t.$1, t.$2)],
          valor: _tipo,
          colorDe: (t) => Color(colorTipoEvento(t)),
          onCambio: (v) => setState(() => _tipo = v),
        ),
        const RotuloDiario('Fecha y hora'),
        BotonFecha(
          fecha: _fecha,
          onCambio: (f) => setState(() => _fecha = f ?? _fecha),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
                onPressed: () async {
                  final p = (_hora ?? '08:00').split(':');
                  final t = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: int.parse(p[0]),
                      minute: int.parse(p[1]),
                    ),
                  );
                  if (t != null) {
                    setState(
                      () => _hora =
                          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
                    );
                  }
                },
                icon: KipuIcon(
                  KipuIcono.horario,
                  size: 18,
                  color: KipuColores.morado,
                ),
                label: Text(
                  _hora == null ? 'Todo el día' : horaBonita(_hora!),
                  style: const TextStyle(color: KipuColores.tinta),
                ),
              ),
            ),
            if (_hora != null)
              TextButton(
                onPressed: () => setState(() => _hora = null),
                child: const Text('Todo el día'),
              ),
          ],
        ),
        const RotuloDiario('Avisarme'),
        ChipsDiario<int?>(
          opciones: opcionesRecordar,
          valor: _recordar,
          onCambio: (v) => setState(() => _recordar = v),
        ),
        if (_recordar != null && _hora == null)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Si es todo el día, se cuenta desde las 7:00 a. m.',
              style: TextStyle(fontSize: 12, color: KipuColores.gris),
            ),
          ),
        if (_recordar != null && recordatorios.esWeb)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'En la web el aviso sale solo si Kipu está abierto. En el '
              'celular (APK) llega aunque la app esté cerrada.',
              style: TextStyle(fontSize: 12, color: KipuColores.gris),
            ),
          ),
        const RotuloDiario('Repetir'),
        ChipsDiario<String?>(
          opciones: opcionesRepetir,
          valor: _repetir,
          onCambio: (v) => setState(() => _repetir = v),
        ),
        StreamBuilder<List<Colegio>>(
          stream: db.verColegios(),
          builder: (context, snap) {
            final colegios = snap.data ?? const <Colegio>[];
            if (colegios.length < 2) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RotuloDiario(
                  _tipo == 'feriado'
                      ? 'Colegio · sin clases solo en el elegido'
                      : 'Colegio',
                ),
                ChipsDiario<int?>(
                  opciones: [
                    (null, 'Todos'),
                    for (final c in colegios) (c.id, c.nombre),
                  ],
                  valor: _colegio,
                  colorDe: (id) =>
                      id == null ? null : colorColegio(colegios, id),
                  onCambio: (v) => setState(() {
                    _colegio = v;
                    _curso = null;
                  }),
                ),
              ],
            );
          },
        ),
        const RotuloDiario('Curso (opcional)'),
        ElegirCurso(
          cursoId: _curso,
          colegioId: _colegio,
          onCambio: (v) => setState(() => _curso = v),
          onColegio: (c) {
            if (c != null) setState(() => _colegio = c);
          },
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _detalle,
          minLines: 1,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Detalle (opcional)',
            hintText: 'Lugar, materiales, qué llevar…',
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            if (_e != null) ...[
              IconButton(
                tooltip: 'Borrar evento',
                onPressed: () async {
                  await db.borrarEvento(_e!.id);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const KipuIcon(
                  KipuIcono.borrar,
                  color: Color(0xFFC2334A),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _guardar,
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Pide permiso de notificaciones la primera vez (debe ser tras un toque).
Future<void> asegurarPermiso(BuildContext context) async {
  if (await recordatorios.tienePermiso()) return;
  final ok = await recordatorios.pedirPermiso();
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Sin permiso de notificaciones: el aviso se verá solo dentro de '
          'Kipu. Puedes activarlo en Mi diario › Avisos.',
        ),
      ),
    );
  }
}

// ───────────────────────── Pendientes ─────────────────────────

class _Pendientes extends StatefulWidget {
  const _Pendientes();

  @override
  State<_Pendientes> createState() => _PendientesState();
}

class _PendientesState extends State<_Pendientes> {
  final _nuevo = TextEditingController();
  bool _verHechos = false;

  @override
  void dispose() {
    _nuevo.dispose();
    super.dispose();
  }

  Future<void> _agregar() async {
    final t = _nuevo.text.trim();
    if (t.isEmpty) return;
    await db.agregarPendiente(t);
    _nuevo.clear();
  }

  @override
  Widget build(BuildContext context) {
    final filtro = FiltroDiario.de(context);
    return StreamBuilder<List<CursoConColegio>>(
      stream: db.verCursos(),
      builder: (context, cu) {
        final colegioDe = {
          for (final c in cu.data ?? const <CursoConColegio>[])
            c.curso.id: c.colegio.id,
        };
        return StreamBuilder<List<Pendiente>>(
      stream: db.verPendientes(),
      builder: (context, snap) {
        final todos = [
          for (final p in snap.data ?? const <Pendiente>[])
            if (filtro?.muestra(p.cursoId == null ? null : colegioDe[p.cursoId]) ??
                true)
              p,
        ];
        final porHacer = [for (final p in todos) if (!p.hecho) p];
        final hechos = [for (final p in todos) if (p.hecho) p];
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nuevo,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Agregar pendiente y Enter',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                      ),
                      onSubmitted: (_) => _agregar(),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Agregar',
                    onPressed: _agregar,
                    icon: KipuIcon(KipuIcono.agregar, color: KipuColores.morado),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (porHacer.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Text(
                  'Sin pendientes. ¡Todo al día!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: KipuColores.gris),
                ),
              ),
            for (final p in porHacer) _FilaPendiente(p, tarjeta: true),
            if (hechos.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => setState(() => _verHechos = !_verHechos),
                    icon: KipuIcon(
                      _verHechos ? KipuIcono.arriba : KipuIcono.abajo,
                      size: 16,
                      color: KipuColores.gris,
                    ),
                    label: Text(
                      'Hechos (${hechos.length})',
                      style: const TextStyle(color: KipuColores.gris),
                    ),
                  ),
                  const Spacer(),
                  if (_verHechos)
                    TextButton(
                      onPressed: db.borrarPendientesHechos,
                      child: const Text('Borrar hechos'),
                    ),
                ],
              ),
              if (_verHechos)
                for (final p in hechos) _FilaPendiente(p, tarjeta: true),
            ],
          ],
        );
      },
    );
      },
    );
  }
}

class _FilaPendiente extends StatelessWidget {
  final Pendiente p;
  final bool tarjeta;
  const _FilaPendiente(this.p, {this.tarjeta = false});

  @override
  Widget build(BuildContext context) {
    final hoy = claveFecha(DateTime.now());
    final vencido = !p.hecho && p.vence != null && p.vence!.compareTo(hoy) < 0;
    final esHoy = p.vence == hoy;
    final fila = Row(
      children: [
        Checkbox(
          value: p.hecho,
          onChanged: (v) => db.marcarPendiente(p.id, v ?? false),
        ),
        Expanded(
          child: InkWell(
            onTap: () => editarPendiente(context, pendiente: p),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.texto,
                    style: TextStyle(
                      fontSize: 15,
                      decoration: p.hecho ? TextDecoration.lineThrough : null,
                      color: p.hecho ? KipuColores.gris : KipuColores.tinta,
                    ),
                  ),
                  if (p.vence != null)
                    Text(
                      vencido
                          ? 'Venció el ${fechaCorta(p.vence!)}'
                          : (esHoy ? 'Vence hoy' : 'Para el ${fechaCorta(p.vence!)}'),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: vencido || esHoy
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: vencido
                            ? const Color(0xFFC2334A)
                            : (esHoy ? const Color(0xFFE07B1F) : KipuColores.gris),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
    if (!tarjeta) return fila;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: fila,
    );
  }
}

Future<void> editarPendiente(
  BuildContext context, {
  Pendiente? pendiente,
  int? colegioId,
}) => hojaDiario(
  context,
  _EditorPendiente(pendiente: pendiente, colegioId: colegioId),
);

class _EditorPendiente extends StatefulWidget {
  final Pendiente? pendiente;
  final int? colegioId;
  const _EditorPendiente({this.pendiente, this.colegioId});

  @override
  State<_EditorPendiente> createState() => _EditorPendienteState();
}

class _EditorPendienteState extends State<_EditorPendiente> {
  Pendiente? get _p => widget.pendiente;
  late final _texto = TextEditingController(text: _p?.texto ?? '');
  late String? _vence = _p?.vence;
  late int? _curso = _p?.cursoId;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final t = _texto.text.trim();
    if (t.isEmpty) return;
    if (_p == null) {
      await db.agregarPendiente(t, vence: _vence, cursoId: _curso);
    } else {
      await db.editarPendiente(_p!.id, texto: t, vence: _vence, cursoId: _curso);
    }
    if (_vence != null && mounted) await asegurarPermiso(context);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      CabezaDiario(
        icono: KipuIcono.check,
        titulo: _p == null ? 'Nuevo pendiente' : 'Editar pendiente',
      ),
      const SizedBox(height: 14),
      TextField(
        controller: _texto,
        autofocus: _p == null,
        minLines: 1,
        maxLines: 3,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: '¿Qué hay que hacer?',
          hintText: 'Ej.: Imprimir la práctica de 2.° A',
        ),
      ),
      const RotuloDiario('Para cuándo (opcional) · avisa ese día a las 8:00'),
      BotonFecha(
        fecha: _vence,
        vacio: 'Sin fecha',
        quitable: true,
        onCambio: (f) => setState(() => _vence = f),
      ),
      const RotuloDiario('Curso (opcional)'),
      ElegirCurso(
        cursoId: _curso,
        colegioId: _p == null ? widget.colegioId : null,
        onCambio: (v) => setState(() => _curso = v),
      ),
      const SizedBox(height: 18),
      Row(
        children: [
          if (_p != null) ...[
            IconButton(
              tooltip: 'Borrar',
              onPressed: () async {
                await db.borrarPendiente(_p!.id);
                if (context.mounted) Navigator.pop(context);
              },
              icon: const KipuIcon(KipuIcono.borrar, color: Color(0xFFC2334A)),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _guardar,
              child: const Text('Guardar'),
            ),
          ),
        ],
      ),
    ],
  );
}

// ───────────────────────── Avisos ─────────────────────────

Future<void> ajustesAvisos(BuildContext context) =>
    hojaDiario(context, const _AjustesAvisos());

class _AjustesAvisos extends StatefulWidget {
  const _AjustesAvisos();

  @override
  State<_AjustesAvisos> createState() => _AjustesAvisosState();
}

class _AjustesAvisosState extends State<_AjustesAvisos> {
  AjustesAvisos? _a;
  bool? _permiso;
  bool _exacto = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final a = AjustesAvisos.deTexto(await db.leerAjuste(claveAvisos));
    final p = await recordatorios.tienePermiso();
    final x = await recordatorios.avisoExacto();
    if (mounted) {
      setState(() {
        _a = a;
        _permiso = p;
        _exacto = x;
      });
    }
  }

  Future<void> _cambiar(AjustesAvisos a) async {
    setState(() => _a = a);
    await db.guardarAjuste(claveAvisos, a.aTexto());
  }

  Widget _interruptor(
    String titulo,
    String detalle,
    bool valor,
    ValueChanged<bool> onCambio,
  ) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Text(detalle, style: const TextStyle(fontSize: 12.5)),
    value: valor,
    onChanged: onCambio,
  );

  @override
  Widget build(BuildContext context) {
    final a = _a;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CabezaDiario(
          icono: KipuIcono.campana,
          titulo: 'Avisos',
          subtitulo: 'Qué te recuerda Kipu además de tus eventos',
        ),
        const SizedBox(height: 10),
        if (a == null)
          const Padding(
            padding: EdgeInsets.all(30),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          if (_permiso == false)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Las notificaciones están apagadas. Actívalas para que '
                      'los avisos te lleguen.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await recordatorios.pedirPermiso();
                      await _cargar();
                    },
                    child: const Text('Activar'),
                  ),
                ],
              ),
            ),
          if (!_exacto)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KipuColores.fondo,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Para que lleguen a la hora exacta, permite «Alarmas y '
                      'recordatorios».',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await recordatorios.pedirAvisoExacto();
                      await _cargar();
                    },
                    child: const Text('Permitir'),
                  ),
                ],
              ),
            ),
          _interruptor(
            'Antes de cada clase',
            'Según tu horario; no avisa los días feriados.',
            a.clases,
            (v) => _cambiar(a.copiar(clases: v)),
          ),
          if (a.clases)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: ChipsDiario<int>(
                opciones: const [
                  (0, 'A la hora'),
                  (5, '5 min'),
                  (10, '10 min'),
                  (15, '15 min'),
                  (30, '30 min'),
                ],
                valor: a.minutosClase,
                onCambio: (v) => _cambiar(a.copiar(minutosClase: v)),
              ),
            ),
          _interruptor(
            'Cumpleaños',
            'El día del cumpleaños de tus estudiantes, a las 7:00 a. m.',
            a.cumples,
            (v) => _cambiar(a.copiar(cumples: v)),
          ),
          _interruptor(
            'Cierre del bimestre',
            '3 días antes y el día que cierra (según Configuración académica).',
            a.cierre,
            (v) => _cambiar(a.copiar(cierre: v)),
          ),
          _interruptor(
            'Pendientes',
            'El día que vencen, a las 8:00 a. m.',
            a.pendientes,
            (v) => _cambiar(a.copiar(pendientes: v)),
          ),
          if (recordatorios.esWeb)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'En la web los avisos salen solo con Kipu abierto. En el '
                'celular (APK) llegan aunque la app esté cerrada.',
                style: TextStyle(fontSize: 12, color: KipuColores.gris),
              ),
            ),
          const RotuloDiario('Próximos avisos'),
          ValueListenableBuilder<List<Aviso>>(
            valueListenable: recordatorios.proximos,
            builder: (context, lista, _) {
              if (lista.isEmpty) {
                return const Text(
                  'No hay avisos en las próximas dos semanas.',
                  style: TextStyle(fontSize: 13, color: KipuColores.gris),
                );
              }
              return Column(
                children: [
                  for (final x in lista.take(6))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(
                              '${fechaCorta(claveFecha(x.cuando))} · '
                              '${horaBonita('${x.cuando.hour}:${x.cuando.minute.toString().padLeft(2, '0')}')}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: KipuColores.gris,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              x.titulo,
                              style: const TextStyle(fontSize: 13.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}
