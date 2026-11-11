import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List;
import 'package:url_launcher/url_launcher.dart';

import '../data/academico.dart';
import '../data/database.dart';
import '../data/registro.dart' show tituloNombre;
import '../data/reportes.dart';
import '../main.dart' show db;
import '../theme.dart';
import '../widgets/graficos.dart';
import '../widgets/kipu_icono.dart';
import 'cursos.dart' show colorColegio;
import 'diario.dart' show ElegirCurso, fechaCorta;
import 'diario_estudiantes.dart' show TarjetaAnecdota, editarReunion;
import 'estudiantes.dart' show AvatarEstudiante;
import 'reportes_exportar.dart';

const _verde = Color(0xFF16A37F);
const _rojo = Color(0xFFC2334A);
const _naranja = Color(0xFFE07B1F);
const _gris2 = Color(0xFF8E8AA0);

String _nombre(Estudiante e) =>
    '${tituloNombre(e.apellidos)}, ${tituloNombre(e.nombres).split(' ').first}';

enum _Vista { resumen, periodos, evaluaciones, asistencia, estudiante, apoyo }

/// Reportes: notas por periodo y anuales, evaluaciones, asistencia, informe
/// por estudiante y quiénes necesitan apoyo; con PDF y Excel.
class PantallaReportes extends StatefulWidget {
  const PantallaReportes({super.key});

  @override
  State<PantallaReportes> createState() => _PantallaReportesState();
}

class _PantallaReportesState extends State<PantallaReportes> {
  var _vista = _Vista.resumen;
  int? _colegio;
  int? _curso;
  int? _cursoColegio;
  int? _periodo = -1; // -1 = aún no elegido (se pone el actual)
  int? _estudiante;
  String _clave = '';
  Future<List<DatosCurso>>? _carga;
  final _anio = db.verAnioActivo();
  final _cursos = db.verCursos();
  final _colegios = db.verColegios();

  static const _claveColegio = 'reportes_colegio';

  @override
  void initState() {
    super.initState();
    db.leerAjuste(_claveColegio).then((v) {
      if (mounted && v != null) setState(() => _colegio = int.tryParse(v));
    });
  }

  Future<List<DatosCurso>> _cargar(
    List<CursoConColegio> cursos,
    ConfigAcademica cfg,
  ) async {
    final r = <DatosCurso>[];
    // De a uno: cada curso recalcula sus promedios antes de leerlos.
    for (final c in cursos) {
      r.add(await db.datosCurso(c, cfg));
    }
    return r;
  }

