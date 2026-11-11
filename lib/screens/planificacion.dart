import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/academico.dart';
import '../data/cneb.dart';
import '../data/database.dart';
import '../data/evaluacion_db.dart';
import '../data/planificacion.dart';
import '../main.dart' show db;
import '../theme.dart';
import '../widgets/calendario_rango.dart';
import '../widgets/kipu_icono.dart';
import '../widgets/ventana.dart';
import 'cursos.dart' show colorColegio;
import 'horario_datos.dart';
import 'planificacion_exportar.dart';
import 'planificacion_unidad.dart';

const _verde = Color(0xFF16A37F);
const _linea = Color(0xFFECEDF4);

/// «2 nov», «18 dic».
String fechaCorta(String? f) {
  if (f == null) return '';
  return DateFormat(
    'd MMM',
    'es_PE',
  ).format(DateTime.parse(f)).replaceAll('.', '');
}

String rangoCorto(String? desde, String? hasta) {
  if (desde == null && hasta == null) return 'Sin fechas';
  if (hasta == null) return 'Desde ${fechaCorta(desde)}';
  if (desde == null) return 'Hasta ${fechaCorta(hasta)}';
  return '${fechaCorta(desde)} – ${fechaCorta(hasta)}';
}

/// «Química · 5.° B».
String nombreCurso(Curso c) => '${c.nombre} · ${aula(c)}';

/// Datos que comparten las vistas Año y Semana.
class _Datos {
  final List<CursoConColegio> cursos;
  final List<Colegio> colegios;
  final ConfigAcademica config;
  final Map<int, String> gestiones;
  const _Datos(this.cursos, this.colegios, this.config, this.gestiones);

  Color color(CursoConColegio c) => colorColegio(colegios, c.colegio.id);
  bool privado(CursoConColegio c) => gestiones[c.colegio.id] == gestionPrivada;
}

class PantallaPlanificacion extends StatefulWidget {
  const PantallaPlanificacion({super.key});

  @override
  State<PantallaPlanificacion> createState() => _PantallaPlanificacionState();
}

