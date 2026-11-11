import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/academico.dart';
import '../data/cneb.dart';
import '../data/database.dart';
import '../data/evaluacion_db.dart';
import '../data/instrumentos.dart';
import '../data/planificacion.dart';
import '../main.dart' show db;
import '../theme.dart';
import '../widgets/calendario_rango.dart';
import '../widgets/kipu_icono.dart';
import 'horario_datos.dart';
import 'planificacion.dart';
import 'planificacion_exportar.dart';

const _linea = Color(0xFFECEDF4);

Future<void> abrirUnidad(BuildContext context, int id, {int? sesion}) =>
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PantallaUnidad(id: id, sesion: sesion),
      ),
    );

/// Todo lo que necesita la ficha de una unidad.
class _Ctx {
  final Unidad unidad;
  final List<Sesion> sesiones;
  final CursoConColegio curso;
  final bool privado;
  final ConfigAcademica config;
  final List<Horario> horario;
  final int numero;
  const _Ctx({
    required this.unidad,
    required this.sesiones,
    required this.curso,
    required this.privado,
    required this.config,
    required this.horario,
    required this.numero,
  });
}

class PantallaUnidad extends StatefulWidget {
  final int id;
  final int? sesion;
  const PantallaUnidad({super.key, required this.id, this.sesion});

  @override
  State<PantallaUnidad> createState() => _PantallaUnidadState();
}