  void _recargar() => setState(() => _clave = '');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _anio,
      builder: (context, a) {
        final anio = a.data ?? DateTime.now().year;
        return StreamBuilder<ConfigAcademica>(
          stream: db.verConfigAcademica(anio),
          builder: (context, cf) => StreamBuilder<List<Colegio>>(
            stream: _colegios,
            builder: (context, co) => StreamBuilder<List<CursoConColegio>>(
              stream: _cursos,
              builder: (context, cu) {
                final cfg = cf.data;
                final colegios = co.data ?? const <Colegio>[];
                final todos = cu.data;
                if (cfg == null || todos == null) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return _pantalla(anio, cfg, colegios, todos);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _pantalla(
    int anio,
    ConfigAcademica cfg,
    List<Colegio> colegios,
    List<CursoConColegio> todos,
  ) {
    final colegio = colegios.any((c) => c.id == _colegio) ? _colegio : null;
    final curso =
        colegio == null || _cursoColegio == colegio ? _curso : null;
    final elegidos = [
      for (final c in todos)
        if ((colegio == null || c.colegio.id == colegio) &&
            (curso == null || c.curso.id == curso))
          c,
    ];
    if (_periodo == -1) {
      // Por defecto, el periodo en curso.
      _periodo = cfg.periodoActual(DateTime.now()) ?? cfg.periodos.length;
      if (_periodo == 0) _periodo = null;
    }
    final clave = '$anio|${[for (final c in elegidos) c.curso.id].join(',')}';
    if (clave != _clave) {
      _clave = clave;
      _carga = _cargar(elegidos, cfg);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _recargar,
            icon: KipuIcon(KipuIcono.refrescar, color: KipuColores.tinta),
          ),
          FutureBuilder<List<DatosCurso>>(
            future: _carga,
            builder: (context, s) => PopupMenuButton<String>(
              tooltip: 'Descargar',
              enabled: s.hasData && s.data!.isNotEmpty,
              icon: KipuIcon(KipuIcono.descargar, color: KipuColores.tinta),
              onSelected: (f) => _descargar(f, s.data!, cfg, anio),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'pdf', child: Text('Reporte de notas (PDF)')),
                PopupMenuItem(value: 'xlsx', child: Text('Reporte de notas (Excel)')),
              ],
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              _Filtros(
                colegios: colegios,
                colegio: colegio,
                curso: curso,
                periodo: _periodo,
                periodos: cfg.periodos,
                onColegio: (v) {
                  setState(() => _colegio = v);
                  db.guardarAjuste(_claveColegio, v?.toString() ?? '');
                },
                onCurso: (v) => setState(() {
                  _curso = v;
                  _estudiante = null;
                }),
                onCursoColegio: (c) => _cursoColegio = c,
                onPeriodo: (v) => setState(() => _periodo = v),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: _Pestanas(
                  actual: _vista,
                  onCambio: (v) => setState(() => _vista = v),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<DatosCurso>>(
                  future: _carga,
                  builder: (context, s) {
                    if (s.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text('No se pudo preparar el reporte: ${s.error}'),
                        ),
                      );
                    }
                    if (!s.hasData) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text(
                              'Calculando promedios…',
                              style: TextStyle(color: KipuColores.gris),
                            ),
                          ],
                        ),
                      );
                    }
                    final datos = s.data!;
                    if (datos.isEmpty) {
                      return const _Vacio(
                        'Todavía no hay cursos. Crea tus cursos y registra '
                        'notas para ver los reportes.',
                      );
                    }
                    final ctx = _Ctx(
                      datos: datos,
                      periodo: _periodo,
                      anio: anio,
                      periodos: cfg.periodos,
                      colegios: colegios,
                    );
                    return switch (_vista) {
                      _Vista.resumen => _Resumen(ctx),
                      _Vista.periodos => _Periodos(ctx),
                      _Vista.evaluaciones => _Evaluaciones(ctx),
                      _Vista.asistencia => _Asistencia(ctx),
                      _Vista.estudiante => _Estudiante(
                        ctx,
                        estudiante: _estudiante,
                        onEstudiante: (id) => setState(() => _estudiante = id),
                      ),
                      _Vista.apoyo => _Apoyo(
                        ctx,
                        onVer: (r) => setState(() {
                          _curso = r.curso.curso.curso.id;
                          _cursoColegio = r.curso.curso.colegio.id;
                          _estudiante = r.estudiante.id;
                          _vista = _Vista.estudiante;
                        }),
                      ),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InfoReporte _info(ConfigAcademica cfg, int anio) => InfoReporte(
    docente: '',
    alcance: _periodo == null || _periodo! > cfg.periodos.length
        ? 'Año $anio'
        : '${cfg.periodos[_periodo! - 1].nombre} $anio',
    anio: anio,
    periodo: _periodo,
    color: KipuColores.morado,
  );

  Future<void> _descargar(
    String formato,
    List<DatosCurso> datos,
    ConfigAcademica cfg,
    int anio,
  ) async {
    final docente = await db.leerAjuste('nombre') ?? '';
    final base = _info(cfg, anio);
    final info = InfoReporte(
      docente: docente,
      alcance: base.alcance,
      anio: anio,
      periodo: base.periodo,
      color: base.color,
    );
    final nombre =
        'Reporte de notas ${info.alcance}${datos.length == 1 ? ' ${datos.first.nombre}' : ''}'
            .replaceAll(RegExp(r'[\\/:*?"<>|·]'), '')
            .replaceAll(RegExp(r'\s+'), ' ');
    try {
      final (Uint8List bytes, String ext, String mime) = formato == 'pdf'
          ? (await pdfConsolidado(datos, info), 'pdf', 'application/pdf')
          : (
              excelConsolidado(datos, info),
              'xlsx',
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            );
      await FilePicker.saveFile(
        fileName: '$nombre.$ext',
        bytes: bytes,
        mimeType: mime,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo descargar: $e')),
      );
    }
  }
}

/// Lo que comparten las vistas.
class _Ctx {
  final List<DatosCurso> datos;
  final int? periodo;
  final int anio;
  final List<Periodo> periodos;
  final List<Colegio> colegios;
  const _Ctx({
    required this.datos,
    required this.periodo,
    required this.anio,
    required this.periodos,
    required this.colegios,
  });

  int? get anterior => periodo != null && periodo! > 1 ? periodo! - 1 : null;

  String get alcance => periodo == null || periodo! > periodos.length
      ? 'Año $anio'
      : periodos[periodo! - 1].nombre;

  List<double> notas(int? p) => [for (final d in datos) ...d.notas(p).values];

  bool get unCurso => datos.length == 1;
}

// ───────────────────────── Filtros ─────────────────────────

class _Filtros extends StatelessWidget {
  final List<Colegio> colegios;
  final int? colegio;
  final int? curso;
  final int? periodo;
  final List<Periodo> periodos;
  final ValueChanged<int?> onColegio;
  final ValueChanged<int?> onCurso;
  final ValueChanged<int?> onCursoColegio;
  final ValueChanged<int?> onPeriodo;
  const _Filtros({
    required this.colegios,
    required this.colegio,
    required this.curso,
    required this.periodo,
    required this.periodos,
    required this.onColegio,
    required this.onCurso,
    required this.onCursoColegio,
    required this.onPeriodo,
  });

  Widget _chip(String texto, bool activo, Color color, VoidCallback onTap,
          {bool punto = false}) =>
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Material(
          color: activo ? color : Colors.white,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (punto) ...[
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

  @override
  Widget build(BuildContext context) {
    final base = KipuColores.morado;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (colegios.length > 1)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _chip('Todos los colegios', colegio == null,
                      KipuColores.tinta, () => onColegio(null)),
                  for (final c in colegios)
                    _chip(
                      c.nombre,
                      colegio == c.id,
                      colorColegio(colegios, c.id),
                      () => onColegio(c.id),
                      punto: true,
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, c) {
              final cursoW = Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElegirCurso(
                  cursoId: curso,
                  colegioId: colegio,
                  vacio: 'Todos los cursos',
                  onCambio: onCurso,
                  onColegio: onCursoColegio,
                ),
              );
              final periodosW = SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final (i, p) in periodos.indexed)
                      _chip(
                        nombrePeriodoCorto(p.nombre, i + 1),
                        periodo == i + 1,
                        base,
                        () => onPeriodo(i + 1),
                      ),
                    _chip('Año', periodo == null, base, () => onPeriodo(null)),
                  ],
                ),
              );
              if (c.maxWidth >= 760) {
                return Row(
                  children: [
                    Expanded(child: cursoW),
                    const SizedBox(width: 12),
                    SizedBox(width: 360, child: periodosW),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [cursoW, const SizedBox(height: 8), periodosW],
              );
            },
          ),
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
    _Vista.resumen: ('Resumen', KipuIcono.reportes),
    _Vista.periodos: ('Por periodo', KipuIcono.promedio),
    _Vista.evaluaciones: ('Evaluaciones', KipuIcono.examen),
    _Vista.asistencia: ('Asistencia', KipuIcono.asistencia),
    _Vista.estudiante: ('Estudiante', KipuIcono.ficha),
    _Vista.apoyo: ('Necesitan apoyo', KipuIcono.aviso),
  };

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
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
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      KipuIcon(
                        _nombres[v]!.$2,
                        size: 17,
                        color: v == actual ? Colors.white : KipuColores.gris,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _nombres[v]!.$1,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: v == actual ? Colors.white : KipuColores.tinta,
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

// ───────────────────────── Piezas ─────────────────────────

class _Vacio extends StatelessWidget {
  final String texto;
  const _Vacio(this.texto);

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KipuIcon(
            KipuIcono.reportes,
            size: 52,
            color: Color.lerp(KipuColores.morado, Colors.white, .45),
          ),
          const SizedBox(height: 12),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(color: KipuColores.gris),
          ),
        ],
      ),
    ),
  );
}

