import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/academico.dart';
import '../data/cneb.dart';
import '../data/database.dart';
import '../data/evaluacion_db.dart';
import '../data/planificacion.dart';
import '../data/planificacion_excel.dart';
import '../main.dart' show db;
import '../theme.dart';
import '../widgets/kipu_icono.dart';
import '../widgets/ventana.dart';
import 'horario_datos.dart' show aula;
import 'planificacion.dart' show nombreCurso;

const _xlsx =
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
const _verdeExcel = Color(0xFF1D6F42);

String _archivo(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9áéíóúñ]+'), '-')
    .replaceAll(RegExp(r'^-|-$'), '');

/// Desde el menú de la vista Año: el periodo actual o todo el año.
Future<void> descargarPlanificacion(
  BuildContext context, {
  required CursoConColegio curso,
  required bool privado,
  required int anio,
  required List<Periodo> periodos,
}) => descargarUnidades(
  context,
  curso: curso,
  privado: privado,
  anio: anio,
  periodos: periodos,
);

/// Ventana para descargar una unidad, un periodo o el año, en PDF o Excel.
/// En un colegio privado se propone el Excel (y se puede usar el formato
/// del colegio); en uno público, el PDF con formato Minedu.
Future<void> descargarUnidades(
  BuildContext context, {
  required CursoConColegio curso,
  required bool privado,
  required int anio,
  required List<Periodo> periodos,
  Unidad? unidad,
}) async {
  final unidades = await db.verUnidades(curso.curso.id, anio).first;
  final sesiones = await db.verSesionesCurso(curso.curso.id, anio).first;
  if (!context.mounted) return;
  if (unidades.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aún no hay unidades para descargar')),
    );
    return;
  }
  final bloques = [
    for (var i = 0; i < unidades.length; i++)
      BloqueUnidad(i + 1, unidades[i], sesiones[unidades[i].id] ?? const []),
  ];
  final periodo =
      unidad?.periodo ??
      ConfigAcademica(
        anio: anio,
        pais: 'PE',
        tipoPeriodo: '',
        periodos: periodos,
        escalas: const [],
        escalaPorDefecto: '',
      ).periodoActual(DateTime.now()) ??
      1;
  await ventanaCentrada<void>(
    context: context,
    ancho: 560,
    builder: (_) => _Descargar(
      curso: curso,
      privado: privado,
      anio: anio,
      periodos: periodos,
      bloques: bloques,
      unidad: unidad,
      periodo: periodo,
    ),
  );
}

class _Descargar extends StatefulWidget {
  final CursoConColegio curso;
  final bool privado;
  final int anio;
  final List<Periodo> periodos;
  final List<BloqueUnidad> bloques;
  final Unidad? unidad;
  final int periodo;
  const _Descargar({
    required this.curso,
    required this.privado,
    required this.anio,
    required this.periodos,
    required this.bloques,
    required this.unidad,
    required this.periodo,
  });

  @override
  State<_Descargar> createState() => _DescargarState();
}

class _DescargarState extends State<_Descargar> {
  late String _alcance = widget.unidad != null ? 'unidad' : 'periodo';
  late bool _excel = widget.privado;
  late final _claveFormato = 'formato_plan_${widget.curso.colegio.id}';
  late final _formato = db.verAjuste(_claveFormato);
  bool _ocupado = false;

  List<BloqueUnidad> get _elegidos => switch (_alcance) {
    'unidad' => [
      for (final b in widget.bloques)
        if (b.unidad.id == widget.unidad!.id) b,
    ],
    'periodo' => [
      for (final b in widget.bloques)
        if (b.unidad.periodo == widget.periodo) b,
    ],
    _ => widget.bloques,
  };

  String get _nombre {
    final c = widget.curso.curso;
    final base = '${c.nombre} ${aula(c)}';
    return switch (_alcance) {
      'unidad' => '$base unidad ${_elegidos.firstOrNull?.numero ?? ''}',
      'periodo' => '$base ${widget.periodos[widget.periodo - 1].nombre}',
      _ => '$base ${widget.anio}',
    };
  }