class _PantallaPlanificacionState extends State<PantallaPlanificacion> {
  final _cursos = db.verCursos();
  final _colegios = db.verColegios();
  final _gestiones = db.verGestiones();
  final _anio = db.verAnioActivo();
  final _vistaAjuste = db.verAjuste('planificacion_vista');
  final _cursoAjuste = db.verAjuste('planificacion_curso');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _anio,
      builder: (context, sa) {
        if (!sa.hasData) return const Scaffold(body: SizedBox.shrink());
        return StreamBuilder<ConfigAcademica>(
          stream: db.verConfigAcademica(sa.data!),
          builder: (context, sc) => StreamBuilder<List<CursoConColegio>>(
            stream: _cursos,
            builder: (context, scu) => StreamBuilder<List<Colegio>>(
              stream: _colegios,
              builder: (context, sco) => StreamBuilder<Map<int, String>>(
                stream: _gestiones,
                builder: (context, sg) => StreamBuilder<String?>(
                  stream: _vistaAjuste,
                  builder: (context, sv) => StreamBuilder<String?>(
                    stream: _cursoAjuste,
                    builder: (context, scs) {
                      if (!sc.hasData || !scu.hasData || !sco.hasData) {
                        return const Scaffold(body: SizedBox.shrink());
                      }
                      final d = _Datos(
                        scu.data!,
                        sco.data!,
                        sc.data!,
                        sg.data ?? const {},
                      );
                      return _pantalla(
                        context,
                        d,
                        semana: sv.data == 'semana',
                        cursoId: int.tryParse(scs.data ?? ''),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _pantalla(
    BuildContext context,
    _Datos d, {
    required bool semana,
    required int? cursoId,
  }) {
    final curso =
        d.cursos.where((c) => c.curso.id == cursoId).firstOrNull ??
        d.cursos.firstOrNull;
    final ancho = MediaQuery.sizeOf(context).width >= 900;
    final selector = SegmentedButton<bool>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: KipuColores.morado,
        selectedForegroundColor: Colors.white,
        backgroundColor: Colors.white,
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
      ),
      segments: const [
        ButtonSegment(value: false, label: Text('Año')),
        ButtonSegment(value: true, label: Text('Semana')),
      ],
      selected: {semana},
      onSelectionChanged: (s) =>
          db.guardarAjuste('planificacion_vista', s.first ? 'semana' : 'anio'),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planificación'),
        actions: [
          if (d.cursos.isNotEmpty) selector,
          if (!semana && curso != null)
            _MenuAnio(
              onElegir: (o) => switch (o) {
                'descargar' => descargarPlanificacion(
                  context,
                  curso: curso,
                  privado: d.privado(curso),
                  anio: d.config.anio,
                  periodos: d.config.periodos,
                ),
                'copiar' => _copiar(context, d, curso),
                _ => null,
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: d.cursos.isEmpty
          ? const _SinCursos()
          : semana
          ? _VistaSemana(datos: d, ancho: ancho)
          : _VistaAnio(datos: d, curso: curso!, ancho: ancho),
    );
  }

  Future<void> _copiar(
    BuildContext context,
    _Datos d,
    CursoConColegio origen,
  ) async {
    final otros = [
      for (final c in d.cursos)
        if (c.curso.id != origen.curso.id) c,
    ];
    if (otros.isEmpty) return;
    // Primero los del mismo curso y grado (5.° B → 5.° A).
    otros.sort((a, b) {
      int p(CursoConColegio c) =>
          (c.curso.nombre == origen.curso.nombre ? 0 : 2) +
          (c.curso.grado == origen.curso.grado ? 0 : 1);
      return p(a).compareTo(p(b));
    });
    final destino = await ventanaCentrada<CursoConColegio>(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 4),
            child: Text(
              'Copiar a otra sección',
              style: Theme.of(ctx).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
            child: Text(
              'Se copian las unidades y sesiones de ${nombreCurso(origen.curso)}, '
              'sin fechas ni marcas de hecha.',
              style: const TextStyle(color: KipuColores.gris),
            ),
          ),
          for (final c in otros)
            ListTile(
              leading: CircleAvatar(radius: 6, backgroundColor: d.color(c)),
              title: Text(nombreCurso(c.curso)),
              subtitle: Text(c.colegio.nombre),
              onTap: () => Navigator.pop(ctx, c),
            ),
        ],
      ),
    );
    if (destino == null) return;
    final n = await db.copiarPlanificacion(
      origen.curso.id,
      destino.curso.id,
      d.config.anio,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          n == 0
              ? 'No hay unidades para copiar'
              : 'Se copiaron $n unidades a ${nombreCurso(destino.curso)}',
        ),
      ),
    );
  }
}

class _MenuAnio extends StatelessWidget {
  final void Function(String) onElegir;
  const _MenuAnio({required this.onElegir});

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: 'Más opciones',
    icon: KipuIcon(KipuIcono.menu, color: KipuColores.tinta),
    onSelected: onElegir,
    itemBuilder: (_) => [
      PopupMenuItem(
        value: 'descargar',
        child: Row(
          children: [
            KipuIcon(KipuIcono.descargar, size: 20, color: KipuColores.morado),
            const SizedBox(width: 12),
            const Text('Descargar'),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'copiar',
        child: Row(
          children: [
            KipuIcon(KipuIcono.copiar, size: 20, color: KipuColores.morado),
            const SizedBox(width: 12),
            const Text('Copiar a otra sección'),
          ],
        ),
      ),
    ],
  );
}

class _SinCursos extends StatelessWidget {
  const _SinCursos();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KipuIcon(
            KipuIcono.planificacion,
            size: 64,
            color: KipuColores.morado,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aún no tienes cursos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Agrega tus cursos en Mis cursos para planificar sus unidades y sesiones.',
            textAlign: TextAlign.center,
            style: TextStyle(color: KipuColores.gris),
          ),
        ],
      ),
    ),
  );
}

/// Chips para elegir el curso.
class _Chips extends StatelessWidget {
  final _Datos datos;
  final int? actual;
  final void Function(int?) onElegir;
  final String? todos;
  const _Chips({
    required this.datos,
    required this.actual,
    required this.onElegir,
    this.todos,
  });

  @override
  Widget build(BuildContext context) {
    Widget chip(String texto, bool sel, Color? color, VoidCallback onTap) =>
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Material(
            color: sel ? KipuColores.morado : Colors.white,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (color != null) ...[
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: sel
                              ? Border.all(color: Colors.white, width: 1.5)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      texto,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: sel ? Colors.white : KipuColores.tinta,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (todos != null)
            chip(todos!, actual == null, null, () => onElegir(null)),
          for (final c in datos.cursos)
            chip(
              nombreCurso(c.curso),
              c.curso.id == actual,
              datos.color(c),
              () => onElegir(c.curso.id),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── Vista Año ─────────────────────────

class _VistaAnio extends StatefulWidget {
  final _Datos datos;
  final CursoConColegio curso;
  final bool ancho;
  const _VistaAnio({
    required this.datos,
    required this.curso,
    required this.ancho,
  });

  @override
  State<_VistaAnio> createState() => _VistaAnioState();
}

class _VistaAnioState extends State<_VistaAnio> {
  late int _periodo = widget.datos.config.periodoActual(DateTime.now()) ?? 1;
  late Stream<List<Unidad>> _unidades;
  late Stream<Map<int, List<Sesion>>> _sesiones;

  @override
  void initState() {
    super.initState();
    _abrir();
  }

  @override
  void didUpdateWidget(_VistaAnio old) {
    super.didUpdateWidget(old);
    if (old.curso.curso.id != widget.curso.curso.id ||
        old.datos.config.anio != widget.datos.config.anio) {
      _abrir();
    }
  }

  void _abrir() {
    final id = widget.curso.curso.id, anio = widget.datos.config.anio;
    _unidades = db.verUnidades(id, anio);
    _sesiones = db.verSesionesCurso(id, anio);
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.datos;
    final periodos = d.config.periodos;
    if (_periodo > periodos.length) _periodo = 1;
    return StreamBuilder<List<Unidad>>(
      stream: _unidades,
      builder: (context, su) => StreamBuilder<Map<int, List<Sesion>>>(
        stream: _sesiones,
        builder: (context, ss) {
          final unidades = su.data ?? const <Unidad>[];
          final sesiones = ss.data ?? const <int, List<Sesion>>{};
          final numero = {
            for (var i = 0; i < unidades.length; i++) unidades[i].id: i + 1,
          };
          Widget tarjeta(Unidad u) => TarjetaUnidad(
            unidad: u,
            numero: numero[u.id]!,
            sesiones: sesiones[u.id] ?? const [],
            onTap: () => abrirUnidad(context, u.id),
          );
          Widget nueva(int p) => _BotonNueva(
            onTap: () => nuevaUnidad(
              context,
              curso: widget.curso,
              config: d.config,
              periodo: p,
            ),
          );
          final hoy = d.config.periodoActual(DateTime.now());
          final cabecera = Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _Chips(
              datos: d,
              actual: widget.curso.curso.id,
              onElegir: (id) => db.guardarAjuste('planificacion_curso', '$id'),
            ),
          );
          final matriz = _Matriz(
            curso: widget.curso,
            unidades: unidades,
            numero: numero,
            privado: d.privado(widget.curso),
          );
          if (widget.ancho) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
              children: [
                cabecera,
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var p = 1; p <= periodos.length; p++) ...[
                        if (p > 1) const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: p == hoy
                                  ? KipuColores.moradoClaro
                                  : Colors.white.withValues(alpha: .5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _CabPeriodo(periodo: periodos[p - 1]),
                                for (final u in unidades)
                                  if (u.periodo == p) tarjeta(u),
                                nueva(p),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                matriz,
              ],
            );
          }
          final delPeriodo = [
            for (final u in unidades)
              if (u.periodo == _periodo) u,
          ];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            children: [
              cabecera,
              _Segmentos(
                textos: [
                  for (var p = 1; p <= periodos.length; p++)
                    p == _periodo
                        ? periodos[p - 1].nombre.replaceAll('bimestre', 'bim.')
                        : _romano(p),
                ],
                actual: _periodo - 1,
                onCambio: (i) => setState(() => _periodo = i + 1),
              ),
              const SizedBox(height: 12),
              if (delPeriodo.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Text(
                    'Aún no hay unidades en el ${periodos[_periodo - 1].nombre}.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: KipuColores.gris),
                  ),
                ),
              for (final u in delPeriodo) tarjeta(u),
              nueva(_periodo),
              const SizedBox(height: 14),
              matriz,
            ],
          );
        },
      ),
    );
  }
}

String _romano(int n) => const ['I', 'II', 'III', 'IV', 'V', 'VI'][n - 1];

class _Segmentos extends StatelessWidget {
  final List<String> textos;
  final int actual;
  final void Function(int) onCambio;
  const _Segmentos({
    required this.textos,
    required this.actual,
    required this.onCambio,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        for (var i = 0; i < textos.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => onCambio(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == actual ? KipuColores.morado : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  textos[i],
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: i == actual ? FontWeight.w600 : FontWeight.w500,
                    color: i == actual ? Colors.white : KipuColores.gris,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _CabPeriodo extends StatelessWidget {
  final Periodo periodo;
  const _CabPeriodo({required this.periodo});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(6, 4, 6, 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(
            periodo.nombre,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        if (periodo.inicio != null)
          Text(
            rangoCorto(periodo.inicio, periodo.fin),
            style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
          ),
      ],
    ),
  );
}

class _BotonNueva extends StatelessWidget {
  final VoidCallback onTap;
  const _BotonNueva({required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC9CBE6), width: 1.5),
      ),
      child: Text(
        '+ Nueva unidad',
        style: TextStyle(
          color: KipuColores.morado,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

/// Letra de competencia en un cuadrito de color.
class LetraCompetencia extends StatelessWidget {
  final String id;
  const LetraCompetencia(this.id, {super.key});

  static const _colores = [
    (Color(0xFFE2ECFD), Color(0xFF2557C7)),
    (Color(0xFFFDE9DB), Color(0xFFC25A16)),
    (Color(0xFFD9F4EC), Color(0xFF0E7A5F)),
    (Color(0xFFEDE7FE), Color(0xFF6D3FD8)),
    (Color(0xFFFCE3EE), Color(0xFFB8336C)),
  ];

  static (Color, Color) colores(String id) {
    final i = competenciasCneb.indexWhere((c) => c.id == id);
    return _colores[(i < 0 ? 0 : i) % _colores.length];
  }

  @override
  Widget build(BuildContext context) {
    final (fondo, texto) = colores(id);
    return Tooltip(
      message: competenciaPorId(id)?.nombre ?? id,
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          letraCompetencia(id),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: texto,
          ),
        ),
      ),
    );
  }
}

class EstadoChip extends StatelessWidget {
  final EstadoUnidad estado;
  const EstadoChip(this.estado, {super.key});

  @override
  Widget build(BuildContext context) {
    final (texto, fondo, color) = switch (estado) {
      EstadoUnidad.terminada => (
        'Terminada',
        const Color(0xFFD9F4EC),
        const Color(0xFF0E7A5F),
      ),
      EstadoUnidad.enCurso => ('En curso', KipuColores.morado, Colors.white),
      EstadoUnidad.porEmpezar => ('Por empezar', _linea, KipuColores.gris),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class TarjetaUnidad extends StatelessWidget {
  final Unidad unidad;
  final int numero;
  final List<Sesion> sesiones;
  final VoidCallback onTap;
  const TarjetaUnidad({
    super.key,
    required this.unidad,
    required this.numero,
    required this.sesiones,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final estado = estadoUnidad(unidad, sesiones, DateTime.now());
    final hechas = sesiones.where((s) => s.hecha).length;
    final total = sesiones.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: estado == EstadoUnidad.enCurso
                  ? Border.all(color: KipuColores.morado, width: 2.2)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'UNIDAD $numero',
                        style: const TextStyle(
                          fontSize: 12,
                          color: KipuColores.gris,
                          fontWeight: FontWeight.w600,
                          letterSpacing: .5,
                        ),
                      ),
                    ),
                    EstadoChip(estado),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  unidad.titulo,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rangoCorto(unidad.desde, unidad.hasta),
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: KipuColores.gris,
                  ),
                ),
                if (unidad.listaCompetencias.isNotEmpty) ...[
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      for (final c in unidad.listaCompetencias)
                        LetraCompetencia(c),
                    ],
                  ),
                ],
                const SizedBox(height: 9),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Sesiones',
                        style: TextStyle(fontSize: 12, color: KipuColores.gris),
                      ),
                    ),
                    Text(
                      total == 0 ? 'Sin sesiones' : '$hechas de $total',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : hechas / total,
                    minHeight: 7,
                    backgroundColor: _linea,
                    color: estado == EstadoUnidad.terminada
                        ? _verde
                        : KipuColores.morado,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Competencias del curso por unidad: trabajada (●), se evalúa (◉) o no (○).
class _Matriz extends StatelessWidget {
  final CursoConColegio curso;
  final List<Unidad> unidades;
  final Map<int, int> numero;
  final bool privado;
  const _Matriz({
    required this.curso,
    required this.unidades,
    required this.numero,
    required this.privado,
  });

  @override
  Widget build(BuildContext context) {
    if (unidades.isEmpty) return const SizedBox.shrink();
    final usadas = {for (final u in unidades) ...u.listaCompetencias};
    final comps = [
      for (final c in competenciasDelCurso(curso.curso))
        if (!c.transversal || usadas.contains(c.id)) c,
    ];
    final evaluadas = {
      for (final u in unidades)
        u.id: {
          for (final p in u.listaPropositos)
            if (p.evidencia.isNotEmpty || p.instrumento.isNotEmpty)
              p.competencia,
        },
    };
    Widget punto(Unidad u, String c) {
      final usa = u.listaCompetencias.contains(c);
      final evalua = evaluadas[u.id]!.contains(c);
      return Center(
        child: Tooltip(
          message: evalua
              ? 'Se evalúa'
              : usa
              ? 'Se trabaja'
              : 'No se trabaja',
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: usa ? KipuColores.morado : null,
              border: usa
                  ? null
                  : Border.all(color: const Color(0xFFDCDDEA), width: 1.5),
              boxShadow: evalua
                  ? [BoxShadow(color: KipuColores.moradoClaro, spreadRadius: 3)]
                  : null,
            ),
          ),
        ),
      );
    }

    const cab = TextStyle(
      fontSize: 12,
      color: KipuColores.gris,
      fontWeight: FontWeight.w600,
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COMPETENCIAS DEL AÑO',
            style: TextStyle(
              fontSize: 13,
              letterSpacing: 1,
              color: KipuColores.gris,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            privado
                ? '● se trabaja en la unidad   ○ no se trabaja'
                : '● se trabaja   ◉ se evalúa   ○ no se trabaja',
            style: const TextStyle(fontSize: 12, color: KipuColores.gris),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: {
                0: FixedColumnWidth(
                  MediaQuery.sizeOf(context).width < 600 ? 190 : 300,
                ),
                for (var i = 1; i <= unidades.length + 1; i++)
                  i: const FixedColumnWidth(48),
              },
              children: [
                TableRow(
                  children: [
                    const SizedBox(),
                    for (final u in unidades)
                      Center(child: Text('U${numero[u.id]}', style: cab)),
                    const Center(child: Text('Veces', style: cab)),
                  ],
                ),
                for (final c in comps)
                  TableRow(
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: _linea)),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          children: [
                            LetraCompetencia(c.id),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                c.corto,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      for (final u in unidades) punto(u, c.id),
                      Center(
                        child: Text(
                          '${unidades.where((u) => u.listaCompetencias.contains(c.id)).length}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color:
                                unidades.any(
                                  (u) => u.listaCompetencias.contains(c.id),
                                )
                                ? KipuColores.tinta
                                : const Color(0xFFC2334A),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pide el título y las fechas de una unidad nueva, la crea y la abre.
Future<void> nuevaUnidad(
  BuildContext context, {
  required CursoConColegio curso,
  required ConfigAcademica config,
  required int periodo,
}) async {
  final existentes = await db.verUnidades(curso.curso.id, config.anio).first;
  if (!context.mounted) return;
  final p = config.periodos[(periodo - 1).clamp(0, config.periodos.length - 1)];
  // Propone empezar el lunes después de la última unidad del periodo.
  String? desde = p.inicio;
  final previas = [
    for (final u in existentes)
      if (u.periodo == periodo && u.hasta != null) u.hasta!,
  ]..sort();
  if (previas.isNotEmpty) {
    var d = DateTime.parse(previas.last).add(const Duration(days: 1));
    while (d.weekday > 5) {
      d = d.add(const Duration(days: 1));
    }
    desde = claveFecha(d);
  }
  final r = await ventanaCentrada<(String, int, String?, String?)>(
    context: context,
    builder: (_) => _NuevaUnidad(
      config: config,
      periodo: periodo,
      desde: desde,
      hasta: p.fin,
    ),
  );
  if (r == null || !context.mounted) return;
  final (titulo, per, d, h) = r;
  final comps = competenciasDelCurso(curso.curso);
  final id = await db.crearUnidad(
    UnidadesCompanion.insert(
      cursoId: curso.curso.id,
      anio: config.anio,
      periodo: per,
      orden: 0,
      titulo: titulo,
      desde: Value(d),
      hasta: Value(h),
      // Arranca con las competencias propias del área (sin transversales).
      competencias: Value(
        comps.where((c) => !c.transversal).map((c) => c.id).join(','),
      ),
    ),
  );
  if (context.mounted) await abrirUnidad(context, id);
}

class _NuevaUnidad extends StatefulWidget {
  final ConfigAcademica config;
  final int periodo;
  final String? desde;
  final String? hasta;
  const _NuevaUnidad({
    required this.config,
    required this.periodo,
    this.desde,
    this.hasta,
  });

  @override
  State<_NuevaUnidad> createState() => _NuevaUnidadState();
}

class _NuevaUnidadState extends State<_NuevaUnidad> {
  final _titulo = TextEditingController();
  late int _periodo = widget.periodo;
  late String? _desde = widget.desde;
  late String? _hasta = widget.hasta;

  @override
  void dispose() {
    _titulo.dispose();
    super.dispose();
  }

  void _guardar() {
    final t = _titulo.text.trim();
    if (t.isEmpty) return;
    Navigator.pop(context, (t, _periodo, _desde, _hasta));
  }

  @override
  Widget build(BuildContext context) {
    final periodos = widget.config.periodos;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Nueva unidad',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _titulo,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Título',
              hintText: 'Ej.: ¿Plásticos o biodegradables?',
            ),
            onSubmitted: (_) => _guardar(),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _periodo,
            decoration: const InputDecoration(labelText: 'Periodo'),
            items: [
              for (var i = 1; i <= periodos.length; i++)
                DropdownMenuItem(value: i, child: Text(periodos[i - 1].nombre)),
            ],
            onChanged: (v) => setState(() {
              _periodo = v!;
              _desde = periodos[v - 1].inicio;
              _hasta = periodos[v - 1].fin;
            }),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final r = await elegirRango(
                context,
                icono: KipuIcono.calendario,
                titulo: 'Fechas de la unidad',
                anio: widget.config.anio,
                inicio: _desde,
                fin: _hasta,
              );
              if (r != null) {
                setState(() {
                  _desde = r.$1;
                  _hasta = r.$2;
                });
              }
            },
            icon: KipuIcon(KipuIcono.calendario, color: KipuColores.morado),
            label: Text(rangoCorto(_desde, _hasta)),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _guardar, child: const Text('Crear')),
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Vista Semana ─────────────────────────

class _VistaSemana extends StatefulWidget {
  final _Datos datos;
  final bool ancho;
  const _VistaSemana({required this.datos, required this.ancho});

  @override
  State<_VistaSemana> createState() => _VistaSemanaState();
}

class _VistaSemanaState extends State<_VistaSemana> {
  final _horario = db.verHorario();
  int _semana = 0; // 0 = esta semana
  int? _curso; // null = todos
  late int _dia = DateTime.now().weekday > 5 ? 1 : DateTime.now().weekday;
  Stream<List<SesionConUnidad>>? _sesiones;
  String? _clave;

  DateTime get _lunes {
    final h = DateTime.now();
    final l = DateTime(h.year, h.month, h.day - (h.weekday - 1));
    return DateTime(l.year, l.month, l.day + 7 * _semana);
  }

  Stream<List<SesionConUnidad>> _sesionesDeSemana() {
    final desde = claveFecha(_lunes);
    if (_clave != desde || _sesiones == null) {
      _clave = desde;
      _sesiones = db.verSesionesEntre(
        desde,
        claveFecha(_lunes.add(const Duration(days: 6))),
      );
    }
    return _sesiones!;
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.datos;
    return StreamBuilder<List<(Horario, CursoConColegio)>>(
      stream: _horario,
      builder: (context, sh) => StreamBuilder<List<SesionConUnidad>>(
        stream: _sesionesDeSemana(),
        builder: (context, ss) {
          final todas = sh.data ?? const <(Horario, CursoConColegio)>[];
          final clases = [
            for (final c in todas)
              if (_curso == null || c.$2.curso.id == _curso) c,
          ];
          final sesiones = ss.data ?? const <SesionConUnidad>[];
          final dias = diasVisibles(todas);
          if (!dias.contains(_dia)) _dia = dias.first;
          final cabecera = _CabSemana(
            lunes: _lunes,
            semana: _semana,
            config: d.config,
            onCambio: (s) => setState(() => _semana = s),
          );
          final chips = _Chips(
            datos: d,
            actual: _curso,
            todos: 'Todos mis cursos',
            onElegir: (id) => setState(() => _curso = id),
          );
          if (todas.isEmpty) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              children: [
                cabecera,
                const SizedBox(height: 40),
                const Text(
                  'Tu horario está vacío. Pon tus clases en Horario y aquí '
                  'verás qué sesión toca en cada una.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: KipuColores.gris),
                ),
              ],
            );
          }
          Widget columnaDia(int dia, {bool lista = false}) {
            final fecha = claveFecha(_lunes.add(Duration(days: dia - 1)));
            final delDia = [
              for (final c in clases)
                if (c.$1.dia == dia) c,
            ]..sort((a, b) => a.$1.inicio.compareTo(b.$1.inicio));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final c in delDia)
                  _TarjetaClase(
                    clase: c,
                    color: d.color(c.$2),
                    fecha: fecha,
                    grande: lista,
                    sesion: sesiones
                        .where(
                          (s) =>
                              s.unidad.cursoId == c.$2.curso.id &&
                              s.sesion.fecha == fecha &&
                              (s.sesion.hora == null ||
                                  s.sesion.hora == c.$1.inicio),
                        )
                        .firstOrNull,
                    ahora: _esAhora(c.$1, fecha),
                    onElegir: () => _elegirSesion(context, d, c, fecha),
                  ),
                if (delDia.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Sin clases',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: KipuColores.gris),
                    ),
                  ),
              ],
            );
          }

          final hoy = claveFecha(DateTime.now());
          if (widget.ancho) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 40),
                      children: [
                        cabecera,
                        const SizedBox(height: 10),
                        chips,
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final dia in dias) ...[
                              if (dia != dias.first) const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _CabDia(
                                      dia: dia,
                                      fecha: _lunes.add(
                                        Duration(days: dia - 1),
                                      ),
                                      hoy:
                                          claveFecha(
                                            _lunes.add(Duration(days: dia - 1)),
                                          ) ==
                                          hoy,
                                    ),
                                    const SizedBox(height: 8),
                                    columnaDia(dia),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 290,
                    child: _PanelSemana(datos: d, clases: todas),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            children: [
              cabecera,
              const SizedBox(height: 10),
              _Segmentos(
                textos: [
                  for (final dia in dias)
                    '${diasCortos[dia - 1]} ${_lunes.add(Duration(days: dia - 1)).day}',
                ],
                actual: dias.indexOf(_dia),
                onCambio: (i) => setState(() => _dia = dias[i]),
              ),
              const SizedBox(height: 12),
              columnaDia(_dia, lista: true),
              const SizedBox(height: 6),
              _PanelSemana(datos: d, clases: todas),
            ],
          );
        },
      ),
    );
  }

  bool _esAhora(Horario h, String fecha) {
    final n = DateTime.now();
    if (claveFecha(n) != fecha) return false;
    final hora = hhmm(n.hour * 60 + n.minute);
    return h.inicio.compareTo(hora) <= 0 && h.fin.compareTo(hora) > 0;
  }

  Future<void> _elegirSesion(
    BuildContext context,
    _Datos d,
    (Horario, CursoConColegio) clase,
    String fecha,
  ) async {
    final curso = clase.$2;
    final pendientes = await db.sesionesSinFecha(curso.curso.id, d.config.anio);
    if (!context.mounted) return;
    final r = await ventanaCentrada<Object>(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 2),
            child: Text(
              nombreCurso(curso.curso),
              style: Theme.of(ctx).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
            child: Text(
              '${DateFormat("EEEE d 'de' MMMM", 'es_PE').format(DateTime.parse(fecha))} · ${clase.$1.inicio}',
              style: const TextStyle(color: KipuColores.gris),
            ),
          ),
          if (pendientes.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 6, 22, 6),
              child: Text(
                'Todas las sesiones de este curso ya tienen fecha.',
                style: TextStyle(color: KipuColores.gris),
              ),
            ),
          for (final s in pendientes.take(8))
            ListTile(
              leading: CircleAvatar(
                radius: 15,
                backgroundColor: KipuColores.moradoClaro,
                child: Text(
                  '${s.sesion.orden}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: KipuColores.morado,
                  ),
                ),
              ),
              title: Text(s.sesion.titulo),
              subtitle: Text(s.unidad.titulo, maxLines: 1),
              onTap: () => Navigator.pop(ctx, s),
            ),
          const Divider(),
          ListTile(
            leading: KipuIcon(KipuIcono.agregar, color: KipuColores.morado),
            title: const Text('Nueva sesión en esta clase'),
            onTap: () => Navigator.pop(ctx, 'nueva'),
          ),
        ],
      ),
    );
    if (r is SesionConUnidad) {
      await db.fecharSesion(r.sesion.id, fecha, clase.$1.inicio);
    } else if (r == 'nueva' && context.mounted) {
      final unidades = await db
          .verUnidades(curso.curso.id, d.config.anio)
          .first;
      if (!context.mounted) return;
      if (unidades.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Primero crea una unidad en la vista Año'),
          ),
        );
        return;
      }
      // La unidad que cubre esa fecha, o la última que empezó antes.
      final unidad =
          unidades
              .where(
                (u) =>
                    (u.desde ?? '').compareTo(fecha) <= 0 &&
                    (u.hasta ?? '9999').compareTo(fecha) >= 0,
              )
              .firstOrNull ??
          unidades.lastWhere(
            (u) => (u.desde ?? '').compareTo(fecha) <= 0,
            orElse: () => unidades.first,
          );
      final id = await db.crearSesion(
        SesionesCompanion.insert(
          unidadId: unidad.id,
          orden: 0,
          titulo: 'Nueva sesión',
          fecha: Value(fecha),
          hora: Value(clase.$1.inicio),
          competencia: Value(unidad.listaCompetencias.firstOrNull),
        ),
      );
      if (context.mounted) await abrirUnidad(context, unidad.id, sesion: id);
    }
  }
}