class _PantallaUnidadState extends State<PantallaUnidad> {
  late final _unidad = db.verUnidad(widget.id);
  late final _sesiones = db.verSesiones(widget.id);
  final _cursos = db.verCursos();
  final _gestiones = db.verGestiones();
  final _horario = db.verHorario();
  late int? _sel = widget.sesion;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Unidad?>(
      stream: _unidad,
      builder: (context, su) {
        final u = su.data;
        if (u == null) return const Scaffold(body: SizedBox.shrink());
        return StreamBuilder<List<Sesion>>(
          stream: _sesiones,
          builder: (context, ss) => StreamBuilder<List<CursoConColegio>>(
            stream: _cursos,
            builder: (context, sc) => StreamBuilder<Map<int, String>>(
              stream: _gestiones,
              builder: (context, sg) =>
                  StreamBuilder<List<(Horario, CursoConColegio)>>(
                    stream: _horario,
                    builder: (context, sh) => StreamBuilder<ConfigAcademica>(
                      stream: db.verConfigAcademica(u.anio),
                      builder: (context, scf) => StreamBuilder<List<Unidad>>(
                        stream: db.verUnidades(u.cursoId, u.anio),
                        builder: (context, sus) {
                          final curso = sc.data
                              ?.where((c) => c.curso.id == u.cursoId)
                              .firstOrNull;
                          if (curso == null || !ss.hasData || !scf.hasData) {
                            return const Scaffold(body: SizedBox.shrink());
                          }
                          final n =
                              (sus.data ?? const <Unidad>[]).indexWhere(
                                (x) => x.id == u.id,
                              ) +
                              1;
                          return _pantalla(
                            context,
                            _Ctx(
                              unidad: u,
                              sesiones: ss.data!,
                              curso: curso,
                              privado:
                                  sg.data?[curso.colegio.id] == gestionPrivada,
                              config: scf.data!,
                              horario: [
                                for (final h in sh.data ?? const [])
                                  if (h.$2.curso.id == u.cursoId) h.$1,
                              ],
                              numero: n < 1 ? 1 : n,
                            ),
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

  Widget _pantalla(BuildContext context, _Ctx c) {
    final ancho = MediaQuery.sizeOf(context).width >= 900;
    final u = c.unidad;
    final per = c.config.periodos.length >= u.periodo
        ? c.config.periodos[u.periodo - 1].nombre
        : '';
    final sub = [
      nombreCurso(c.curso.curso),
      c.curso.colegio.nombre,
      per,
      rangoCorto(u.desde, u.hasta),
    ].join(' · ');
    if (_sel != null && !c.sesiones.any((s) => s.id == _sel)) _sel = null;
    final sel =
        c.sesiones.where((s) => s.id == _sel).firstOrNull ??
        (ancho ? c.sesiones.firstOrNull : null);

    final titulo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sub,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
        ),
        Text(
          'Unidad ${c.numero} · ${u.titulo}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
    final acciones = [
      if (c.privado)
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: ancho
              ? FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1D6F42),
                  ),
                  onPressed: () => _descargar(context, c),
                  icon: const KipuIcon(
                    KipuIcono.descargar,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text('Descargar Excel'),
                )
              : IconButton(
                  tooltip: 'Descargar Excel',
                  onPressed: () => _descargar(context, c),
                  icon: KipuIcon(KipuIcono.descargar, color: KipuColores.tinta),
                ),
        )
      else
        IconButton(
          tooltip: 'Descargar',
          onPressed: () => _descargar(context, c),
          icon: KipuIcon(KipuIcono.descargar, color: KipuColores.tinta),
        ),
      PopupMenuButton<String>(
        tooltip: 'Más opciones',
        icon: KipuIcon(KipuIcono.menu, color: KipuColores.tinta),
        onSelected: (o) {
          if (o == 'borrar') _borrar(context, c);
          if (o == 'mover') _mover(context, c);
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'mover', child: Text('Cambiar de periodo')),
          PopupMenuItem(value: 'borrar', child: Text('Borrar unidad')),
        ],
      ),
      const SizedBox(width: 8),
    ];
    final ficha = c.privado
        ? _FichaPrivada(key: ValueKey('fp${u.id}'), c: c)
        : _FichaPublica(key: ValueKey('fu${u.id}'), c: c);

    if (ancho) {
      return Scaffold(
        appBar: AppBar(title: titulo, actions: acciones, toolbarHeight: 68),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 5, child: _Tarjeta(child: ficha)),
              const SizedBox(width: 14),
              Expanded(
                flex: 5,
                child: _Tarjeta(
                  scroll: false,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 200,
                        child: _ListaSesiones(
                          c: c,
                          sel: sel?.id,
                          onSel: (id) => setState(() => _sel = id),
                        ),
                      ),
                      const VerticalDivider(width: 20, color: _linea),
                      Expanded(
                        child: sel == null
                            ? const Center(
                                child: Text(
                                  'Agrega la primera sesión de la unidad.',
                                  style: TextStyle(color: KipuColores.gris),
                                ),
                              )
                            : SingleChildScrollView(
                                child: _EditorSesion(
                                  key: ValueKey('s${sel.id}'),
                                  c: c,
                                  sesion: sel,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return DefaultTabController(
      length: 2,
      initialIndex: widget.sesion != null ? 1 : 0,
      child: Scaffold(
        appBar: AppBar(
          title: titulo,
          actions: acciones,
          bottom: TabBar(
            tabs: [
              const Tab(text: 'Unidad'),
              Tab(text: 'Sesiones (${c.sesiones.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              children: [_Tarjeta(scroll: false, child: ficha)],
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              children: [
                _Tarjeta(
                  scroll: false,
                  child: _ListaSesiones(
                    c: c,
                    sel: null,
                    onSel: (id) => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _PaginaSesion(
                          unidadId: c.unidad.id,
                          sesionId: id,
                          c: c,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _descargar(BuildContext context, _Ctx c) => descargarUnidades(
    context,
    curso: c.curso,
    privado: c.privado,
    anio: c.config.anio,
    periodos: c.config.periodos,
    unidad: c.unidad,
  );

  Future<void> _mover(BuildContext context, _Ctx c) async {
    final p = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Cambiar de periodo'),
        children: [
          for (var i = 1; i <= c.config.periodos.length; i++)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, i),
              child: Text(c.config.periodos[i - 1].nombre),
            ),
        ],
      ),
    );
    if (p == null || p == c.unidad.periodo) return;
    await db.editarUnidad(
      c.unidad.id,
      UnidadesCompanion(periodo: Value(p), orden: const Value(999)),
    );
  }

  Future<void> _borrar(BuildContext context, _Ctx c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Borrar la unidad?'),
        content: Text(
          'Se borran «${c.unidad.titulo}» y sus ${c.sesiones.length} sesiones. '
          'Las columnas del registro que creaste desde ellas se quedan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC2334A),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await db.borrarUnidad(c.unidad.id);
    if (context.mounted) Navigator.pop(context);
  }
}

class _Tarjeta extends StatelessWidget {
  final Widget child;
  final bool scroll;
  const _Tarjeta({required this.child, this.scroll = true});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: scroll ? SingleChildScrollView(child: child) : child,
  );
}

class _Etiqueta extends StatelessWidget {
  final String texto;
  const _Etiqueta(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 6),
    child: Text(
      texto.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        color: KipuColores.gris,
        fontWeight: FontWeight.w600,
        letterSpacing: .8,
      ),
    ),
  );
}

/// Campo de texto que se guarda solo, al dejar de escribir.
class Campo extends StatefulWidget {
  final String? valor;
  final String? pista;
  final int lineas;
  final void Function(String?) onGuardar;
  final TextStyle? estilo;
  final Color? relleno;
  const Campo({
    super.key,
    required this.valor,
    required this.onGuardar,
    this.pista,
    this.lineas = 1,
    this.estilo,
    this.relleno,
  });

  @override
  State<Campo> createState() => _CampoState();
}

class _CampoState extends State<Campo> {
  late final _c = TextEditingController(text: widget.valor);
  Timer? _espera;
  String? _ultimo;

  @override
  void initState() {
    super.initState();
    _ultimo = widget.valor;
  }

  void _guardar() {
    _espera?.cancel();
    final t = _c.text.trim();
    final v = t.isEmpty ? null : t;
    if (v == _ultimo) return;
    _ultimo = v;
    widget.onGuardar(v);
  }

  @override
  void dispose() {
    _guardar();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Focus(
    onFocusChange: (f) {
      if (!f) _guardar();
    },
    child: TextField(
      controller: _c,
      minLines: widget.lineas,
      maxLines: widget.lineas == 1 ? 1 : null,
      style: widget.estilo ?? const TextStyle(fontSize: 14, height: 1.4),
      textCapitalization: TextCapitalization.sentences,
      onChanged: (_) {
        _espera?.cancel();
        _espera = Timer(const Duration(milliseconds: 700), _guardar);
      },
      decoration: InputDecoration(
        hintText: widget.pista,
        isDense: true,
        filled: true,
        fillColor: widget.relleno ?? KipuColores.fondo,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}

class _Fechas extends StatelessWidget {
  final _Ctx c;
  const _Fechas({required this.c});

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: OutlinedButton.icon(
      onPressed: () async {
        final r = await elegirRango(
          context,
          icono: KipuIcono.calendario,
          titulo: 'Fechas de la unidad',
          anio: c.unidad.anio,
          inicio: c.unidad.desde,
          fin: c.unidad.hasta,
        );
        if (r == null) return;
        await db.editarUnidad(
          c.unidad.id,
          UnidadesCompanion(desde: Value(r.$1), hasta: Value(r.$2)),
        );
      },
      icon: KipuIcon(KipuIcono.calendario, color: KipuColores.morado, size: 20),
      label: Text(rangoCorto(c.unidad.desde, c.unidad.hasta)),
    ),
  );
}

/// Chips para elegir las competencias de la unidad.
class _Competencias extends StatelessWidget {
  final _Ctx c;
  const _Competencias({required this.c});

  @override
  Widget build(BuildContext context) {
    final elegidas = c.unidad.listaCompetencias;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final k in competenciasDelCurso(c.curso.curso))
          FilterChip(
            showCheckmark: false,
            avatar: LetraCompetencia(k.id),
            label: Text(k.corto, style: const TextStyle(fontSize: 13)),
            selected: elegidas.contains(k.id),
            selectedColor: KipuColores.moradoClaro,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: elegidas.contains(k.id)
                  ? KipuColores.morado
                  : const Color(0xFFDCDDEA),
            ),
            onSelected: (v) {
              final nueva = [
                for (final x in competenciasDelCurso(c.curso.curso))
                  if (x.id == k.id ? v : elegidas.contains(x.id)) x.id,
              ];
              // Los propósitos siguen a las competencias elegidas.
              final props = c.unidad.listaPropositos;
              final nuevos = [
                for (final id in nueva)
                  props.where((p) => p.competencia == id).firstOrNull ??
                      Proposito(id),
              ];
              db.editarUnidad(
                c.unidad.id,
                UnidadesCompanion(
                  competencias: Value(nueva.join(',')),
                  propositos: Value(
                    c.privado ? c.unidad.propositos : Proposito.aTexto(nuevos),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Colegio privado: solo lo esencial.
class _FichaPrivada extends StatelessWidget {
  final _Ctx c;
  const _FichaPrivada({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    final u = c.unidad;
    void guardar(UnidadesCompanion x) => db.editarUnidad(u.id, x);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'LA UNIDAD',
          style: TextStyle(
            fontSize: 13,
            letterSpacing: 1,
            color: KipuColores.gris,
            fontWeight: FontWeight.w600,
          ),
        ),
        const _Etiqueta('Título'),
        Campo(
          valor: u.titulo,
          onGuardar: (v) {
            if (v != null) guardar(UnidadesCompanion(titulo: Value(v)));
          },
        ),
        const _Etiqueta('Fechas'),
        _Fechas(c: c),
        const _Etiqueta('Competencias'),
        _Competencias(c: c),
        const _Etiqueta('Temas'),
        Campo(
          valor: u.temas,
          lineas: 2,
          pista: 'Ej.: Polímeros naturales y sintéticos, reciclaje',
          onGuardar: (v) => guardar(UnidadesCompanion(temas: Value(v))),
        ),
        const _Etiqueta('Producto final'),
        Campo(
          valor: u.producto,
          pista: 'Ej.: Informe del experimento',
          onGuardar: (v) => guardar(UnidadesCompanion(producto: Value(v))),
        ),
      ],
    );
  }
}

/// Colegio público: unidad con el CNEB completo.
class _FichaPublica extends StatefulWidget {
  final _Ctx c;
  const _FichaPublica({super.key, required this.c});

  @override
  State<_FichaPublica> createState() => _FichaPublicaState();
}

class _FichaPublicaState extends State<_FichaPublica> {
  final _biblioteca = db.verBiblioteca();

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final u = c.unidad;
    void guardar(UnidadesCompanion x) => db.editarUnidad(u.id, x);
    final props = {for (final p in u.listaPropositos) p.competencia: p};
    void guardarProp(Proposito p) {
      final lista = [
        for (final id in u.listaCompetencias)
          id == p.competencia ? p : props[id] ?? Proposito(id),
      ];
      guardar(UnidadesCompanion(propositos: Value(Proposito.aTexto(lista))));
    }

    final enfoques = u.listaEnfoques;
    return StreamBuilder<List<Instrumento>>(
      stream: _biblioteca,
      builder: (context, sb) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Etiqueta('Título'),
          Campo(
            valor: u.titulo,
            onGuardar: (v) {
              if (v != null) guardar(UnidadesCompanion(titulo: Value(v)));
            },
          ),
          const _Etiqueta('Fechas'),
          _Fechas(c: c),
          const _Etiqueta('Situación significativa'),
          Campo(
            valor: u.situacion,
            lineas: 3,
            pista:
                'El reto o problema de su contexto que da sentido a la unidad…',
            onGuardar: (v) => guardar(UnidadesCompanion(situacion: Value(v))),
          ),
          const _Etiqueta('Competencias'),
          _Competencias(c: c),
          const _Etiqueta('Propósitos de aprendizaje'),
          if (u.listaCompetencias.isEmpty)
            const Text(
              'Elige arriba las competencias que trabajarás.',
              style: TextStyle(color: KipuColores.gris),
            ),
          for (final id in u.listaCompetencias)
            _PropositoCaja(
              key: ValueKey('p${u.id}$id'),
              proposito: props[id] ?? Proposito(id),
              instrumentos: [
                for (final i in sb.data ?? const <Instrumento>[])
                  if (i.competencias.isEmpty || i.competencias.contains(id)) i,
              ],
              onCambio: guardarProp,
            ),
          const _Etiqueta('Enfoques transversales'),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final e in enfoquesTransversales)
                FilterChip(
                  showCheckmark: false,
                  label: Text(e, style: const TextStyle(fontSize: 13)),
                  selected: enfoques.contains(e),
                  selectedColor: KipuColores.moradoClaro,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: enfoques.contains(e)
                        ? KipuColores.morado
                        : const Color(0xFFDCDDEA),
                  ),
                  onSelected: (v) => guardar(
                    UnidadesCompanion(
                      enfoques: Value(
                        [
                          for (final x in enfoquesTransversales)
                            if (x == e ? v : enfoques.contains(x)) x,
                        ].join('|'),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const _Etiqueta('Producto de la unidad'),
          Campo(
            valor: u.producto,
            pista: 'Ej.: Campaña para cuidar el río',
            onGuardar: (v) => guardar(UnidadesCompanion(producto: Value(v))),
          ),
          const _Etiqueta('Materiales y recursos'),
          Campo(
            valor: u.materiales,
            lineas: 2,
            onGuardar: (v) => guardar(UnidadesCompanion(materiales: Value(v))),
          ),
          Container(
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Las competencias y capacidades salen del CNEB según el área y el '
              'nivel del curso. Los criterios y evidencias los escribes tú.',
              style: TextStyle(fontSize: 13, color: Color(0xFF8A5A00)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PropositoCaja extends StatelessWidget {
  final Proposito proposito;
  final List<Instrumento> instrumentos;
  final void Function(Proposito) onCambio;
  const _PropositoCaja({
    super.key,
    required this.proposito,
    required this.instrumentos,
    required this.onCambio,
  });

  @override
  Widget build(BuildContext context) {
    final p = proposito;
    final comp = competenciaPorId(p.competencia);
    final caps = capacidadesCneb[p.competencia] ?? const <String>[];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: _linea, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              LetraCompetencia(p.competencia),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  comp?.nombre ?? p.competencia,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (caps.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Capacidades',
              style: TextStyle(fontSize: 12.5, color: KipuColores.gris),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                for (final cap in caps)
                  FilterChip(
                    visualDensity: VisualDensity.compact,
                    showCheckmark: false,
                    label: Text(cap, style: const TextStyle(fontSize: 12)),
                    selected: p.capacidades.contains(cap),
                    selectedColor: KipuColores.moradoClaro,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: p.capacidades.contains(cap)
                          ? KipuColores.morado
                          : const Color(0xFFDCDDEA),
                    ),
                    onSelected: (v) => onCambio(
                      p.copiar(
                        capacidades: [
                          for (final x in caps)
                            if (x == cap ? v : p.capacidades.contains(x)) x,
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Campo(
            valor: p.criterios.isEmpty ? null : p.criterios,
            lineas: 2,
            pista: 'Criterios de evaluación (uno por línea)',
            onGuardar: (v) => onCambio(p.copiar(criterios: v ?? '')),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Campo(
                  valor: p.evidencia.isEmpty ? null : p.evidencia,
                  pista: 'Evidencia',
                  onGuardar: (v) => onCambio(p.copiar(evidencia: v ?? '')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Instrumento(
                  valor: p.instrumento,
                  instrumentos: instrumentos,
                  onCambio: (v) => onCambio(p.copiar(instrumento: v)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Instrumento extends StatelessWidget {
  final String valor;
  final List<Instrumento> instrumentos;
  final void Function(String) onCambio;
  const _Instrumento({
    required this.valor,
    required this.instrumentos,
    required this.onCambio,
  });

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: 'Elegir instrumento',
    onSelected: onCambio,
    itemBuilder: (_) => [
      for (final i in instrumentos.take(15))
        PopupMenuItem(value: i.nombre, child: Text(i.nombre)),
      for (final t in const [
        'Rúbrica',
        'Lista de cotejo',
        'Escala de valoración',
      ])
        PopupMenuItem(value: t, child: Text(t)),
      if (valor.isNotEmpty)
        const PopupMenuItem(value: '', child: Text('Quitar')),
    ],
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: valor.isEmpty ? KipuColores.fondo : const Color(0xFFD9F4EC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              valor.isEmpty ? 'Instrumento' : valor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: valor.isEmpty
                    ? KipuColores.gris
                    : const Color(0xFF0E7A5F),
                fontWeight: valor.isEmpty ? null : FontWeight.w600,
              ),
            ),
          ),
          const KipuIcon(KipuIcono.abajo, size: 18, color: KipuColores.gris),
        ],
      ),
    ),
  );
}

// ───────────────────────── Sesiones ─────────────────────────

String textoFechaSesion(Sesion s) {
  if (s.fecha == null) return 'Sin fecha';
  final d = DateTime.parse(s.fecha!);
  final hoy = claveFecha(DateTime.now());
  final dia = s.fecha == hoy
      ? 'Hoy'
      : DateFormat('EEE d MMM', 'es_PE').format(d).replaceAll('.', '');
  final t = dia[0].toUpperCase() + dia.substring(1);
  return s.hora == null ? t : '$t · ${s.hora}';
}

class _ListaSesiones extends StatelessWidget {
  final _Ctx c;
  final int? sel;
  final void Function(int) onSel;
  const _ListaSesiones({
    required this.c,
    required this.sel,
    required this.onSel,
  });

  Future<void> _nueva(BuildContext context) async {
    final id = await db.crearSesion(
      SesionesCompanion.insert(
        unidadId: c.unidad.id,
        orden: 0,
        titulo: 'Sesión ${c.sesiones.length + 1}',
        competencia: Value(c.unidad.listaCompetencias.firstOrNull),
        minInicio: Value(c.privado ? null : 15),
        minCierre: Value(c.privado ? null : 15),
      ),
    );
    onSel(id);
  }

  Future<void> _repartir(BuildContext context) async {
    final n = DateTime.now();
    final cuantas = await db.repartirSesiones(
      c.unidad,
      c.horario,
      n,
      horaActual: hhmm(n.hour * 60 + n.minute),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          c.horario.isEmpty
              ? 'Este curso no tiene clases en tu Horario'
              : cuantas == 0
              ? 'Todas las sesiones ya tienen fecha'
              : 'Se programaron $cuantas sesiones en tus próximas clases',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sinFecha = c.sesiones.where((s) => s.fecha == null && !s.hecha);
    final lista = [
      for (final s in c.sesiones)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Material(
            color: s.id == sel ? KipuColores.moradoClaro : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onSel(s.id),
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: s.id == sel
                            ? KipuColores.morado
                            : s.hecha
                            ? const Color(0xFFD9F4EC)
                            : KipuColores.fondo,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: s.hecha && s.id != sel
                          ? const KipuIcon(
                              KipuIcono.check,
                              size: 16,
                              color: Color(0xFF0E7A5F),
                            )
                          : Text(
                              '${c.sesiones.indexOf(s) + 1}',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: s.id == sel
                                    ? Colors.white
                                    : KipuColores.gris,
                              ),
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.titulo,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13.5),
                          ),
                          Text(
                            textoFechaSesion(s),
                            style: const TextStyle(
                              fontSize: 12,
                              color: KipuColores.gris,
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
        ),
    ];
    final botones = [
      TextButton.icon(
        onPressed: () => _nueva(context),
        icon: KipuIcon(KipuIcono.agregar, size: 18, color: KipuColores.morado),
        label: const Text('Nueva sesión'),
      ),
      if (sinFecha.isNotEmpty)
        TextButton(
          onPressed: () => _repartir(context),
          child: Text(
            'Repartir en mis clases (${sinFecha.length})',
            textAlign: TextAlign.center,
          ),
        ),
    ];
    final cab = Text(
      '${c.sesiones.length} SESIONES',
      style: const TextStyle(
        fontSize: 13,
        letterSpacing: 1,
        color: KipuColores.gris,
        fontWeight: FontWeight.w600,
      ),
    );
    // En la ficha ancha la lista va en una columna con su propio scroll.
    if (sel != null || MediaQuery.sizeOf(context).width >= 900) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          cab,
          const SizedBox(height: 8),
          Expanded(child: ListView(children: lista)),
          ...botones,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [cab, const SizedBox(height: 8), ...lista, ...botones],
    );
  }
}

/// Página de una sesión en el celular.
class _PaginaSesion extends StatelessWidget {
  final int unidadId;
  final int sesionId;
  final _Ctx c;
  const _PaginaSesion({
    required this.unidadId,
    required this.sesionId,
    required this.c,
  });

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Sesion>>(
    stream: db.verSesiones(unidadId),
    builder: (context, ss) {
      final s = ss.data?.where((x) => x.id == sesionId).firstOrNull;
      return Scaffold(
        appBar: AppBar(title: Text(s?.titulo ?? 'Sesión')),
        body: s == null
            ? const SizedBox.shrink()
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                children: [
                  _Tarjeta(
                    scroll: false,
                    child: _EditorSesion(
                      key: ValueKey('s${s.id}'),
                      c: c,
                      sesion: s,
                      alBorrar: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
      );
    },
  );
}

class _EditorSesion extends StatelessWidget {
  final _Ctx c;
  final Sesion sesion;
  final VoidCallback? alBorrar;
  const _EditorSesion({
    super.key,
    required this.c,
    required this.sesion,
    this.alBorrar,
  });

  int get _numero => c.sesiones.indexWhere((s) => s.id == sesion.id) + 1;

  Future<void> _fecha(BuildContext context) async {
    final s = sesion;
    final ocupadas = <String>{};
    for (final x in c.sesiones) {
      if (x.fecha != null && x.id != s.id) ocupadas.add('${x.fecha} ${x.hora}');
    }
    final n = DateTime.now();
    final proximas = proximasClases(
      c.horario,
      n,
      cantidad: 6,
      ocupadas: ocupadas,
      horaActual: hhmm(n.hour * 60 + n.minute),
    );
    final r = await showModalBottomSheet<Object>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 6),
              child: Text(
                'Próximas clases del curso',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            for (final p in proximas)
              ListTile(
                leading: KipuIcon(KipuIcono.horario, color: KipuColores.morado),
                title: Text(
                  toBeginningOfSentenceCase(
                    DateFormat(
                      "EEEE d 'de' MMMM",
                      'es_PE',
                    ).format(DateTime.parse(p.fecha)),
                  ),
                ),
                subtitle: Text(p.hora),
                onTap: () => Navigator.pop(ctx, p),
              ),
            if (proximas.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  'Pon las clases de este curso en tu Horario para elegirlas aquí.',
                  style: TextStyle(color: KipuColores.gris),
                ),
              ),
            ListTile(
              leading: KipuIcon(
                KipuIcono.calendario,
                color: KipuColores.morado,
              ),
              title: const Text('Otro día…'),
              onTap: () => Navigator.pop(ctx, 'otro'),
            ),
            if (s.fecha != null)
              ListTile(
                leading: const KipuIcon(
                  KipuIcono.cerrar,
                  color: KipuColores.gris,
                ),
                title: const Text('Quitar la fecha'),
                onTap: () => Navigator.pop(ctx, 'quitar'),
              ),
          ],
        ),
      ),
    );
    if (r is ClaseFecha) {
      await db.fecharSesion(s.id, r.fecha, r.hora);
    } else if (r == 'quitar') {
      await db.fecharSesion(s.id, null, null);
    } else if (r == 'otro' && context.mounted) {
      final f = await elegirFecha(
        context,
        icono: KipuIcono.calendario,
        titulo: 'Fecha de la sesión',
        anio: c.unidad.anio,
        fecha: s.fecha,
      );
      if (f == null) return;
      final dia = DateTime.parse(f).weekday;
      final bloque = c.horario.where((h) => h.dia == dia).firstOrNull;
      await db.fecharSesion(s.id, f, bloque?.inicio);
    }
  }

  Future<void> _columna(BuildContext context) async {
    final s = sesion;
    if (s.columnaId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta sesión ya tiene su columna en el registro'),
        ),
      );
      return;
    }
    final escala = c.privado && c.config.escalas.any((e) => e.id == 'vigesimal')
        ? 'vigesimal'
        : c.config.escalaPorDefecto;
    await db.columnaDeSesion(s, c.unidad, escala: escala);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Columna «${s.titulo}» creada en el registro de '
          '${nombreCurso(c.curso.curso)}',
        ),
      ),
    );
  }

  Future<void> _borrar(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Borrar la sesión?'),
        content: Text('Se borra «${sesion.titulo}».'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC2334A),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await db.borrarSesion(sesion.id);
    alBorrar?.call();
  }

  @override
  Widget build(BuildContext context) {
    final s = sesion;
    void guardar(SesionesCompanion x) => db.editarSesion(s.id, x);
    final comps = c.unidad.listaCompetencias;
    final i = c.sesiones.indexWhere((x) => x.id == s.id);
    final total = [
      s.minInicio,
      s.minDesarrollo,
      s.minCierre,
    ].whereType<int>().fold(0, (a, b) => a + b);

    Widget momento(
      String nombre,
      String? texto,
      int? min,
      Color fondo,
      Color color,
      SesionesCompanion Function(String?) conTexto,
      SesionesCompanion Function(int?) conMin,
    ) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nombre,
                  style: TextStyle(fontWeight: FontWeight.w700, color: color),
                ),
              ),
              SizedBox(
                width: 64,
                child: _Minutos(
                  valor: min,
                  color: color,
                  onGuardar: (v) => guardar(conMin(v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _CampoClaro(valor: texto, onGuardar: (v) => guardar(conTexto(v))),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ActionChip(
              avatar: KipuIcon(
                KipuIcono.calendario,
                size: 16,
                color: s.fecha == null ? KipuColores.morado : Colors.white,
              ),
              label: Text(
                s.fecha == null
                    ? 'Ponerle fecha'
                    : textoFechaSesion(s) +
                          (total > 0 && !c.privado ? ' · $total min' : ''),
              ),
              labelStyle: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: s.fecha == null ? KipuColores.morado : Colors.white,
              ),
              backgroundColor: s.fecha == null
                  ? KipuColores.moradoClaro
                  : KipuColores.morado,
              side: BorderSide.none,
              onPressed: () => _fecha(context),
            ),
            if (comps.isNotEmpty)
              PopupMenuButton<String>(
                tooltip: 'Competencia de la sesión',
                onSelected: (v) =>
                    guardar(SesionesCompanion(competencia: Value(v))),
                itemBuilder: (_) => [
                  for (final k in comps)
                    PopupMenuItem(
                      value: k,
                      child: Row(
                        children: [
                          LetraCompetencia(k),
                          const SizedBox(width: 8),
                          Text(competenciaPorId(k)?.corto ?? k),
                        ],
                      ),
                    ),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (s.competencia != null) LetraCompetencia(s.competencia!),
                    const SizedBox(width: 4),
                    Text(
                      competenciaPorId(s.competencia ?? '')?.corto ??
                          'Competencia',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: KipuColores.gris,
                      ),
                    ),
                    const KipuIcon(
                      KipuIcono.abajo,
                      size: 16,
                      color: KipuColores.gris,
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Sesión $_numero',
          style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
        ),
        Campo(
          valor: s.titulo,
          estilo: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          onGuardar: (v) {
            if (v != null) guardar(SesionesCompanion(titulo: Value(v)));
          },
        ),
        const _Etiqueta('Propósito'),
        Campo(
          valor: s.proposito,
          lineas: 2,
          pista: 'Hoy aprenderemos a…',
          onGuardar: (v) => guardar(SesionesCompanion(proposito: Value(v))),
        ),
        if (c.privado) ...[
          const _Etiqueta('Actividades'),
          Campo(
            valor: s.desarrollo,
            lineas: 3,
            pista: '1. …\n2. …',
            onGuardar: (v) => guardar(SesionesCompanion(desarrollo: Value(v))),
          ),
        ] else ...[
          const SizedBox(height: 12),
          momento(
            'Inicio',
            s.inicio,
            s.minInicio,
            const Color(0xFFE2ECFD),
            const Color(0xFF2557C7),
            (v) => SesionesCompanion(inicio: Value(v)),
            (v) => SesionesCompanion(minInicio: Value(v)),
          ),
          momento(
            'Desarrollo',
            s.desarrollo,
            s.minDesarrollo,
            const Color(0xFFEDE7FE),
            const Color(0xFF6D3FD8),
            (v) => SesionesCompanion(desarrollo: Value(v)),
            (v) => SesionesCompanion(minDesarrollo: Value(v)),
          ),
          momento(
            'Cierre',
            s.cierre,
            s.minCierre,
            const Color(0xFFD9F4EC),
            const Color(0xFF0E7A5F),
            (v) => SesionesCompanion(cierre: Value(v)),
            (v) => SesionesCompanion(minCierre: Value(v)),
          ),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Etiqueta('Materiales'),
                  Campo(
                    valor: s.materiales,
                    onGuardar: (v) =>
                        guardar(SesionesCompanion(materiales: Value(v))),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Etiqueta('Tarea'),
                  Campo(
                    valor: s.tarea,
                    onGuardar: (v) =>
                        guardar(SesionesCompanion(tarea: Value(v))),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => _columna(context),
              icon: KipuIcon(
                s.columnaId == null ? KipuIcono.agregar : KipuIcono.check,
                size: 18,
                color: Colors.white,
              ),
              label: Text(
                s.columnaId == null
                    ? 'Columna en el registro'
                    : 'Ya está en el registro',
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: () => db.marcarSesion(s.id, !s.hecha),
              icon: KipuIcon(
                KipuIcono.check,
                size: 18,
                color: KipuColores.moradoOscuro,
              ),
              label: Text(s.hecha ? 'Desmarcar hecha' : 'Marcar hecha'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              tooltip: 'Subir',
              onPressed: i > 0 ? () => db.moverSesion(c.sesiones, i, -1) : null,
              icon: const KipuIcon(KipuIcono.arriba, color: KipuColores.gris),
            ),
            IconButton(
              tooltip: 'Bajar',
              onPressed: i < c.sesiones.length - 1
                  ? () => db.moverSesion(c.sesiones, i, 1)
                  : null,
              icon: const KipuIcon(KipuIcono.abajo, color: KipuColores.gris),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _borrar(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFC2334A),
              ),
              icon: const KipuIcon(
                KipuIcono.borrar,
                size: 18,
                color: Color(0xFFC2334A),
              ),
              label: const Text('Borrar'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Texto de un momento, sobre el fondo de color.
class _CampoClaro extends StatelessWidget {
  final String? valor;
  final void Function(String?) onGuardar;
  const _CampoClaro({required this.valor, required this.onGuardar});

  @override
  Widget build(BuildContext context) => Campo(
    valor: valor,
    lineas: 2,
    relleno: Colors.white.withValues(alpha: .75),
    onGuardar: onGuardar,
  );
}

class _Minutos extends StatelessWidget {
  final int? valor;
  final Color color;
  final void Function(int?) onGuardar;
  const _Minutos({
    required this.valor,
    required this.color,
    required this.onGuardar,
  });

  @override
  Widget build(BuildContext context) => Campo(
    valor: valor?.toString(),
    pista: 'min',
    relleno: Colors.white.withValues(alpha: .75),
    estilo: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w700),
    onGuardar: (v) => onGuardar(int.tryParse(v ?? '')),
  );
}
