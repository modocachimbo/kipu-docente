import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/academico.dart';
import '../data/database.dart';
import '../data/registro.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/calendario_rango.dart';
import '../widgets/kipu_icono.dart';
import '../widgets/selector_color.dart' show textoSobre;
import 'asistencia_exportar.dart';
import 'cursos.dart' show colorColegio;
import 'estudiantes.dart' show AvatarEstudiante;

class EstadoAsistencia {
  final String codigo;
  final String nombre;
  final Color color;
  final IconData icono;
  const EstadoAsistencia(this.codigo, this.nombre, this.color, this.icono);
}

const estadosAsistencia = [
  EstadoAsistencia('P', 'Presente', Color(0xFF2FBF8F), Icons.check),
  EstadoAsistencia('T', 'Tarde', Color(0xFFE9A23B), Icons.schedule),
  EstadoAsistencia('F', 'Falta', Color(0xFFE0697A), Icons.close),
  EstadoAsistencia(
    'J',
    'Justificada',
    Color(0xFF6C7BD9),
    Icons.description_outlined,
  ),
];

String fechaClave(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

/// Pestaña principal: elige un curso y pasa lista.
class PantallaAsistencia extends StatefulWidget {
  const PantallaAsistencia({super.key});

  @override
  State<PantallaAsistencia> createState() => _AsistenciaState();
}

class _AsistenciaState extends State<PantallaAsistencia> {
  int? _cursoId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencia'),
        actions: const [_SelectorColegio(), SizedBox(width: 12)],
      ),
      body: StreamBuilder<String?>(
        stream: db.verAjuste('colegio_activo'),
        builder: (context, snapAct) => StreamBuilder<List<CursoConColegio>>(
          stream: db.verCursos(),
          builder: (context, snap) {
            final todos = snap.data ?? [];
            // Solo los cursos del colegio activo (el elegido en Mis cursos).
            final colegios = {for (final c in todos) c.colegio.id: c.colegio};
            final activo =
                colegios[int.tryParse(snapAct.data ?? '')] ??
                (colegios.isEmpty ? null : colegios.values.first);
            final cursos = todos
                .where((c) => c.colegio.id == activo?.id)
                .toList();
            if (snap.hasData && cursos.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Primero crea un curso y agrega estudiantes en "Mis cursos".',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: KipuColores.gris),
                  ),
                ),
              );
            }
            if (cursos.isEmpty) return const SizedBox.shrink();
            final actual = cursos.firstWhere(
              (c) => c.curso.id == _cursoId,
              orElse: () => cursos.first,
            );
            return Column(
              children: [
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      for (final c in cursos)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              '${c.curso.nombre} · ${c.curso.grado} ${c.curso.seccion}',
                            ),
                            selected: c.curso.id == actual.curso.id,
                            showCheckmark: false,
                            selectedColor: colorColegio(
                              colegios.values.toList(),
                              c.colegio.id,
                            ),
                            labelStyle: TextStyle(
                              color: c.curso.id == actual.curso.id
                                  ? textoSobre(
                                      colorColegio(
                                        colegios.values.toList(),
                                        c.colegio.id,
                                      ),
                                    )
                                  : KipuColores.tinta,
                            ),
                            onSelected: (_) =>
                                setState(() => _cursoId = c.curso.id),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: PasarLista(
                    key: ValueKey(actual.curso.id),
                    datos: actual,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Muestra el colegio activo y permite cambiarlo (es el mismo de Mis cursos).
class _SelectorColegio extends StatelessWidget {
  const _SelectorColegio();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Colegio>>(
      stream: db.verColegios(),
      builder: (context, snapCol) => StreamBuilder<String?>(
        stream: db.verAjuste('colegio_activo'),
        builder: (context, snapAct) {
          final colegios = snapCol.data ?? [];
          if (colegios.length < 2) return const SizedBox.shrink();
          final activo = colegios.firstWhere(
            (c) => c.id.toString() == snapAct.data,
            orElse: () => colegios.first,
          );
          return PopupMenuButton<int>(
            tooltip: 'Cambiar de colegio',
            color: Colors.white,
            position: PopupMenuPosition.under,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (id) =>
                db.guardarAjuste('colegio_activo', id.toString()),
            itemBuilder: (_) => [
              for (final c in colegios)
                PopupMenuItem(value: c.id, child: Text(c.nombre)),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: KipuColores.moradoClaro,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(
                      activo.nombre,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: KipuColores.moradoOscuro,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  KipuIcon(
                    KipuIcono.abajo,
                    size: 18,
                    color: KipuColores.moradoOscuro,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

const _justif = Color(0xFF6C7BD9);
const _linea = Color(0xFFECEDF4);
const _motivos = [
  'Salud',
  'Cita médica',
  'Viaje',
  'Trámite',
  'Problema familiar',
  'Sin aviso',
  'Otro',
];

/// Datos del curso que necesitan las dos pestañas.
class _Contexto {
  final CursoConColegio datos;
  final ColoresRegistro colores;
  final List<Periodo> periodos;
  final int periodo;
  final List<Estudiante> estudiantes;
  const _Contexto(
    this.datos,
    this.colores,
    this.periodos,
    this.periodo,
    this.estudiantes,
  );
  Color get base => colores.base;
}

/// Lista de un curso. Pestaña Hoy para pasar lista y Historial con la tabla
/// del periodo. Se usa en la pestaña Asistencia y desde el registro.
class PasarLista extends StatefulWidget {
  final CursoConColegio datos;
  const PasarLista({super.key, required this.datos});

  @override
  State<PasarLista> createState() => _PasarListaState();
}

class _PasarListaState extends State<PasarLista> {
  late final _colegios = db.verColegios();
  late final _propios = db.verColoresRegistro(widget.datos.curso.id);
  late final _config = db.verAnioActivo().asyncExpand(db.verConfigAcademica);
  late final _estudiantes = db.verEstudiantes(widget.datos.curso.id);
  var _pestana = 0;
  int? _periodoHistorial;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Colegio>>(
      stream: _colegios,
      builder: (context, sc) => StreamBuilder<Map<String, dynamic>?>(
        stream: _propios,
        builder: (context, sp) => StreamBuilder<ConfigAcademica>(
          stream: _config,
          builder: (context, sconf) => StreamBuilder<List<Estudiante>>(
            stream: _estudiantes,
            builder: (context, se) {
              if (!sc.hasData || !se.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              var colores = ColoresRegistro.delColegio(
                colorColegio(sc.data!, widget.datos.colegio.id),
              );
              if (sp.data != null) colores = colores.con(sp.data!);
              final periodos = sconf.data?.periodos ?? periodosDe('bimestre');
              final actual = sconf.data?.periodoActual(DateTime.now()) ?? 1;
              final ctx = _Contexto(
                widget.datos,
                colores,
                periodos,
                (_periodoHistorial ?? actual).clamp(1, periodos.length),
                [...se.data!]
                  ..sort((a, b) => claveOrden(a).compareTo(claveOrden(b))),
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: _Segmentos(
                          opciones: const ['Hoy', 'Historial'],
                          valor: _pestana,
                          onCambio: (i) => setState(() => _pestana = i),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _pestana == 0
                        ? _Hoy(ctx: ctx)
                        : _Historial(
                            ctx: ctx,
                            onPeriodo: (p) =>
                                setState(() => _periodoHistorial = p),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Segmentos extends StatelessWidget {
  final List<String> opciones;
  final int valor;
  final ValueChanged<int> onCambio;
  const _Segmentos({
    required this.opciones,
    required this.valor,
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
        for (var i = 0; i < opciones.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => onCambio(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: i == valor ? KipuColores.tinta : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  opciones[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: i == valor ? Colors.white : KipuColores.gris,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

// ───────────────────────────── Hoy ─────────────────────────────

class _Hoy extends StatefulWidget {
  final _Contexto ctx;
  const _Hoy({required this.ctx});

  @override
  State<_Hoy> createState() => _HoyState();
}

class _HoyState extends State<_Hoy> {
  DateTime _fecha = DateUtils.dateOnly(DateTime.now());
  late Stream<Map<int, Asistencia>> _marcas = _abrir();
  // null: aún no se decide; al abrir un día ya completo se muestra condensado.
  bool? _condensado;

  Stream<Map<int, Asistencia>> _abrir() =>
      db.verAsistenciaDelDia(widget.ctx.datos.curso.id, fechaClave(_fecha));

  void _irA(DateTime f) => setState(() {
    _fecha = DateUtils.dateOnly(f);
    _marcas = _abrir();
    _condensado = null;
  });

  Future<void> _elegirFecha() async {
    final f = await elegirFecha(
      context,
      icono: KipuIcono.calendario,
      titulo: 'Día de la asistencia',
      anio: _fecha.year,
      fecha: fechaClave(_fecha),
    );
    if (f != null) _irA(DateTime.parse(f));
  }

  int? _periodoDe(String clave) {
    final ps = widget.ctx.periodos;
    for (var i = 0; i < ps.length; i++) {
      final p = ps[i];
      if (p.inicio != null &&
          p.fin != null &&
          clave.compareTo(p.inicio!) >= 0 &&
          clave.compareTo(p.fin!) <= 0) {
        return i + 1;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ctx = widget.ctx;
    final clave = fechaClave(_fecha);
    final per = _periodoDe(clave);
    final lista = [
      for (final e in ctx.estudiantes)
        if (per == null ? e.hasta == null : estaEnPeriodo(e, per)) e,
    ];
    final texto = DateFormat("EEEE d 'de' MMMM", 'es_PE').format(_fecha);
    return StreamBuilder<Map<int, Asistencia>>(
      stream: _marcas,
      builder: (context, snap) {
        final marcas = snap.data ?? const <int, Asistencia>{};
        final completo =
            lista.isNotEmpty && lista.every((e) => marcas.containsKey(e.id));
        if (snap.hasData && _condensado == null) _condensado = completo;
        final condensado = (_condensado ?? false) && completo;
        final cuenta = <String, int>{};
        for (final e in lista) {
          final m = marcas[e.id]?.estado;
          if (m != null) cuenta[m] = (cuenta[m] ?? 0) + 1;
        }
        final cabecera = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: Color.lerp(ctx.base, Colors.white, .88),
                    borderRadius: BorderRadius.circular(13),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(13),
                      onTap: _elegirFecha,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            KipuIcon(
                              KipuIcono.calendario,
                              size: 19,
                              color: ctx.base,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                [
                                  texto[0].toUpperCase() + texto.substring(1),
                                  if (per != null) ctx.periodos[per - 1].nombre,
                                ].join(' · '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color.lerp(ctx.base, Colors.black, .2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _BotonCuadro(
                  KipuIcono.izquierda,
                  ctx.base,
                  () => _irA(_fecha.subtract(const Duration(days: 1))),
                ),
                const SizedBox(width: 6),
                _BotonCuadro(
                  KipuIcono.derecha,
                  ctx.base,
                  () => _irA(_fecha.add(const Duration(days: 1))),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final (i, e) in 'PTFJ'.split('').indexed) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    child: _Cuenta(
                      n: cuenta[e] ?? 0,
                      texto: _nombre(e, plural: true),
                      color: colorEstado(e, ctx.base),
                    ),
                  ),
                ],
              ],
            ),
          ],
        );

        Widget cuerpo;
        if (lista.isEmpty) {
          cuerpo = const Padding(
            padding: EdgeInsets.all(28),
            child: Text(
              'Este curso aún no tiene estudiantes en este periodo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: KipuColores.gris),
            ),
          );
        } else if (condensado) {
          final revisar = [
            for (final e in lista)
              if (marcas[e.id]!.estado != 'P' || marcas[e.id]!.nota != null) e,
          ];
          final asistieron = lista
              .where((e) => {'P', 'T'}.contains(marcas[e.id]!.estado))
              .length;
          cuerpo = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _Dona(
                      valores: [
                        for (final e in 'PTFJ'.split(''))
                          (cuenta[e] ?? 0, colorEstado(e, ctx.base)),
                      ],
                      centro: '${(asistieron * 100 / lista.length).round()}%',
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lista pasada',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            revisar.isEmpty
                                ? 'Asistieron los ${lista.length}. ¡Aula completa!'
                                : '$asistieron de ${lista.length} asistieron. '
                                      'Solo ves a los que tienen algo que revisar.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: KipuColores.gris,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (revisar.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 16, 6, 8),
                  child: Text(
                    'PARA REVISAR · ${revisar.length}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .4,
                      color: KipuColores.gris,
                    ),
                  ),
                ),
                for (final e in revisar)
                  _FilaRevisar(
                    estudiante: e,
                    marca: marcas[e.id]!,
                    base: ctx.base,
                    onTap: () => _nota(lista, lista.indexOf(e), marcas),
                  ),
              ],
            ],
          );
        } else {
          cuerpo = Column(
            children: [
              for (var i = 0; i < lista.length; i++)
                _FilaEstudiante(
                  numero: i + 1,
                  estudiante: lista[i],
                  marca: marcas[lista[i].id],
                  base: ctx.base,
                  onMarcar: (estado) =>
                      db.marcarAsistencia(lista[i].id, clave, estado),
                  onNota: () => _nota(lista, i, marcas),
                ),
            ],
          );
        }

        final sinMarcar = [
          for (final e in lista)
            if (!marcas.containsKey(e.id)) e.id,
        ];
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          cabecera,
                          const SizedBox(height: 12),
                          cuerpo,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (lista.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: _linea)),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Row(
                      children: condensado
                          ? [
                              Expanded(
                                child: _BotonPie(
                                  icono: KipuIcono.ojo,
                                  texto: 'Ver todos (${lista.length})',
                                  base: ctx.base,
                                  onTap: () =>
                                      setState(() => _condensado = false),
                                ),
                              ),
                            ]
                          : [
                              Expanded(
                                child: _BotonPie(
                                  icono: KipuIcono.check,
                                  texto: sinMarcar.isEmpty
                                      ? 'Todos marcados'
                                      : sinMarcar.length == lista.length
                                      ? 'Todos presentes'
                                      : 'Presentes los demás',
                                  base: ctx.base,
                                  onTap: sinMarcar.isEmpty
                                      ? null
                                      : () => db.marcarTodos(
                                          sinMarcar,
                                          clave,
                                          'P',
                                        ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _BotonPie(
                                  icono: KipuIcono.check,
                                  texto: 'Terminar',
                                  base: ctx.base,
                                  lleno: true,
                                  onTap: () async {
                                    if (sinMarcar.isNotEmpty) {
                                      await db.marcarTodos(
                                        sinMarcar,
                                        clave,
                                        'P',
                                      );
                                    }
                                    setState(() => _condensado = true);
                                  },
                                ),
                              ),
                            ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _nota(
    List<Estudiante> lista,
    int i,
    Map<int, Asistencia> marcas,
  ) => notaAsistencia(
    context,
    estudiantes: lista,
    inicio: i,
    fecha: fechaClave(_fecha),
    base: widget.ctx.base,
  );
}

String _nombre(String e, {bool plural = false}) => switch (e) {
  'P' => plural ? 'Presentes' : 'Presente',
  'T' => plural ? 'Tardanzas' : 'Tarde',
  'F' => plural ? 'Faltas' : 'Falta',
  _ => plural ? 'Justificadas' : 'Justificada',
};

KipuIcono _icono(String e) => switch (e) {
  'P' => KipuIcono.check,
  'T' => KipuIcono.horario,
  'F' => KipuIcono.cerrar,
  _ => KipuIcono.apuntes,
};

class _Cuenta extends StatelessWidget {
  final int n;
  final String texto;
  final Color color;
  const _Cuenta({required this.n, required this.texto, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: Color.lerp(color, Colors.white, .88),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Column(
      children: [
        Text(
          '$n',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: Color.lerp(color, Colors.black, .15),
          ),
        ),
        FittedBox(
          child: Text(
            texto,
            style: const TextStyle(fontSize: 11.5, color: KipuColores.gris),
          ),
        ),
      ],
    ),
  );
}

class _BotonCuadro extends StatelessWidget {
  final KipuIcono icono;
  final Color color;
  final VoidCallback onTap;
  const _BotonCuadro(this.icono, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Center(child: KipuIcon(icono, size: 18, color: color)),
      ),
    ),
  );
}

class _BotonPie extends StatelessWidget {
  final KipuIcono icono;
  final String texto;
  final Color base;
  final bool lleno;
  final VoidCallback? onTap;
  const _BotonPie({
    required this.icono,
    required this.texto,
    required this.base,
    this.lleno = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tinta = lleno ? Colors.white : base;
    return Opacity(
      opacity: onTap == null ? .5 : 1,
      child: Material(
        color: lleno ? base : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: lleno
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFD9DAE6), width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KipuIcon(icono, size: 18, color: tinta),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    texto,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: lleno ? Colors.white : KipuColores.tinta,
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
}

class _FilaEstudiante extends StatelessWidget {
  final int numero;
  final Estudiante estudiante;
  final Asistencia? marca;
  final Color base;
  final ValueChanged<String?> onMarcar;
  final VoidCallback onNota;

  const _FilaEstudiante({
    required this.numero,
    required this.estudiante,
    required this.marca,
    required this.base,
    required this.onMarcar,
    required this.onNota,
  });

  @override
  Widget build(BuildContext context) {
    final estado = marca?.estado;
    final conNota = marca?.nota != null || marca?.motivo != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onLongPress: onNota,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  child: Text(
                    '$numero',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: KipuColores.gris,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                AvatarEstudiante(estudiante, tam: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tituloNombre(estudiante.apellidos),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                      Text(
                        conNota
                            ? [
                                marca!.motivo,
                                marca!.nota,
                              ].whereType<String>().join(' · ')
                            : estudiante.nombres,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: conNota ? base : KipuColores.gris,
                        ),
                      ),
                    ],
                  ),
                ),
                for (final e in 'PTFJ'.split(''))
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: _BotonEstado(
                      codigo: e,
                      color: colorEstado(e, base),
                      activo: estado == e,
                      // Tocar el estado ya marcado lo desmarca.
                      onTap: () => onMarcar(estado == e ? null : e),
                    ),
                  ),
                IconButton(
                  tooltip: 'Nota',
                  visualDensity: VisualDensity.compact,
                  onPressed: onNota,
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      KipuIcon(
                        KipuIcono.apuntes,
                        size: 20,
                        color: conNota ? base : const Color(0xFFB5B2C4),
                      ),
                      if (conNota)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: base,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
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
  }
}

class _BotonEstado extends StatelessWidget {
  final String codigo;
  final Color color;
  final bool activo;
  final VoidCallback onTap;
  const _BotonEstado({
    required this.codigo,
    required this.color,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
    message: _nombre(codigo),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 32,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: activo ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: activo ? color : Color.lerp(color, Colors.white, .6)!,
            width: 1.5,
          ),
        ),
        child: Text(
          codigo,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: activo ? Colors.white : color,
          ),
        ),
      ),
    ),
  );
}

class _FilaRevisar extends StatelessWidget {
  final Estudiante estudiante;
  final Asistencia marca;
  final Color base;
  final VoidCallback onTap;
  const _FilaRevisar({
    required this.estudiante,
    required this.marca,
    required this.base,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = colorEstado(marca.estado, base);
    final detalle = [marca.motivo, marca.nota].whereType<String>().join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 11, 8, 11),
            child: Row(
              children: [
                AvatarEstudiante(estudiante, tam: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${tituloNombre(estudiante.apellidos)}, ${estudiante.nombres}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Color.lerp(c, Colors.white, .85),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                KipuIcon(
                                  _icono(marca.estado),
                                  size: 13,
                                  color: Color.lerp(c, Colors.black, .2),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _nombre(marca.estado),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color.lerp(c, Colors.black, .2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              detalle.isEmpty ? '+ Agregar nota' : detalle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: detalle.isEmpty
                                    ? base
                                    : KipuColores.gris,
                                fontWeight: detalle.isEmpty
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                KipuIcon(KipuIcono.editar, size: 18, color: base),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Dona extends StatelessWidget {
  final List<(int, Color)> valores;
  final String centro;
  const _Dona({required this.valores, required this.centro});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 66,
    height: 66,
    child: CustomPaint(
      painter: _PintaDona(valores),
      child: Center(
        child: Text(
          centro,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    ),
  );
}

class _PintaDona extends CustomPainter {
  final List<(int, Color)> valores;
  _PintaDona(this.valores);

  @override
  void paint(Canvas canvas, Size size) {
    const g = 8.0;
    final arco = (Offset.zero & size).deflate(g / 2);
    final lapiz = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = g;
    final total = valores.fold(0, (a, v) => a + v.$1);
    if (total == 0) {
      canvas.drawArc(arco, 0, 2 * pi, false, lapiz..color = _linea);
      return;
    }
    var inicio = -pi / 2;
    for (final (n, c) in valores) {
      if (n == 0) continue;
      final b = 2 * pi * n / total;
      canvas.drawArc(arco, inicio, b, false, lapiz..color = c);
      inicio += b;
    }
  }

  @override
  bool shouldRepaint(_PintaDona old) => true;
}

// ───────────────────────── Nota de la asistencia ─────────────────────────

/// Estado, motivo y nota de una asistencia, con Anterior y Siguiente para
/// seguir con los demás estudiantes sin cerrar la ventana.
Future<void> notaAsistencia(
  BuildContext context, {
  required List<Estudiante> estudiantes,
  required int inicio,
  required String fecha,
  required Color base,
}) => showDialog(
  context: context,
  barrierColor: const Color(0x661F1B2E),
  builder: (_) => Dialog(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: _NotaAsistencia(
        estudiantes: estudiantes,
        inicio: inicio,
        fecha: fecha,
        base: base,
      ),
    ),
  ),
);

class _NotaAsistencia extends StatefulWidget {
  final List<Estudiante> estudiantes;
  final int inicio;
  final String fecha;
  final Color base;
  const _NotaAsistencia({
    required this.estudiantes,
    required this.inicio,
    required this.fecha,
    required this.base,
  });

  @override
  State<_NotaAsistencia> createState() => _NotaAsistenciaState();
}

class _NotaAsistenciaState extends State<_NotaAsistencia> {
  late int _i = widget.inicio;
  final _nota = TextEditingController();
  String? _estado;
  String? _motivo;
  bool _cargado = false;

  Estudiante get _e => widget.estudiantes[_i];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final a = (await db
        .verAsistenciaDelDia(_e.cursoId, widget.fecha)
        .first)[_e.id];
    if (!mounted) return;
    setState(() {
      _estado = a?.estado;
      _motivo = a?.motivo;
      _nota.text = a?.nota ?? '';
      _cargado = true;
    });
  }

  Future<void> _guardar() async {
    final n = _nota.text.trim();
    if (_estado == null) {
      await db.marcarAsistencia(_e.id, widget.fecha, null);
    } else {
      await db.guardarAsistencia(
        _e.id,
        widget.fecha,
        _estado!,
        motivo: _motivo,
        nota: n.isEmpty ? null : n,
      );
    }
  }

  Future<void> _ir(int d) async {
    await _guardar();
    setState(() {
      _i += d;
      _cargado = false;
    });
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.base;
    final dia = DateFormat(
      "EEEE d 'de' MMMM",
      'es_PE',
    ).format(DateTime.parse(widget.fecha));
    final hayMas = _i < widget.estudiantes.length - 1;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AvatarEstudiante(_e, tam: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${tituloNombre(_e.apellidos)}, ${_e.nombres}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'N.° ${_i + 1} · $dia',
                      style: const TextStyle(
                        fontSize: 13,
                        color: KipuColores.gris,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: KipuColores.fondo,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.pop(context),
                  child: const SizedBox(
                    width: 36,
                    height: 36,
                    child: Center(
                      child: KipuIcon(
                        KipuIcono.cerrar,
                        size: 18,
                        color: KipuColores.gris,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Opacity(
            opacity: _cargado ? 1 : .4,
            child: Row(
              children: [
                for (final (i, e) in 'PTFJ'.split('').indexed) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _EstadoGrande(
                      codigo: e,
                      color: colorEstado(e, base),
                      activo: _estado == e,
                      onTap: () =>
                          setState(() => _estado = _estado == e ? null : e),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'MOTIVO',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              letterSpacing: .4,
              color: KipuColores.gris,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final m in _motivos)
                Material(
                  color: m == _motivo ? base : KipuColores.fondo,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () =>
                        setState(() => _motivo = m == _motivo ? null : m),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      child: Text(
                        m,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: m == _motivo
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: m == _motivo ? Colors.white : KipuColores.gris,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            decoration: BoxDecoration(
              color: KipuColores.fondo,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nota',
                  style: TextStyle(fontSize: 11.5, color: KipuColores.gris),
                ),
                TextField(
                  controller: _nota,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor: base,
                  style: const TextStyle(fontSize: 14.5),
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    filled: false,
                    contentPadding: EdgeInsets.only(top: 4),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: 'Ej.: avisó la mamá, trajo certificado…',
                    hintStyle: TextStyle(color: Color(0xFFA3A1B3)),
                  ),
                ),
              ],
            ),
          ),
          if (_estado == 'F' || _estado == 'J') ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
              decoration: BoxDecoration(
                color: Color.lerp(_justif, Colors.white, .92),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const KipuIcon(KipuIcono.apuntes, size: 20, color: _justif),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Presentó justificación',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'La falta pasa a Justificada',
                          style: TextStyle(
                            fontSize: 12,
                            color: KipuColores.gris,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _estado == 'J',
                    activeThumbColor: Colors.white,
                    activeTrackColor: _justif,
                    onChanged: (v) => setState(() => _estado = v ? 'J' : 'F'),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: _i > 0 && _cargado ? () => _ir(-1) : null,
                  child: KipuIcon(
                    KipuIcono.izquierda,
                    size: 18,
                    color: _i > 0 ? base : const Color(0xFFB5B2C4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    foregroundColor: KipuColores.tinta,
                  ),
                  onPressed: hayMas && _cargado ? () => _ir(1) : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Siguiente'),
                      const SizedBox(width: 4),
                      KipuIcon(KipuIcono.derecha, size: 16, color: base),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    backgroundColor: base,
                  ),
                  onPressed: _cargado
                      ? () async {
                          await _guardar();
                          if (context.mounted) Navigator.pop(context);
                        }
                      : null,
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EstadoGrande extends StatelessWidget {
  final String codigo;
  final Color color;
  final bool activo;
  final VoidCallback onTap;
  const _EstadoGrande({
    required this.codigo,
    required this.color,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: activo ? color : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: activo ? color : _linea, width: 1.5),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            KipuIcon(
              _icono(codigo),
              size: 22,
              color: activo ? Colors.white : color,
            ),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                _nombre(codigo),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: activo ? Colors.white : KipuColores.tinta,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ───────────────────────────── Historial ─────────────────────────────

class _Historial extends StatefulWidget {
  final _Contexto ctx;
  final ValueChanged<int> onPeriodo;
  const _Historial({required this.ctx, required this.onPeriodo});

  @override
  State<_Historial> createState() => _HistorialState();
}

class _HistorialState extends State<_Historial> {
  late int _periodo = widget.ctx.periodo;
  late Stream<List<Asistencia>> _datos = _abrir();
  var _filtro = 'todos';

  Periodo get _p => widget.ctx.periodos[_periodo - 1];

  Stream<List<Asistencia>> _abrir() => db.verAsistenciaCurso(
    widget.ctx.datos.curso.id,
    widget.ctx.periodos[_periodo - 1].inicio ?? '0000',
    widget.ctx.periodos[_periodo - 1].fin ?? '9999',
  );

  void _cambiar(int p) {
    setState(() {
      _periodo = p;
      _datos = _abrir();
    });
    widget.onPeriodo(p);
  }

  Future<void> _exportar(
    String tipo,
    List<Estudiante> lista,
    List<String> fechas,
    Map<(int, String), Asistencia> marcas,
  ) async {
    final ctx = widget.ctx;
    final r = ReporteAsistencia(
      colegio: ctx.datos.colegio.nombre,
      curso: ctx.datos.curso,
      periodo: _p.nombre,
      desde: _p.inicio,
      hasta: _p.fin,
      docente: await db.leerAjuste('nombre') ?? '',
      color: ctx.base,
      estudiantes: lista,
      fechas: fechas,
      marcas: marcas,
    );
    if (tipo == 'pdf') {
      await FilePicker.saveFile(
        fileName: '${r.archivo}.pdf',
        bytes: await pdfAsistencia(r),
        mimeType: 'application/pdf',
      );
    } else {
      await FilePicker.saveFile(
        fileName: '${r.archivo}.xlsx',
        bytes: excelAsistencia(r),
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctx = widget.ctx;
    final c = ctx.colores;
    final ancho = MediaQuery.sizeOf(context).width >= 700;
    final todos = [
      for (final e in ctx.estudiantes)
        if (estaEnPeriodo(e, _periodo)) e,
    ];
    return StreamBuilder<List<Asistencia>>(
      stream: _datos,
      builder: (context, snap) {
        final filas = snap.data ?? const <Asistencia>[];
        final marcas = {for (final a in filas) (a.estudianteId, a.fecha): a};
        final fechas = {for (final a in filas) a.fecha}.toList()..sort();
        bool tiene(Estudiante e, bool Function(Asistencia) f) => fechas.any(
          (d) => marcas[(e.id, d)] != null && f(marcas[(e.id, d)]!),
        );
        final lista = switch (_filtro) {
          'faltas' => todos.where(
            (e) => tiene(e, (a) => a.estado == 'F' || a.estado == 'J'),
          ),
          'tarde' => todos.where((e) => tiene(e, (a) => a.estado == 'T')),
          'notas' => todos.where(
            (e) => tiene(e, (a) => (a.nota ?? a.motivo) != null),
          ),
          _ => todos,
        }.toList();

        Widget filtro(String id, String texto) => Padding(
          padding: const EdgeInsets.only(right: 6),
          child: ChoiceChip(
            label: Text(texto),
            selected: _filtro == id,
            showCheckmark: false,
            selectedColor: KipuColores.tinta,
            backgroundColor: Colors.white,
            side: BorderSide.none,
            labelStyle: TextStyle(
              fontSize: 13,
              color: _filtro == id ? Colors.white : KipuColores.gris,
              fontWeight: _filtro == id ? FontWeight.w600 : FontWeight.w400,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
            onSelected: (_) => setState(() => _filtro = id),
          ),
        );

        final barra = Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var i = 1; i <= ctx.periodos.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(
                                  i == _periodo
                                      ? ctx.periodos[i - 1].nombre
                                      : '$i.°',
                                ),
                                selected: i == _periodo,
                                showCheckmark: false,
                                selectedColor: ctx.base,
                                backgroundColor: Colors.white,
                                side: BorderSide.none,
                                labelStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: i == _periodo
                                      ? Colors.white
                                      : KipuColores.gris,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                onSelected: (_) => _cambiar(i),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Exportar',
                    color: Colors.white,
                    position: PopupMenuPosition.under,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    enabled: fechas.isNotEmpty,
                    onSelected: (t) => _exportar(t, todos, fechas, marcas),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'pdf', child: Text('Descargar PDF')),
                      PopupMenuItem(
                        value: 'excel',
                        child: Text('Descargar Excel'),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          KipuIcon(KipuIcono.abajo, size: 18, color: ctx.base),
                          const SizedBox(width: 6),
                          Text(
                            ancho ? 'PDF / Excel' : 'Exportar',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    filtro('todos', 'Todos'),
                    filtro('faltas', 'Con faltas'),
                    filtro('tarde', 'Con tardanzas'),
                    filtro('notas', 'Con notas'),
                  ],
                ),
              ),
            ],
          ),
        );

        if (fechas.isEmpty) {
          return Column(
            children: [
              barra,
              const Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Text(
                      'Aún no hay asistencia en este periodo.',
                      style: TextStyle(color: KipuColores.gris),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        const filaH = 48.0, cabH = 54.0;
        final nombreW = ancho ? 250.0 : 150.0;
        const diaW = 46.0, resW = 46.0;

        Widget celda(Estudiante e, String d, int fila) {
          final a = marcas[(e.id, d)];
          final conNota = a != null && (a.nota ?? a.motivo) != null;
          Widget dentro;
          if (a == null) {
            dentro = const Text(
              '·',
              style: TextStyle(color: Color(0xFFC9C7D6)),
            );
          } else if (a.estado == 'P') {
            dentro = KipuIcon(KipuIcono.check, size: 20, color: ctx.base);
          } else {
            final col = colorEstado(a.estado, ctx.base);
            dentro = Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color.lerp(col, Colors.white, .84),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                a.estado,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color.lerp(col, Colors.black, .2),
                ),
              ),
            );
          }
          final cuerpo = InkWell(
            onTap: () => notaAsistencia(
              context,
              estudiantes: lista,
              inicio: lista.indexOf(e),
              fecha: d,
              base: ctx.base,
            ),
            child: Container(
              width: diaW,
              height: filaH,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: _linea)),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  dentro,
                  if (conNota)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: KipuColores.tinta,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
          return conNota
              ? Tooltip(
                  message: [
                    _nombre(a.estado),
                    a.motivo,
                    a.nota,
                  ].whereType<String>().join(' · '),
                  child: cuerpo,
                )
              : cuerpo;
        }

        final nombres = Container(
          width: nombreW,
          color: c.nombres,
          child: Column(
            children: [
              Container(
                height: cabH,
                color: c.cabecera,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 14),
                child: Text(
                  'Estudiante',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: c.tintaCabecera,
                  ),
                ),
              ),
              for (var i = 0; i < lista.length; i++)
                Container(
                  height: filaH,
                  padding: const EdgeInsets.only(left: 8, right: 6),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: _linea)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        child: Text(
                          '${i + 1}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: KipuColores.gris,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (ancho) ...[
                        AvatarEstudiante(lista[i], tam: 30),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: ancho
                                    ? tituloNombre(lista[i].apellidos)
                                    : apellidoCorto(lista[i].apellidos),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: ancho
                                    ? ', ${lista[i].nombres.split(' ').first}'
                                    : '\n${lista[i].nombres.split(' ').first}',
                                style: const TextStyle(color: KipuColores.gris),
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, height: 1.2),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );

        final dias = Row(
          children: [
            for (final d in fechas)
              Column(
                children: [
                  Container(
                    width: diaW,
                    height: cabH,
                    color: c.cabecera,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          d.substring(8),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: c.tintaCabecera,
                          ),
                        ),
                        Text(
                          DateFormat(
                            'MMM',
                            'es_PE',
                          ).format(DateTime.parse(d)).replaceAll('.', ''),
                          style: const TextStyle(
                            fontSize: 11,
                            color: KipuColores.gris,
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (var i = 0; i < lista.length; i++)
                    Container(
                      color: Colors.white,
                      child: celda(lista[i], d, i),
                    ),
                ],
              ),
          ],
        );

        Widget resumen(
          String t,
          String Function(Estudiante) v,
          Color? Function(Estudiante) color,
        ) => Column(
          children: [
            Container(
              width: resW,
              height: cabH,
              color: c.calculadas,
              alignment: Alignment.center,
              child: Text(
                t,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            for (final e in lista)
              Container(
                width: resW,
                height: filaH,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.celdaCalculada,
                  border: const Border(top: BorderSide(color: _linea)),
                ),
                child: Text(
                  v(e),
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: color(e) ?? KipuColores.tinta,
                  ),
                ),
              ),
          ],
        );
        ({int f, int t, int? pct}) cuenta(Estudiante e) {
          var f = 0, t = 0, ok = 0, total = 0;
          for (final d in fechas) {
            final m = marcas[(e.id, d)]?.estado;
            if (m == null) continue;
            total++;
            if (m == 'F' || m == 'J') f++;
            if (m == 'T') t++;
            if (m == 'P' || m == 'T') ok++;
          }
          return (
            f: f,
            t: t,
            pct: total == 0 ? null : (ok * 100 / total).round(),
          );
        }

        final calc = {for (final e in lista) e.id: cuenta(e)};
        final res = Row(
          children: [
            resumen(
              '%',
              (e) => calc[e.id]!.pct == null ? '—' : '${calc[e.id]!.pct}',
              (e) => (calc[e.id]!.pct ?? 100) < 80
                  ? const Color(0xFFC0445A)
                  : null,
            ),
            resumen(
              'F',
              (e) => '${calc[e.id]!.f}',
              (e) => calc[e.id]!.f == 0
                  ? const Color(0xFFB5B2C4)
                  : const Color(0xFFC0445A),
            ),
            resumen(
              'T',
              (e) => '${calc[e.id]!.t}',
              (e) => calc[e.id]!.t == 0
                  ? const Color(0xFFB5B2C4)
                  : const Color(0xFFB9771A),
            ),
          ],
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            barra,
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                // La tabla mide lo que sus columnas; si no entran, las
                // fechas se deslizan y el resumen queda fijo a la derecha.
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SingleChildScrollView(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          nombres,
                          Flexible(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: dias,
                            ),
                          ),
                          res,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