class _CabSemana extends StatelessWidget {
  final DateTime lunes;
  final int semana;
  final ConfigAcademica config;
  final void Function(int) onCambio;
  const _CabSemana({
    required this.lunes,
    required this.semana,
    required this.config,
    required this.onCambio,
  });

  @override
  Widget build(BuildContext context) {
    final viernes = lunes.add(const Duration(days: 4));
    final p = config.periodoActual(lunes) ?? config.periodoActual(viernes);
    String texto;
    if (lunes.month == viernes.month) {
      texto =
          '${lunes.day} al ${viernes.day} de ${DateFormat('MMMM', 'es_PE').format(lunes)}';
    } else {
      texto =
          '${fechaCorta(claveFecha(lunes))} al ${fechaCorta(claveFecha(viernes))}';
    }
    String? semanaDel;
    if (p != null) {
      final ini = DateTime.parse(config.periodos[p - 1].inicio!);
      final n = lunes.difference(ini).inDays ~/ 7 + 1;
      semanaDel =
          'Semana ${n < 1 ? 1 : n} del ${config.periodos[p - 1].nombre}';
    }
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                semana == 0 ? 'Esta semana' : texto,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                [?semanaDel, if (semana == 0) texto].join(' · '),
                style: const TextStyle(color: KipuColores.gris, fontSize: 13),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Semana anterior',
          style: IconButton.styleFrom(backgroundColor: Colors.white),
          onPressed: () => onCambio(semana - 1),
          icon: KipuIcon(KipuIcono.izquierda, color: KipuColores.tinta),
        ),
        if (semana != 0)
          TextButton(onPressed: () => onCambio(0), child: const Text('Hoy')),
        IconButton.filledTonal(
          tooltip: 'Semana siguiente',
          style: IconButton.styleFrom(backgroundColor: Colors.white),
          onPressed: () => onCambio(semana + 1),
          icon: KipuIcon(KipuIcono.derecha, color: KipuColores.tinta),
        ),
      ],
    );
  }
}