  Future<void> _subirFormato() async {
    final f = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (f == null) return;
    final bytes = await f.xFile.readAsBytes();
    final prueba = llenarFormato(bytes, const []);
    if (!mounted) return;
    if (prueba.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(prueba.error ?? 'No se pudo usar ese Excel')),
      );
      return;
    }
    await db.guardarAjuste(
      _claveFormato,
      jsonEncode({'nombre': f.xFile.name, 'datos': base64Encode(bytes)}),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Listo. Kipu llenará: ${prueba.columnas.join(', ')}'),
      ),
    );
  }

  Future<void> _descargar(String? formato) async {
    setState(() => _ocupado = true);
    final bloques = _elegidos;
    final c = widget.curso;
    try {
      if (_excel) {
        if (formato != null) {
          final j = jsonDecode(formato) as Map<String, dynamic>;
          final r = llenarFormato(base64Decode(j['datos'] as String), [
            for (final b in bloques) ...b.filas,
          ]);
          if (r.bytes == null) throw r.error ?? 'formato no válido';
          await FilePicker.saveFile(
            fileName: '${_archivo(_nombre)}.xlsx',
            bytes: r.bytes!,
            mimeType: _xlsx,
          );
        } else {
          await FilePicker.saveFile(
            fileName: '${_archivo(_nombre)}.xlsx',
            bytes: excelPlanificacion(
              titulo:
                  '${c.colegio.nombre} · ${c.curso.nombre} ${aula(c.curso)} · '
                  'Planificación ${widget.anio}',
              bloques: bloques,
            ),
            mimeType: _xlsx,
          );
        }
      } else {
        await FilePicker.saveFile(
          fileName: '${_archivo(_nombre)}.pdf',
          bytes: await pdfPlanificacion(
            curso: c,
            bloques: bloques,
            periodos: widget.periodos,
            docente: await db.leerAjuste('nombre') ?? '',
            simple: widget.privado,
          ),
          mimeType: 'application/pdf',
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _ocupado = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo descargar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final per = widget.periodos[widget.periodo - 1].nombre;
    final enPeriodo = widget.bloques
        .where((b) => b.unidad.periodo == widget.periodo)
        .toList();
    Widget opcion(String v, String t, String s) {
      final on = _alcance == v;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _alcance = v),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: on ? KipuColores.moradoClaro : null,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: on ? KipuColores.morado : const Color(0xFFECEDF4),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  s,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: KipuColores.gris,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final sesionesDe = _elegidos.fold(0, (n, b) => n + b.sesiones.length);
    return StreamBuilder<String?>(
      stream: _formato,
      builder: (context, sf) {
        final formato = sf.data;
        final nombreFormato = formato == null
            ? null
            : (jsonDecode(formato) as Map<String, dynamic>)['nombre']
                  as String?;
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Descargar planificación',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                nombreCurso(widget.curso.curso),
                style: const TextStyle(color: KipuColores.gris),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  if (widget.unidad != null) ...[
                    opcion(
                      'unidad',
                      'Esta unidad',
                      '${_bloque(widget.unidad!)?.sesiones.length ?? 0} sesiones',
                    ),
                    const SizedBox(width: 8),
                  ],
                  opcion('periodo', 'El $per', '${enPeriodo.length} unidades'),
                  const SizedBox(width: 8),
                  opcion(
                    'anio',
                    'Todo el año',
                    '${widget.bloques.length} unidades',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: false, label: Text('PDF')),
                  ButtonSegment(value: true, label: Text('Excel')),
                ],
                selected: {_excel},
                onSelectionChanged: (s) => setState(() => _excel = s.first),
              ),
              const SizedBox(height: 10),
              Text(
                _excel
                    ? (nombreFormato != null
                          ? 'Con el formato de tu colegio ($nombreFormato): una fila por sesión.'
                          : 'Una fila por sesión con su fecha, tema, competencia, '
                                'actividades y materiales. Listo para subir.')
                    : widget.privado
                    ? 'Lista de unidades y sesiones con sus actividades.'
                    : 'Formato Minedu: datos informativos, situación significativa, '
                          'propósitos, enfoques y cada sesión con inicio, desarrollo y cierre.',
                style: const TextStyle(fontSize: 13, color: KipuColores.gris),
              ),
              if (_excel) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        nombreFormato == null
                            ? '¿Tu colegio te da su propio Excel? Súbelo una vez y Kipu llena sus columnas.'
                            : 'Formato del colegio guardado.',
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    ),
                    if (nombreFormato != null)
                      TextButton(
                        onPressed: () => db.borrarAjuste(_claveFormato),
                        child: const Text('Quitar'),
                      )
                    else
                      OutlinedButton(
                        onPressed: _subirFormato,
                        child: const Text('Subir formato del colegio'),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    style: _excel
                        ? FilledButton.styleFrom(backgroundColor: _verdeExcel)
                        : null,
                    onPressed: _ocupado || _elegidos.isEmpty
                        ? null
                        : () => _descargar(formato),
                    icon: const KipuIcon(
                      KipuIcono.descargar,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      _elegidos.isEmpty
                          ? 'No hay unidades'
                          : _excel
                          ? 'Descargar .xlsx ($sesionesDe sesiones)'
                          : 'Descargar PDF',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  BloqueUnidad? _bloque(Unidad u) =>
      widget.bloques.where((b) => b.unidad.id == u.id).firstOrNull;
}

// ───────────────────────── PDF ─────────────────────────

PdfColor _pdf(Color c) => PdfColor(c.r, c.g, c.b);
const _tinta = Color(0xFF1F1B2E);
const _gris = Color(0xFF6E6A80);
const _azul = Color(0xFF2F4FB0);
const _azulClaro = Color(0xFFE6EBFA);

String _fechaLarga(String? f) => f == null
    ? '—'
    : DateFormat("d 'de' MMMM", 'es_PE').format(DateTime.parse(f));

/// PDF de la planificación. En un colegio público, formato Minedu: cada
/// unidad con sus datos informativos, situación, propósitos y enfoques, y
/// cada sesión en su página con inicio, desarrollo y cierre. Con [simple],
/// solo la lista de unidades y sesiones.
Future<Uint8List> pdfPlanificacion({
  required CursoConColegio curso,
  required List<BloqueUnidad> bloques,
  required List<Periodo> periodos,
  required String docente,
  bool simple = false,
}) async {
  Future<pw.Font> fuente(String f) async =>
      pw.Font.ttf(await rootBundle.load('assets/fonts/Outfit-$f.ttf'));
  final normal = await fuente('Regular');
  final negrita = await fuente('SemiBold');
  final fuerte = await fuente('Bold');
  final c = curso.curso;
  final doc = pw.Document(
    title: 'Planificación · ${c.nombre} ${aula(c)}',
    author: docente,
    creator: 'Kipu Docente',
    theme: pw.ThemeData.withFont(base: normal, bold: negrita),
  );

  pw.Widget t(
    String s, {
    double size = 9.5,
    pw.Font? font,
    Color color = _tinta,
  }) => pw.Text(
    s,
    style: pw.TextStyle(
      font: font ?? normal,
      fontSize: size,
      color: _pdf(color),
      lineSpacing: 1.5,
    ),
  );

  pw.Widget titulo(String s) => pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.symmetric(vertical: 7, horizontal: 10),
    decoration: pw.BoxDecoration(
      color: _pdf(_azul),
      borderRadius: pw.BorderRadius.circular(4),
    ),
    child: t(s, size: 11.5, font: fuerte, color: Colors.white),
  );

  pw.Widget seccion(String s) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 12, bottom: 5),
    child: t(s.toUpperCase(), size: 9.5, font: fuerte, color: _azul),
  );

  final borde = pw.TableBorder.all(
    color: _pdf(const Color(0xFFC9CFE3)),
    width: .6,
  );
  pw.Widget celda(String s, {bool cab = false, pw.Font? font}) => pw.Container(
    color: cab ? _pdf(_azulClaro) : null,
    padding: const pw.EdgeInsets.all(5),
    child: t(
      s,
      size: cab ? 8.5 : 9,
      font: cab ? fuerte : font,
      color: cab ? _azul : _tinta,
    ),
  );

  pw.Widget datos(List<(String, String)> filas) => pw.Table(
    border: borde,
    columnWidths: const {0: pw.FixedColumnWidth(110), 1: pw.FlexColumnWidth()},
    children: [
      for (final f in filas)
        pw.TableRow(children: [celda(f.$1, cab: true), celda(f.$2)]),
    ],
  );

  String periodo(Unidad u) =>
      u.periodo <= periodos.length ? periodos[u.periodo - 1].nombre : '';

  final paginas = <pw.Widget>[];
  if (simple) {
    paginas.add(titulo('PLANIFICACIÓN · ${c.nombre.toUpperCase()} ${aula(c)}'));
    paginas.add(pw.SizedBox(height: 8));
    paginas.add(
      datos([
        ('Colegio', curso.colegio.nombre),
        ('Docente', docente.isEmpty ? '—' : docente),
        ('Grado y sección', '${c.grado} ${c.seccion} · ${c.nivel}'),
      ]),
    );
    for (final b in bloques) {
      final u = b.unidad;
      paginas.add(seccion('Unidad ${b.numero}: ${u.titulo} · ${periodo(u)}'));
      final extra = [
        '${_fechaLarga(u.desde)} al ${_fechaLarga(u.hasta)}',
        if (u.listaCompetencias.isNotEmpty)
          'Competencias: ${u.listaCompetencias.map((x) => competenciaPorId(x)?.corto ?? x).join(', ')}',
        if ((u.temas ?? '').isNotEmpty) 'Temas: ${u.temas}',
        if ((u.producto ?? '').isNotEmpty) 'Producto: ${u.producto}',
      ];
      paginas.add(t(extra.join(' · '), size: 9, color: _gris));
      paginas.add(pw.SizedBox(height: 5));
      paginas.add(
        pw.Table(
          border: borde,
          columnWidths: const {
            0: pw.FixedColumnWidth(22),
            1: pw.FixedColumnWidth(52),
            2: pw.FlexColumnWidth(2),
            3: pw.FlexColumnWidth(3),
            4: pw.FlexColumnWidth(1.4),
          },
          children: [
            pw.TableRow(
              children: [
                for (final h in [
                  'N.°',
                  'Fecha',
                  'Tema',
                  'Actividades',
                  'Materiales',
                ])
                  celda(h, cab: true),
              ],
            ),
            for (final f in b.filas)
              pw.TableRow(
                children: [
                  celda('${f.numero}'),
                  celda(f.fecha),
                  celda(f.tema, font: negrita),
                  celda(f.actividades),
                  celda(f.materiales),
                ],
              ),
          ],
        ),
      );
    }
  }

  for (final b in simple ? const <BloqueUnidad>[] : bloques) {
    final u = b.unidad;
    final props = u.listaPropositos;
    paginas.add(
      titulo('UNIDAD DE APRENDIZAJE ${b.numero}: ${u.titulo.toUpperCase()}'),
    );
    var n = 0;
    pw.Widget apartado(String s) =>
        seccion('${const ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII'][n++]}. $s');
    paginas.add(apartado('Datos informativos'));
    paginas.add(
      datos([
        ('Institución educativa', curso.colegio.nombre),
        ('Área', c.area ?? c.nombre),
        ('Grado y sección', '${c.grado} ${c.seccion} · ${c.nivel}'),
        ('Docente', docente.isEmpty ? '—' : docente),
        ('Periodo', periodo(u)),
        (
          'Duración',
          '${_fechaLarga(u.desde)} al ${_fechaLarga(u.hasta)} · '
              '${b.sesiones.length} sesiones',
        ),
      ]),
    );
    if ((u.situacion ?? '').isNotEmpty) {
      paginas.add(apartado('Situación significativa'));
      paginas.add(t(u.situacion!));
    }
    paginas.add(apartado('Propósitos de aprendizaje'));
    paginas.add(
      pw.Table(
        border: borde,
        columnWidths: const {
          0: pw.FlexColumnWidth(2.2),
          1: pw.FlexColumnWidth(2.6),
          2: pw.FlexColumnWidth(1.5),
          3: pw.FlexColumnWidth(1.2),
        },
        children: [
          pw.TableRow(
            children: [
              celda('Competencias y capacidades', cab: true),
              celda('Criterios de evaluación', cab: true),
              celda('Evidencia', cab: true),
              celda('Instrumento', cab: true),
            ],
          ),
          for (final id in u.listaCompetencias)
            () {
              final p =
                  props.where((x) => x.competencia == id).firstOrNull ??
                  Proposito(id);
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        t(competenciaPorId(id)?.nombre ?? id, font: negrita),
                        for (final cap in p.capacidades) t('• $cap', size: 8.5),
                      ],
                    ),
                  ),
                  celda(
                    p.criterios
                        .split('\n')
                        .where((l) => l.trim().isNotEmpty)
                        .map((l) => '• ${l.trim()}')
                        .join('\n'),
                  ),
                  celda(p.evidencia),
                  celda(p.instrumento),
                ],
              );
            }(),
        ],
      ),
    );
    if (u.listaEnfoques.isNotEmpty) {
      paginas.add(apartado('Enfoques transversales'));
      paginas.add(t(u.listaEnfoques.map((e) => 'Enfoque $e').join(' · ')));
    }
    if ((u.producto ?? '').isNotEmpty) {
      paginas.add(apartado('Producto'));
      paginas.add(t(u.producto!));
    }
    paginas.add(apartado('Secuencia de sesiones'));
    paginas.add(
      pw.Table(
        border: borde,
        columnWidths: const {
          0: pw.FixedColumnWidth(24),
          1: pw.FixedColumnWidth(70),
          2: pw.FlexColumnWidth(3),
          3: pw.FlexColumnWidth(2),
        },
        children: [
          pw.TableRow(
            children: [
              for (final h in [
                'N.°',
                'Fecha',
                'Título de la sesión',
                'Competencia',
              ])
                celda(h, cab: true),
            ],
          ),
          for (final f in b.filas)
            pw.TableRow(
              children: [
                celda('${f.numero}'),
                celda(f.fecha),
                celda(f.tema),
                celda(f.competencia),
              ],
            ),
        ],
      ),
    );
    if ((u.materiales ?? '').isNotEmpty) {
      paginas.add(apartado('Materiales y recursos'));
      paginas.add(t(u.materiales!));
    }
    // Cada sesión empieza en su página.
    for (var i = 0; i < b.sesiones.length; i++) {
      final s = b.sesiones[i];
      final p = props.where((x) => x.competencia == s.competencia).firstOrNull;
      paginas.add(pw.NewPage());
      paginas.add(
        titulo('SESIÓN DE APRENDIZAJE ${i + 1}: ${s.titulo.toUpperCase()}'),
      );
      paginas.add(pw.SizedBox(height: 8));
      final total = [
        s.minInicio,
        s.minDesarrollo,
        s.minCierre,
      ].whereType<int>().fold(0, (a, b) => a + b);
      paginas.add(
        datos([
          ('Institución educativa', curso.colegio.nombre),
          ('Área · Grado', '${c.area ?? c.nombre} · ${c.grado} ${c.seccion}'),
          ('Unidad', 'Unidad ${b.numero}: ${u.titulo}'),
          (
            'Fecha',
            '${_fechaLarga(s.fecha)}${s.hora == null ? '' : ' · ${s.hora}'}'
                '${total > 0 ? ' · $total minutos' : ''}',
          ),
          ('Docente', docente.isEmpty ? '—' : docente),
        ]),
      );
      if (s.competencia != null) {
        paginas.add(seccion('Propósito de aprendizaje'));
        paginas.add(
          pw.Table(
            border: borde,
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(2.4),
              2: pw.FlexColumnWidth(1.4),
            },
            children: [
              pw.TableRow(
                children: [
                  celda('Competencia y capacidades', cab: true),
                  celda('Criterios de evaluación', cab: true),
                  celda('Evidencia · Instrumento', cab: true),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        t(
                          competenciaPorId(s.competencia!)?.nombre ??
                              s.competencia!,
                          font: negrita,
                        ),
                        for (final cap in p?.capacidades ?? const <String>[])
                          t('• $cap', size: 8.5),
                      ],
                    ),
                  ),
                  celda(
                    (p?.criterios ?? '')
                        .split('\n')
                        .where((l) => l.trim().isNotEmpty)
                        .map((l) => '• ${l.trim()}')
                        .join('\n'),
                  ),
                  celda(
                    [
                      if ((p?.evidencia ?? '').isNotEmpty) p!.evidencia,
                      if ((p?.instrumento ?? '').isNotEmpty) p!.instrumento,
                    ].join(' · '),
                  ),
                ],
              ),
            ],
          ),
        );
      }
      if ((s.proposito ?? '').isNotEmpty) {
        paginas.add(pw.SizedBox(height: 6));
        paginas.add(t('Propósito de la sesión: ${s.proposito}', font: negrita));
      }
      paginas.add(seccion('Momentos de la sesión'));
      String min(int? m) => m == null ? '' : '$m min';
      paginas.add(
        pw.Table(
          border: borde,
          columnWidths: const {
            0: pw.FixedColumnWidth(72),
            1: pw.FlexColumnWidth(),
            2: pw.FixedColumnWidth(48),
          },
          children: [
            pw.TableRow(
              children: [
                celda('Momento', cab: true),
                celda('Estrategias y actividades', cab: true),
                celda('Tiempo', cab: true),
              ],
            ),
            pw.TableRow(
              children: [
                celda('Inicio', font: negrita),
                celda(s.inicio ?? ''),
                celda(min(s.minInicio)),
              ],
            ),
            pw.TableRow(
              children: [
                celda('Desarrollo', font: negrita),
                celda(s.desarrollo ?? ''),
                celda(min(s.minDesarrollo)),
              ],
            ),
            pw.TableRow(
              children: [
                celda('Cierre', font: negrita),
                celda(s.cierre ?? ''),
                celda(min(s.minCierre)),
              ],
            ),
          ],
        ),
      );
      if ((s.materiales ?? '').isNotEmpty || (s.tarea ?? '').isNotEmpty) {
        paginas.add(pw.SizedBox(height: 8));
        paginas.add(
          datos([
            if ((s.materiales ?? '').isNotEmpty) ('Materiales', s.materiales!),
            if ((s.tarea ?? '').isNotEmpty) ('Tarea', s.tarea!),
          ]),
        );
      }
      paginas.add(pw.SizedBox(height: 40));
      paginas.add(
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            for (final f in ['Docente', 'V.° B.° Dirección'])
              pw.Column(
                children: [
                  pw.Container(width: 150, height: .6, color: _pdf(_gris)),
                  pw.SizedBox(height: 3),
                  t(f, size: 8.5, color: _gris),
                ],
              ),
          ],
        ),
      );
    }
    if (b != bloques.last) paginas.add(pw.NewPage());
  }

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 34, 36, 34),
      footer: (ctx) => pw.Row(
        children: [
          t('Kipu Docente', size: 7.5, color: _gris),
          pw.Spacer(),
          t('${ctx.pageNumber} / ${ctx.pagesCount}', size: 7.5, color: _gris),
        ],
      ),
      build: (_) => paginas,
    ),
  );
  return doc.save();
}