/// Tarjeta blanca con título.
class _Tarjeta extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final Widget hijo;
  final Widget? accion;
  const _Tarjeta({
    required this.titulo,
    required this.hijo,
    this.subtitulo,
    this.accion,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitulo != null)
                    Text(
                      subtitulo!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: KipuColores.gris,
                      ),
                    ),
                ],
              ),
            ),
            ?accion,
          ],
        ),
        const SizedBox(height: 14),
        hijo,
      ],
    ),
  );
}

/// Número grande con cambio respecto al periodo anterior.
class _Kpi extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color color;
  final KipuIcono icono;
  final double? cambio;
  final String? sufijo;
  final String? nota;
  final bool menosEsMejor;
  const _Kpi({
    required this.titulo,
    required this.valor,
    required this.color,
    required this.icono,
    this.cambio,
    this.sufijo,
    this.nota,
    this.menosEsMejor = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = cambio;
    final bueno = c == null ? null : (menosEsMejor ? c < 0 : c > 0);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Color.lerp(color, Colors.white, .86),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(child: KipuIcon(icono, size: 19, color: color)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(fontSize: 13, color: KipuColores.gris),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                valor,
                style: TextStyle(
                  fontSize: 30,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              if (c != null && c.abs() >= .05) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: (bueno! ? _verde : _rojo).withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      KipuIcon(
                        c > 0 ? KipuIcono.arriba : KipuIcono.abajo,
                        size: 13,
                        color: bueno ? _verde : _rojo,
                      ),
                      Text(
                        '${numeroCorto(c.abs())}${sufijo ?? ''}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: bueno ? _verde : _rojo,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (nota != null) ...[
            const SizedBox(height: 6),
            Text(
              nota!,
              style: const TextStyle(fontSize: 12, color: KipuColores.gris),
            ),
          ],
        ],
      ),
    );
  }
}

/// Rejilla adaptable de tarjetas.
class _Rejilla extends StatelessWidget {
  final List<Widget> hijos;
  final double minimo;
  const _Rejilla(this.hijos, {this.minimo = 220});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final n = (c.maxWidth / minimo).floor().clamp(1, hijos.length);
      final w = (c.maxWidth - (n - 1) * 12) / n;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [for (final h in hijos) SizedBox(width: w, child: h)],
      );
    },
  );
}

/// Dos tarjetas lado a lado en pantallas anchas.
class _Par extends StatelessWidget {
  final Widget a;
  final Widget b;
  const _Par(this.a, this.b);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => c.maxWidth >= 820
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: a),
              const SizedBox(width: 14),
              Expanded(child: b),
            ],
          )
        : Column(children: [a, b]),
  );
}

List<Segmento> _segmentosNiveles(List<double> notas) {
  final t = tramosReporte();
  final n = nombresTramos(t);
  final d = distribucion(notas, t);
  return [
    for (var i = t.length - 1; i >= 0; i--) (n[i], d[i].toDouble(), Color(t[i].color)),
  ];
}

String _corto(DatosCurso d) =>
    '${d.curso.curso.grado.replaceAll(RegExp(r'\s*(grado|año|años)'), '')} '
    '${d.curso.curso.seccion}';

// ───────────────────────── Resumen ─────────────────────────

class _Resumen extends StatelessWidget {
  final _Ctx c;
  const _Resumen(this.c);