class _CabDia extends StatelessWidget {
  final int dia;
  final DateTime fecha;
  final bool hoy;
  const _CabDia({required this.dia, required this.fecha, required this.hoy});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: hoy ? KipuColores.morado : Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Text(
          diasLargos[dia - 1].toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: .5,
            color: hoy ? Colors.white : KipuColores.gris,
          ),
        ),
        Text(
          DateFormat('d MMM', 'es_PE').format(fecha).replaceAll('.', ''),
          style: TextStyle(
            fontSize: 11.5,
            color: hoy ? Colors.white : KipuColores.gris,
          ),
        ),
      ],
    ),
  );
}

class _TarjetaClase extends StatelessWidget {
  final (Horario, CursoConColegio) clase;
  final Color color;
  final String fecha;
  final SesionConUnidad? sesion;
  final bool ahora;
  final bool grande;
  final VoidCallback onElegir;
  const _TarjetaClase({
    required this.clase,
    required this.color,
    required this.fecha,
    required this.sesion,
    required this.ahora,
    required this.grande,
    required this.onElegir,
  });

  @override
  Widget build(BuildContext context) {
    final s = sesion?.sesion;
    final hecha = s?.hecha ?? false;
    Widget? chip;
    if (hecha) {
      chip = _chip('Hecha', const Color(0xFFD9F4EC), const Color(0xFF0E7A5F));
    } else if (ahora) {
      chip = _chip('Ahora', const Color(0xFFFDE9DB), const Color(0xFFC25A16));
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: hecha ? .62 : 1,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: s == null
                ? onElegir
                : () => abrirUnidad(context, s.unidadId, sesion: s.id),
            child: Container(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: color, width: 5)),
              ),
              padding: EdgeInsets.fromLTRB(
                11,
                grande ? 12 : 9,
                10,
                grande ? 12 : 9,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          clase.$1.inicio,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: KipuColores.gris,
                          ),
                        ),
                      ),
                      ?chip,
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nombreCurso(clase.$2.curso),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: grande ? 16 : 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Divider(height: 1, color: _linea),
                  ),
                  Text(
                    s == null ? '+ Elegir sesión' : 'S${s.orden} · ${s.titulo}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: grande ? 13.5 : 12.5,
                      height: 1.3,
                      fontWeight: s == null ? FontWeight.w600 : null,
                      color: s == null ? KipuColores.morado : KipuColores.tinta,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String t, Color fondo, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: fondo,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      t,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
    ),
  );
}

/// Panel de la semana: sesiones sin fecha para repartir y el avance del
/// periodo de cada curso.
class _PanelSemana extends StatefulWidget {
  final _Datos datos;
  final List<(Horario, CursoConColegio)> clases;
  const _PanelSemana({required this.datos, required this.clases});

  @override
  State<_PanelSemana> createState() => _PanelSemanaState();
}

class _PanelSemanaState extends State<_PanelSemana> {
  final _streams = <int, Stream<List<Unidad>>>{};
  final _sesiones = <int, Stream<Map<int, List<Sesion>>>>{};

  @override
  Widget build(BuildContext context) {
    final d = widget.datos;
    final periodo = d.config.periodoActual(DateTime.now());
    final cursos = [
      for (final c in d.cursos)
        if (widget.clases.any((x) => x.$2.curso.id == c.curso.id)) c,
    ];
    const titulo = TextStyle(
      fontSize: 13,
      letterSpacing: 1,
      color: KipuColores.gris,
      fontWeight: FontWeight.w600,
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            periodo == null
                ? 'AVANCE DEL AÑO'
                : 'AVANCE DEL ${d.config.periodos[periodo - 1].nombre.toUpperCase()}',
            style: titulo,
          ),
          const SizedBox(height: 10),
          for (final c in cursos)
            StreamBuilder<List<Unidad>>(
              stream: _streams[c.curso.id] ??= db.verUnidades(
                c.curso.id,
                d.config.anio,
              ),
              builder: (context, su) => StreamBuilder<Map<int, List<Sesion>>>(
                stream: _sesiones[c.curso.id] ??= db.verSesionesCurso(
                  c.curso.id,
                  d.config.anio,
                ),
                builder: (context, ss) {
                  final us = [
                    for (final u in su.data ?? const <Unidad>[])
                      if (periodo == null || u.periodo == periodo) u,
                  ];
                  final ses = [for (final u in us) ...?ss.data?[u.id]];
                  final hechas = ses.where((s) => s.hecha).length;
                  final sinFecha = [
                    for (final u in us)
                      if (ss.data?[u.id]?.any(
                            (s) => s.fecha == null && !s.hecha,
                          ) ??
                          false)
                        u,
                  ];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                nombreCurso(c.curso),
                                style: const TextStyle(fontSize: 13.5),
                              ),
                            ),
                            Text(
                              ses.isEmpty ? '—' : '$hechas/${ses.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ses.isEmpty ? 0 : hechas / ses.length,
                            minHeight: 7,
                            backgroundColor: _linea,
                            color: d.color(c),
                          ),
                        ),
                        if (sinFecha.isNotEmpty)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () =>
                                  _repartir(context, c, sinFecha.first),
                              child: Text(
                                'Repartir ${ss.data![sinFecha.first.id]!.where((s) => s.fecha == null && !s.hecha).length} sesiones sin fecha',
                                style: const TextStyle(fontSize: 12.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          const Text(
            'Toca una clase para elegir su sesión, o «Repartir» para ponerlas '
            'en orden en tus próximas clases.',
            style: TextStyle(fontSize: 12, color: KipuColores.gris),
          ),
        ],
      ),
    );
  }

  Future<void> _repartir(
    BuildContext context,
    CursoConColegio c,
    Unidad u,
  ) async {
    final horario = [
      for (final x in widget.clases)
        if (x.$2.curso.id == c.curso.id) x.$1,
    ];
    final n = DateTime.now();
    final cuantas = await db.repartirSesiones(
      u,
      horario,
      n,
      horaActual: hhmm(n.hour * 60 + n.minute),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cuantas == 0
              ? 'No hay sesiones por repartir'
              : 'Se programaron $cuantas sesiones de «${u.titulo}»',
        ),
      ),
    );
  }
}