  @override
  Widget build(BuildContext context) {
    final p = c.periodo;
    final notas = c.notas(p);
    final antes = c.anterior == null ? null : c.notas(c.anterior);
    final prom = promedioDe(notas);
    final promAntes = antes == null ? null : promedioDe(antes);
    final apr = porcentajeAprobados(notas);
    final aprAntes = antes == null ? null : porcentajeAprobados(antes);
    final asis = porcentajeAsistencia(conteoAsistencia([
      for (final d in c.datos) ...d.asistenciaEn(p, c.anio),
    ]));
    final asisAntes = c.anterior == null
        ? null
        : porcentajeAsistencia(conteoAsistencia([
            for (final d in c.datos) ...d.asistenciaEn(c.anterior, c.anio),
          ]));
    final riesgo = [for (final d in c.datos) ...enRiesgo(d, p, c.anio)];
    final total = c.datos.fold<int>(0, (s, d) => s + d.estudiantes.length);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      children: [
        _Rejilla([
          _Kpi(
            titulo: 'Promedio · ${c.alcance}',
            valor: prom == null ? '—' : numeroCorto(prom),
            color: colorNota(prom),
            icono: KipuIcono.promedio,
            cambio: prom == null || promAntes == null ? null : prom - promAntes,
            nota: '$total estudiantes · ${c.datos.length} '
                '${c.datos.length == 1 ? 'curso' : 'cursos'}',
          ),
          _Kpi(
            titulo: 'Aprobados',
            valor: apr == null ? '—' : '${numeroCorto(apr, 0)} %',
            color: _verde,
            icono: KipuIcono.check,
            cambio: apr == null || aprAntes == null ? null : apr - aprAntes,
            sufijo: ' %',
            nota: '${notas.where((n) => n >= aprobatoria).length} de ${notas.length} con nota',
          ),
          _Kpi(
            titulo: 'Asistencia',
            valor: asis == null ? '—' : '${numeroCorto(asis, 0)} %',
            color: const Color(0xFF1A9BD7),
            icono: KipuIcono.asistencia,
            cambio: asis == null || asisAntes == null ? null : asis - asisAntes,
            sufijo: ' %',
          ),
          _Kpi(
            titulo: 'Necesitan apoyo',
            valor: '${riesgo.length}',
            color: riesgo.isEmpty ? _verde : _rojo,
            icono: KipuIcono.aviso,
            nota: riesgo.isEmpty ? '¡Todos van bien!' : 'Mira la pestaña «Necesitan apoyo»',
          ),
        ]),
        const SizedBox(height: 14),
        _Par(
          _Tarjeta(
            titulo: 'Niveles de logro',
            subtitulo: c.alcance,
            hijo: notas.isEmpty
                ? const _SinDatos()
                : GraficoDona(
                    segmentos: _segmentosNiveles(notas),
                    centro: '${notas.length}',
                    debajo: 'estudiantes',
                  ),
          ),
          c.unCurso
              ? _Tarjeta(
                  titulo: 'Promedio por periodo',
                  subtitulo: c.datos.first.nombre,
                  hijo: GraficoBarras(
                    referencia: aprobatoria,
                    barras: [
                      for (final (i, per) in c.periodos.indexed)
                        () {
                          final v = promedioDe(c.datos.first.notaPeriodo[i + 1]?.values ?? const []);
                          return Barra(nombrePeriodoCorto(per.nombre, i + 1), v,
                              colorNota(v), detalle: per.nombre);
                        }(),
                      () {
                        final v = promedioDe(c.datos.first.notas(null).values);
                        return Barra('Anual', v, colorNota(v));
                      }(),
                    ],
                  ),
                )
              : _Tarjeta(
                  titulo: 'Promedio por curso',
                  subtitulo: c.alcance,
                  hijo: GraficoBarras(
                    referencia: aprobatoria,
                    barras: [
                      for (final d in c.datos)
                        () {
                          final v = promedioDe(d.notas(p).values);
                          return Barra(_corto(d), v, colorNota(v),
                              detalle: '${d.nombre} · ${d.curso.colegio.nombre}');
                        }(),
                    ],
                  ),
                ),
        ),
        if (c.colegios.length > 1 && !c.unCurso)
          () {
            final porColegio = <int, List<double>>{};
            for (final d in c.datos) {
              (porColegio[d.curso.colegio.id] ??= []).addAll(d.notas(p).values);
            }
            if (porColegio.length < 2) return const SizedBox.shrink();
            return _Tarjeta(
              titulo: 'Comparación entre colegios',
              subtitulo: c.alcance,
              hijo: GraficoBarras(
                alto: 140,
                referencia: aprobatoria,
                barras: [
                  for (final col in c.colegios)
                    if (porColegio[col.id] case final l?)
                      Barra(col.nombre, promedioDe(l),
                          colorColegio(c.colegios, col.id)),
                ],
              ),
            );
          }(),
        if (c.anterior != null)
          _Tarjeta(
            titulo: 'Comparación con el ${c.periodos[c.anterior! - 1].nombre}',
            subtitulo: 'Promedio de cada curso',
            hijo: Column(
              children: [
                for (final d in c.datos)
                  () {
                    final a = promedioDe(d.notas(c.anterior).values);
                    final b = promedioDe(d.notas(p).values);
                    final dif = a == null || b == null ? null : b - a;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              d.nombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(
                            width: 48,
                            child: Text(
                              a == null ? '—' : numeroCorto(a),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colorNota(a)),
                            ),
                          ),
                          const KipuIcon(KipuIcono.derecha, size: 14, color: _gris2),
                          SizedBox(
                            width: 48,
                            child: Text(
                              b == null ? '—' : numeroCorto(b),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: colorNota(b),
                              ),
                            ),
                          ),
                          SizedBox(width: 70, child: _Cambio(dif)),
                        ],
                      ),
                    );
                  }(),
              ],
            ),
          ),
      ],
    );
  }
}

class _SinDatos extends StatelessWidget {
  const _SinDatos();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 30),
    child: Text(
      'Sin notas en este periodo.',
      textAlign: TextAlign.center,
      style: TextStyle(color: KipuColores.gris),
    ),
  );
}

/// «▲ 1,2» en verde o «▼ 0,8» en rojo.
class _Cambio extends StatelessWidget {
  final double? dif;
  const _Cambio(this.dif);

  @override
  Widget build(BuildContext context) {
    final d = dif;
    if (d == null || d.abs() < .05) {
      return const Text('=', textAlign: TextAlign.center,
          style: TextStyle(color: KipuColores.gris));
    }
    final color = d > 0 ? _verde : _rojo;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        KipuIcon(d > 0 ? KipuIcono.arriba : KipuIcono.abajo, size: 14, color: color),
        Text(
          numeroCorto(d.abs()),
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}

// ───────────────────────── Por periodo ─────────────────────────

class _Periodos extends StatelessWidget {
  final _Ctx c;
  const _Periodos(this.c);

  @override
  Widget build(BuildContext context) {
    final etiquetas = [
      for (final (i, p) in c.periodos.indexed) nombrePeriodoCorto(p.nombre, i + 1),
    ];
    final colores = [
      KipuColores.morado,
      const Color(0xFF1A9BD7),
      _naranja,
      _verde,
      const Color(0xFFE5508E),
      const Color(0xFF7B4FD6),
    ];
    final evolucion = _Tarjeta(
      titulo: 'Evolución del promedio',
      subtitulo: c.unCurso ? c.datos.first.nombre : 'Un color por curso (máx. 6)',
      hijo: GraficoLinea(
        etiquetas: etiquetas,
        referencia: aprobatoria,
        series: [
          for (final (k, d) in c.datos.take(6).indexed)
            Serie(
              _corto(d),
              [
                for (var p = 1; p <= c.periodos.length; p++)
                  promedioDe(d.notaPeriodo[p]?.values ?? const []),
              ],
              colores[k % colores.length],
            ),
        ],
      ),
    );
    if (!c.unCurso) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        children: [
          evolucion,
          const _Aviso('Elige un curso arriba para ver la tabla de notas por '
              'periodo y el promedio anual de cada estudiante.'),
        ],
      );
    }
    final d = c.datos.first;
    final ps = c.periodos;
    // Quiénes subieron o bajaron entre los dos últimos periodos con nota.
    final hasta = c.periodo ?? ps.length;
    int? previo;
    for (var p = hasta - 1; p >= 1; p--) {
      if ((d.notaPeriodo[p] ?? const {}).isNotEmpty) {
        previo = p;
        break;
      }
    }
    final cambios = <(Estudiante, double)>[];
    if (previo != null) {
      for (final e in d.estudiantes) {
        final a = d.notaPeriodo[previo]?[e.id];
        final b = d.notaPeriodo[hasta]?[e.id];
        if (a != null && b != null) cambios.add((e, b - a));
      }
      cambios.sort((x, y) => y.$2.compareTo(x.$2));
    }
    final suben = cambios.where((x) => x.$2 >= .5).take(5).toList();
    final bajan = cambios.reversed.where((x) => x.$2 <= -.5).take(5).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      children: [
        evolucion,
        _Tarjeta(
          titulo: 'Notas por periodo y promedio anual',
          subtitulo: d.letras
              ? 'Anual: nivel del último periodo con nota (Minedu)'
              : 'Anual: promedio de los periodos con nota',
          hijo: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.sizeOf(context).width > 1100
                    ? 1030
                    : MediaQuery.sizeOf(context).width - 68,
              ),
              child: _TablaPeriodos(d),
            ),
          ),
        ),
        if (suben.isNotEmpty || bajan.isNotEmpty)
          _Par(
            _Tarjeta(
              titulo: 'Más subieron',
              subtitulo: '${ps[previo! - 1].nombre} → ${ps[hasta - 1].nombre}',
              hijo: suben.isEmpty
                  ? const Text('Nadie subió más de medio punto.',
                      style: TextStyle(color: KipuColores.gris))
                  : Column(children: [for (final (e, v) in suben) _FilaCambio(e, v)]),
            ),
            _Tarjeta(
              titulo: 'Más bajaron',
              subtitulo: '${ps[previo - 1].nombre} → ${ps[hasta - 1].nombre}',
              hijo: bajan.isEmpty
                  ? const Text('Nadie bajó más de medio punto.',
                      style: TextStyle(color: KipuColores.gris))
                  : Column(children: [for (final (e, v) in bajan) _FilaCambio(e, v)]),
            ),
          ),
      ],
    );
  }
}

class _Aviso extends StatelessWidget {
  final String texto;
  const _Aviso(this.texto);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Color.lerp(KipuColores.morado, Colors.white, .9),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        KipuIcon(KipuIcono.cursos, size: 22, color: KipuColores.morado),
        const SizedBox(width: 12),
        Expanded(child: Text(texto)),
      ],
    ),
  );
}

class _FilaCambio extends StatelessWidget {
  final Estudiante e;
  final double v;
  const _FilaCambio(this.e, this.v);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        AvatarEstudiante(e, tam: 32),
        const SizedBox(width: 10),
        Expanded(child: Text(_nombre(e))),
        _Cambio(v),
      ],
    ),
  );
}

class _TablaPeriodos extends StatelessWidget {
  final DatosCurso d;
  const _TablaPeriodos(this.d);

  @override
  Widget build(BuildContext context) {
    final ps = d.periodos;
    Widget celda(double? n, String? t, {bool fuerte = false}) => Container(
      width: 62,
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: n != null && n < aprobatoria
            ? BoxDecoration(
                color: const Color(0xFFFCE8EB),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Text(
          t ?? '·',
          style: TextStyle(
            fontSize: fuerte ? 16 : 15,
            fontWeight: fuerte ? FontWeight.w800 : FontWeight.w600,
            color: t == null ? const Color(0xFFCFCFDB) : colorNota(n),
          ),
        ),
      ),
    );
    Widget cabeza(String t, {double ancho = 62}) => SizedBox(
      width: ancho,
      child: Text(
        t,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: KipuColores.gris,
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const SizedBox(
                width: 250,
                child: Text(
                  'ESTUDIANTE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: KipuColores.gris,
                  ),
                ),
              ),
              for (final (i, p) in ps.indexed) cabeza(nombrePeriodoCorto(p.nombre, i + 1)),
              cabeza('ANUAL'),
              cabeza('CAMBIO', ancho: 76),
            ],
          ),
        ),
        for (final (k, e) in d.estudiantes.indexed)
          () {
            final con = [
              for (var p = ps.length; p >= 1; p--) ?d.notaPeriodo[p]?[e.id],
            ];
            final dif = con.length >= 2 ? con[0] - con[1] : null;
            return Container(
              color: k.isOdd ? const Color(0xFFF8F8FC) : null,
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 250,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 26,
                          child: Text(
                            '${k + 1}',
                            style: const TextStyle(fontSize: 12, color: _gris2),
                          ),
                        ),
                        AvatarEstudiante(e, tam: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _nombre(e),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (var p = 1; p <= ps.length; p++)
                    celda(d.notaPeriodo[p]?[e.id], d.texto(p, e.id)),
                  Container(
                    color: Color.lerp(KipuColores.morado, Colors.white, .93),
                    child: celda(d.anual(e.id), d.textoAnual(e.id), fuerte: true),
                  ),
                  SizedBox(width: 76, child: _Cambio(dif)),
                ],
              ),
            );
          }(),
        const Divider(height: 18),
        Row(
          children: [
            const SizedBox(
              width: 250,
              child: Text('Promedio del aula',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            for (var p = 1; p <= ps.length; p++)
              () {
                final v = promedioDe(d.notaPeriodo[p]?.values ?? const []);
                return celda(v, v == null ? null : numeroCorto(v));
              }(),
            () {
              final v = promedioDe(d.notas(null).values);
              return celda(v, v == null ? null : numeroCorto(v), fuerte: true);
            }(),
          ],
        ),
      ],
    );
  }
}

// ───────────────────────── Evaluaciones ─────────────────────────

class _Evaluaciones extends StatelessWidget {
  final _Ctx c;
  const _Evaluaciones(this.c);

  @override
  Widget build(BuildContext context) {
    if (!c.unCurso) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        children: const [
          _Aviso('Elige un curso arriba para ver el promedio de cada '
              'evaluación, por tema y por semana.'),
        ],
      );
    }
    final d = c.datos.first;
    final evs = [
      for (var p = 1; p <= c.periodos.length; p++)
        if (c.periodo == null || c.periodo == p)
          for (final e in d.evaluaciones[p] ?? const <EvaluacionDato>[])
            if (e.notas.isNotEmpty) e,
    ];
    if (evs.isEmpty) {
      return const _Vacio('Todavía no hay evaluaciones con notas en este periodo.');
    }
    final porSemana = <String, List<EvaluacionDato>>{};
    for (final e in evs) {
      final f = e.columna.fecha;
      (porSemana[f == null ? '' : lunesDe(f)] ??= []).add(e);
    }
    final semanas = porSemana.keys.toList()
      ..sort((a, b) => a.isEmpty ? 1 : (b.isEmpty ? -1 : b.compareTo(a)));
    final ordenadas = [...evs]..sort((a, b) => a.promedio!.compareTo(b.promedio!));
    final dificil = ordenadas.first;
    final mejor = ordenadas.last;
    String titulo(EvaluacionDato e) => [
      e.columna.codigo,
      if ((e.columna.tema ?? '').isNotEmpty) e.columna.tema!,
    ].join(' · ');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      children: [
        _Rejilla([
          _Kpi(
            titulo: 'Evaluaciones',
            valor: '${evs.length}',
            color: KipuColores.morado,
            icono: KipuIcono.examen,
            nota: c.alcance,
          ),
          _Kpi(
            titulo: 'Más difícil',
            valor: numeroCorto(dificil.promedio!),
            color: colorNota(dificil.promedio),
            icono: KipuIcono.aviso,
            nota: titulo(dificil),
          ),
          _Kpi(
            titulo: 'Mejor resultado',
            valor: numeroCorto(mejor.promedio!),
            color: colorNota(mejor.promedio),
            icono: KipuIcono.estrella,
            nota: titulo(mejor),
          ),
        ]),
        const SizedBox(height: 14),
        _Tarjeta(
          titulo: 'Promedio de cada evaluación',
          subtitulo: 'La línea roja es la nota aprobatoria',
          hijo: GraficoBarras(
            referencia: aprobatoria,
            barras: [
              for (final e in evs)
                Barra(
                  e.columna.codigo,
                  e.promedio,
                  colorNota(e.promedio),
                  detalle: [
                    titulo(e),
                    if (e.columna.fecha != null) fechaCorta(e.columna.fecha!),
                    '${numeroCorto(porcentajeAprobados(e.notas.values)!, 0)} % aprobados',
                  ].join(' · '),
                ),
            ],
          ),
        ),
        _Tarjeta(
          titulo: 'Por semana',
          subtitulo: 'Según la fecha de cada columna del registro',
          hijo: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final s in semanas)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        s.isEmpty ? 'Sin fecha' : 'Semana del ${fechaCorta(s)}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: KipuColores.gris,
                        ),
                      ),
                      const SizedBox(height: 6),
                      for (final e in porSemana[s]!)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  titulo(e),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: BarraPorcentaje(
                                  e.promedio! / 20 * 100,
                                  color: colorNota(e.promedio),
                                ),
                              ),
                              SizedBox(
                                width: 52,
                                child: Text(
                                  numeroCorto(e.promedio!),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: colorNota(e.promedio),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 64,
                                child: Text(
                                  '${numeroCorto(porcentajeAprobados(e.notas.values)!, 0)} % apr.',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: KipuColores.gris,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Asistencia ─────────────────────────

const _estados = <(String, String, Color)>[
  ('P', 'Presente', _verde),
  ('T', 'Tarde', Color(0xFFE0A31F)),
  ('F', 'Falta', _rojo),
  ('J', 'Justificada', Color(0xFF1A9BD7)),
];

class _Asistencia extends StatelessWidget {
  final _Ctx c;
  const _Asistencia(this.c);

  @override
  Widget build(BuildContext context) {
    final lista = [for (final d in c.datos) ...d.asistenciaEn(c.periodo, c.anio)];
    final conteo = conteoAsistencia(lista);
    final pct = porcentajeAsistencia(conteo);
    final antes = c.anterior == null
        ? null
        : porcentajeAsistencia(conteoAsistencia([
            for (final d in c.datos) ...d.asistenciaEn(c.anterior, c.anio),
          ]));
    if (lista.isEmpty) {
      return const _Vacio('No hay asistencia tomada en este periodo.');
    }
    final semanas = asistenciaPorSemana(lista);
    final ult = semanas.entries.toList();
    final ver = ult.length > 12 ? ult.sublist(ult.length - 12) : ult;

    // Estudiantes con más faltas.
    final filas = <(Estudiante, DatosCurso, Map<String, int>)>[];
    for (final d in c.datos) {
      for (final e in d.estudiantes) {
        final cn = conteoAsistencia(lista.where((a) => a.estudianteId == e.id));
        if (cn['F']! + cn['T']! > 0) filas.add((e, d, cn));
      }
    }
    filas.sort((a, b) {
      final f = b.$3['F']!.compareTo(a.$3['F']!);
      return f != 0 ? f : b.$3['T']!.compareTo(a.$3['T']!);
    });

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      children: [
        _Rejilla([
          _Kpi(
            titulo: 'Asistencia · ${c.alcance}',
            valor: pct == null ? '—' : '${numeroCorto(pct, 0)} %',
            color: _verde,
            icono: KipuIcono.asistencia,
            cambio: pct == null || antes == null ? null : pct - antes,
            sufijo: ' %',
          ),
          _Kpi(
            titulo: 'Faltas',
            valor: '${conteo['F']}',
            color: _rojo,
            icono: KipuIcono.cerrar,
            nota: '${conteo['J']} justificadas',
          ),
          _Kpi(
            titulo: 'Tardanzas',
            valor: '${conteo['T']}',
            color: const Color(0xFFE0A31F),
            icono: KipuIcono.horario,
          ),
        ]),
        const SizedBox(height: 14),
        _Par(
          _Tarjeta(
            titulo: 'Cómo asistieron',
            subtitulo: c.alcance,
            hijo: GraficoDona(
              segmentos: [
                for (final (k, n, col) in _estados) (n, conteo[k]!.toDouble(), col),
              ],
              centro: pct == null ? '—' : '${numeroCorto(pct, 0)}%',
              debajo: 'asistencia',
            ),
          ),
          _Tarjeta(
            titulo: 'Por semana',
            subtitulo: '% de asistencia (últimas ${ver.length})',
            hijo: GraficoBarras(
              maximo: 100,
              barras: [
                for (final s in ver)
                  Barra(
                    fechaCorta(s.key),
                    s.value,
                    s.value >= 90
                        ? _verde
                        : (s.value >= 75 ? const Color(0xFFE0A31F) : _rojo),
                    texto: '${s.value.round()}%',
                    detalle: 'Semana del ${fechaCorta(s.key)}',
                  ),
              ],
            ),
          ),
        ),
        _Tarjeta(
          titulo: 'Más faltas y tardanzas',
          subtitulo: 'Con 30 % de faltas o más se marcan en rojo',
          hijo: filas.isEmpty
              ? const Text('Sin faltas ni tardanzas. ¡Excelente!',
                  style: TextStyle(color: KipuColores.gris))
              : Column(
                  children: [
                    for (final (e, d, cn) in filas.take(15))
                      () {
                        final tot = cn['P']! + cn['T']! + cn['F']!;
                        final pf = tot == 0 ? 0.0 : cn['F']! / tot * 100;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              AvatarEstudiante(e, tam: 32),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_nombre(e),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    if (!c.unCurso)
                                      Text(d.nombre,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: KipuColores.gris)),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: BarraPorcentaje(pf,
                                    color: pf >= 30 ? _rojo : _naranja),
                              ),
                              SizedBox(
                                width: 112,
                                child: Text(
                                  '${cn['F']} F · ${cn['T']} T',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: pf >= 30 ? _rojo : KipuColores.tinta,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }(),
                  ],
                ),
        ),
      ],
    );
  }
}

// ───────────────────────── Estudiante ─────────────────────────

class _Estudiante extends StatelessWidget {
  final _Ctx c;
  final int? estudiante;
  final ValueChanged<int?> onEstudiante;
  const _Estudiante(this.c, {required this.estudiante, required this.onEstudiante});

  @override
  Widget build(BuildContext context) {
    if (!c.unCurso) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        children: const [
          _Aviso('Elige un curso arriba y luego al estudiante para ver su '
              'informe y descargar su libreta en PDF.'),
        ],
      );
    }
    final d = c.datos.first;
    final e = d.estudiantes.where((x) => x.id == estudiante).firstOrNull ??
        d.estudiantes.firstOrNull;
    if (e == null) return const _Vacio('Este curso no tiene estudiantes.');
    final ps = c.periodos;
    final asis = conteoAsistencia(
      d.asistenciaEn(c.periodo, c.anio).where((a) => a.estudianteId == e.id),
    );
    final pa = porcentajeAsistencia(asis);
    final cond = d.conductasEn(c.periodo, c.anio)
        .where((x) => x.estudianteId == e.id)
        .toList();
    final anec = [for (final x in d.anecdotas) if (x.$2.id == e.id) x];
    final anual = d.anual(e.id);

    Future<void> libreta() async {
      final docente = await db.leerAjuste('nombre') ?? '';
      try {
        final bytes = await pdfLibreta(
          d,
          e,
          InfoReporte(
            docente: docente,
            alcance: c.alcance,
            anio: c.anio,
            periodo: c.periodo,
            color: KipuColores.morado,
          ),
        );
        await FilePicker.saveFile(
          fileName: 'Informe ${tituloNombre(e.apellidos)} ${tituloNombre(e.nombres)}.pdf',
          bytes: bytes,
          mimeType: 'application/pdf',
        );
      } catch (err) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo descargar: $err')),
        );
      }
    }

    Future<void> whatsapp() async {
      final cel = (e.telefono ?? '').replaceAll(RegExp(r'\D'), '');
      final texto = [
        'Buen día${(e.apoderado ?? '').isEmpty ? '' : ', ${tituloNombre(e.apoderado!)}'}.',
        'Le comparto el avance de ${tituloNombre(e.nombres).split(' ').first} en ${d.curso.curso.nombre}:',
        for (var p = 1; p <= ps.length; p++)
          if (d.texto(p, e.id) case final t?) '• ${ps[p - 1].nombre}: $t',
        if (d.textoAnual(e.id) case final t?) '• Promedio anual: $t',
        if (pa != null) '• Asistencia (${c.alcance}): ${numeroCorto(pa, 0)} %',
        'Quedo atento(a) a cualquier consulta. Gracias.',
      ].join('\n');
      await launchUrl(
        Uri.https('wa.me', '/${cel.length == 9 ? '51$cel' : cel}', {'text': texto}),
        mode: LaunchMode.externalApplication,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                key: ValueKey('est-${e.id}'),
                initialValue: e.id,
                isExpanded: true,
                decoration: const InputDecoration(isDense: true),
                items: [
                  for (final x in d.estudiantes)
                    DropdownMenuItem(value: x.id, child: Text(_nombre(x))),
                ],
                onChanged: onEstudiante,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  AvatarEstudiante(e, tam: 64),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${tituloNombre(e.apellidos)}, ${tituloNombre(e.nombres)}',
                          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                        ),
                        Text('${d.nombre} · ${d.curso.colegio.nombre}',
                            style: const TextStyle(color: KipuColores.gris)),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const Text('Anual', style: TextStyle(fontSize: 12, color: KipuColores.gris)),
                      Text(
                        d.textoAnual(e.id) ?? '—',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: colorNota(anual),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: libreta,
                    icon: const KipuIcon(KipuIcono.descargar, size: 18, color: Colors.white),
                    label: const Text('Informe en PDF'),
                  ),
                  if ((e.telefono ?? '').isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: whatsapp,
                      icon: const KipuIcon(KipuIcono.whatsapp, size: 18, color: _verde),
                      label: const Text('Enviar al apoderado'),
                    ),
                  OutlinedButton.icon(
                    onPressed: () => editarReunion(context, estudiante: e),
                    icon: KipuIcon(KipuIcono.familia, size: 18, color: KipuColores.morado),
                    label: const Text('Reunión con padres'),
                  ),
                ],
              ),
            ],
          ),
        ),
        _Par(
          _Tarjeta(
            titulo: 'Notas por periodo',
            subtitulo: 'Comparado con el promedio del aula',
            hijo: GraficoLinea(
              etiquetas: [
                for (final (i, p) in ps.indexed) nombrePeriodoCorto(p.nombre, i + 1),
              ],
              referencia: aprobatoria,
              series: [
                Serie(
                  tituloNombre(e.nombres).split(' ').first,
                  [for (var p = 1; p <= ps.length; p++) d.notaPeriodo[p]?[e.id]],
                  KipuColores.morado,
                ),
                Serie(
                  'Aula',
                  [
                    for (var p = 1; p <= ps.length; p++)
                      promedioDe(d.notaPeriodo[p]?.values ?? const []),
                  ],
                  _gris2,
                ),
              ],
            ),
          ),
          _Tarjeta(
            titulo: 'Asistencia',
            subtitulo: c.alcance,
            hijo: GraficoDona(
              tam: 130,
              segmentos: [
                for (final (k, n, col) in _estados) (n, asis[k]!.toDouble(), col),
              ],
              centro: pa == null ? '—' : '${numeroCorto(pa, 0)}%',
            ),
          ),
        ),
        _Tarjeta(
          titulo: 'Evaluaciones',
          subtitulo: c.alcance,
          hijo: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var p = 1; p <= ps.length; p++)
                if (c.periodo == null || c.periodo == p)
                  for (final ev in d.evaluaciones[p] ?? const <EvaluacionDato>[])
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: KipuColores.fondo,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${ev.columna.codigo}  ',
                              style: const TextStyle(color: KipuColores.gris, fontSize: 12.5),
                            ),
                            TextSpan(
                              text: ev.notas[e.id] == null
                                  ? '·'
                                  : numeroCorto(ev.notas[e.id]!, 0),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: colorNota(ev.notas[e.id]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
        _Tarjeta(
          titulo: 'Conducta',
          subtitulo: c.alcance,
          hijo: cond.isEmpty
              ? const Text('Sin anotaciones de conducta.',
                  style: TextStyle(color: KipuColores.gris))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('+${cond.where((x) => x.positiva).length}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _verde)),
                        const SizedBox(width: 18),
                        Text('−${cond.where((x) => !x.positiva).length}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _rojo)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final x in cond.take(12))
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (x.positiva ? _verde : _rojo).withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${x.motivo} · ${fechaCorta(x.fecha)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: x.positiva ? _verde : _rojo,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
        ),
        if (anec.isNotEmpty)
          _Tarjeta(
            titulo: 'Anecdotario',
            hijo: Column(
              children: [
                for (final x in anec.take(6)) TarjetaAnecdota(x, conNombre: false),
              ],
            ),
          ),
      ],
    );
  }
}

// ───────────────────────── Necesitan apoyo ─────────────────────────

class _Apoyo extends StatelessWidget {
  final _Ctx c;
  final ValueChanged<Riesgo> onVer;
  const _Apoyo(this.c, {required this.onVer});

  @override
  Widget build(BuildContext context) {
    final lista = [for (final d in c.datos) ...enRiesgo(d, c.periodo, c.anio)]
      ..sort((a, b) => b.peso.compareTo(a.peso));
    if (lista.isEmpty) {
      return const _Vacio('¡Nadie necesita apoyo especial en este periodo!');
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 4),
          child: Text(
            '${lista.length} estudiantes · ${c.alcance}. Se marcan por nota '
            'desaprobada, si bajaron 2 puntos o más, 30 % de faltas o '
            'varias anotaciones por mejorar.',
            style: const TextStyle(color: KipuColores.gris),
          ),
        ),
        for (final r in lista)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border(
                left: BorderSide(
                  color: r.peso >= 4 ? _rojo : (r.peso >= 2 ? _naranja : const Color(0xFFE0A31F)),
                  width: 4,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarEstudiante(r.estudiante, tam: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nombre(r.estudiante),
                        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${r.curso.nombre} · ${r.curso.curso.colegio.nombre}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final m in r.motivos)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFCE8EB),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                m,
                                style: const TextStyle(fontSize: 12, color: _rojo),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    TextButton(
                      onPressed: () => onVer(r),
                      child: const Text('Ver informe'),
                    ),
                    TextButton(
                      onPressed: () => editarReunion(context, estudiante: r.estudiante),
                      child: const Text('Reunión'),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
